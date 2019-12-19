pragma solidity >=0.5.0 <0.6.0;


import '../../libs/lifecycle/LockableDestroyable.sol';
import '../IRegistry.sol';
import './IBrokerDealerRegistry.sol';


/**
 *  @title BrokerDealer Registry
 *
 */
contract BrokerDealerRegistry is IBrokerDealerRegistry, LockableDestroyable {
    IRegistry public registry;

    uint8 constant private CUSTODIAN = 1;         // Registry, custodian kind
    uint8 constant private CUSTODIAL_ACCOUNT = 2; // Registry, custodian kind
    uint8 constant private BROKER_DEALER = 3;     // Registry, broker-dealer kind

    // ------------------------------- Modifiers -------------------------------
    modifier onlyCustodian() {
        require(registry.accountKindExists(msg.sender, CUSTODIAN), "Custodian address required");
        require(!registry.accountFrozen(msg.sender), "Custodian is frozen");
        _;
    }

    modifier onlyNewAccount(address account) {
        require(!registry.accountExists(account), "Account already exists");
        _;
    }

    modifier onlyBrokerDealersCustodian(address brokerDealer) {
        require(registry.accountKindExists(msg.sender, CUSTODIAN), "Custodian required");
        require(msg.sender == registry.accountParent(brokerDealer), "Broker-Dealer's custodian required");
        require(!registry.accountFrozen(msg.sender), "Custodian is frozen");
        _;
    }

    modifier onlyAccountsCustodian(address account) {
        require(registry.accountKindExists(account, CUSTODIAL_ACCOUNT), "Not a custodial account");
        address broker = registry.accountParent(account);
        require(msg.sender == registry.accountParent(broker), "Account's custodian requried");
        require(!registry.accountFrozen(msg.sender), "Custodian is frozen");
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
     *  Adds a brokerDealer to the registry
     *  Upon successful addition, the contract must emit `BrokerDealerAdded(brokerDealer)`
     *  THROWS if the address has already been added, or is zero
     *  @param brokerDealer The address of the broker-dealer
     *  @param hash The hash that uniquely identifies the broker
     */
    function add(address brokerDealer, bytes32 hash)
    onlyCustodian
    external {
        registry.addAccount(brokerDealer, BROKER_DEALER, false, msg.sender, hash);

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
        registry.removeAccount(brokerDealer);

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
        bytes32 hash = registry.accountHash(brokerDealer);
        registry.addAccount(account, CUSTODIAL_ACCOUNT, false, brokerDealer, hash);
    }

    /**
     *  Removes the account, along with destination, from the broker-dealer
     *  @param account The account to remove
     */
    function removeAccount(address account)
    onlyAccountsCustodian(account)
    external {
        registry.removeAccount(account);
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
        registry.setAccountFrozen(brokerDealer, frozen);

        emit BrokerDealerFrozen(brokerDealer, frozen, msg.sender);
    }

}
