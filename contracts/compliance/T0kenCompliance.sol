pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/Compliance.sol";
import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/ownership/Administrable.sol";
import "tzero/libs/lifecycle/AdminLockableDestroyable.sol";


contract T0kenCompliance is Compliance, Administrable, AdminLockableDestroyable {
    uint8 private constant UNSET_KIND = 0;
    uint8 private constant CUSTODIAN_KIND = 1;
    uint8 private constant INVESTOR_KIND = 4;

    uint8 public maxRules = 25;

    Storage public store;
    mapping(address => bool) public addressFreezes; // list of addresses frozen for just this token
    mapping(uint8 => ComplianceRule[]) private complianceRules;

    /**
     *  Set the internal storage/registry contract
     *  @param s The storage contract.
     */
    function setStorage(Storage s)
    onlyOwner
    external {
        store = s;
    }

    /**
     *
     *  Set the compliance rule limit
     *  @param limit The maximum number of compliance rules that can be set.
     */
    function setMaxRules(uint8 limit)
    onlyOwner
    external {
        maxRules = limit;
    }

    /**
     *  Sets an address frozen status for this token
     *  @param addr The address to update frozen status.
     *  @param freeze Frozen status of the address.
     */
    function setFrozen(address addr, bool freeze)
    onlyAdmins
    external {
        addressFreezes[addr] = freeze;

        emit AddressFrozen(addr, freeze, msg.sender);
    }

    /**
     *  Replaces all of the existing rules with the given ones
     *  @param kind The bucket of rules to set.
     *  @param rules New compliance rules.
     */
    function setRules(uint8 kind, ComplianceRule[] calldata rules)
    onlyAdmins
    external {
        require(rules.length <= maxRules, "Too many rules");
        complianceRules[kind] = rules;
    }

    /**
     *  Returns all of the current compliance rules for this token
     *  @param kind The bucket of rules to get.
     *  @return List of all compliance rules.
     */
    function getRules(uint8 kind)
    external
    view
    returns (ComplianceRule[] memory) {
        return complianceRules[kind];
    }

    /**
     *  @dev Checks if issuance can occur between the from/to addresses.
     *
     *  Both addresses must be whitelisted and unfrozen
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
        getUnfrozenKind(to, UNSET_KIND);
        // This catches during cancel-and-reissue, but not on issuance.
        if (issuer != from) {
            getUnfrozenKind(from, UNSET_KIND);
        }
        return true;
    }

    /**
     *  @dev Checks if a transfer can occur between the from/to addresses.
     *
     *  Both addresses must be whitelisted, unfrozen, and pass all compliance rule checks.
     *  THROWS when the transfer should fail.
     *  @param initiator The address initiating the transfer.
     *  @param from The address of the sender.
     *  @param to The address of the receiver.
     *  @param tokens The number of tokens being transferred.
     *  @return If a transfer can occur between the from/to addresses.
     */
    function canTransfer(address initiator, address from, address to, uint256 tokens)
    external
    returns (bool) {
        uint8 fromKind = getUnfrozenKind(from, UNSET_KIND);
        uint8 toKind = getUnfrozenKind(to, UNSET_KIND);
        if (initiator != from) {
            getUnfrozenKind(initiator, UNSET_KIND);
        }
        checkRules(initiator, from, to, fromKind, toKind, tokens);
        return true;
    }

    /**
     *  @dev Checks if an override by the sender can occur between the from/to addresses.
     *
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
        require(isAdmin(admin), "Admin account is required");

        // Ensure the receive is unfrozen, along with their ancestors.
        getUnfrozenKind(to, UNSET_KIND);
        return true;
    }

    /**
     *  Returns the kind for the account and if it, or any of it's ancestors are frozen.
     *  @param addr The account to retrieve kind and frozen state for.
     *  @param kind Recursive return value. This should be passed in initially as '0'.
     *  @return (uint8, bool) Returns the kind and frozen state
     */
    function getUnfrozenKind(address addr, uint8 kind)
    private
    returns (uint8) {
        // Ensure the address is not frozen at the token.
        require(addressFreezes[addr] == false, "Address is frozen at the token");

        // Get the kind, frozen, parent of the address from the registry.
        // THROWS when the account doesn't exist (isn't whitelisted)
        (uint8 k, bool frozen, address parent) = store.accountGet(addr);

        // Ensure the address is not frozen within the registry.
        require(frozen == false, "Address is frozen at the registry");

        // Set the kind to the first invocations kind
        if (kind == UNSET_KIND) {
            require(k <= INVESTOR_KIND, "Invalid account kind");
            kind = k;
        }
        // Check ancestor state, unless this is a custodian.
        if (k > CUSTODIAN_KIND) {
            getUnfrozenKind(parent, kind);
        }
        return kind;
    }

    /**
     *  Checks if a transfer is compliant for the given amount of tokens, between the accounts.
     *  @param initiator The address initiating the transfer.
     *  @param from The from account.
     *  @param to The to account.
     */
    function checkRules(address initiator, address from, address to, uint8 fromKind, uint8 toKind, uint256 tokens)
    private {
        // Ensure the transfer is compliant with each rule matching the from account's kind.
        ComplianceRule[] storage rules = complianceRules[fromKind];
        for (uint8 i = 0; i < rules.length; i++) {
            rules[i].check(initiator, from, to, toKind, tokens, store);
        }
    }

}
