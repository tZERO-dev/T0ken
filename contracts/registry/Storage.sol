pragma solidity >=0.4.24 <0.5.0;


import '../libs/collections/AccountMap.sol';
import '../libs/collections/AddressMap.sol';
import '../libs/lifecycle/LockableDestroyable.sol';
import '../libs/ownership/Ownable.sol';


/**
 *  @title Registry Storage
 */
contract Storage is Ownable, LockableDestroyable {
    using AccountMap for AccountMap.Data;
    using AddressMap for AddressMap.Data;

    // ------------------------------- Variables -------------------------------
    // Number of data slots available for accounts
    uint8 constant MAX_DATA = 30;

    // Accounts
    AccountMap.Data public accounts;

    // Account Data
    //   - mapping of:
    //     (address        => (index =>    data))
    mapping(address => mapping(uint8 => bytes32)) public data;

    // Address write permissions
    //     (kind  => address)
    mapping(uint8 => AddressMap.Data) public permissions;


    // ------------------------------- Modifiers -------------------------------
    /**
     *  Ensures the `msg.sender` has permission for the given kind/type of account.
     *
     *    - The `owner` account is always allowed
     *    - Addresses/Contracts must have a corresponding entry, for the given kind
     */
    modifier isAllowed(uint8 kind) {
        require(kind > 0, "Invalid, or missing permission");
        if (msg.sender != owner) {
            require(permissions[kind].exists(msg.sender), "Missing permission");
        }
        _;
    }

    // -------------------------------------------------------------------------

    /**
     *  Adds an account to storage
     *  THROWS when `msg.sender` doesn't have permission
     *  THROWS when the account already exists
     *  @param addr The address of the account
     *  @param kind The kind of account
     *  @param isFrozen The frozen status of the account
     *  @param parent The account parent/owner
     */
    function addAccount(address addr, uint8 kind, bool isFrozen, address parent)
    isUnlocked
    isAllowed(kind)
    external {
        require(accounts.append(addr, kind, isFrozen, parent), "Account already exists");
    }

    /**
     *  Sets an account's frozen status
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @param frozen The frozen status of the account
     */
    function setAccountFrozen(address addr, bool frozen)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        // NOTE: Not bounds checking `index` here, as `isAllowed` ensures the address exists.
        //       Indices are one-based internally, so we need to add one to compensate.
        int256 index = accounts.indexOf(addr) + 1;
        accounts.items[index].frozen = frozen;
    }

    /**
     *  Removes an account from storage
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     */
    function removeAccount(address addr)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        bytes32 ZERO_BYTES = bytes32(0);
        mapping(uint8 => bytes32) accountData = data[addr];

        // Remove data
        for (uint8 i = 0; i < MAX_DATA; i++) {
            if (accountData[i] != ZERO_BYTES) {
                delete accountData[i];
            }
        }

        // Remove account
        accounts.remove(addr);
    }

    /**
     *  Sets data for an address/caller
     *  THROWS when the account doesn't exist
     *  @param addr The address
     *  @param index The index of the data
     *  @param customData The data store set
     */
    function setAccountData(address addr, uint8 index, bytes32 customData)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        require(index < MAX_DATA, "index outside of bounds");
        data[addr][index] = customData;
    }

    /**
     *  Grants the address permission for the given kind
     *  @param kind The kind of address
     *  @param addr The address
     */
    function grantPermission(uint8 kind, address addr)
    isUnlocked
    isAllowed(kind)
    external {
        permissions[kind].append(addr);
    }

    /**
     *  Revokes the address permission for the given kind
     *  @param kind The kind of address
     *  @param addr The address
     */
    function revokePermission(uint8 kind, address addr)
    isUnlocked
    isAllowed(kind)
    external {
        permissions[kind].remove(addr);
    }

    // ---------------------------- Address Getters ----------------------------
    /**
     *  Gets the account at the given index
     *  THROWS when the index is out-of-bounds
     *  @param index The index of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountAt(int256 index)
    external
    view
    returns(address, uint8, bool, address) {
        AccountMap.Account memory acct = accounts.at(index);
        return (acct.addr, acct.kind, acct.frozen, acct.parent);
    }

    /**
     *  Gets the account for the given address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountGet(address addr)
    external
    view
    returns(uint8, bool, address) {
        AccountMap.Account memory acct = accounts.get(addr);
        return (acct.kind, acct.frozen, acct.parent);
    }

    /**
     *  Gets the parent address for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The parent address
     */
    function accountParent(address addr)
    external
    view
    returns(address) {
        return accounts.get(addr).parent;
    }

    /**
     *  Gets the account kind, for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind of account
     */
    function accountKind(address addr)
    external
    view
    returns(uint8) {
        return accounts.get(addr).kind;
    }

    /**
     *  Gets the frozen status of the account
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The frozen status of the account
     */
    function accountFrozen(address addr)
    external
    view
    returns(bool) {
        return accounts.get(addr).frozen;
    }

    /**
     *  Gets the index of the account
     *  Returns -1 for missing accounts
     *  @param addr The address of the account to get the index for
     *  @return The index of the given account address
     */
    function accountIndexOf(address addr)
    external
    view
    returns(int256) {
        return accounts.indexOf(addr);
    }

    /**
     *  Returns whether or not the given address exists
     *  @param addr The account address
     *  @return If the given address exists
     */
    function accountExists(address addr)
    external
    view
    returns(bool) {
        return accounts.exists(addr);
    }

    /**
     *  Returns whether or not the given address exists for the given kind
     *  @param addr The account address
     *  @param kind The kind of address
     *  @return If the given address exists with the given kind
     */
    function accountExists(address addr, uint8 kind)
    external
    view
    returns(bool) {
        int256 index = accounts.indexOf(addr);
        if (index < 0) {
            return false;
        }
        return accounts.at(index).kind == kind;
    }


    // -------------------------- Permission Getters ---------------------------
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
    returns(address) {
        return permissions[kind].at(index);
    }

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
    returns(int256) {
        return permissions[kind].indexOf(addr);
    }

    /**
     *  Returns whether or not the given permission address exists for the given type
     *  @param kind The kind of permission
     *  @param addr The address to check for permission
     *  @return If the given address has permission or not
     */
    function permissionExists(uint8 kind, address addr)
    external
    view
    returns(bool) {
        return permissions[kind].exists(addr);
    }

}
