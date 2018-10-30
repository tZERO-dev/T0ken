pragma solidity >=0.4.24 <0.5.0;


import "./Lockable.sol";
import "./Destroyable.sol";


/**
 *  Contract to facilitate locking and self destructing.
 */
contract LockableDestroyable is Lockable, Destroyable { }
