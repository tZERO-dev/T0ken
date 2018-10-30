pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/lifecycle/LockableDestroyable.sol";

import "../ComplianceRule.sol";


contract RestrictToAccreditedInvestor is ComplianceRule {

    uint8 constant INVESTOR = 4;

    /**
     *  Blocks transfers to an unaccredited investor.
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool) {
        if (toKind != INVESTOR) {
            return true;
        }
        return uint48(uint256(store.data(to, 1))>>16) > now;
    }
}
