pragma solidity >=0.5.0 <0.6.0;


import '../../libs/lifecycle/LockableDestroyable.sol';
import '../IRegistry.sol';
import './ICustodianRegistry.sol';


/**
 *  @title Custodian Registry
 *
 */
contract CustodianRegistry is ICustodianRegistry, LockableDestroyable {
    IRegistry public registry;

    uint8 constant private CUSTODIAN = 1; // Registry, custodian kind

    // ------------------------------- Modifiers -------------------------------
    modifier isAllowed() {
        require(registry.permissionExists(CUSTODIAN, msg.sender), "Missing permission");
        _;
    }

    // -------------------------------------------------------------------------

    constructor(IRegistry r)
    public {
        registry = r;
    }

    /**
     *  Sets the registry contract address
     *  @param r The registry contract to use
     */
    function setRegistry(IRegistry r)
    onlyOwner
    external {
        registry = r;
    }

    /**
     *  Adds a custodian to the registry
     *  Upon successful addition, the contract must emit `CustodianAdded(custodian)`
     *  THROWS if the address has already been added, or is zero
     *  @param custodian The address of the custodian
     *  @param hash The hash that uniquely identifies the broker
     */
    function add(address custodian, bytes32 hash)
    isAllowed
    external {
        registry.addAccount(custodian, CUSTODIAN, false, address(0), hash);

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
        registry.removeAccount(custodian);

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
        registry.setAccountFrozen(custodian, frozen);

        emit CustodianFrozen(custodian, frozen, msg.sender);
    }

}
