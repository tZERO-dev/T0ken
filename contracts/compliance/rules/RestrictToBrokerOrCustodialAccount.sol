pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/lifecycle/LockableDestroyable.sol";

import "../ComplianceRule.sol";


contract RestrictToBrokerOrCustodialAccount is ComplianceRule {

    uint8 constant CUSTODIAL_ACCOUNT = 2;
    uint8 constant BROKER_DEALER = 3;

    /**
     *  Blocks the transfer when the receiver is not a broker-dealer or custodial account.
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool) {
        return toKind == CUSTODIAL_ACCOUNT || toKind == BROKER_DEALER;
    }
}
