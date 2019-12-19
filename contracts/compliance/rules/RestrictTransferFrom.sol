pragma solidity >=0.5.0 <0.6.0;


import "../ComplianceRule.sol";
import "../../libs/lifecycle/Destroyable.sol";


contract RestrictTransferFrom is ComplianceRule, Destroyable {

    string public name = "Restrict Transfer From";

    /**
     *  Blocks all transfers on behalf of
     *  @param token The token contract
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        require(initiator == from, "The sending address must be the initiator");
    }

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
    returns (string memory s) {
        if (!(initiator == from)) {
            s = "The sending address must be the initiator";
        }
    }
}
