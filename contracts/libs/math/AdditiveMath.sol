pragma solidity >=0.4.24 <0.5.0;


library AdditiveMath {
    /**
     *  Adds two numbers and returns the result
     *  THROWS when the result overflows
     *  @return The sum of the arguments
     */
    function add(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        uint256 sum = x + y;
        require(sum >= x, "Results in overflow");
        return sum;
    }

    /**
     *  Subtracts two numbers and returns the result
     *  THROWS when the result underflows
     *  @return The difference of the arguments
     */
    function subtract(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        require(y <= x, "Results in underflow");
        return x - y;
    }
}
