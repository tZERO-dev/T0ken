pragma solidity >=0.5.0 <0.6.0;


import "../registry/IRegistry.sol";
import "../token/IT0ken.sol";
import "./ICompliance.sol";
import "./IComplianceStorage.sol";


contract IComplianceRule {

    /**
     *  Gets the registry of the msg.senger
     *  @dev Only call this when `msg.sender` is a Compliance contract
     *  @return The registry of compliance
     */
    function registry()
    internal
    view
    returns (IRegistry);

    /**
     *  Gets the compliance-storage of the msg.senger
     *  @dev Only call this when `msg.sender` is a Compliance contract
     *  @return The compliance-storage of compliance
     */
    function complianceStore()
    internal
    view
    returns (IComplianceStorage);

    /**
     *  Returns the rule name
     */
    function name()
    external
    view
    returns (string memory);

    /**
     *  Checks if a transfer can occur between the from/to addresses and MUST throw when the check fails.
     *  @param token The address of the token that triggered the check
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external;

    /**
     *  Tests if a transfer can occur between the from/to addresses and returns an error string when it would fail
     *  @param compliance The Compliance address
     *  @param token The address of the token that triggered the check
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     *  @return The error message
     */
    function test(ICompliance compliance, IT0ken token, address initiator, address from, address to, uint256 tokens)
    external
    view
    returns (string memory);
}
