pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictTransferFrom is ComplianceRule, Destroyable {

    /**
     *  Blocks all transfers on behalf of
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        require(initiator == from, "The sending address must be the initiator");
    }
}
