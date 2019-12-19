pragma solidity >=0.5.0 <0.6.0;


import "../../registry/IRegistry.sol";


library InvestorData {

    /* Data[0]
     * ---------------------------------------
     * 0000 0000 0000 0000 0000 0000 0000 0000    32 256
     * 0000 0000 0000 0000 0000 0000 0000 0000    28 224
     * 0000 0000 0000 0000 0000 0000 0000 0000    24 192
     * 0000 0000 0000 0000 0000 0000 0000 0000    20 160
     * 0000 0000 0000 0000 0000 0000 0000 0000    16 128
     * 0000 0000 0000 0000 0000 0000 0000 0000    12  96
     * 0000 0000 0000 0000 0000 0000 0000 0000     8  64   Accreditation  (48)
     * 0000 0000 0000 0000
     *                     0000 0000 0000 0000     2  16   Country        (16)
     */


    /**
     *  Returns the given investor's accreditation epoch date
     *  @param investor The investor address to check status of
     *  @return Accreditation expiration epoch of investor
     */
    function accreditation(IRegistry self, address investor)
    internal
    view
    returns (uint48) {
        bytes32 data = self.data(investor, 0);
        return uint48(uint256(data)>>16);
    }

    /**
     *  Returns if the given investor is accredited
     *  @param investor The investor address to check status of
     *  @return If the investor is accredited
     */
    function isAccredited(IRegistry self, address investor)
    internal
    view
    returns (bool) {
        bytes32 data = self.data(investor, 0);
        return uint48(uint256(data)>>16) > now;
    }

    /**
     *  Returns the given investor's country code
     *  @param investor The investor address to check status of
     *  @return Country code of investor
     */
    function country(IRegistry self, address investor)
    internal
    view
    returns (bytes2) {
        bytes32 data = self.data(investor, 0);
        return bytes2(uint16(uint256(data)));
    }


    /**
     *  Sets an investor's accreditation and country
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param accreditationDate The date of accreditation
     *  @param countryCode The investor's 2 character country code
     */
    function setData(IRegistry self, address investor, uint48 accreditationDate, bytes2 countryCode)
    internal {
        uint256 data = uint256(uint16(countryCode)) | (uint256(accreditationDate)<<16);
        self.setAccountData(investor, 0, bytes32(data));
    }

    /**
     *  Sets an investor's accreditation date
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param accreditationDate The date of accreditation
     */
    function setAccreditation(IRegistry self, address investor, uint48 accreditationDate)
    internal {
        uint256 data = uint256(self.data(investor, 0));
        uint256 mask = uint256(0xffffffffffff)<<16;
        data = (data & ~mask) | ((uint256(accreditationDate)<<16) & mask);
        self.setAccountData(investor, 0, bytes32(data));
    }

    /**
     *  Sets an investor's country
     *  THROWS if the address doesn't exist, or is zero
     *  @param investor The address of the investor
     *  @param countryCode The investor's 2 character country code
     */
    function setCountry(IRegistry self, address investor, bytes2 countryCode)
    internal {
        uint256 data = uint256(self.data(investor, 0));
        uint256 mask = uint256(0xffff);
        data = (data & ~mask) | (uint256(uint16(countryCode) & mask));
        self.setAccountData(investor, 0, bytes32(data));
    }

}
