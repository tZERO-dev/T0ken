pragma solidity >=0.5.0 <0.6.0;


import 'tzero/libs/lifecycle/LockableDestroyable.sol';
import 'tzero/registry/brokerDealer/IBrokerDealerRegistry.sol';
import 'tzero/registry/Storage.sol';


/**
 *  @title BrokerDealer Registry
 *
 */
contract BrokerDealerRegistry is IBrokerDealerRegistry, LockableDestroyable {
    Storage public store;

    uint8 constant private CUSTODIAN = 1;         // Storage, custodian kind
    uint8 constant private CUSTODIAL_ACCOUNT = 2; // Storage, custodian kind
    uint8 constant private BROKER_DEALER = 3;     // Storage, broker-dealer kind

    // ------------------------------- Modifiers -------------------------------
    modifier onlyCustodian() {
        require(store.accountExists(msg.sender, CUSTODIAN), "Custodian address required");
        require(!store.accountFrozen(msg.sender), "Custodian is frozen");
        _;
    }

    modifier onlyNewAccount(address account) {
        require(!store.accountExists(account), "Account already exists");
        _;
    }

    modifier onlyBrokerDealersCustodian(address brokerDealer) {
        require(store.accountExists(msg.sender, CUSTODIAN), "Custodian required");
        require(msg.sender == store.accountParent(brokerDealer), "Broker-Dealer's custodian required");
        require(!store.accountFrozen(msg.sender), "Custodian is frozen");
        _;
    }

    modifier onlyAccountsCustodian(address account) {
        require(store.accountExists(account, CUSTODIAL_ACCOUNT), "Not a custodial account");
        address broker = store.accountParent(account);
        require(msg.sender == store.accountParent(broker), "Account's custodian requried");
        require(!store.accountFrozen(msg.sender), "Custodian is frozen");
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
     *  Adds a brokerDealer to the registry
     *  Upon successful addition, the contract must emit `BrokerDealerAdded(brokerDealer)`
     *  THROWS if the address has already been added, or is zero
     *  @param brokerDealer The address of the broker-dealer
     */
    function add(address brokerDealer)
    onlyCustodian
    external {
        store.addAccount(brokerDealer, BROKER_DEALER, false, msg.sender);

        emit BrokerDealerAdded(brokerDealer, msg.sender);
    }

    /**
     *  Removes a brokerDealer from the registry
     *  Upon successful removal, the contract must emit `BrokerDealerRemoved(brokerDealer)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param brokerDealer The address of the broker-dealer
     */
    function remove(address brokerDealer)
    onlyBrokerDealersCustodian(brokerDealer)
    external {
        store.removeAccount(brokerDealer);

        emit BrokerDealerRemoved(brokerDealer, msg.sender);
    }

    /**
     *  Adds an account for the broker-dealer, using the account as the destination address
     *  @param brokerDealer The broker-dealer to add the account for
     *  @param account The account, and destination, to add for the broker-dealer
     */
    function addAccount(address brokerDealer, address account)
    onlyNewAccount(account)
    onlyBrokerDealersCustodian(brokerDealer)
    external {
        store.addAccount(account, CUSTODIAL_ACCOUNT, false, brokerDealer);
    }

    /**
     *  Removes the account, along with destination, from the broker-dealer
     *  @param account The account to remove
     */
    function removeAccount(address account)
    onlyAccountsCustodian(account)
    external {
        store.removeAccount(account);
    }

    /**
     *  Sets whether or not an broker-dealer is frozen
     *  Upon status change, the contract must emit `BrokerDealerFrozen(brokerDealer, frozen, custodian)`
     *  @param brokerDealer The broker-dealer address that is being frozen
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address brokerDealer, bool frozen)
    onlyBrokerDealersCustodian(brokerDealer)
    external {
        store.setAccountFrozen(brokerDealer, true);

        emit BrokerDealerFrozen(brokerDealer, frozen, msg.sender);
    }

}
