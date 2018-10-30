pragma solidity >=0.4.24 <0.5.0;


import '../Storage.sol';


/**
 *  @title BrokerDealer Registry Interface
 */
interface IBrokerDealerRegistry {

    /**
     *  This event is emitted when a brokerDealer is added to the registry
     *  @param brokerDealer The brokerDealer that has been added
     *  @param owner The address that caused the brokerDealer to be added
     */
    event BrokerDealerAdded(
        address indexed brokerDealer,
        address indexed owner
    );

    /**
     *  This event is emitted when a brokerDealer is removed from the registry
     *  @param brokerDealer The brokerDealer that has been removed
     *  @param owner The address that caused the brokerDealer to be removed
     */
    event BrokerDealerRemoved(
        address indexed brokerDealer,
        address indexed owner
    );

    /**
     *  Sets whether or not an broker-dealer is frozen
     *  Upon status change, the contract must emit `BrokerDealerFrozen(brokerDealer, frozen, custodian)`
     *  @param brokerDealer The broker-dealer address that is being frozen
     *  @param frozen Whether or not the custodian is frozen
     */
    event BrokerDealerFrozen(
        address indexed brokerDealer,
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
     *  Adds a brokerDealer to the registry
     *  Upon successful addition, the contract must emit `BrokerDealerAdded(brokerDealer)`
     *  THROWS if the address has already been added, or is zero
     *  @param brokerDealer The address of the broker-dealer
     */
    function add(address brokerDealer)
    external;

    /**
     *  Removes a brokerDealer from the registry
     *  Upon successful removal, the contract must emit `BrokerDealerRemoved(brokerDealer)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param brokerDealer The address of the broker-dealer
     */
    function remove(address brokerDealer)
    external;

    /**
     *  Adds an account for the broker-dealer, using the account as the destination address
     *  @param brokerDealer The broker-dealer to add the account for
     *  @param account The account, and destination, to add for the broker-dealer
     */
    function addAccount(address brokerDealer, address account)
    external;

    /**
     *  Removes the account, along with destination, from the broker-dealer
     *  param brokerDealer The broker-dealer to add the account for
     *  @param account The account to remove
     */
    function removeAccount(address account)
    external;

    /**
     *  Sets whether or not an broker-dealer is frozen
     *  Upon status change, the contract must emit `BrokerDealerFrozen(brokerDealer, frozen, custodian)`
     *  @param brokerDealer The broker-dealer address that is being frozen
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address brokerDealer, bool frozen)
    external;

}
