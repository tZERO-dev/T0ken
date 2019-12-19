pragma solidity >=0.5.0 <0.6.0;


import '../libs/collections/AddressMap.sol';
import '../libs/lifecycle/LockableDestroyable.sol';
import '../libs/ownership/Ownable.sol';
import "../libs/strings/AddressToASCII.sol";
import "./IRegistry.sol";


/**
 *  @title Registry
 */
contract Registry is IRegistry, Ownable, LockableDestroyable {
  
    using AddressMap for AddressMap.Data;
    using AddressToASCII for address;

    struct Account {
        address addr;
        uint8 kind;
        bool frozen;
        address parent;
        bytes32 hash;
    }


    // ------------------------------- Variables -------------------------------
    // Number of data slots available per account
    uint8 constant MAX_DATA = 100;

    // Account variables
    //   - indices:  Mapping of address to index
    //   - items:    Mapping of index to account
    //   - accounts: Count of items/accounts
    mapping(address => int256) private indices;
    mapping(int256 => Account) private items;
    int256 public accounts;

    // Account data
    //   - mapping of:
    //                         MAX_DATA
    //     (address        => (index =>    data))
    mapping(address => mapping(uint8 => bytes32)) public data;

    // Account hash mappings
    mapping(bytes32 => AddressMap.Data) public hashes;

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
        // Verify permission
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
     *  @param hash The hash that uniquely identifies the account
     */
    function addAccount(address addr, uint8 kind, bool isFrozen, address parent, bytes32 hash)
    isUnlocked
    isAllowed(kind)
    external {
        // Check if the account already exists
        int256 oneBasedIndex = indices[addr];
        require(oneBasedIndex < 1 || oneBasedIndex > accounts, "Account already exists");

        // Prevent cyclical lineage
        Account memory a = Account(addr, kind, isFrozen, parent, hash);
        (bool cyclical, address at) = hasCyclicalLineage(a);
        require(!cyclical, string(abi.encodePacked("Cyclical lineage at address: ", at.toString())));

        // Append the account/index and update the count
        accounts++;
        indices[addr] = accounts;
        items[accounts] = a;

        hashes[hash].append(addr);
    }

    /**
     *  Sets an account's frozen status
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @param frozen The frozen status of the account
     */
    function setAccountFrozen(address addr, bool frozen)
    isUnlocked
    isAllowed(get(addr).kind)
    external {
        // NOTE: Not bounds checking `index` here, as `isAllowed` ensures the address exists.
        //       Indices are one-based internally, so we need to add one to compensate.
        int256 oneBasedIndex = indices[addr];
        items[oneBasedIndex].frozen = frozen;
    }

    /**
     *  Sets the account's parent
     *  THROWS when the account doesn't exist or when the new parent would cause a cyclical lineage
     *  @param addr The address of the account
     *  @param parent The new parent of the account
     */
    function setAccountParent(address addr, address parent)
    isUnlocked
    isAllowed(get(addr).kind)
    external {
        // NOTE: Not bounds checking `index` here, as `isAllowed` ensures the address exists.
        //       Indices are one-based internally, so we need to add one to compensate.
        Account storage a = items[indices[addr]];
        a.parent = parent;
        (bool cyclical, address at) = hasCyclicalLineage(a);
        require(!cyclical, string(abi.encodePacked("Cyclical lineage at address: ", at.toString())));
    }

    /**
     *  Sets the account's hash
     *  THROWS when the account doesn't exist
     *  @dev Removes the current hash from `hashes` and adds a new entry, using the new hash, to `hashes`
     *  @param addr The address of the account
     *  @param hash The new hash of the account
     */
    function setAccountHash(address addr, bytes32 hash)
    isUnlocked
    isAllowed(get(addr).kind)
    external {
        // NOTE: Not bounds checking `index` here, as `isAllowed` ensures the address exists.
        //       Indices are one-based internally, so we need to add one to compensate.
        Account storage a = items[indices[addr]];
        hashes[a.hash].remove(addr);
        hashes[hash].append(addr);
        a.hash = hash;
    }

    /**
     *  Removes an account from storage
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     */
    function removeAccount(address addr)
    isUnlocked
    isAllowed(get(addr).kind)
    external {
        // Remove data
        bytes32 ZERO_BYTES = bytes32(0);
        mapping(uint8 => bytes32) storage accountData = data[addr];
        for (uint8 i = 0; i < MAX_DATA; i++) {
            if (accountData[i] != ZERO_BYTES) {
                delete accountData[i];
            }
        }

        // Remove hash
        int256 oneBasedIndex = indices[addr];
        bytes32 h = items[oneBasedIndex].hash;
        hashes[h].remove(addr);

        // Remove account
        //   When the item being removed is not the last item in the collection,
        //   replace that item with the last one, otherwise zero it out.
        //
        //    If {2} is the item to be removed
        //       [0, 1, 2, 3, 4]
        //    The result would be:
        //       [0, 1, 4, 3]
        //
        if (oneBasedIndex < accounts) {
            // Replace with last item
            Account storage last = items[accounts];  // Get the last item
            indices[last.addr] = oneBasedIndex;      // Update last items index to current index
            items[oneBasedIndex] = last;             // Update current index to last item
            delete items[accounts];                  // Delete the last item, since it's moved
        } else {
            // Delete the account
            delete items[oneBasedIndex];
        }

        delete indices[addr];
        accounts--;
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
    isAllowed(get(addr).kind)
    external {
        require(index < MAX_DATA, "index outside of bounds");
        data[addr][index] = customData;
    }

    /**
     *  Adds/Removes permissions for the given address
     *  THROWS when the permissions can't be granted/revoked
     *  @param kind The kind of the permissions to grant
     *  @param addr The address to add/remove permissions for
     *  @param grant If permissions are being granted or revoked
     */
    function setPermission(uint8 kind, address addr, bool grant)
    isUnlocked
    isAllowed(kind)
    external {
        if (grant) {
            require(permissions[kind].append(addr), "Address already has permission");
        } else {
            require(permissions[kind].remove(addr), "Address permission don't exist");
        }
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
    returns(address, uint8, bool, address, bytes32) {
        require(index >= 0 && index < accounts, "Index outside of bounds");
        Account memory a = items[index + 1];
        return (a.addr, a.kind, a.frozen, a.parent, a.hash);
    }

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
    returns(address, uint8, bool, address, bytes32) {
        Account memory a = get(hashes[hash].at(index));
        return (a.addr, a.kind, a.frozen, a.parent, a.hash);
    }

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
    returns(address) {
        return hashes[hash].at(index);
    }

    /**
     *  Gets the account for the given address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the item to retrieve
     *  @return The address, kind, frozen status, parent, and hash of the account at the given index
     */
    function accountGet(address addr)
    external
    view
    returns(uint8, bool, address, bytes32) {
        Account memory a = get(addr);
        return (a.kind, a.frozen, a.parent, a.hash);
    }

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
    returns(bytes32) {
        return get(addr).hash;
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
        return get(addr).parent;
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
        return get(addr).kind;
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
        return get(addr).frozen;
    }

    /**
     *  Gets the kind and frozen status of the account
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind and frozen status of the account
     */
    function accountKindAndFrozen(address addr)
    external
    view
    returns(uint8, bool) {
        Account memory a = get(addr);
        return (a.kind, a.frozen);
    }

    /**
     *  Returns the kind of the addr and the first lineage address that's frozen, or itself when frozen.
     *  THROWS when the account doesn't exist
     *  @dev It IS required to check ancestral existence, as this function doesn't use `lineageCount(address)`
     *  @param addr The address of the account
     *  @return The kind of the addr and whether any account in its lineage is frozen, or blocked by the callback
     */
    function accountKindAndFrozenAddress(address addr)
    external
    view
    returns(uint8, address) {
        int256 oneBasedIndex = indices[addr];
        require(oneBasedIndex > 0 && oneBasedIndex <= accounts, "Account doesn't exist");

        Account memory a = items[oneBasedIndex];
        if (a.frozen) {
            return (a.kind, a.addr);
        }

        uint8 kind = a.kind;
        address frozen;
        while(a.parent != ZERO_ADDRESS) {
            oneBasedIndex = indices[a.parent];
            if (oneBasedIndex < 1 || oneBasedIndex > accounts) {
                break;  // Parent doesn't exist
            }
            a = items[oneBasedIndex];
            if (a.frozen) {
                frozen = a.addr;
                break;
            }
        }
        return (kind, frozen);
    }

    /**
     *  Returns the kind of the addr, the first frozen address within the lineage, or the addr when it's frozen, and
     *  an array of lineage addresses.
     *  THROWS when the account doesn't exist
     *  @dev It IS NOT required to check ancestral existence, as this is taken care of within `lineageCount(address)`
     *  @param addr The address to get the kind, frozen address, and lineage for
     *  @return The kind of the addr, frozen address, lineage addresses
     */
    function accountKindAndFrozenAddressLineage(address addr)
    external
    view
    returns(uint8, address, address[] memory) {
        uint256 count = lineageCount(addr);
        address[] memory lineage = new address[](count);
        Account memory a = items[indices[addr]];
        uint8 kind = a.kind;
        address frozen;

        if (a.frozen) {
            frozen = a.addr;
        }
        for (uint256 i = 0; i < count; i++) {
            a = items[indices[a.parent]];
            lineage[i] = a.addr;
            // Set to the first frozen address
            if (a.frozen && frozen == ZERO_ADDRESS) {
                frozen = a.addr;
            }
        }
        return (kind, frozen, lineage);
    }

    /**
     *  Returns the lineage addresses of the addr
     *  THROWS when the account doesn't exist
     *  @dev It IS NOT required to check ancestral existence, as this is taken care of within `lineageCount(address)`
     *  @param addr The address to retrieve the lineage for
     *  @return The lineage of the given addr
     */
    function accountLineage(address addr)
    external
    view
    returns(address[] memory) {
        uint256 count = lineageCount(addr);
        address[] memory lineage = new address[](count);
        Account memory a = items[indices[addr]];
        for (uint256 i = 0; i < count; i++) {
            a = items[indices[a.parent]];
            lineage[i] = a.addr;
        }
        return lineage;
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
        if (addr == ZERO_ADDRESS) {
            return -1;
        }

        int256 index = indices[addr] - 1;
        if (index < 0 || index >= accounts) {
            return -1;
        }
        return index;
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
        int256 oneBasedIndex = indices[addr];
        return oneBasedIndex > 0 && oneBasedIndex <= accounts;
    }

    /**
     *  Returns whether or not the given address exists for the given kind
     *  @param addr The account address
     *  @param kind The kind of address
     *  @return If the given address exists with the given kind
     */
    function accountKindExists(address addr, uint8 kind)
    external
    view
    returns(bool) {
        int256 oneBasedIndex = indices[addr];
        if (oneBasedIndex < 1 || oneBasedIndex > accounts) {
            return false;
        }
        return items[oneBasedIndex].kind == kind;
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

    // -------------------------------------------------------------------------

    /**
     *  Returns the lineage addresses of all the addresses
     *  THROWS when any account doesn't exist
     *  @dev Only contains existant ancestors, stopping at the first non-existent account
     *  @param addresses The addresses to retrieve the lineage for
     *  @return The lineage of the given addresses
     */
    function accountLineage(address[] memory addresses)
    public
    view
    returns(address[] memory) {
        // Get the total lineage count for all addresses
        uint256 count;
        for (uint256 i = 0; i < addresses.length; i++) {
            count += lineageCount(addresses[i]);
        }

        // Get each lineage address for all addresses
        address[] memory lineage = new address[](count);
        uint256 i = 0;
        for (uint256 j = 0; j < addresses.length; j++) {
            Account memory a = items[indices[addresses[j]]];
            int256 oneBasedIndex = indices[a.parent];
            while (oneBasedIndex > 0 && oneBasedIndex <= accounts) {
                a = items[oneBasedIndex];
                lineage[i++] = a.addr;
                oneBasedIndex = indices[a.parent];
            }
        }
        return lineage;
    }

    /**
     *  Gets the number of ancestors of the given addr
     *  THROWS when the account doesn't exist
     *  @dev Only counts existant ancestors, stopping at the first non-existent account
     *  @param addr The address to retrieve ancestry count for
     *  @return The number of ancestry addresses
     */
    function lineageCount(address addr)
    public
    view
    returns(uint256) {
        int256 oneBasedIndex = indices[addr];
        require(oneBasedIndex > 0 && oneBasedIndex <= accounts, "Account doesn't exist");

        uint256 count;
        Account memory a = items[oneBasedIndex];
        while(a.parent != ZERO_ADDRESS) {
            oneBasedIndex = indices[a.parent];
            if (oneBasedIndex < 1 || oneBasedIndex > accounts) {
                break;  // Parent doesn't exist
            }
            a = items[oneBasedIndex];
            count++;
        }
        return count;
    }

    /**
     *  Gets the account for the given address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function get(address addr)
    internal
    view
    returns(Account memory) {
        int256 oneBasedIndex = indices[addr];
        require(oneBasedIndex > 0 && oneBasedIndex <= accounts, "Account doesn't exist");
        return items[oneBasedIndex];
    }

    /**
     *  Checks if the given account has a cyclical kind lineage
     *  @param account The account to check lineage for
     *  @return If the lineage is non-cyclical
     */
    function hasCyclicalLineage(Account memory account)
    internal
    view
    returns (bool, address) {
        // Account can't be its parent
        if (account.addr == account.parent) {
            return (true, account.parent);
        }
        // Ensure lineage kind uniqueness
        uint256 lineage;
        Account memory a = account;
        while(a.parent != ZERO_ADDRESS) {
            int256 oneBasedIndex = indices[a.parent];
            if (oneBasedIndex < 1 || oneBasedIndex > accounts) {
                break;
            }
            uint256 l = lineage | (1 << uint256(a.kind));
            if (lineage == l) {
                return (true, a.parent);
            }
            lineage = l;
            a = items[oneBasedIndex]; 
        }
        return (false, ZERO_ADDRESS);
    }

}
