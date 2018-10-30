# T0ken Contract
The token contract which represents the security to be traded is compliant with [ERC-20][ERC-20] standard, providing flexibility for the token to be used within other, and future, trading platforms.

The token contract is also compliant with [Delaware Senate Bill 69][bill-69] and [Title 8][title-8] of Delaware Code relating to the General Corporation Law.

The token contract supports the Title 8's requirements:
- Token owners must have their identity verified (KYC).
- Must provide the following three functions of a “Corporations Stock Ledger” (Section 224 of the act).
  - Enable the corporation to prepare the list of shareholders, specified in Sections 219 and 220 of the act.
  - Record “Partly Paid Share,” “Total Amount Paid,” “Total Amount to be Paid,” specified in Sections 156, 159, 217(a) and 218 of the act.
  - Record transfers of shares, specified in Section 159 of the act.
- Require that each token corresponds to a single share (i.e. no partial tokens).
- Provide a way to re-issue tokens to a new address, cancelling the current one.

This document walks through the Solidity code for the token contract [T0ken.sol](../../contracts/token/T0ken.sol) and uses "Company A Preferred Stock" as an example company that is attempting to implement security tokens for offering equities (in this case, Company A Preferred Stock).

## Definition
The Token contract is the main contract that handles the base methods in the tZERO security token ecosystem.

![Token Design Diagram][design]  


[ERC-20]: //theethereum.wiki/w/index.php/ERC-20_Token_Standard
[bill-69]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[title-8]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[design]: http://www.plantuml.com/plantuml/png/bPHTwzem5CRl-oa2kzaOmjYrY4KcysgWijjoJ4vhy3GfEQV_8U9tNssrfgKJbwloUvASb_EaInO8KfUKLA1FKA3Q-nCwDPzlKGkuWd2nK9SaKSsoJZ3ae57zsAw-VskmkgyiK_Y1JhZvwk453Ym1j5nLMbN1Vm1z_ZAbxWCupZ54QXRTyrK1aVy3JcEp8wBjfKDs0Bhj-vKFg7W1sjLLHUSXZmEFuJhuyYvSk_er0VEzGPVeXBw590Antd7FFpsIUQ9PLmcQ93fjcMiC8s1TiRREyX5DTE6p3dzkq-0u2rzMP6y18yZY0yRH79G3_LmUF4N0eBOb4ByzsjyOR6xHfCO4P6womy1eq4pFUjDMkqDv8R-G7aqPMYMRdlKRpfXsrj6JmP3A05h-sU8HZ0kEX0Bb7mgZhFfHZPMT-005_hTBNxyAHkdwFigzGPsD1ZnlUxpfNDWeOwEdpconFTm_ZslI_H7cirdtFf8bEbENz1S0