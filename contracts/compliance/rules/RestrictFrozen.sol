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
contract RestrictFrozen is ComplianceRule, Destroyable {

    string private constant FREEZE_KEY = "Token.freezes";
    string public name = "RestrictFrozen";

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
        (bool fromFrozen, bool toFrozen) =  frozenStatus(complianceStore(), token.symbol(), from, to);
        require(fromFrozen == false, "From address is frozen");
        require(toFrozen == false, "To address is frozen");
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
        (bool fromFrozen, bool toFrozen) = frozenStatus(compliance.store(), token.symbol(), from, to);
        bytes memory b;
        if (fromFrozen)
            b = abi.encodePacked("From address is frozen");
        if (toFrozen)
            b = abi.encodePacked(b, "To address is frozen");

        return string(b);
    }

    /**
     *  Gets the frozen status for both the from and to addresses
     */
    function frozenStatus(IComplianceStorage store, string memory symbol, address from, address to)
    private
    view
    returns (bool, bool) {
        bytes32[] memory keys = new bytes32[](2);
        keys[0] = keccak256(abi.encodePacked(FREEZE_KEY, symbol, from));
        keys[1] = keccak256(abi.encodePacked(FREEZE_KEY, symbol, to));
        bool[] memory frozen = store.getBools(keys);
        return (frozen[0], frozen[1]);
    }
}
