pragma solidity >=0.5.0 <0.6.0;


/**
 *  @title Cloneable
 *  Allows this contract, or inheritors, to be cloned.
 */
contract Cloneable {

    /**
     * Clones this contract
     * @return The cloned contract's address
     */
    function clone()
    public
    payable
    returns(address payable) {
        address payable cloned;
        assembly{
            // Clone
            mstore(0, or(0x5880730000000000000000000000000000000000000000803b80938091923cF3, shl(0x48, address)))
            cloned := create(callvalue, 0, 0x20)
            if iszero(extcodesize(cloned)) { invalid() }
        }
        return cloned;
    }
}

/**
 *  @title Deterministic Cloneable
 *  Allows this contract, or inheritors, to be cloned with a deterministic address.
 */
contract CloneableDeterministic {

    /**
     * Clones this contract
     * @param salt The salt used for the deterministic address generation
     * @return The cloned contract's deterministic address
     */
    function clone(uint256 salt)
    public
    payable
    returns(address payable) {
        address payable cloned;
        assembly{
            // Clone with a deterministic contract address
            mstore(0, or(0x5880730000000000000000000000000000000000000000803b80938091923cF3, shl(0x48, address)))
            cloned := create2(callvalue, 0, 0x20, salt)
            if iszero(extcodesize(cloned)) { invalid() }
        }
        return cloned;
    }

    /**
     * Deterministically generates an address for a clone of this contract, using the given salt.
     *
     * reference: https://eips.ethereum.org/EIPS/eip-1014
     *
     * @dev Only generates addresses for the address of `this`.
     *      The hash is generated via:  
     *        ```
     *        keccak256(0xff + address + salt + keccak256(init_code))[12:]
     *        ```
     * @param salt The unique salt for address generation
     * @return The deterministic address
     */
    function addressFor(uint256 salt)
    external
    view
    returns(address) {
        /**
         * The below assembly can be shortened to the below, for an increase in cost:
         *
         *     ```
         *     bytes32 init_code;
         *     assembly {
         *         init_code := or(sload(initCode_slot), shl(0x48, address))
         *     }
         *     return address(uint256(keccak256(
         *         abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(abi.encodePacked(init_code)))
         *     )));
         *     ```
         */
        assembly {
            //           '0xff000...'     '0x00address...'
            mstore(0, or(shl(0xf8, 0xff), shl(0x58, address))) // '0xff ++ address'
            mstore(0x15, salt)                                 // '0xff ++ address ++ salt'
            mstore(0x35, or(0x5880730000000000000000000000000000000000000000803b80938091923cF3, shl(0x48, address)))
            mstore(0x35, keccak256(0x35, 0x20))                // '0xff ++ address ++ salt ++ keccak256(init_code)'
            mstore(0, keccak256(0, 0x55))                      // 'keccak256(0xff ++ address ++ salt ++ keccak256(init_code)'
            return(0, 0x20)                                    // 'keccak256(0xff ++ address ++ salt ++ keccak256(init_code))[12:]'
        }
    }

}
