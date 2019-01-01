pragma solidity >=0.5.0 <0.6.0;


/**
 *
 *  @title AddressMap
 *  @dev Map of unique indexed addresseses.
 *
 *  **NOTE**
 *    The internal collections are one-based.
 *    This is simply because null values are expressed as zero,
 *    which makes it hard to check for the existence of items within the array,
 *    or grabbing the first item of an array for non-existent items.
 *
 *    This is only exposed internally, so callers still use zero-based indices.
 *
 */
library AddressMap {
    struct Data {
        int256 count;
        mapping(address => int256) indices;
        mapping(int256 => address) items;
    }

    address constant ZERO_ADDRESS = address(0);

    /**
     *  Appends the address to the end of the map, if the address is not
     *  zero and the address doesn't currently exist.
     *  @param addr The address to append.
     *  @return true if the address was added.
     */
    function append(Data storage self, address addr)
    internal
    returns (bool) {
        if (addr == ZERO_ADDRESS) {
            return false;
        }

        int256 index = self.indices[addr] - 1;
        if (index >= 0 && index < self.count) {
            return false;
        }

        self.count++;
        self.indices[addr] = self.count;
        self.items[self.count] = addr;
        return true;
    }

    /**
     *  Removes the given address from the map.
     *  @param addr The address to remove from the map.
     *  @return true if the address was removed.
     */
    function remove(Data storage self, address addr)
    internal
    returns (bool) {
        int256 oneBasedIndex = self.indices[addr];
        if (oneBasedIndex < 1 || oneBasedIndex > self.count) {
            return false;  // address doesn't exist, or zero.
        }

        // When the item being removed is not the last item in the collection,
        // replace that item with the last one, otherwise zero it out.
        //
        //  If {2} is the item to be removed
        //     [0, 1, 2, 3, 4]
        //  The result would be:
        //     [0, 1, 4, 3]
        //
        if (oneBasedIndex < self.count) {
            // Replace with last item
            address last = self.items[self.count];  // Get the last item
            self.indices[last] = oneBasedIndex;     // Update last items index to current index
            self.items[oneBasedIndex] = last;       // Update current index to last item
            delete self.items[self.count];          // Delete the last item, since it's moved
        } else {
            // Delete the address
            delete self.items[oneBasedIndex];
        }

        delete self.indices[addr];
        self.count--;
        return true;
    }

    /**
     * Clears all items within the map.
     */
    function clear(Data storage self)
    internal {
        self.count = 0;
    }

    /**
     *  Retrieves the address at the given index.
     *  THROWS when the index is invalid.
     *  @param index The index of the item to retrieve.
     *  @return The address of the item at the given index.
     */
    function at(Data storage self, int256 index)
    internal
    view
    returns (address) {
        require(index >= 0 && index < self.count, "Index outside of bounds.");
        return self.items[index + 1];
    }

    /**
     *  Gets the index of the given address.
     *  @param addr The address of the item to get the index for.
     *  @return The index of the given address.
     */
    function indexOf(Data storage self, address addr)
    internal
    view
    returns (int256) {
        if (addr == ZERO_ADDRESS) {
            return -1;
        }

        int256 index = self.indices[addr] - 1;
        if (index < 0 || index >= self.count) {
            return -1;
        }
        return index;
    }

    /**
     *  Returns whether or not the given address exists within the map.
     *  @param addr The address to check for existence.
     *  @return If the given address exists or not.
     */
    function exists(Data storage self, address addr)
    internal
    view
    returns (bool) {
        int256 index = self.indices[addr] - 1;
        return index >= 0 && index < self.count;
    }

}
