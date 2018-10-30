pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/lifecycle/LockableDestroyable.sol";

import "../ComplianceRule.sol";


contract RestrictToCustodianOrCustodialAccountOrBroker is ComplianceRule {

    uint8 constant INVESTOR = 4;

    /**
     *  Blocks the transfer if the sender is not a custodian.
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool) {
        return toKind < INVESTOR;
    }
}
