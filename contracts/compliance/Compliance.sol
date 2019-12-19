pragma solidity >=0.5.0 <0.6.0;


import "../libs/ownership/Administrable.sol";
import "../libs/lifecycle/AdminLockableDestroyable.sol";
import "../libs/strings/AddressToASCII.sol";
import "../token/IT0ken.sol";
import "./ICompliance.sol";


contract Compliance is ICompliance, AdminLockableDestroyable {
    using AddressToASCII for address;

    string private constant RULES_KEY = "Compliance.rules";

    IRegistry public registry;
    IComplianceStorage public store;

    constructor(IRegistry r, IComplianceStorage s)
    public {
        registry = r;
        store = s;
    }

    /**
     *  Set the internal registry contract
     *  @param r The IRegistry contract.
     *  @param s The compliance-storage contract.
     */
    function setRegistryAndComplianceStore(IRegistry r, IComplianceStorage s)
    onlyOwner
    external {
        registry = r;
        store = s;
    }

    /**
     *  Replaces all of the existing rules with the given ones
     *  @dev Converts array of `rules` into `bytes`, allowing compliance to read once during rule checks
     *  @param token The token to set rules for
     *  @param kind The bucket of rules to set
     *  @param rules New compliance rules
     */
    function setRules(IT0ken token, uint8 kind, IComplianceRule[] calldata rules)
    onlyAdmins
    external {
        bytes memory b;
        if (rules.length > 0) {
            assembly {
                b := mload(0x40)                        // free mem ptr
                let size := sub(calldatasize, 0x64)     // get the size of the rules array (sig + token + kind + rules ptr = 0x64)
                mstore(0x40, add(b, size))              // new size of b
                mstore(b, sub(size, 0x20))              // rules minus the count slot
                calldatacopy(add(b, 0x20), 0x84, size)  // copy rules addresses into b (sig + token + kind + rules ptr + count = 0x84)
            }
        }
        store.setBytes(keccak256(abi.encodePacked(RULES_KEY, token, kind)), b);
    }

    /**
     *  Returns all of the current compliance rules for this token
     *  @dev Reads the single `bytes`, converting it back into an array of rules
     *  @param token The token to get rules for
     *  @param kind The bucket of rules to get
     *  @return List of all compliance rules
     */
    function getRules(IT0ken token, uint8 kind)
    external
    view
    returns (IComplianceRule[] memory) {
        bytes memory b = store.getBytes(keccak256(abi.encodePacked(RULES_KEY, token, kind)));
        require(b.length % 32 == 0, "Rules are corrupted");

        IComplianceRule[] memory rules = new IComplianceRule[](b.length / 32);
        if (rules.length > 0) {
            for (uint256 i = 32; i <= b.length; i += 32) {
                assembly { mstore(add(rules, i), mload(add(b, i))) }
            }
        }
        return rules;
    }

    /**
     *  Verifies that the receiving address is whitelisted/unfrozen.
     *  During cancel-and-reissue, the from address will be that of the shareholder being
     *  cancelled and verified to be whitelisted/unfrozen.
     *  THROWS when the transfer should fail.
     *  @param issuer The address initiating the issuance.
     *  @param from The address of the sender.
     *  @param to The address of the receiver.
     *  @param tokens The number of tokens being transferred.
     *  @return If a issuance can occur between the from/to addresses.
     */
    function canIssue(address issuer, address from, address to, uint256 tokens)
    external
    returns (bool) {
        freezeCheck(to);
        if (issuer != from) {
            // Ensure the from address is whitelisted/unfrozen during cancel-and-reissue
            freezeCheck(from);
        }
        return true;
    }

    /**
     *  Checks if an override by the sender can occur between the from/to addresses.
     *  Both addresses must be whitelisted and unfrozen.
     *  THROWS when the sender is not allowed to override.
     *  @param admin The address initiating the transfer.
     *  @param from The address of the sender.
     *  @param to The address of the receiver.
     *  @param tokens The number of tokens being transferred.
     *  @return If an override can occur between the from/to addresses.
     */
    function canOverride(address admin, address from, address to, uint256 tokens)
    external
    returns (bool) {
        IT0ken t = IT0ken(msg.sender);
        require(isAdmin(admin) || admin == t.issuer(), "Admin or issuer required");

        freezeCheck(to);
        return true;

    }

    /**
     *  Checks if a transfer can occur between the from/to addresses
     *  Both addresses must be whitelisted, unfrozen, and pass all compliance rule checks
     *  THROWS when the transfer should fail
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     *  @return If a transfer can occur between the from/to addresses
     */
    function canTransfer(address initiator, address from, address to, uint256 tokens)
    external
    returns (bool) {
        uint8 fromKind = freezeCheck(from);
        freezeCheck(to);
        if (initiator != from) {
            freezeCheck(initiator);
        }
        checkRules(initiator, from, to, fromKind, tokens);
        return true;
    }

    /**
     *  Performs a readonly `canTransfer` check
     *  @param token The token to perform the check against
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     *  @return All errors related to the transfer (JSON)
     */
    function canTransferTest(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external
    view
    returns (string memory) {
        bytes memory b;
        // Account registration checks
        if (!registry.accountExists(from)) {
            b = abi.encodePacked('"From address not whitelisted"');
        }
        if (!registry.accountExists(to)) {
            b = abi.encodePacked(b, b.length > 0 ? "," : "", '"To address not whitelisted"');
        }
        if (b.length > 0) {
            return string(abi.encodePacked('[', b, ']'));
        }

        // Freeze checks
        uint8 toKind;
        uint8 fromKind;
        address frozen;
        (fromKind, frozen) = registry.accountKindAndFrozenAddress(from);
        if (frozen != ZERO_ADDRESS) {
            b = abi.encodePacked(b, b.length > 0 ? "," : "", '"From address or lineage is frozen: ', frozen.toString(), '"');
        }
        (toKind, frozen) = registry.accountKindAndFrozenAddress(to);
        if (frozen != ZERO_ADDRESS) {
            b = abi.encodePacked(b, b.length > 0 ? "," : "", '"To address or lineage is frozen: ', frozen.toString(), '"');
        }

        // Compliance rule checks
        bytes memory r = testRules(token, initiator, from, to, fromKind, tokens);
        b = abi.encodePacked(b, b.length > 0 && r.length > 0 ? "," : "", r);
        return string(abi.encodePacked('[', b, ']'));
    }

    /**
     *  Returns the kind for the account and if it, or any of its ancestors are frozen
     *  @param addr The account to retrieve kind and frozen state for
     *  @return The kind of the given address
     */
    function freezeCheck(address addr)
    private
    view
    returns (uint8) {
        uint8 kind;
        (kind, addr) = registry.accountKindAndFrozenAddress(addr);
        if (addr != ZERO_ADDRESS) {
            revert(string(abi.encodePacked("Address or lineage is frozen: ", addr.toString())));
        }
        return kind;
    }

    /**
     *  Checks if a transfer is compliant for the given amount of tokens, between the accounts
     *  @dev Reads the `bytes` of rules, and traverses 32 byte chunks for each rule address
     *  @param initiator The address initiating the transfer
     *  @param from The from account
     *  @param to The to account
     *  @param fromKind The from account kint
     *  @param tokens The number of tokens
     */
    function checkRules(address initiator, address from, address to, uint8 fromKind, uint256 tokens)
    private {
        bytes32 key = keccak256(abi.encodePacked(RULES_KEY, msg.sender, fromKind));
        bytes memory b = store.getBytes(key);

        if (b.length == 0) return;
        require(b.length % 32 == 0, "Rules are corrupted");

        IComplianceRule rule;
        for (uint256 i = 32; i <= b.length; i += 32) {
            assembly { rule := mload(add(b, i)) }
            rule.check(IT0ken(msg.sender), initiator, from, to, tokens);
        }
    }

    /**
     *  Test each rule and returns a comma separated list of error strings
     *  @dev Packing args into `Transfer` struct to avoid a stack depth that is too deep
     *  @param token The token to perform the check against
     *  @param initiator The address initiating the transfer
     *  @param from The from account
     *  @param to The to account
     *  @param fromKind The from account kind
     *  @param tokens The number of tokens
     *  @return Error strings
     */
    function testRules(IT0ken token, address initiator, address from, address to, uint8 fromKind, uint256 tokens)
    private
    view
    returns (bytes memory) {
        bytes memory b = store.getBytes(keccak256(abi.encodePacked(RULES_KEY, token, fromKind)));

        if (b.length == 0) return "";
        else if (b.length % 32 != 0) return abi.encodePacked('"Rules are corrupted"');

        bytes memory errors;
        IComplianceRule rule;
        for (uint256 i = 32; i <= b.length; i += 32) {
            assembly { rule := mload(add(b, i)) }
            string memory s = rule.test(this, token, initiator, from, to, tokens);
            if (bytes(s).length > 0) {
                errors = abi.encodePacked(errors, (errors.length > 0 ? "," : ""), '"',  s, '"');
            }
        }
        return errors;
    }

}
