pragma solidity >=0.5.0 <0.6.0;


library AddressToASCII {

    /**
     *  Converts the given address to ASCII encoded bytes
     *  @dev To use with payable addresses, use: `using AddressToASCII for address payable;`
     *  @param addr The address to convert to ASCII
     *  @return The encoded address
     */
    function toString(address addr)
    internal
    pure
    returns (bytes memory) {
        bytes memory s = new bytes(42);
        // Adds `0x` prefix
        s[0] = 0x30;
        s[1] = 0x78;
        // Convert byte chars to ASCII
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(addr) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i+2]   = uint8(hi) < 10 ? byte(uint8(hi) + 0x30) : byte(uint8(hi) + 0x57);
            s[2*i+3] = uint8(lo) < 10 ? byte(uint8(lo) + 0x30) : byte(uint8(lo) + 0x57);
        }
        return s;
    }

}
