pragma solidity >=0.5.0 <0.6.0;


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
    
    /**
     *  Multiplies two unsigned integers
     *  THROWS when the result overflows
     *  @return The product of the arguments
     */
    function multiply(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        if (x == 0) {
            return 0;
        }
        uint256 product = x * y;
        require(product / x == y);
        return product;
    }

    /**
     *  Divides two unsigned integers
     *  THROWS when the result underflows
     *  @return The quotient of the arguments
     */
    function divide(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        require(y > 0);
        return x / y;
    }
}
