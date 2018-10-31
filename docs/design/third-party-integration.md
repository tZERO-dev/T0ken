# Third-Party Integration

## Token Contract
To create your own token using tZERO's security token implementation, clone or fork
[T0ken.sol](../../contracts/token/T0ken.sol) and update the following variables in the contract:
```              
-string public constant name = "Company A Preferred";
-string public constant symbol = "COMPA";    //Token Ticker
-uint8 public constant decimals = 0;
```

The t0ken.sol contract also inherits from Ownable.sol, and LockableDestroyable.sol. These are libraries that provide a
few extra functions around owning, locking, and destroying a contract but are not necessary for the base of creating a token.

## Compliance Contract
The next contract that will need to be deployed and linked to from this newly created token is the
[T0kenCompliance.sol](../../contracts/compliance/T0kenCompliance.sol) contract. The compliance contract has a method
that returns if a transfer can take place: `canTransfer`. If this returns `false` in any compliance rule contract, the
`transfer` method in the newly deployed token contract will block the transfer. To link the token contract to this newly
deployed compliance contract, use the method `setCompliance` in the token contract and pass in the compliance contract
address as the parameter.

The compliance contract has a mapping storing compliance rules (contract addresses) based on kind. Using tZERO's storage
kinds are based as follows:

 - Kind 1: Custodian
 - Kind 2: Custodial-account
 - Kind 3: Broker Dealer
 - Kind 4: Investor

Compliance rules can be set through the method `setRules` which takes as parameters the `kind` and `ComplianceRule[]`,
an array of compliance rule contracts used to check for that specific kind.
i.e

```
setRules(1, ["0x0001", "0x0002", "0x0003"], {from: owner})
```

This example sets the compliance rules for custodians. Once a custodian calls the `transfer` method in the token
contract, this set of rules will be checked against in the `canTransfer` method in the compliance contract to make sure
the custodian can indeed transfer.

## Storage Contract
Also to take care of on-boarding and KYC of investors you can link to and use the Storage.sol contract tZERO is using by
referencing the contract in any newly created token through the method `setStorage`. This method takes the address of the
storage contract as the parameter. tZERO's public storage contract address is [0x2d1477dd9c494e8758ec8d03f9f8b838ce394414][storage].

The Storage contract uses the kind system as laid out above for giving permissions within the tZERO security token
ecosystem. When connecting to the storage contract address above in your own token, there are a few methods to note.
You can fork and use the same contracts from this repo to handle investors, broker dealers, and custodians, or you can
create your own contracts to link into the storage contract. The tZERO ecosystem uses the [CustodianRegistry][custodianRegistry],
[BrokerDealerRegistry][brokerDealerRegistry], and [InvestorRegistry][investorRegistry] to store data and users in the storage
contract. Each has an `add` function which will add the address and kind to the storage contract. The `add` function in
the investor registry takes a few more parameters to add data along with the investor's address, a bytes32 PII hash,
bytes2 country code, and a uint48 accreditation. You can also bypass using any of these contracts and call the storage
contract directly to set users and data. These methods in the storage contract are `addAccount`, and `setAccountData`.


Although unnecessary, you can deploy your own registry set of contracts found in this repo which consist of
[CustodianRegistry][custodianRegistry], [BrokerDealerRegistry][brokerDealerRegistry], [InvestorRegistry][investorRegistry],
and [Storage][storage]. Then link the first three to the storage contract to be used to store these kinds.


[storage]: ../../contracts/registry/Storage.sol
[custodianRegistry]: ../../contracts/registry/custodian/CustodianRegistry.sol
[brokerDealerRegistry]: ../../contracts/registry/brokerDealer/BrokerDealerRegistry.sol
[investorRegistry]: ../../contracts/registry/investor/InvestorRegistry.sol
