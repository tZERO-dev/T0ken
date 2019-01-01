pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictToCustodianOrCustodialAccountOrBroker is ComplianceRule, Destroyable {

    uint8 constant INVESTOR = 4;

    /**
     *  Blocks the transfer if the sender is not a custodian, custodial-account, or broker-dealer.
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        require(toKind < INVESTOR, "Recipient is not a custodian, custodial-account, or broker");
    }
}
