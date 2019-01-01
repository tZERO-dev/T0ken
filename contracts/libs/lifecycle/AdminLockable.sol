pragma solidity >=0.5.0 <0.6.0;


import "tzero/libs/ownership/Administrable.sol";


/**
 *  @title Lockable
 *  @dev The Lockable contract adds the ability for the contract owner to set the lock status
 *  of the account. A modifier is provided that checks the throws when the contract is
 *  in the locked state.
 */
contract AdminLockable is Administrable {
    bool public isLocked;

    constructor() public {
        isLocked = false;
    }

    modifier isUnlocked() {
        require(!isLocked, "Contract is currently locked for modification");
        _;
    }

    /**
     *  Set the contract to a read-only state.
     *  @param locked The locked state to set the contract to.
     */
    function setLocked(bool locked)
    onlyAdmins
    external {
        require(isLocked != locked, "Contract already in requested lock state");

        isLocked = locked;
    }
}
