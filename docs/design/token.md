# T0ken Contract
The token contract which represents the security to be traded is compliant with the [ERC-20][ERC-20] standard, providing
flexibility for the token to be used within other, and future, trading platforms.

The token contract is also compliant with [Delaware Senate Bill 69][bill-69] and [Title 8][title-8] of Delaware Code
relating to the General Corporation Law, supporting the following Title 8 requirements:.

- Token owners must have their identity verified (KYC).
- Must provide the following three functions of a “Corporations Stock Ledger” (Section 224 of the act).
  - Enable the corporation to prepare the list of shareholders, specified in Sections 219 and 220 of the act.
  - Record “Partly Paid Share,” “Total Amount Paid,” “Total Amount to be Paid,” specified in Sections 156, 159, 217(a) and 218 of the act.
  - Record transfers of shares, specified in Section 159 of the act.
- Require that each token corresponds to a single share (i.e. no partial tokens).
- Provide a way to re-issue tokens to a new address, cancelling the current one.

This document walks through the Solidity code for the token contract [T0ken.sol](../../contracts/token/T0ken.sol) and
uses "Company A Preferred Stock" as an example company that is attempting to implement security tokens for offering
equities (in this case, Company A Preferred Stock).

## Definition
The Token contract is the main contract that handles the base methods in the tZERO security token ecosystem.

![Token Design Diagram][design]  


[ERC-20]: //theethereum.wiki/w/index.php/ERC-20_Token_Standard
[bill-69]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[title-8]: //legis.delaware.gov/json/BillDetail/GenerateHtmlDocument?legislationId=25730&legislationTypeId=1&docTypeId=2&legislationName=SB69
[design]: http://www.plantuml.com/plantuml/png/ZLF1Zjem43tZhx2qXxRQ8j6gxQhIQhNR55HEAm5tD8adnCAnex43eYZ_tk2O3Oa8NP_ytanctenVdgq3ScMks0T-T-tmfJiejDU3p6wbBe0WvpO3OVPIRtWAok95f81a2nlaHyPvR4WWHKOPudUJIJHz-5spgT6korKNtqlja598cWf0PFRz0d7TOaEcr294eeVPp-cFcmsNyY_oBzyxhI99YK8HPJLA718__bTTei3QOMKPWa3wDQol5zbdqk5xT0VKpm3dICQbmzbjrIOlZ4Rj-F6T8WBNdxBLDQpr6wi6t7NxC7QspifiKVF7nmKc3lH6uTDJBPoDMclCLvCcPVxPA_K9ez4zrv3Znq_-QWzvR5G00XEPWx8UhjSSTwYTvUjr3OyGMtToGCNdrfP8ItG-hnS0dU0GFvDQsWn5FxxCW30pIY2z274pli3Sx9gCYZ5UdtRUwIBwEkcDoyEvvw2KsGTr5snHaDbrkHZKAUyrxR3EE53BiYZKeSiJQ9iYNILdPFABG6UdP_9Yq1Ul1bJuf1TTTJlLyu-QF-typb7ldPkLMNy_kLl9qrmUIl-6uTfz7K-67Po-7NFhf_PNlyKwfmRjbAyx998YUAgfxUrf0vFwqgqzF6dHDKvgSVGcCd315EwjyXzFU3Zc2UXs9vvn0RRTArQnO8pnkDaK2pz6IpoZ5cMk_W40
