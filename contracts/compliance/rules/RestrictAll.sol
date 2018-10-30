pragma solidity >=0.4.24 <0.5.0;


import "../ComplianceRule.sol";


contract RestrictAll is ComplianceRule {

    /**
     *  Blocks all transfers
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool) {
        return false;
    }
}
