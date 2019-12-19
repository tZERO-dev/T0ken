pragma solidity >=0.5.0 <0.6.0;


import "../ComplianceRule.sol";
import "../../libs/lifecycle/Destroyable.sol";


contract RestrictToBrokerOrCustodialAccount is ComplianceRule, Destroyable {

    uint8 constant CUSTODIAL_ACCOUNT = 2;
    uint8 constant BROKER_DEALER = 3;

    string public name = "Restrict To Broker or Custodial-Account";

    /**
     *  Blocks the transfer when the receiver is not a broker-dealer or custodial account.
     *  @param token The token contract
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        uint8 toKind = registry().accountKind(to);
        require(toKind == CUSTODIAL_ACCOUNT || toKind == BROKER_DEALER,
                "The to address must be either a custodial-account or broker-dealer");
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
        uint8 toKind = compliance.registry().accountKind(to);
        if (!(toKind == CUSTODIAL_ACCOUNT || toKind == BROKER_DEALER)) {
            s = "The 'to' address must be either a custodial-account or broker-dealer";
        }
    }
}
