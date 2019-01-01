pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictFromAffiliate is ComplianceRule, Destroyable {

    mapping(address => bool) public affiliates;

    /**
     *  Sets an address affiliate status for this token
     *  @param addr The address to set affiliate status for.
     *  @param status Whether the address is an affiliate, or not.
     */
    function setAffiliate(address addr, bool status)
    onlyOwner
    external {
        affiliates[addr] = status;
    }

    /**
     *  Blocks when the sender is an affiliate.
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        require(affiliates[from] == false,
            "The from address is an affiliate and not allowed to send tokens.");
    }
}
