pragma solidity >=0.5.0 <0.6.0;


import "../../libs/lifecycle/Destroyable.sol";
import "../../libs/registry/InvestorData.sol";
import "../ComplianceRule.sol";


contract RestrictToAccreditedInvestor is ComplianceRule, Destroyable {
    using InvestorData for IRegistry;

    uint8 constant INVESTOR = 4;

    string public name = "Restrict To Accredited Investor";

    /**
     *  Blocks the transfer when the recipient is unaccredited
     *  @param token The token contract
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        if (registry().accountKind(to) == INVESTOR) {
            require(registry().isAccredited(to), "The to address is not currently accredited");
        }
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
        IRegistry r = compliance.registry();
        if (r.accountKind(to) == INVESTOR && r.isAccredited(to) == false) {
            s = "The 'to' address is not currently accredited";
        }
    }
}
