pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictToContract is ComplianceRule, Destroyable {

    /**
     *  Blocks transfers to contracts
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
	  uint32 size;
	  assembly {
		size := extcodesize(to)
	  }
	  require(size == 0, "Transfers to contracts are not allowed.");
    }
}
