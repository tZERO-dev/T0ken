pragma solidity >=0.5.0 <0.6.0;


import '../../libs/lifecycle/LockableDestroyable.sol';
import '../../libs/ownership/Administrable.sol';
import '../../libs/registry/InvestorData.sol';
import '../IRegistry.sol';
import './IInvestorRegistry.sol';


/**
 *  @title External Investor Registry
 *
 */
contract ExternalInvestorRegistry is IInvestorRegistry, Administrable, LockableDestroyable {
    using InvestorData for IRegistry;

    IRegistry public registry;

    uint8 constant private EXTERNAL_INVESTOR = 5;  // Registry, external investor kind
    address constant private ZERO_ADDRESS = address(0);


    // -------------------------------------------------------------------------

    constructor(IRegistry r)
    public {
        registry = r;
    }

    /**
     *  Sets the registry contract address
     *  @param r The Registry contract to use
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
    onlyAdmins
    external {
        registry.addAccount(investor, EXTERNAL_INVESTOR, false, msg.sender, hash);
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
    onlyAdmins
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
    onlyAdmins
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
    onlyAdmins
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
    onlyAdmins
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
    onlyAdmins
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
