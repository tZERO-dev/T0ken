pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/lifecycle/LockableDestroyable.sol";

import "../ComplianceRule.sol";


contract RestrictFromInvestor is ComplianceRule {

    uint8 INVESTOR = 4;

    /**
     *  Blocks when the receiver is an investors.
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool) {
        return toKind != INVESTOR;
    }
}
