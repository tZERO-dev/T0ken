pragma solidity >=0.5.0 <0.6.0;


import "../ownership/Ownable.sol";


/**
 *  @title Destroyable
 *  @dev The Destroyable contract alows the owner address to `selfdestruct` the contract.
 */
contract Destroyable is Ownable {
    /**
     *  Allow the owner to destroy this contract.
     */
    function kill()
    onlyOwner
    external {
        selfdestruct(owner);
    }
}
