pragma solidity >=0.5.0 <0.6.0;


import "../ComplianceRule.sol";
import "../../libs/lifecycle/Destroyable.sol";


contract RestrictFromInvestor is ComplianceRule, Destroyable {

    uint8 INVESTOR = 4;
    uint8 EXTERNAL_INVESTOR = 5;

    string public name = "Restrict From Investor";

    /**
     *  Blocks when the receiver is an investor.
     *  @param token The token contract
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        uint8 toKind = registry().accountKind(to);
        require(toKind != INVESTOR && toKind != EXTERNAL_INVESTOR, "The to address cannot be an investor");
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
        if (!(toKind != INVESTOR && toKind != EXTERNAL_INVESTOR)) {
            s = "The 'to' address cannot be an investor";
        }
    }
}
