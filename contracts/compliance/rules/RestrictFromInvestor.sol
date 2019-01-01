pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictFromInvestor is ComplianceRule, Destroyable {

    uint8 INVESTOR = 4;

    /**
     *  Blocks when the receiver is an investors.
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        require(toKind != INVESTOR, "The to address cannot be an investor");
    }
}
