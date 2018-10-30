pragma solidity >=0.4.24 <0.5.0;


import '../Storage.sol';


/**
 *  @title Investor Registry Interface
 */
interface IInvestorRegistry {

    /**
     *  This event is emitted when a investor is added to the registry
     *  @param investor The investor that has been added.
     *  @param owner The address that caused the investor to be added
     */
    event InvestorAdded(
        address indexed investor,
        address indexed owner
    );

    /**
     *  This event is emitted when a investor is removed from the registry
     *  @param investor The investor that has been removed
     *  @param owner The address that caused the investor to be removed
     */
    event InvestorRemoved(
        address indexed investor,
        address indexed owner
    );

    /**
     *  This event is emitted when a investor's frozen status has changed
     *  @param investor The investor whose forzen status has been updated
     *  @param frozen Whether the investor is being frozen
     *  @param owner The address that updated the frozen status
     */
    event InvestorFrozen(
        address indexed investor,
        bool indexed frozen,
        address indexed owner
    );

    /**
     *  Returns the given investor hash
     *  @param investor The investor address to check status of
     *  @return PII has of investor
     */
    function getHash(address investor)
    external
    view
    returns(bytes32);

    /**
     *  Returns the given investor's accreditation epoch date
     *  @param investor The investor address to check status of
     *  @return Accreditation expiration epoch of investor
     */
    function getAccreditation(address investor)
    external
    view
    returns(uint48);

    /**
     *  Returns the given investor's country code
     *  @param investor The investor address to check status of
     *  @return Country code of investor
     */
    function getCountry(address investor)
    external
    view
    returns(bytes2);

    /**
     *  Sets the storage contract address
     *  @param s The Storage contract to use
     */
    function setStorage(Storage s)
    external;

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
    external;

    /**
     *  Removes an investor from the registry
     *  Upon successful removal, the contract must emit `InvestorRemoved(investor, brokerDealer)`
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     */
    function remove(address investor)
    external;

    /**
     *  Sets an investor's PII hash
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param hash The PII hash of the investor
     */
    function setHash(address investor, bytes32 hash)
    external;

    /**
     *  Sets an investor's accreditation date
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param accreditation The date of accreditation
     */
    function setAccreditation(address investor, uint48 accreditation)
    external;

    /**
     *  Sets an investor's country
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param country The investor's 2 character country code
     */
    function setCountry(address investor, bytes2 country)
    external;

    /**
     *  Sets whether or not an investor is frozen
     *  Upon status change, the contract must emit `InvestorFrozen(investor, frozen, custodian)`
     *  @param investor The investor address that is being updated
     *  @param frozen Whether or not the custodian is frozen
     */
    function setFrozen(address investor, bool frozen)
    external;

}
