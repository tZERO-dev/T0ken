<img src="http://tzero.design/assets/img/logo.png" width="400px" />

# The Trading Platform
The trading platform is a regulatory-compliant suite of smart contracts serving as an Alternative Trading Solution (ATS) that allows trading and fast settlement of securities in t-0 time. Built on the Ethereum chain, the platform provides secure, fault-tolerant, transparent, and fast transaction settlement while being compliant to regulatory requirements.

The platform provides methods for issuance of security tokens which can be customized to represent various types of securities. The security tokens are [ERC-20][erc-20] compliant and compliant with the Delaware General Corporate Law, [Title 8][Title 8].

This project describes the set of Ethereum contracts that represent tZERO's token and trading functionality. See below for instructions and walk-throughs for third-party integration and customization.

## Components
For a token to be tradable, it first has to be defined, created and then be constrained within the set of regulatory rules to ensure compliance with the trading laws for the parties involved (investors, broker-dealers, and custodians).

![Detailed Design Diagram][uml-overall]

The tokens are created and their trades validated within the following interrelated set of components:
 - [Token](docs/design/token.md)
 - [Registry](docs/design/registry.md)
 - [Compliance](docs/design/compliance.md)

### T0ken
The token contract that defines and creates the tokens which are the securities to be traded.

*See the [Token contract](docs/design/token.md) page for in-depth details.*

### Registry
The registry is the grouping of storage, investor, broker-dealer, and custodian contracts that define and coordinate
the behavior of these interacting entities.

*See the [Registry](docs/design/registry.md) page for in-depth details.*

### Compliance
The Compliance is a contract that houses the set of trade rules and exemptions (e.g. [Reg A][reg-a], [Reg D][reg-d], etc.). The compliance rule set allows valid trades and stops the improper trades from taking place.

*See the [Compliance](docs/design/compliance.md) page for in-depth details.*

### Mainnet
v1.0.0

|  Contract       | Address                                                                                                               |
|-----------------|-----------------------------------------------------------------------------------------------------------------------|
| Storage         | [0x2d1477dd9c494e8758ec8d03f9f8b838ce394414](https://etherscan.io/address/0x2d1477dd9c494e8758ec8d03f9f8b838ce394414) |
| Custodian       | [0x2963488e2a140ca324e086ab8f89b5d533f1081d](https://etherscan.io/address/0x2963488e2a140ca324e086ab8f89b5d533f1081d) |
| Broker          | [0x3ecb8f0d127e22d436b26fccad4f38d7f5b91ee9](https://etherscan.io/address/0x3ecb8f0d127e22d436b26fccad4f38d7f5b91ee9) |
| Investor        | [0x857f6a42634a14847cc4e0226f36906f0a77cee3](https://etherscan.io/address/0x857f6a42634a14847cc4e0226f36906f0a77cee3) |
| T0kenCompliance | [0x0e108767f1c207a5a045ac67d488b3447e7e0eae](https://etherscan.io/address/0x0e108767f1c207a5a045ac67d488b3447e7e0eae) |
| RestrictAll     | [0x206616df4c55a7af9395f2d906477f0dbb45369a](https://etherscan.io/address/0x206616df4c55a7af9395f2d906477f0dbb45369a) |
| T0ken           | [0xc4bf277257c140a799b785c6c5096c6da7ef6a62](https://etherscan.io/address/0xc4bf277257c140a799b785c6c5096c6da7ef6a62) |

## Third-Party Integration
*See the [Third Party Integration](./docs/design/third-party-integration.md) page for in-depth details.*

## License
This project is licensed under the [Apache 2.0][apache 2.0] license.

## Links
tZERO's website: www.tzero.com


[erc-20]: //theethereum.wiki/w/index.php/ERC20_Token_Standard
[T-plus-N]: //www.investopedia.com/terms/t/tplus1.asp
[Title 8]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[reg-a]: //www.sec.gov/smallbusiness/exemptofferings/rega
[reg-d]: //www.sec.gov/fast-answers/answers-regdhtm.html
[apache 2.0]: //www.apache.org/licenses/LICENSE-2.0.html
[uml-overall]: http://www.plantuml.com/plantuml/png/NL4zJyGm3DtzAwpRKo5cX4wq3AmzDiHWYAbEf0dA1z89yTzntOPUkzdlu-MvFQPCCPVHWQLCRvGOUnxEASSB_W3Yooc7I0E_JdDRKWxsJ5wtXnW-ENPCZgC2J_wRHI3BBomsl3C6_sqRzDg-8MeC87n46XaV-zRStinrdiNafmV01ylOXl7BIV8xptHV7AULFiWjnP64NL2fmonhcaOR2ztLuQIs9G6DkQ_e7kfsa8P1_MfwWhRSGcjJMCShyP6zbT_m1m00
