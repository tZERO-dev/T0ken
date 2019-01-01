pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictToAccreditedInvestor is ComplianceRule, Destroyable {

    uint8 constant INVESTOR = 4;

    /**
     *  Blocks transfers to an unaccredited investor.
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        if (toKind == INVESTOR) {
            require(uint48(uint256(store.data(to, 1))>>16) > now,
                    "The to address is not currently accredited");
        }
    }
}
