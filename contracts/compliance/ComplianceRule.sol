pragma solidity >=0.4.24 <0.5.0;


import "t0ken/registry/Storage.sol";

interface ComplianceRule {

    /**
     * @param from The address of the sender
     * @param to The address of the receiver
     * @param toKind The kind of the to address
     * @param store The Storage contract
     * @return true if transfer is allowed
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool);
}
