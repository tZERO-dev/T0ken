pragma solidity >=0.5.0 <0.6.0;


import 'tzero/libs/lifecycle/LockableDestroyable.sol';
import 'tzero/registry/custodian/ICustodianRegistry.sol';
import 'tzero/registry/Storage.sol';


/**
 *  @title Custodian Registry
 *
 */
contract CustodianRegistry is ICustodianRegistry, LockableDestroyable {
    Storage public store;

    uint8 constant private CUSTODIAN = 1; // Storage, custodian kind

    // ------------------------------- Modifiers -------------------------------
    modifier isAllowed() {
        require(store.permissionExists(CUSTODIAN, msg.sender), "Missing permission");
        _;
    }

    // -------------------------------------------------------------------------
    /**
     *  Sets the storage contract address
     *  @param s The Storage contract to use
     */
    function setStorage(Storage s)
    onlyOwner
    external {
        store = s;
    }

    /**
     *  Adds a custodian to the registry
     *  Upon successful addition, the contract must emit `CustodianAdded(custodian)`
     *  THROWS if the address has already been added, or is zero
     *  @param custodian The address of the custodian
     */
    function add(address custodian)
    isAllowed
    external {
        store.addAccount(custodian, CUSTODIAN, false, msg.sender);

        emit CustodianAdded(custodian, msg.sender);
    }

    /**
     *  Removes a custodian from the registry
     *  Upon successful removal, the contract must emit `CustodianRemoved(custodian)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param custodian The address of the custodian
     */
    function remove(address custodian)
    isAllowed
    external {
        store.removeAccount(custodian);

        emit CustodianRemoved(custodian, msg.sender);
    }

    /**
     *  Sets whether or not a custodian is frozen
     *  Upon status change, the contract must emit `CustodianFrozen(custodian, frozen, owner)`
     *  @param custodian The custodian address that is being updated
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address custodian, bool frozen)
    isAllowed
    external {
        store.setAccountFrozen(custodian, frozen);

        emit CustodianFrozen(custodian, frozen, msg.sender);
    }

}
