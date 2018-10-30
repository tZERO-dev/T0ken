pragma solidity >=0.4.24 <0.5.0;


/**
 *  @title Ownable
 *  @dev Provides a modifier that requires the caller to be the owner of the contract.
 */
contract Ownable {
    address public owner;

    event OwnerTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner account is required.");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwner(address newOwner)
    public
    onlyOwner {
        require(newOwner != owner, "New Owner cannot be the current owner.");
        require(newOwner != address(0), "New Owner cannot be zero address.");
        address prevOwner = owner;
        owner = newOwner;
        emit OwnerTransferred(prevOwner, newOwner);
    }
}
