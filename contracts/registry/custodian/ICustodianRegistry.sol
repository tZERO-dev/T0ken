pragma solidity >=0.5.0 <0.6.0;


import 'tzero/registry/Storage.sol';


/**
 *  @title Custodian Registry Interface
 */
interface ICustodianRegistry {

    /**
     *  This event is emitted when a custodian is added to the registry
     *  @param custodian The custodian that has been added
     *  @param owner The address that caused the custodian to be added
     */
    event CustodianAdded(
        address indexed custodian,
        address indexed owner
    );

    /**
     *  This event is emitted when a custodian is removed from the registry
     *  @param custodian The custodian that has been removed
     *  @param owner The address that caused the custodian to be removed
     */
    event CustodianRemoved(
        address indexed custodian,
        address indexed owner
    );

    /**
     *  This event is emitted when a custodian's frozen status has changed
     *  @param custodian The custodian whose forzen status has been updated
     *  @param frozen Whether the custodian is being frozen
     *  @param owner The address that updated the frozen status
     */
    event CustodianFrozen(
        address indexed custodian,
        bool indexed frozen,
        address indexed owner
    );

    /**
     *  Sets the storage contract address
     *  @param s The Storage contract to use
     */
    function setStorage(Storage s)
    external;

    /**
     *  Adds a custodian to the registry
     *  Upon successful addition, the contract must emit `CustodianAdded(custodian)`
     *  THROWS if the address has already been added, or is zero
     *  @param custodian The address of the custodian
     */
    function add(address custodian)
    external;

    /**
     *  Removes a custodian from the registry
     *  Upon successful removal, the contract must emit `CustodianRemoved(custodian)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param custodian The address of the custodian
     */
    function remove(address custodian)
    external;

    /**
     *  Sets whether or not a custodian is frozen
     *  Upon status change, the contract must emit `CustodianFrozen(custodian, frozen, owner)`
     *  @param custodian The custodian address that is being updated
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address custodian, bool frozen)
    external;

}
