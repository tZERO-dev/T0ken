pragma solidity >=0.5.0 <0.6.0;


import "./Destroyable.sol";
import "./Lockable.sol";


/**
 *  Contract to facilitate locking and self destructing.
 */
contract LockableDestroyable is Lockable, Destroyable { }
