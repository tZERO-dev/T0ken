pragma solidity >=0.5.0 <0.6.0;


import "tzero/libs/collections/AddressMap.sol";
import "tzero/libs/ownership/Ownable.sol";


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
     * @dev Returns if the address is an admin.
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
     * @dev Adds address to list of admins.
     * @param admin The address to add.
     */
    function addAdmin(address admin)
    public
    onlyOwner {
        require(admins.append(admin), "Unable to add admin");
        emit AdminAdded(admin);
    }

    /**
     * @dev Removes address from list of admins.
     * @param admin The address to remove.
     */
    function removeAdmin(address admin)
    public
    onlyOwner {
        require(admins.remove(admin), "Unable to remove admin");
        emit AdminRemoved(admin);
    }
}
