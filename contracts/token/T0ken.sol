pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/collections/AddressMap.sol";
import "t0ken/libs/lifecycle/LockableDestroyable.sol";
import "t0ken/libs/math/AdditiveMath.sol";
import "t0ken/libs/ownership/Ownable.sol";
import "t0ken/registry/Storage.sol";
import "t0ken/compliance/Compliance.sol";

import "./ERC20.sol";


contract T0ken is ERC20, Ownable, LockableDestroyable {
    // ------------------------------- Variables -------------------------------
    using AdditiveMath for uint256;
    using AddressMap for AddressMap.Data;

    address constant internal ZERO_ADDRESS = address(0);
    // 3rd party integration variables
    string public constant name = "Company A Preferred";
    string public constant symbol = "COMPA";    //Token Ticker
    uint8 public constant decimals = 0;

    AddressMap.Data public shareholders;
    Compliance public compliance;
    Storage public store;
    address public issuer;
    bool public issuingFinished = false;
    mapping(address => address) public cancellations;

    mapping(address => uint256) internal balances;
    uint256 internal totalSupplyTokens;

    mapping (address => mapping (address => uint256)) private allowed;

    // ------------------------------- Modifiers -------------------------------
    modifier transferCheck(uint256 value, address fromAddr) {
        require(value <= balances[fromAddr], "Balance is more than what from address has.");
        _;
    }

    modifier isNotCancelled(address addr) {
        require(cancellations[addr] == ZERO_ADDRESS, "Address has been cancelled.");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer is allowed.");
        _;
    }

    modifier canIssue() {
        require(!issuingFinished, "Issuing has already ended.");
        _;
    }

    modifier canTransfer(address fromAddress, address toAddress) {
        if(fromAddress == issuer) {
            require(store.accountExists(toAddress), "The to address does not exist.");
        }
        else {
            require(compliance.canTransfer(fromAddress, toAddress), "The address cannot transfer.");
        }
        _;
    }

    modifier canTransferFrom(address fromAddress, address toAddress) {
        if(msg.sender == owner) {
            require(store.accountExists(toAddress), "The to address does not exist.");
        }
        else {
            require(compliance.canTransfer(fromAddress, toAddress), "The address cannot transfer.");
        }
        _;
    }

    // -------------------------- Events -------------------------------

    /**
     *  This event is emitted when an address is cancelled and replaced with
     *  a new address.  This happens in the case where a shareholder has
     *  lost access to their original address and needs to have their share
     *  reissued to a new address.  This is the equivalent of issuing replacement
     *  share certificates.
     *  @param original The address being superseded.
     *  @param replacement The new address.
     *  @param sender The address that caused the address to be superseded.
    */
    event VerifiedAddressSuperseded(address indexed original, address indexed replacement, address indexed sender);
    event IssuerSet(address indexed previousIssuer, address indexed newIssuer);
    event Issue(address indexed to, uint256 amount);
    event IssueFinished();


    // ---------------------------- Functions -------------------------------------

    /**
     * @dev transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     *  The `transfer` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `msg.sender`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transfer(address to, uint256 value)
    public
    isUnlocked
    isNotCancelled(to)
    transferCheck(value, msg.sender)
    canTransfer(msg.sender, to)
    returns (bool) {
        balances[msg.sender] = balances[msg.sender].subtract(value);
        balances[to] = balances[to].add(value);

        // Adds the shareholder, if they don't already exist.
        shareholders.append(to);

        // Remove the shareholder if they no longer hold tokens.
        if (balances[msg.sender] == 0) {
            shareholders.remove(msg.sender);
        }

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     *  The `transferFrom` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `from`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transferFrom(address from, address to, uint256 value)
    public
    transferCheck(value, from)
    isNotCancelled(to)
    canTransferFrom(from, to)
    isUnlocked
    returns (bool) {
        if(msg.sender != owner) {
            require(value <= allowed[from][msg.sender], "Value exceeds what is allowed to transfer");
            allowed[from][msg.sender] = allowed[from][msg.sender].subtract(value);
        }

        balances[from] = balances[from].subtract(value);
        balances[to] = balances[to].add(value);

        // Adds the shareholder, if they don't already exist.
        shareholders.append(to);

        // Remove the shareholder if they no longer hold tokens.
        if (balances[from] == 0) {
            shareholders.remove(from);
        }

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * Tokens will be issued only to the issuer's address
     * @param quantity The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function issueTokens(uint256 quantity)
    public
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        address issuer = msg.sender;
        totalSupplyTokens = totalSupplyTokens.add(quantity);
        balances[issuer] = balances[issuer].add(quantity);
        shareholders.append(issuer);
        emit Issue(issuer, quantity);
        return true;
    }

    function finishIssuing()
    public
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        issuingFinished = true;
        emit IssueFinished();
        return issuingFinished;
    }

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *
     *  ***It's on the issuer to make sure the replacement address belongs to a verified investor.***
     *
     *  Access to this function MUST be strictly controlled.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a shareholder.
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  @param original The address to be superseded. This address MUST NOT be reused.
     *  @param replacement The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(address original, address replacement)
    external
    isUnlocked
    onlyOwner
    isNotCancelled(replacement) {
        // replace the original address in the shareholders mapping
        // and update all the associated mappings
        require(shareholders.exists(original) && !shareholders.exists(replacement), "Original doesn't exist or replacement does.");
        shareholders.remove(original);
        shareholders.append(replacement);
        cancellations[original] = replacement;
        balances[replacement] = balances[original];
        balances[original] = 0;
        emit VerifiedAddressSuperseded(original, replacement, msg.sender);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
    external
    isUnlocked
    returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


    // ---------------------------- Getters ----------------------------

    /**
     * @return total number of tokens in existence
     */
    function totalSupply()
    external
    view
    returns (uint256) {
        return totalSupplyTokens;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param addr The address to query the balance of
     * @return An uint256 representing the amount owned by the passed address
     */
    function balanceOf(address addr)
    external
    view
    returns (uint256) {
        return balances[addr];
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param addrOwner address The address which owns the funds
     * @param spender address The address which will spend the funds
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address addrOwner, address spender)
    external
    isUnlocked
    view
    returns (uint256) {
        return allowed[addrOwner][spender];
    }

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(int256 index)
    external
    view
    returns (address){
        return shareholders.at(index);
    }

    /**
     *  Checks to see if the supplied address is a shareholder.
     *  @param addr The address to check
     *  @return true if the supplied address owns a token
     */
    function isHolder(address addr)
    external
    view
    returns (bool) {
        return shareholders.exists(addr);
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
    external
    onlyOwner
    view
    returns (bool) {
        return cancellations[addr] != ZERO_ADDRESS;
    }

    /**
     *  Gets the most recent address, given a superseded one.
     *  Addresses may be superseded multiple times, so this function needs to
     *  follow the chain of addresses until it reaches the final, verified address.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function getSuperseded(address addr)
    public
    onlyOwner
    view
    returns (address) {
        require(addr != ZERO_ADDRESS, "A non-zero address is required.");
        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return ZERO_ADDRESS;
        }
        return candidate;
    }

    // ---------------------------- Setters ----------------------------

    /**
     *  Set issuer of token
     *   @param newIssuer address - The address of the issuer
     */
    function setIssuer(address newIssuer)
    external
    isUnlocked
    onlyOwner {
        issuer = newIssuer;
        emit IssuerSet(issuer, newIssuer);
    }

    /**
     * Sets the contract address for the Compliance contract
     * @param newComplianceAddress address - The address of the compliance contract
     */
    function setCompliance(address newComplianceAddress)
    external
    isUnlocked
    onlyOwner {
        compliance = Compliance(newComplianceAddress);
    }

    /**
     * Sets the contract address for the Storage contract
     * @param s Storage - The Storage object
     */
    function setStorage(Storage s)
    external
    isUnlocked
    onlyOwner {
        store = s;
    }


}
