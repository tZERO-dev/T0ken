pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";


interface Compliance {

    /**
     *  This event is emitted when an address's frozen status has changed.
     *  @param addr The address whose frozen status has been updated.
     *  @param isFrozen Whether the custodian is being frozen.
     *  @param owner The address that updated the frozen status.
     */
    event AddressFrozen(
        address indexed addr,
        bool indexed isFrozen,
        address indexed owner
    );

    /**
     *  Sets an address frozen status for this token
     *  @param addr The address to update frozen status.
     *  @param freeze Frozen status of the address.
     */
    function setFrozen(address addr, bool freeze)
    external;

    /**
     *  Replaces all of the existing rules with the given ones
     *  @param kind The bucket of rules to set.
     *  @param rules New compliance rules.
     */
    function setRules(uint8 kind, ComplianceRule[] calldata rules)
    external;

    /**
     *  Returns all of the current compliance rules for this token
     *  @param kind The bucket of rules to get.
     *  @return List of all compliance rules.
     */
    function getRules(uint8 kind)
    external
    view
    returns (ComplianceRule[] memory);

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
    returns (bool);

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
    returns (bool);

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
    returns (bool);
}
