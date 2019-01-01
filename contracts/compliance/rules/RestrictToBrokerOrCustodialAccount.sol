pragma solidity >=0.5.0 <0.6.0;


import "tzero/compliance/ComplianceRule.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


contract RestrictToBrokerOrCustodialAccount is ComplianceRule, Destroyable {

    uint8 constant CUSTODIAL_ACCOUNT = 2;
    uint8 constant BROKER_DEALER = 3;

    /**
     *  Blocks the transfer when the receiver is not a broker-dealer or custodial account.
     */
    function check(address initiator, address from, address to, uint8 toKind, uint256 tokens, Storage store)
    external {
        require(toKind == CUSTODIAL_ACCOUNT || toKind == BROKER_DEALER,
                "The to address must be either a custodial-account or broker-dealer");
    }
}
