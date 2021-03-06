pragma solidity >=0.5.0 <0.6.0;


import '../../libs/lifecycle/LockableDestroyable.sol';
import '../../libs/registry/InvestorData.sol';
import '../Registry.sol';
import './IInvestorRegistry.sol';


/**
 *  @title Investor Registry
 *
 */
contract InvestorRegistry is IInvestorRegistry, LockableDestroyable {
    using InvestorData for IRegistry;

    IRegistry public registry;

    uint8 constant private BROKER_DEALER = 3; // Registry, broker-dealer kind
    uint8 constant private INVESTOR = 4;      // Registry, investor kind

    
    // ------------------------------- Modifiers -------------------------------
    modifier onlyBrokerDealer() {
        require(registry.accountKindExists(msg.sender, BROKER_DEALER), "Broker-dealer required");
        require(!registry.accountFrozen(msg.sender), "Broker-dealer is frozen");
        require(!registry.accountFrozen(registry.accountParent(msg.sender)), "Custodian is frozen");
        _;
    }

    modifier onlyInvestorsBrokerDealer(address investor) {
        require(registry.accountKindExists(msg.sender, BROKER_DEALER), "Broker-Dealer required");
        require(msg.sender == registry.accountParent(investor), "Investor's broker-dealer required");
        require(!registry.accountFrozen(msg.sender), "Broker-dealer is frozen");
        require(!registry.accountFrozen(registry.accountParent(msg.sender)), "Custodian is frozen");
        _;
    }

    modifier onlyInvestorsBrokerDealerOrCustodian(address investor) {
        address broker = registry.accountParent(investor);
        address custodian = registry.accountParent(broker);

        require(msg.sender == broker || msg.sender == custodian, "Broker-Dealer or Custodian required");
        require(!registry.accountFrozen(custodian), "Custodian is frozen");
        if (msg.sender == broker) {
            require(!registry.accountFrozen(broker), "Broker-Dealer is frozen");
        }
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
     *  Adds a verified investor to the registry
     *  Upon successful addition, the contract must emit `InvestorAdded(investor, brokerDealer)`
     *  THROWS if the address has already been added, or is zero
     *  @param investor The address of the investor
     *  @param hash The PII hash of the investor
     *  @param country The country of the investor
     *  @param accreditation The accreditation date of the investor
     */
    function add(address investor, bytes32 hash, bytes2 country, uint48 accreditation)
    onlyBrokerDealer
    external {
        registry.addAccount(investor, INVESTOR, false, msg.sender, hash);
        registry.setData(investor, accreditation, country);

        emit InvestorAdded(investor, msg.sender);
    }

    /**
     *  Removes an investor from the registry
     *  Upon successful removal, the contract must emit `InvestorRemoved(investor, brokerDealer)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     */
    function remove(address investor)
    onlyInvestorsBrokerDealer(investor)
    external {
        registry.removeAccount(investor);
        emit InvestorRemoved(investor, msg.sender);
    }

    /**
     *  Sets an investor's PII hash
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param hash The PII hash of the investor
     */
    function setHash(address investor, bytes32 hash)
    onlyInvestorsBrokerDealer(investor)
    external {
        registry.setAccountHash(investor, hash);
        emit InvestorUpdated(investor, msg.sender);
    }

    /**
     *  Sets an investor's accreditation date
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param accreditation The date of accreditation
     */
    function setAccreditation(address investor, uint48 accreditation)
    onlyInvestorsBrokerDealer(investor)
    external {
        registry.setAccreditation(investor, accreditation);
        emit InvestorUpdated(investor, msg.sender);
    }

    /**
     *  Sets an investor's country
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param country The investor's 2 character country code
     */
    function setCountry(address investor, bytes2 country)
    onlyInvestorsBrokerDealer(investor)
    external {
        registry.setCountry(investor, country);
        emit InvestorUpdated(investor, msg.sender);
    }

    /**
     *  Sets whether or not an investor is frozen
     *  Upon status change, the contract must emit `InvestorFrozen(investor, frozen, custodian)`
     *  @param investor The investor address that is being updated
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address investor, bool frozen)
    onlyInvestorsBrokerDealerOrCustodian(investor)
    external {
        registry.setAccountFrozen(investor, frozen);
        emit InvestorFrozen(investor, frozen, msg.sender);
    }

    // -------------------------------- Getters --------------------------------

    /**
     *  Returns the given investor hash
     *  @param investor The investor address to check status of
     *  @return PII has of investor
     */
    function getHash(address investor)
    external
    view
    returns(bytes32) {
        return registry.accountHash(investor);
    }

    /**
     *  Returns the given investor's accreditation epoch date
     *  @param investor The investor address to check status of
     *  @return Accreditation expiration epoch of investor
     */
    function getAccreditation(address investor)
    external
    view
    returns(uint48) {
        return registry.accreditation(investor);
    }

    /**
     *  Returns the given investor's country code
     *  @param investor The investor address to check status of
     *  @return Country code of investor
     */
    function getCountry(address investor)
    external
    view
    returns(bytes2) {
        return registry.country(investor);
    }

}
