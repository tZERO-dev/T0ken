pragma solidity >=0.5.0 <0.6.0;


import "tzero/libs/lifecycle/AdminLockable.sol";
import "tzero/libs/lifecycle/Destroyable.sol";


/**
 *  Contract to facilitate locking and self destructing.
 */
contract AdminLockableDestroyable is AdminLockable, Destroyable { }
