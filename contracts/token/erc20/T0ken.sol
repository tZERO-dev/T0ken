pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/Compliance.sol";
import "tzero/libs/collections/AddressMap.sol";
import "tzero/libs/lifecycle/LockableDestroyable.sol";
import "tzero/libs/math/AdditiveMath.sol";
import "tzero/libs/ownership/Ownable.sol";
import "tzero/token/erc20/ERC20.sol";


contract T0ken is ERC20, Ownable, LockableDestroyable {

    // ------------------------------- Variables -------------------------------

    using AdditiveMath for uint256;
    using AddressMap for AddressMap.Data;

    address constant internal ZERO_ADDRESS = address(0);
    string public constant name = "TZERO PREFERRED";
    string public constant symbol = "TZROP";
    uint8 public constant decimals = 0;

    AddressMap.Data public shareholders;
    Compliance public compliance;
    address public issuer;
    bool public issuingFinished = false;
    mapping(address => address) public cancellations;

    mapping(address => uint256) internal balances;
    uint256 internal totalSupplyTokens;

    mapping (address => mapping (address => uint256)) private allowed;

    // ------------------------------- Modifiers -------------------------------

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer allowed");
        _;
    }

    modifier canIssue() {
        require(!issuingFinished, "Issuing is already finished");
        _;
    }

    modifier isNotCancelled(address addr) {
        require(cancellations[addr] == ZERO_ADDRESS, "Address has been cancelled");
        _;
    }

    modifier hasFunds(address addr, uint256 tokens) {
        require(tokens <= balances[addr], "Insufficient funds");
        _;
    }

    // -------------------------------- Events ---------------------------------

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
    event Issue(address indexed to, uint256 tokens);
    event IssueFinished();
    event ShareholderAdded(address shareholder);
    event ShareholderRemoved(address shareholder);

    // -------------------------------------------------------------------------

    /**
     *  @dev Transfers tokens to the whitelisted account.
     *
     *  If the 'to' address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce 'msg.sender' balance to 0, then that address MUST be removed
     *  from the list of shareholders.
     *  MUST be removed from the list of shareholders.
     *  @param to The address to transfer to.
     *  @param tokens The number of tokens to be transferred.
     */
    function transfer(address to, uint256 tokens)
    external
    isUnlocked
    isNotCancelled(to)
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
     *  @dev Transfers tokens between whitelisted accounts.
     *
     *  If the 'to' address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce 'from' balance to 0 then that address MUST be removed from the list of shareholders.
     *  @param from The address to transfer from
     *  @param to The address to transfer to.
     *  @param tokens uint256 the number of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 tokens)
    external
    isUnlocked
    isNotCancelled(to)
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
     *  @dev Overrides a transfer of tokens to the whitelisted account.
     *
     *  If the 'to' address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce 'msg.sender' balance to 0, then that address MUST be removed
     *  from the list of shareholders.
     *  MUST be removed from the list of shareholders.
     *  @param from The address to transfer from
     *  @param to The address to transfer to.
     *  @param tokens The number of tokens to be transferred.
     */
    function transferOverride(address from, address to, uint256 tokens)
    external
    isUnlocked
    isNotCancelled(to)
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
     *  @dev Tokens will be issued to the issuer's address only.
     *  @param quantity The number of tokens to mint.
     *  @return A boolean that indicates if the operation was successful.
     */
    function issueTokens(uint256 quantity)
    external
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        // Avoid doing any state changes for zero quantities
        if (quantity > 0) {
            totalSupplyTokens = totalSupplyTokens.add(quantity);
            balances[issuer] = balances[issuer].add(quantity);
            shareholders.append(issuer);
        }
        emit Issue(issuer, quantity);
        emit Transfer(ZERO_ADDRESS, issuer, quantity);
        return true;
    }

    /**
     *  @dev Finishes token issuance.
     *  This is a single use function, once invoked it cannot be undone.
     */
    function finishIssuing()
    external
    isUnlocked
    onlyIssuer
    canIssue
    returns (bool) {
        issuingFinished = true;
        emit IssueFinished();
        return issuingFinished;
    }

    /**
     *  @dev Cancel the original address and reissue the Tokens to the replacement address.
     *
     *  Access to this function is restricted to the Issuer only.
     *  The 'original' address MUST be removed from the set of whitelisted addresses.
     *  Throw if the 'original' address supplied is not a shareholder.
     *  Throw if the 'replacement' address is not a whitelisted address.
     *  This function MUST emit the 'VerifiedAddressSuperseded' event.
     *  @param original The address to be superseded. This address MUST NOT be reused and must be whitelisted.
     *  @param replacement The address  that supersedes the original. This address MUST be whitelisted.
     */
    function cancelAndReissue(address original, address replacement)
    external
    isUnlocked
    onlyIssuer
    isNotCancelled(replacement) {
        // Ensure the reissue can take place
        require(shareholders.exists(original) && !shareholders.exists(replacement), "Original doesn't exist or replacement does");
        if (address(compliance) != ZERO_ADDRESS) {
            require(compliance.canIssue(msg.sender, original, replacement, balances[original]), "Failed 'canIssue' check.");
        }

        // Replace the original shareholder with the replacement
        shareholders.remove(original);
        shareholders.append(replacement);
        // Add the original as a cancelled address (preventing it from future trading)
        cancellations[original] = replacement;
        // Transfer the balance to the replacement
        balances[replacement] = balances[original];
        balances[original] = 0;
        emit VerifiedAddressSuperseded(original, replacement, msg.sender);
    }

    /**
     * @dev Approve the passed address to spend the specified number of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param tokens The number of tokens of tokens to be spent.
     */
    function approve(address spender, uint256 tokens)
    external
    isUnlocked
    isNotCancelled(msg.sender)
    returns (bool) {
        require(shareholders.exists(msg.sender), "Must be a shareholder to approve token transfer");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    /**
     *  @dev Set the issuer address.
     *  @param newIssuer The address of the issuer.
     */
    function setIssuer(address newIssuer)
    external
    isUnlocked
    onlyOwner {
        issuer = newIssuer;
        emit IssuerSet(issuer, newIssuer);
    }

    /**
     *  @dev Sets the compliance contract address to use during transfers.
     *  @param newComplianceAddress The address of the compliance contract.
     */
    function setCompliance(address newComplianceAddress)
    external
    isUnlocked
    onlyOwner {
        compliance = Compliance(newComplianceAddress);
    }

    // -------------------------------- Getters --------------------------------

    /**
     *  @dev Returns the total token supply
     *  @return total number of tokens in existence
     */
    function totalSupply()
    external
    view
    returns (uint256) {
        return totalSupplyTokens;
    }

    /**
     *  @dev Gets the balance of the specified address.
     *  @param addr The address to query the the balance of.
     *  @return An uint256 representing the tokens owned by the passed address.
     */
    function balanceOf(address addr)
    external
    view
    returns (uint256) {
        return balances[addr];
    }

    /**
     *  @dev Gets the number of tokens that an owner has allowed the spender to transfer.
     *  @param addrOwner address The address which owns the funds.
     *  @param spender address The address which will spend the funds.
     *  @return A uint256 specifying the number of tokens still available for the spender.
     */
    function allowance(address addrOwner, address spender)
    external
    view
    returns (uint256) {
        return allowed[addrOwner][spender];
    }

    /**
     *  By counting the number of token holders using 'holderCount'
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if 'index >= holderCount()'.
     *  @dev Returns the holder at the given index.
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
     *  @dev Checks to see if the supplied address is a share holder.
     *  @param addr The address to check.
     *  @return true if the supplied address owns a token.
     */
    function isHolder(address addr)
    external
    view
    returns (bool) {
        return shareholders.exists(addr);
    }

    /**
     *  @dev Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
    external
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
    external
    view
    returns (address) {
        require(addr != ZERO_ADDRESS, "Non-zero address required");

        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return ZERO_ADDRESS;
        }
        return candidate;
    }


    // -------------------------------- Private --------------------------------

    /**
     *  @dev Checks if a transfer/override may take place between the two accounts.
     *
     *   Validates that the transfer can take place.
     *     - Ensure the 'to' address is not cancelled
     *     - Ensure the transfer is compliant
     *  @param from The sender address.
     *  @param to The recipient address.
     *  @param tokens The number of tokens being transferred.
     *  @param isOverride If this is a transfer override
     *  @return If the transfer can take place.
     */
    function canTransfer(address from, address to, uint256 tokens, bool isOverride)
    private
    isNotCancelled(to)
    returns (bool) {
        // Don't allow overrides and ignore compliance rules when compliance not set.
        if (address(compliance) == ZERO_ADDRESS) {
            return !isOverride;
        }

        // Ensure the override is valid, or that the transfer is compliant.
        if (isOverride) {
            return compliance.canOverride(msg.sender, from, to, tokens);
        } else {
            return compliance.canTransfer(msg.sender, from, to, tokens);
        }
    }

    /**
     *  @dev Transfers tokens from one address to another
     *  @param from The sender address.
     *  @param to The recipient address.
     *  @param tokens The number of tokens being transferred.
     */
    function transferTokens(address from, address to, uint256 tokens)
    private {
        // Update balances
        balances[from] = balances[from].subtract(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);

        // Adds the shareholder if they don't already exist.
        if (balances[to] > 0 && shareholders.append(to)) {
            emit ShareholderAdded(to);
        }
        // Remove the shareholder if they no longer hold tokens.
        if (balances[from] == 0 && shareholders.remove(from)) {
            emit ShareholderRemoved(from);
        }
    }

}
