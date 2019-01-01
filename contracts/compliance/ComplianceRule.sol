pragma solidity >=0.5.0 <0.6.0;


import "tzero/registry/Storage.sol";


interface ComplianceRule {

    /**
     *  @dev Checks if a transfer can occur between the from/to addresses and MUST throw when the check fails.
     *  @param initiator The address initiating the transfer.
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param toKind The kind of the to address
     *  @param tokens The number of tokens being transferred.
     *  @param store The Storage contract
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external;
}
