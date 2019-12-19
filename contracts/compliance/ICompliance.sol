pragma solidity >=0.5.0 <0.6.0;


import "../registry/IRegistry.sol";
import "../token/IT0ken.sol";
import "./IComplianceRule.sol";
import "./IComplianceStorage.sol";


interface ICompliance {

    function registry()
    external
    view
    returns (IRegistry);

    function store()
    external
    view
    returns (IComplianceStorage);

    /**
     *  Replaces all of the existing rules with the given ones
     *  @param token The token to set rules for
     *  @param kind The bucket of rules to set.
     *  @param rules New compliance rules.
     */
    function setRules(IT0ken token, uint8 kind, IComplianceRule[] calldata rules)
    external;

    /**
     *  Returns all of the current compliance rules for this token
     *  @param token The token to set rules for
     *  @param kind The bucket of rules to get.
     *  @return List of all compliance rules.
     */
    function getRules(IT0ken token, uint8 kind)
    external
    view
    returns (IComplianceRule[] memory);

    /**
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
     *  Checks if an override by the sender can occur between the from/to addresses.
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
