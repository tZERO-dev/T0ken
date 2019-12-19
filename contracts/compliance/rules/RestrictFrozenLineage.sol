pragma solidity >=0.5.0 <0.6.0;


import "../ComplianceRule.sol";
import "../../libs/lifecycle/Destroyable.sol";


/**
 *
 *  Handles token level freezes, performing freeze checks on an address and its lineage
 *
 *  Freeze:
 *      ```
 *      var key = web3.sha3(web3.toHex('Token.freezes') + web3.toHex("TZROP").substr(2) + "c01c68ac7dd1cc48f95e3187a33a170fdb9023e7", {encoding: 'hex'})
 *      ComplianceStorage.setBool(key, true, {from: owner, gas: 999999})
 *      ```
 *
 *  Unfreeze:
 *      ```
 *      var key = web3.sha3(web3.toHex('Token.freezes') + web3.toHex("TZROP").substr(2) + "c01c68ac7dd1cc48f95e3187a33a170fdb9023e7", {encoding: 'hex'})
 *      ComplianceStorage.setBool(key, false, {from: owner, gas: 999999})
 *      ```
 *
 *  IsFrozen:
 *      ```
 *      var key = web3.sha3(web3.toHex('Token.freezes') + web3.toHex("TZROP").substr(2) + "c01c68ac7dd1cc48f95e3187a33a170fdb9023e7", {encoding: 'hex'})
 *      ComplianceStorage.getBool(key)
 *      ```
 *
 */
contract RestrictFrozenLineage is ComplianceRule, Destroyable {

    string private constant FREEZE_KEY = "Token.freezes";
    string public name = "RestrictFrozenLineage";

    /**
     *  This event is emitted when an address's frozen status has changed.
     *  @param addr The address whose frozen status has been updated.
     *  @param isFrozen Whether the custodian is being frozen.
     *  @param owner The address that updated the frozen status.
     */
    event AddressFrozen(
        address indexed addr,
        bool indexed isFrozen,
        address indexed owner
    );

    /**
     *  Checks if the current rule state is set to restricted, and passes/fails the transfer check accordingly.
     *  @param token The token contract
     *  @param initiator The address initiating the transfer.
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred.
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    external {
        if (hasFreeze(registry(), complianceStore(), token.symbol(), from, to)) {
            revert("Token is frozen for address or linage");
        }
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
        if (hasFreeze(compliance.registry(), compliance.store(), token.symbol(), from, to)) {
            s = "Token is frozen for address or lineage";
        }
    }

    /**
     *  Returns if either the from, or to, address are frozen at the token, or their lineages
     */
    function hasFreeze(IRegistry registry, IComplianceStorage store, string memory symbol, address from, address to)
    private
    view
    returns (bool) {
        // Get lineages
        address[] memory lineage = new address[](2);
        lineage[0] = from;
        lineage[1] = to;
        lineage = registry.accountLineage(lineage);  // recycling `lineage` to avoid creating separate arrays

        // Generate freeze keys
        bytes32[] memory keys = new bytes32[](lineage.length + 2);
        uint256 i;
        //   Add lineage keys
        for(i = 0; i < lineage.length; i++) {
            keys[i+2] = keccak256(abi.encodePacked(FREEZE_KEY, symbol, lineage[i]));
        }
        //   Add from/to keys
        keys[0] = keccak256(abi.encodePacked(FREEZE_KEY, symbol, from));
        keys[1] = keccak256(abi.encodePacked(FREEZE_KEY, symbol, to));

        // Check if any account is frozen
        bool[] memory frozen = store.getBools(keys);
        for (i = 0; i < frozen.length; i++) {
            if (frozen[i]) return true;
        }
        return false;
    }

}
