pragma solidity >=0.5.0 <0.6.0;


import "../collections/AddressMap.sol";
import "./Ownable.sol";


/**
 *  @title Administrable
 *  @dev Provides a modifier that requires the caller to be the owner or an admin of the contract.
 */
contract Administrable is Ownable {

    using AddressMap for AddressMap.Data;
    AddressMap.Data public admins;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);


    modifier onlyAdmins {
        require(msg.sender == owner || admins.exists(msg.sender), "Admin account is required");
        _;
    }


    /**
     * Returns if the address is an admin.
     * @param addr The address to check.
     * @return Whether or not the address is an admin.
     */
    function isAdmin(address addr)
    public
    view
    returns(bool) {
        return addr == owner || admins.exists(addr);
    }

    /**
     *  Retrieves the admin at the given index.
     *  THROWS when the index is invalid.
     *  @param index The index of the item to retrieve.
     *  @return The admin address of the item at the given index.
     */
    function adminAt(int256 index)
    public
    view
    returns (address) {
        return admins.at(index);
    }

    /**
     *  Adds/Removes the addr as an admin
     *  @param addr The admin address to add/remove
     *  @param add Whether the address should be added/removed
     */
    function setAdmin(address addr, bool add)
    public
    onlyOwner {
        if (add) {
            require(admins.append(addr), "Unable to add admin");
            emit AdminAdded(addr);
        } else {
            require(admins.remove(addr), "Unable to remove admin");
            emit AdminRemoved(addr);
        }
    }

}
