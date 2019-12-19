pragma solidity >=0.5.0 <0.6.0;


import "../compliance/Compliance.sol";
import "../libs/collections/AddressMap.sol";
import "../libs/lifecycle/LockableDestroyable.sol";
import "../libs/math/AdditiveMath.sol";
import "../libs/ownership/Ownable.sol";
import "./IT0ken.sol";


contract T0ken is IT0ken, Ownable, LockableDestroyable {

    // ------------------------------- Variables -------------------------------

    using AdditiveMath for uint256;
    using AddressMap for AddressMap.Data;

    address constant internal ZERO_ADDRESS = address(0);
    string public name;
    string public symbol;
    uint8 public decimals;

    AddressMap.Data public holders;
    Compliance public compliance;
    address public issuer;
    bool public issuanceFinished;

    mapping(address => uint256) public balances;
    uint256 internal supply;

    mapping (address => mapping (address => uint256)) internal allowed;

    // ------------------------------- Modifiers -------------------------------

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer allowed");
        _;
    }

    modifier canIssue() {
        require(!issuanceFinished, "Issuance already finished");
        _;
    }

    modifier hasFunds(address addr, uint256 tokens) {
        require(tokens <= balances[addr], "Insufficient funds");
        _;
    }

    // -------------------------------------------------------------------------

    constructor(string memory tokenName, string memory tokenSymbol, uint8 decimalPlaces)
    public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalPlaces;
    }

    /**
     *  Transfers tokens to the whitelisted account
     *  @param to The address to transfer to
     *  @param tokens The number of tokens to be transferred
     */
    function transfer(address to, uint256 tokens)
    public
    isUnlocked
    hasFunds(msg.sender, tokens)
    returns (bool) {
        bool transferAllowed;

        // Issuance
        if (msg.sender == issuer) {
            transferAllowed = address(compliance) == ZERO_ADDRESS;
            if (!transferAllowed) {
                transferAllowed = compliance.canIssue(issuer, issuer, to, tokens);
            }
        }
        // Transfer
        else {
            transferAllowed = canTransfer(msg.sender, to, tokens, false);
        }

        // Ensure the transfer is allowed.
        if (transferAllowed) {
            transferTokens(msg.sender, to, tokens);
        }
        return transferAllowed;
    }

    /**
     *  Transfers tokens between whitelisted accounts
     *  @param from The address to transfer from
     *  @param to The address to transfer to
     *  @param tokens uint256 the number of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 tokens)
    public
    isUnlocked
    hasFunds(from, tokens)
    returns (bool) {
        require(tokens <= allowed[from][msg.sender], "Transfer exceeds allowance");

        // Transfer the tokens
        bool transferAllowed = canTransfer(from, to, tokens, false);
        if (transferAllowed) {
            // Update the allowance to reflect the transfer
            allowed[from][msg.sender] = allowed[from][msg.sender].subtract(tokens);
            // Transfer the tokens
            transferTokens(from, to, tokens);
        }
        return transferAllowed;
    }

    /**
     *  Overrides a transfer of tokens to the whitelisted account
     *  @param from The address to transfer from
     *  @param to The address to transfer to
     *  @param tokens The number of tokens to be transferred
     */
    function transferOverride(address from, address to, uint256 tokens)
    public
    isUnlocked
    hasFunds(from, tokens)
    returns (bool) {
        // Ensure the sender can perform the override.
        bool transferAllowed = canTransfer(from, to, tokens, true);
        // Ensure the transfer is allowed.
        if (transferAllowed) {
            transferTokens(from, to, tokens);
        }
        return transferAllowed;
    }

    /**
     *  Issue tokens, placing them within the issuer's address
     *  @dev A zero quantity transfer is essentially a noop that emits issuance events
     *  @param quantity The number of tokens to mint
     *  @return A boolean that indicates if the operation was successful
     */
    function issueTokens(uint256 quantity)
    public
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        // Avoid doing any state changes for zero quantities
        if (quantity > 0) {
            supply = supply.add(quantity);
            balances[issuer] = balances[issuer].add(quantity);
            holders.append(issuer);
        }
        emit Issuance(issuer, quantity);
        emit Transfer(ZERO_ADDRESS, issuer, quantity);
        return true;
    }

    /**
     *  Finishes token issuance
     *  @dev This is a single use function, once invoked it cannot be undone
     *  @return A boolean that indicates if the operation was successful
     */
    function finishIssuance()
    public
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        issuanceFinished = true;
        emit IssuanceFinished();
        return issuanceFinished;
    }

    /**
     * Approve the spender address to transfer the number of tokens on behalf of the sender
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds
     * @param tokens The number of tokens of tokens to be spent
     * @return A boolean that indicates if the operation was successful
     */
    function approve(address spender, uint256 tokens)
    public
    isUnlocked
    returns (bool) {
        require(holders.exists(msg.sender), "Must be a shareholder");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    /**
     *  Set the issuer address.
     *  @param newIssuer The address of the issuer.
     */
    function setIssuer(address newIssuer)
    public
    isUnlocked
    onlyOwner {
        require(holders.exists(newIssuer) == false, "New issuer can't be a shareholder");

        transferTokens(issuer, newIssuer, balances[issuer]);
        issuer = newIssuer;

        emit IssuerSet(issuer, newIssuer);
    }

    /**
     *  Sets the compliance contract address to use during transfers.
     *  @param newComplianceAddress The address of the compliance contract.
     */
    function setCompliance(address newComplianceAddress)
    public
    isUnlocked
    onlyOwner {
        compliance = Compliance(newComplianceAddress);
    }

    // -------------------------------- Getters --------------------------------

    /**
     *  Returns the total token supply
     *  @return total number of tokens in existence
     */
    function totalSupply()
    public
    view
    returns (uint256) {
        return supply;
    }

    /**
     *  Gets the balance of the specified address.
     *  @param addr The address to query the the balance of.
     *  @return An uint256 representing the tokens owned by the passed address.
     */
    function balanceOf(address addr)
    public
    view
    returns (uint256) {
        return balances[addr];
    }

    /**
     *  Gets the number of tokens that an owner has allowed the spender to transfer.
     *  @param addrOwner address The address which owns the funds.
     *  @param spender address The address which will spend the funds.
     *  @return A uint256 specifying the number of tokens still available for the spender.
     */
    function allowance(address addrOwner, address spender)
    public
    view
    returns (uint256) {
        return allowed[addrOwner][spender];
    }

    /**
     *  Returns the holder address at for the given index.
     *  @dev Returns the holder at the given index.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(int256 index)
    public
    view
    returns (address){
        return holders.at(index);
    }

    /**
     *  Checks to see if the supplied address is a share holder.
     *  @param addr The address to check.
     *  @return true if the supplied address owns a token.
     */
    function isHolder(address addr)
    public
    view
    returns (bool) {
        return holders.exists(addr);
    }

    // -------------------------------- Internal --------------------------------

    /**
     *  Checks if a transfer/override may take place between the two accounts.
     *
     *   Validates that the transfer can take place.
     *     - Ensure the 'to' address is not cancelled
     *     - Ensure the transfer is compliant
     *  @dev Ignores calls to compliance when unset
     *  @param from The sender address.
     *  @param to The recipient address.
     *  @param tokens The number of tokens being transferred.
     *  @param isOverride If this is a transfer override
     *  @return If the transfer can take place.
     */
    function canTransfer(address from, address to, uint256 tokens, bool isOverride)
    internal
    returns (bool) {
        // Don't allow overrides when compliance not set.
        if (address(compliance) == ZERO_ADDRESS) {
            return !isOverride;
        }

        // Ensure the override is valid, or the transfer is compliant.
        if (isOverride) {
            return compliance.canOverride(msg.sender, from, to, tokens);
        } else {
            return compliance.canTransfer(msg.sender, from, to, tokens);
        }
    }

    /**
     *  Transfers tokens from one address to another
     *  @dev Updates the balances variable for both addresses, removing them if their balance is zero
     *  @param from The sender address.
     *  @param to The recipient address.
     *  @param tokens The number of tokens being transferred.
     */
    function transferTokens(address from, address to, uint256 tokens)
    internal {
        // Update balances
        balances[from] = balances[from].subtract(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);

        // Adds the shareholder if they don't already exist.
        if (balances[to] > 0 && holders.append(to)) {
            emit ShareholderAdded(to);
        }
        // Remove the shareholder if they no longer hold tokens.
        if (balances[from] == 0 && holders.remove(from)) {
            emit ShareholderRemoved(from);
        }
    }

}
