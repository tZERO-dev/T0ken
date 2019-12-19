pragma solidity >=0.5.0 <0.6.0;


/**
 *  @title IRegistry
 */
contract IRegistry {

    /**
     *  Returns the number of accounts
     *  @return The number of accounts
     */
    function accounts()
    external
    view
    returns(int256);

    /**
     *  Returns the data at the given slot for the provided address
     *  @return the data at the given slot for the provided address
     */
    function data(address, uint8)
    external
    view
    returns(bytes32);

    /**
     *  Returns the number of accounts for the given hash
     *  @return The number of accounts for the given hash
     */
    function hashes(bytes32)
    external
    view
    returns(int256);

    /**
     *  Returns the number of permissions for the kind
     *  @return The number of permissions for the kind
     */
    function permissions(uint8)
    external
    view
    returns(int256);

    /**
     *  Adds an account to storage
     *  THROWS when `msg.sender` doesn't have permission
     *  THROWS when the account already exists
     *  @param addr The address of the account
     *  @param kind The kind of account
     *  @param isFrozen The frozen status of the account
     *  @param parent The account parent/owner
     *  @param hash The hash that uniquely identifies the account
     */
    function addAccount(address addr, uint8 kind, bool isFrozen, address parent, bytes32 hash)
    external;

    /**
     *  Sets an account's frozen status
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @param frozen The frozen status of the account
     */
    function setAccountFrozen(address addr, bool frozen)
    external;

    /**
     *  Sets the account's parent
     *  THROWS when the account doesn't exist or when the new parent would cause a cyclical lineage
     *  @param addr The address of the account
     *  @param parent The new parent of the account
     */
    function setAccountParent(address addr, address parent)
    external;

    /**
     *  Sets the account's hash
     *  THROWS when the account doesn't exist
     *  @dev Removes the current hash from `hashes` and adds a new entry, using the new hash, to `hashes`
     *  @param addr The address of the account
     *  @param hash The new hash of the account
     */
    function setAccountHash(address addr, bytes32 hash)
    external;

    /**
     *  Removes an account from storage
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     */
    function removeAccount(address addr)
    external;

    /**
     *  Sets data for an address/caller
     *  THROWS when the account doesn't exist
     *  @param addr The address
     *  @param index The index of the data
     *  @param customData The data store set
     */
    function setAccountData(address addr, uint8 index, bytes32 customData)
    external;

    /**
     *  Adds/Removes permissions for the given address
     *  THROWS when the permissions can't be granted/revoked
     *  @param kind The kind of the permissions to grant
     *  @param addr The address to add/remove permissions for
     *  @param grant If permissions are being granted or revoked
     */
    function setPermission(uint8 kind, address addr, bool grant)
    external;

    /**
     *  Gets the account at the given index
     *  THROWS when the index is out-of-bounds
     *  @param index The index of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountAt(int256 index)
    external
    view
    returns(address, uint8, bool, address, bytes32);

    /**
     *  Gets the account of the hash at the given index
     *  THROWS when the index is out-of-bounds
     *  @param hash The hash of the item to retrieve
     *  @param index The index of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountAtHash(bytes32 hash, int256 index)
    external
    view
    returns(address, uint8, bool, address, bytes32);

    /**
     *  Gets the address of the hash at the given index
     *  THROWS when the index is out-of-bounds
     *  @param hash The hash of the item to retrieve
     *  @param index The index of the item to retrieve
     *  @return The address of the hash at the given index
     */
    function addressAtHash(bytes32 hash, int256 index)
    external
    view
    returns(address);

    /**
     *  Gets the account for the given address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the item to retrieve
     *  @return The address, kind, frozen status, parent, and hash of the account at the given index
     */
    function accountGet(address addr)
    external
    view
    returns(uint8, bool, address, bytes32);

    /**
     *  Gets the hash for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The hash
     *  @return The hash of the address
     */
    function accountHash(address addr)
    external
    view
    returns(bytes32);

    /**
     *  Gets the parent address for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The parent address
     */
    function accountParent(address addr)
    external
    view
    returns(address);

    /**
     *  Gets the account kind, for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind of account
     */
    function accountKind(address addr)
    external
    view
    returns(uint8);

    /**
     *  Gets the frozen status of the account
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The frozen status of the account
     */
    function accountFrozen(address addr)
    external
    view
    returns(bool);

    /**
     *  Gets the kind and frozen status of the account
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind and frozen status of the account
     */
    function accountKindAndFrozen(address addr)
    external
    view
    returns(uint8, bool);

    /**
     *  Returns the kind of the addr and the first lineage address that's frozen, or itself when frozen.
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind of the addr and whether any account in it's lineage is frozen, or blocked by the callback
     */
    function accountKindAndFrozenAddress(address addr)
    external
    view
    returns(uint8, address);

    /**
     *  Returns the kind of the addr, the first frozen address within the lineage, or the addr when it's frozen, and
     *  an array of lineage addresses.
     *  THROWS when the account doesn't exist
     *  @param addr The address to get the kind, frozen address, and lineage for
     *  @return The kind of the addr, frozen address, lineage addresses
     */
    function accountKindAndFrozenAddressLineage(address addr)
    external
    view
    returns(uint8, address, address[] memory);

    /**
     *  Returns the lineage addresses of the addr
     *  THROWS when the account doesn't exist
     *  @param addr The address to retrieve the lineage for
     *  @return The lineage of the given addr
     */
    function accountLineage(address addr)
    external
    view
    returns(address[] memory);

    /**
     *  Gets the index of the account
     *  Returns -1 for missing accounts
     *  @param addr The address of the account to get the index for
     *  @return The index of the given account address
     */
    function accountIndexOf(address addr)
    external
    view
    returns(int256);

    /**
     *  Returns whether or not the given address exists
     *  @param addr The account address
     *  @return If the given address exists
     */
    function accountExists(address addr)
    external
    view
    returns(bool);

    /**
     *  Returns whether or not the given address exists for the given kind
     *  @param addr The account address
     *  @param kind The kind of address
     *  @return If the given address exists with the given kind
     */
    function accountKindExists(address addr, uint8 kind)
    external
    view
    returns(bool);

    /**
     *  Retrieves the permission address at the index for the given type
     *  THROWS when the index is out-of-bounds
     *  @param kind The kind of permission
     *  @param index The index of the item to retrieve
     *  @return The permission address of the item at the given index
     */
    function permissionAt(uint8 kind, int256 index)
    external
    view
    returns(address);

    /**
     *  Gets the index of the permission address for the given type
     *  Returns -1 for missing permission
     *  @param kind The kind of permission
     *  @param addr The address of the permission to get the index for
     *  @return The index of the given permission address
     */
    function permissionIndexOf(uint8 kind, address addr)
    external
    view
    returns(int256);

    /**
     *  Returns whether or not the given permission address exists for the given type
     *  @param kind The kind of permission
     *  @param addr The address to check for permission
     *  @return If the given address has permission or not
     */
    function permissionExists(uint8 kind, address addr)
    external
    view
    returns(bool);

    /**
     *  Returns the lineage addresses of all the addresses
     *  THROWS when any account doesn't exist
     *  @param addresses The addresses to retrieve the lineage for
     *  @return The lineage of the given addresses
     */
    function accountLineage(address[] memory addresses)
    public
    view
    returns(address[] memory);

    /**
     *  Gets the number of ancestors of the given addr
     *  THROWS when the account doesn't exist
     *  @param addr The address to retrieve ancestry count for
     *  @return The number of ancestry addresses
     */
    function lineageCount(address addr)
    public
    view
    returns(uint256);

}
