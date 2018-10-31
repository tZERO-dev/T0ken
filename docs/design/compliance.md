# The Compliance Contract
The compliance contract uses compliance rules to regulate the transfer of tokens. The contract maintains and manages the
collection of rules which enforce compliant transfers between account types (custodian, broker, custodial-account, or investor).

Rules are stored within buckets matching the sender's account type, providing flexibility, while preventing unnecessary
compliance checks for accounts that do not require it.

![Compliance Design Diagram][design]

_See [T0kenCompliance.sol](../../contracts/compliance/T0kenCompliance.sol) for a reference implementation_


[design]: http://www.plantuml.com/plantuml/png/XP11geCm48RtESKiMwGt4B4KUW3fNgPn57bnb9cnYuftRomYTY7lMuKl_vzCagkXsDW5Dw3_muRWrdT3Q94zGPeMv0sv2PHbC3c8j6maDVfzi1W3hTiB2NZaXo1hJN8wV_tiZjhxPba2lOXDusgJ4pxL1BtDSAqg8TMxz6_YvUILIsHtlP8T9HDeo9PvzKVg9lzvnUnouYh-rmS0
