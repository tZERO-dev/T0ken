pragma solidity >=0.5.0 <0.6.0;


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
contract IComplianceStorage {

    // ------------------------------ Permission -------------------------------

    /**
     * Returns the total number of permission entries
     * return The number of permission count
     */
    function permissions()
    external
    returns(uint256);

    /**
     *  Adds/Removes permissions for the given address
     *  THROWS when the permissions can't be granted/revoked
     *  @param addr The address to add/remove permissions for
     *  @param grant If permissions are being granted or revoked
     */
    function setPermission(address addr, bool grant)
    external;

    /**
     *  Retrieves the permission address at the index for the given type
     *  THROWS when the index is out-of-bounds
     *  @param index The index of the item to retrieve
     *  @return The permission address of the item at the given index
     */
    function permissionAt(int256 index)
    external
    view
    returns(address);

    /**
     *  Gets the index of the permission address for the given type
     *  Returns -1 for missing permission
     *  @param addr The address of the permission to get the index for
     *  @return The index of the given permission address
     */
    function permissionIndexOf(address addr)
    external
    view
    returns(int256);

    /**
     *  Returns whether or not the given permission address exists for the given type
     *  @param addr The address to check for permission
     *  @return If the given address has permission or not
     */
    function permissionExists(address addr)
    external
    view
    returns(bool);

    // ------------------------------ Storage ----------------------------------

    // -- Address
    function getAddresses(bytes32[] memory k) public view returns(address[] memory);
    function getAddress(bytes32 k) external view returns(address);
    function setAddress(bytes32 k, address v) external;
    function deleteAddress(bytes32 k) external;

    function getBools(bytes32[] memory k) public view returns(bool[] memory);
    function getBool(bytes32 k) external view returns(bool);
    function setBool(bytes32 k, bool v) external;
    function deleteBool(bytes32 k) external;

    // -- Bytes
    function getBytes(bytes32 k) external view returns(bytes memory);
    function setBytes(bytes32 k, bytes calldata v) external;
    function deleteBytes(bytes32 k) external;

    // -- Bytes32
    function getBytes32s(bytes32[] memory k) public view returns(bytes32[] memory);
    function getBytes32(bytes32 k) external view returns(bytes32);
    function setBytes32(bytes32 k, bytes32 v) external;
    function deleteBytes32(bytes32 k) external;

    // -- String
    function getString(bytes32 k) external view returns(string memory);
    function setString(bytes32 k, string calldata v) external;
    function deleteString(bytes32 k) external;

    // -- Int256
    function getInt256s(bytes32[] memory k) public view returns(int256[] memory);
    function getInt256(bytes32 k) external view returns(uint256);
    function setInt256(bytes32 k, int256 v) external;
    function deleteInt256(bytes32 k) external;

    // -- Uint256
    function getUint256s(bytes32[] memory k) public view returns(uint256[] memory);
    function getUint256(bytes32 k) external view returns(uint256);
    function setUint256(bytes32 k, uint256 v) external;
    function deleteUint256(bytes32 k) external;
}
