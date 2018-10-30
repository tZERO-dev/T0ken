pragma solidity >=0.4.24 <0.5.0;

import "t0ken/registry/Storage.sol";

import "./ComplianceRule.sol";


interface Compliance {

    /**
     * This event is emitted when an address's frozen status has changed.
     * @param addr The address whose frozen status has been updated
     * @param isFrozen Whether the custodian is being frozen
     * @param owner The address that updated the frozen status
     */
    event AddressFrozen(
        address indexed addr,
        bool indexed isFrozen,
        address indexed owner
    );

    /**
     *  Sets an address frozen status for this token
     *  @param addr The address to update frozen status
     *  @param freeze Frozen status of the address
     */
    function setAddressFrozen(address addr, bool freeze)
    external;

    /**
     *  Replaces all of the existing rules with the given ones
     *  @param kind The bucket of rules to set
     *  @param rules New compliance rules
     */
    function setRules(uint8 kind, ComplianceRule[] rules)
    external;

    /**
     *  Returns all of the current compliance rules for this token
     *  @param kind The bucket of rules to get
     *  @return List of all compliance rules
     */
    function getRules(uint8 kind)
    external
    view
    returns(ComplianceRule[]);

    /**
     *  Checks if a transfer can occur between the from/to addresses.
     *  Both addresses must be valid, unfrozen, and pass all compliance rule checks.
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @return If a transfer can occur between the from and to addresses
     */
    function canTransfer(address from, address to)
    external
    view
    returns(bool);

}
