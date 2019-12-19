pragma solidity >=0.5.0 <0.6.0;


/**
 *  @title Ownable
 *  @dev Provides a modifier that requires the caller to be the owner of the contract.
 */
contract Ownable {
    address payable public owner;

    address public ZERO_ADDRESS = address(0);

    event OwnerTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    // Note: Do we need to be concerned with someone setting owner of a clone contract before we can?
    // Checks that msg.sender is the owner OR that owner is a ZER_ADDRESS (no contract owner)
    modifier onlyOwner() {
        require(msg.sender == owner || owner == ZERO_ADDRESS, "Owner account is required");
        _;
    }


    /**
     * Allows the current owner to transfer control of the contract to newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwner(address payable newOwner)
    public
    onlyOwner {
        require(newOwner != owner, "New Owner cannot be the current owner");
        require(newOwner != address(0), "New Owner cannot be zero address");
        address payable prevOwner = owner;
        owner = newOwner;
        emit OwnerTransferred(prevOwner, newOwner);
    }
}
