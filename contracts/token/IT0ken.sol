pragma solidity >=0.5.0 <0.6.0;


interface IT0ken {
    // ERC-20
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);


    // Common
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);


    // T0ken
    event IssuerSet(address indexed previousIssuer, address indexed newIssuer);
    event Issuance(address indexed to, uint256 tokens);
    event IssuanceFinished();
    event ShareholderAdded(address shareholder);
    event ShareholderRemoved(address shareholder);

    function holders() external view returns (uint256);
    function holderAt(int256 index) external view returns (address);
    function isHolder(address addr) external view returns (bool);
    function issuer() external view returns (address);
    function transferOverride(address from, address to, uint256 tokens) external returns (bool);
}

