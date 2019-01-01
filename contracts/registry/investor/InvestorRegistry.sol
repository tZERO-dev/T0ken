pragma solidity >=0.5.0 <0.6.0;


import 'tzero/libs/lifecycle/LockableDestroyable.sol';
import 'tzero/registry/investor/IInvestorRegistry.sol';
import 'tzero/registry/Storage.sol';


/**
 *  @title Investor Registry
 *
 */
contract InvestorRegistry is IInvestorRegistry, LockableDestroyable {
    Storage public store;

    uint8 constant private BROKER_DEALER = 3; // Storage, broker-dealer kind
    uint8 constant private INVESTOR = 4;      // Storage, investor kind
    uint8 constant private HASH_INDEX = 0;    // Storage, investor data index (PII hash)
    uint8 constant private DATA_INDEX = 1;    // Storage, investor data index (accreditation, etc.)

    uint256 constant private MASK_ACCR = uint256(0xffffffffffff)<<16;
    uint256 constant private MASK_CTRY = uint256(0xffff);

    /* Data[0] - PII Hash
     * ---------------------------------------
     * 0000 0000 0000 0000 0000 0000 0000 0000    32 256
     * 0000 0000 0000 0000 0000 0000 0000 0000    28 224
     * 0000 0000 0000 0000 0000 0000 0000 0000    24 192
     * 0000 0000 0000 0000 0000 0000 0000 0000    20 160
     * 0000 0000 0000 0000 0000 0000 0000 0000    16 128
     * 0000 0000 0000 0000 0000 0000 0000 0000    12  96
     * 0000 0000 0000 0000 0000 0000 0000 0000     8  64
     * 0000 0000 0000 0000 0000 0000 0000 0000     4  32
     */

    /* Data[1]
     * ---------------------------------------
     * 0000 0000 0000 0000 0000 0000 0000 0000    32 256
     * 0000 0000 0000 0000 0000 0000 0000 0000    28 224
     * 0000 0000 0000 0000 0000 0000 0000 0000    24 192
     * 0000 0000 0000 0000 0000 0000 0000 0000    20 160
     * 0000 0000 0000 0000 0000 0000 0000 0000    16 128
     * 0000 0000 0000 0000 0000 0000 0000 0000    12  96
     * 0000 0000 0000 0000 0000 0000 0000 0000     8  64   Accreditation  (48)
     * 0000 0000 0000 0000
     *                     0000 0000 0000 0000     2  16   Country        (16)
     */


    
    // ------------------------------- Modifiers -------------------------------
    modifier isInvestor(address addr) {
        require(store.accountExists(addr, INVESTOR), "Investor doesn't exist");
        _;
    }

    modifier onlyBrokerDealer() {
        require(store.accountExists(msg.sender, BROKER_DEALER));
        require(!store.accountFrozen(msg.sender), "Broker-dealer is frozen");
        require(!store.accountFrozen(store.accountParent(msg.sender)), "Custodian is frozen");
        _;
    }

    modifier onlyInvestorsBrokerDealer(address investor) {
        require(store.accountExists(msg.sender, BROKER_DEALER), "Broker-Dealer required");
        require(msg.sender == store.accountParent(investor), "Investor's broker-dealer required");
        require(!store.accountFrozen(msg.sender), "Broker-dealer is frozen");
        require(!store.accountFrozen(store.accountParent(msg.sender)), "Custodian is frozen");
        _;
    }

    modifier onlyInvestorsBrokerDealerOrCustodian(address investor) {
        address broker = store.accountParent(investor);
        address custodian = store.accountParent(broker);

        require(msg.sender == broker || msg.sender == custodian, "Broker-Dealer or Custodian required");
        require(!store.accountFrozen(custodian), "Custodian is frozen");
        if (msg.sender == broker) {
            require(!store.accountFrozen(broker), "Broker-Dealer is frozen");
        }
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
        uint256 data = uint256(uint16(country));
        data |= uint256(accreditation)<<16;

        store.addAccount(investor, INVESTOR, false, msg.sender);
        store.setAccountData(investor, HASH_INDEX, hash);
        store.setAccountData(investor, DATA_INDEX, bytes32(data));

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
        store.removeAccount(investor);

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
        store.setAccountData(investor, HASH_INDEX, hash);
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
        uint256 data = uint256(store.data(investor, DATA_INDEX));
        data = updatedData(data, uint256(accreditation), MASK_ACCR, 16);
        store.setAccountData(investor, DATA_INDEX, bytes32(data));
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
        uint256 data = uint256(store.data(investor, DATA_INDEX));
        data = updatedData(data, uint256(uint16(country)), MASK_CTRY, 0);
        store.setAccountData(investor, DATA_INDEX, bytes32(data));
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
        store.setAccountFrozen(investor, frozen);

        emit InvestorFrozen(investor, frozen, msg.sender);
    }

    // -------------------------------- Getters --------------------------------

    /**
     *  Returns the given investor hash
     *  @param addr The investor address to check status of
     *  @return PII has of investor
     */
    function getHash(address addr)
    external
    view
    returns(bytes32) {
        return store.data(addr, HASH_INDEX);
    }

    /**
     *  Returns the given investor's accreditation epoch date
     *  @param addr The investor address to check status of
     *  @return Accreditation expiration epoch of investor
     */
    function getAccreditation(address addr)
    external
    view
    returns(uint48) {
        uint256 data = uint256(store.data(addr, DATA_INDEX));
        return uint48(data>>16);
    }

    /**
     *  Returns the given investor's country code
     *  @param addr The investor address to check status of
     *  @return Country code of investor
     */
    function getCountry(address addr)
    external
    view
    returns(bytes2) {
        return bytes2(uint16(uint256(store.data(addr, DATA_INDEX))));
    }

    // -------------------------------------------------------------------------

    function updatedData(uint256 data, uint256 value, uint256 mask, uint8 shift)
    private
    pure
    returns (uint256){
        return (data & ~mask) | (value<<shift & mask);
    }

}
