pragma solidity >=0.5.0 <0.6.0;


import '../libs/collections/AddressMap.sol';
import "../libs/lifecycle/LockableDestroyable.sol";
import "../libs/ownership/Ownable.sol";
import "./IComplianceStorage.sol";


/**
 *  Eternal Storage for compliance/rules.
 *
 *    Keys:
 *      All contracts should use the below pattern for key generation `keccak256({contractName}.{identifier}.{type})`
 *        ({type} should use the default alias for the type, uint instead of uint<m>)
 *      Any optional identifiers should follow the aformentioned keys.
 *
 *      eg.
 *      ```
 *      bytes32 key = keccak256("T0kenCompliance.freezes.address", addr);
 *      storage.setAddress(key, addr);
 *
 *      ...
 *
 *      bytes32 key = keccak256("T0kenCompliance.rules.address", kind, index);
 *      storage.getAddress(key);
 *      ```
 *
 *    Web3:
 *      When generating a key it is critical that you account for the width of all types used.
 *
 *      For example, if you generate a key using:
 *        keccak256(abi.encodePacked("T0kenCompliance.ruleCount.uint", fromKind));  <- where `fromKind` is a `uint8`
 *
 *      The web3 code to replicate this would be:
 *        web3.sha3(web3.toHex("T0kenCompliance.ruleCount.uint") + "00", {encoding:'hex'})
 *
 *      If the `fromKind` were a uint16:
 *        web3.sha3(web3.toHex("T0kenCompliance.ruleCount.uint") + "0000", {encoding:'hex'})
 *
 */
contract ComplianceStorage is IComplianceStorage, Ownable, LockableDestroyable {
    using AddressMap for AddressMap.Data;
    AddressMap.Data public permissions;

    mapping(bytes32 => address) public getAddress;
    mapping(bytes32 => bool) public getBool;
    mapping(bytes32 => bytes32) public getBytes32;
    mapping(bytes32 => bytes) public getBytes;
    mapping(bytes32 => int256) public getInt256;
    mapping(bytes32 => string) public getString;
    mapping(bytes32 => uint256) public getUint256;

    modifier isAllowed {
        require(permissions.exists(msg.sender) || msg.sender == owner, "Missing storage permission");
        _;
    }

    // ------------------------------ Permission -------------------------------
    /**
     *  Adds/Removes permissions for the given address
     *  THROWS when the permissions can't be granted/revoked
     *  @param addr The address to add/remove permissions for
     *  @param grant If permissions are being granted or revoked
     */
    function setPermission(address addr, bool grant)
    external
    onlyOwner {
        if (grant) {
            require(permissions.append(addr), "Address already has permission");
        } else {
            require(permissions.remove(addr), "Address permission don't exist");
        }
    }

    /**
     *  Retrieves the permission address at the index for the given type
     *  THROWS when the index is out-of-bounds
     *  @param index The index of the item to retrieve
     *  @return The permission address of the item at the given index
     */
    function permissionAt(int256 index)
    external
    view
    returns(address) {
        return permissions.at(index);
    }

    /**
     *  Gets the index of the permission address for the given type
     *  Returns -1 for missing permission
     *  @param addr The address of the permission to get the index for
     *  @return The index of the given permission address
     */
    function permissionIndexOf(address addr)
    external
    view
    returns(int256) {
        return permissions.indexOf(addr);
    }

    /**
     *  Returns whether or not the given permission address exists for the given type
     *  @param addr The address to check for permission
     *  @return If the given address has permission or not
     */
    function permissionExists(address addr)
    external
    view
    returns(bool) {
        return permissions.exists(addr);
    }

    // ------------------------------ Storage ----------------------------------

    // -- Address
    function getAddresses(bytes32[] memory k) public view returns(address[] memory o) {
        o = new address[](k.length);
        for (uint256 i = 0; i < k.length; i++)
            o[i] = getAddress[k[i]];
    }
    function setAddress(bytes32 k, address v) external isAllowed { getAddress[k] = v; }
    function deleteAddress(bytes32 k) external isAllowed { delete getAddress[k]; }

    function getBools(bytes32[] memory k) public view returns(bool[] memory o) {
        o = new bool[](k.length);
        for (uint256 i = 0; i < k.length; i++)
            o[i] = getBool[k[i]];
    }
    function setBool(bytes32 k, bool v) external isAllowed { getBool[k] = v; }
    function deleteBool(bytes32 k) external isAllowed { delete getBool[k]; }

    // -- Bytes
    function setBytes(bytes32 k, bytes calldata v) external isAllowed { getBytes[k] = v; }
    function deleteBytes(bytes32 k) external isAllowed { delete getBytes[k]; }

    // -- Bytes32
    function getBytes32s(bytes32[] memory k) public view returns(bytes32[] memory o) {
        o = new bytes32[](k.length);
        for (uint256 i = 0; i < k.length; i++)
            o[i] = getBytes32[k[i]];
    }
    function setBytes32(bytes32 k, bytes32 v) external isAllowed { getBytes32[k] = v; }
    function deleteBytes32(bytes32 k) external isAllowed { delete getBytes32[k]; }

    // -- String
    function setString(bytes32 k, string calldata v) external isAllowed { getString[k] = v; }
    function deleteString(bytes32 k) external isAllowed { delete getString[k]; }

    // -- Int256
    function getInt256s(bytes32[] memory k) public view returns(int256[] memory o) {
        o = new int256[](k.length);
        for (uint256 i = 0; i < k.length; i++)
            o[i] = getInt256[k[i]];
    }
    function setInt256(bytes32 k, int256 v) external isAllowed { getInt256[k] = v; }
    function deleteInt256(bytes32 k) external isAllowed { delete getInt256[k]; }

    // -- Uint256
    function getUint256s(bytes32[] memory k) public view returns(uint256[] memory o) {
        o = new uint256[](k.length);
        for (uint256 i = 0; i < k.length; i++)
            o[i] = getUint256[k[i]];
    }
    function setUint256(bytes32 k, uint256 v) external isAllowed { getUint256[k] = v; }
    function deleteUint256(bytes32 k) external isAllowed { delete getUint256[k]; }
}
