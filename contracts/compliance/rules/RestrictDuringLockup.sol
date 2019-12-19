pragma solidity >=0.5.0 <0.6.0;


import "../ComplianceRule.sol";
import "../../libs/lifecycle/Destroyable.sol";


contract RestrictDuringLockup is ComplianceRule, Destroyable {

    string public name = "Restrict During Lockup";
    string private constant DURATIONS_KEY = "RestrictDuringLockup.durations";

    /**
     *  Blocks the transfer during a lockup period
     *  @param token The token contract
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        bytes32 key = keccak256(abi.encodePacked(DURATIONS_KEY, token.symbol()));
        uint256 duration = complianceStore().getUint256(key);
        require(duration < now, "Holder currently in lockup period");
    }

    /**
     *  Tests if a transfer can occur between the from/to addresses and returns an error string when it would fail
     *  @param compliance The Compliance address
     *  @param token The address of the token that triggered the check
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     *  @return The error message
     */
    function test(ICompliance compliance, IT0ken token, address initiator, address from, address to, uint256 tokens)
    external
    view
    returns (string memory s) {
        bytes32 key = keccak256(abi.encodePacked(DURATIONS_KEY, token.symbol()));
        uint256 duration = compliance.store().getUint256(key);

        if (!(duration < now)) {
            s = "Holder currently in lockup period";
        }
    }
}