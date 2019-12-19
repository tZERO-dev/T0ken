[<img src="https://storage.googleapis.com/media.tzero.com/t0ken/logo.png" width="400px" />](https://www.tzero.com/)

---

# The Trading Platform
The trading platform is a regulatory-compliant suite of smart contracts serving as an Alternative Trading Solution (ATS)
that allows trading and fast settlement of securities in t-0 time. Built on the Ethereum chain, the platform provides
secure, fault-tolerant, transparent, and fast transaction settlement while being compliant to regulatory requirements.

The platform provides methods for issuance of security tokens which can be customized to represent various types of
securities. The security tokens are compliant with both [ERC-20][erc-20] and Delaware General Corporate Law, [Title 8][Title 8].

This project describes the set of Ethereum contracts that represent tZERO's token and trading functionality. See below
for instructions and walk-throughs for third-party integration and customization.

## Components
For a token to be tradable, it first has to be defined, created and then be constrained within the set of regulatory
rules to ensure compliance with the trading laws for the parties involved (investors, broker-dealers, and custodians).

The tokens are created and their trades validated within the following interrelated set of components:
 - [Token](docs/design/token.md)
 - [Registry](docs/design/registry.md)
 - [Compliance](docs/design/compliance.md)

![Detailed Design Diagram][uml-overall]

### T0ken
The token contract defines and creates the tokens representative of the securities to be traded.

*See the [Token contract](docs/design/token.md) page for in-depth details.*

### Registry
The registry is a grouping of investor, broker-dealer, and custodian contracts that define and coordinate
the behavior of these interacting entities.

*See the [Registry](docs/design/registry.md) page for in-depth details.*

### Compliance
The compliance contracts maintain the set of trade rules and exemptions (e.g. [Reg A][reg-a], [Reg D][reg-d],
etc.) allowing valid trades, while halting improper ones from taking place.

*See the [Compliance](docs/design/compliance.md) page for in-depth details.*

### Mainnet
_v1.2.2_

| Contract        | Address                                                                                                               |
|-----------------|-----------------------------------------------------------------------------------------------------------------------|
| Registry        | [0x01bb19b8BaaF46660a0F18a881e0778f5E594140](https://etherscan.io/address/0x01bb19b8BaaF46660a0F18a881e0778f5E594140) |
| Custodian       | [0x69261Ee9C1819bF953a9207d5e1E5F5d1DbF62a0](https://etherscan.io/address/0x69261Ee9C1819bF953a9207d5e1E5F5d1DbF62a0) |
| Broker          | [0x3fc5508990FE954972CCe8f94C862a856ec536e3](https://etherscan.io/address/0x3fc5508990FE954972CCe8f94C862a856ec536e3) |
| Investor        | [0x3367fc2aAAd25AE42c9aB3210455Ad08E20675DA](https://etherscan.io/address/0x3367fc2aAAd25AE42c9aB3210455Ad08E20675DA) |
| Compliance      | [0xe1E93B6Da4DC935A77Ff06254ebFd1a0Ffb49694](https://etherscan.io/address/0xe1E93B6Da4DC935A77Ff06254ebFd1a0Ffb49694) |

_v1.1.0_

| Contract        | Address                                                                                                               |
|-----------------|-----------------------------------------------------------------------------------------------------------------------|
| T0ken _(TZROP)_ | [0x5bd5b4e1a2c9b12812795e7217201b78c8c10b78](https://etherscan.io/token/0x5bd5b4e1a2c9b12812795e7217201b78c8c10b78)   |

[<img src="https://storage.googleapis.com/media.tzero.com/t0ken/t0ken.png" />](https://etherscan.io/token/0x5bd5b4e1a2c9b12812795e7217201b78c8c10b78)

## Third-Party Integration
*See the [Third Party Integration](./docs/design/third-party-integration.md) page for in-depth details.*

## Developer

This repo contains only the Solidity contracts, all other files _(including tests, tools, etc.)_ have been excluded for now.  
We'll be providing all other files in the future, but for now this allows anyone to use the contracts in Truffle, ZeppelinOS, etc.

We have included a `Makefile`, which relies on [Docker](https://www.docker.com/get-started), if you just want to compile the contracts for ABI/Bin:

To build, simply run:

```
% make
```

This will create the `build/` folder with all ABI/Bin files, along with a `contracts.js` that can be used within a Geth session.

## License
This project is licensed under the [Apache 2.0][apache 2.0] license.

## Links
 - [tZERO's Website](https://www.tzero.com/)
 - [tZERO T0ken](https://etherscan.io/token/0x5bd5B4e1a2c9B12812795E7217201B78C8C10b78)


[erc-20]: //theethereum.wiki/w/index.php/ERC20_Token_Standard
[T-plus-N]: //www.investopedia.com/terms/t/tplus1.asp
[Title 8]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[reg-a]: //www.sec.gov/smallbusiness/exemptofferings/rega
[reg-d]: //www.sec.gov/fast-answers/answers-regdhtm.html
[apache 2.0]: //www.apache.org/licenses/LICENSE-2.0.html
[uml-overall]: http://www.plantuml.com/plantuml/png/jPBFQy8m5CVl-IiUUl1KSMER4yQGjGvsjRk9XzY-rcAQI99EtF1_NvesjPOw66mzbBpl-_7vviTSQIfraJCoWc7V1w4-CbJzIQ9s6TzJINDGMngBGyPJI2XJsCfm4IDy4O0DZNQf50MFVS64X64mUtrS-6L6o1XbhKuc_c8Q63KHN8VP9yBDVHrTLfnQa9Xgkg7g2YYQ9ZDy-1DGOdx_Jub4lXSSkUub7RQPnWx7QLHASUX3NxTpHqxszd_x4LArmHBJJ6bv9CqjB84g63XzO7UnSk6w3Fn2QH5dbDleHOeToW0fGsc5D_w1fi049-BwuCdpeEcxbDi3BZDkKcEsOAY8VPG3kwxTZSVZTUqoS8kmnAzirHeyxzc9NIdeIEKin_FDLJBZDy8AwjkZEQirFZGMQOgMt2HjEAf6Tq-YFRXk_ackjct_dJ9dzDsS82VL-ruiVUzsKZcpUaa_jzW9LVqSULpax1i0
