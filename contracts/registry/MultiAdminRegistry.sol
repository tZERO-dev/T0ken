pragma solidity >=0.5.0 <0.6.0;


import '../libs/lifecycle/Cloneable.sol';
import '../libs/ownership/MultiAdministrable.sol';


/**
 *  @title MultiAdminRegistry
 *  @dev Multi-admin registry that allows admins to invoke functions of the backing registry by utilizing the
 *       contract's registry permissions. Also allows this contract to be cloned with a deterministic address.
 *       During cloning, new admins will be set and the clone's registry will be set to match this contract's registry.
 */
contract MultiAdminRegistry is MultiAdministrable, CloneableDeterministic {

    uint256 constant ELECTION_DURATION_DAYS = 15;

    address public creator;
    address public registry;

    constructor()
    public {
        // Setting the creator on initial deploy.
        // Clones don't invoke the constructor, so we check for the zero address within `init`.
        // Cloning invokes `init` immediately after clone creation, so we're never left in a vulnerable state.
        creator = msg.sender;
    }

    /**
     *  Initializes the contract with the given registry and admin accounts.
     *  This function should only be invoked from 'clone'.
     *  @param registryAddress The address of the registry to proxy calls to
     *  @param adminAddresses The admin address for this contract
     */
    function init(address registryAddress, address[] calldata adminAddresses)
    external {
        require(msg.sender == creator || creator == address(0), "Invocation requires creator");

        // Init with admins and threshold of 50% + 1
        super.init(adminAddresses, adminAddresses.length / 2 + 1, ELECTION_DURATION_DAYS);
        registry = registryAddress;
    }

    /**
     *  Sets the registry that this should proxy calls to
     *  @param r Address of the backing registry
     */
    function setRegistry(address r)
    onlyAdmins
    external {
        require(r != address(0), "Valid address required");
        registry = r;
    }

    /**
     *  Proxy calls to the backing registry
     *  @dev Passes calls to the backing registry using this contracts address as the sender, allowing admins
     *       to invoke functions of the registry by piggy-backing off of this contract's permissions.
     *       View functions will also be rejected by non-admins, but can be invoked against the 'registry'
     *       address directly.
     */
    function ()
    onlyAdmins
    external {
        bytes memory cd = msg.data;
        assembly {
            let success := call(sub(gas, 1000), sload(registry_slot), 0, add(cd, 0x20), calldatasize, 0, 0)
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize)
            if iszero(success) { revert(ptr, returndatasize) }
            return(ptr, returndatasize)
        }
    }

    /**
     *  Clones this registry, setting the registry to this contract's registry and the admins to this contract's admins
     *  @param salt The salt used to generate the clones address
     *  @return address The clone's address
     */
    function clone(uint256 salt)
    public
    payable
    returns(address payable) {
        // Get the current admins
        address[] memory a = new address[](uint256(admins.count));
        for (int256 i = 0; i < admins.count; i++) {
            a[uint256(i)] = admins.at(i);
        }
        return clone(salt, a);
    }

    /**
     *  Clones this registry, setting the registry to this contract's registry and the admins to the provided addresses
     *  @param salt The salt used to generate the clones address
     *  @param addresses The admin addresses to use for the clone
     *  @return address The clone's address
     */
    function clone(uint256 salt, address[] memory addresses)
    public
    payable
    onlyAdmins
    returns(address payable) {
        address payable cloned = super.clone(salt);
        (MultiAdminRegistry(cloned)).init(registry, addresses);
        return cloned;
    }

}
