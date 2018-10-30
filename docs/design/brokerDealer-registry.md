
# The Broker-Dealer Contract
A broker-dealer falls underneath its managing custodian. Only the broker-dealer's custodian (parent) may freeze, assign custodial-accounts to, or remove a broker from the ecosystem.

##### Broker-Dealer's On-chain Responsibilities

 - Onboarding of investors
 - Providing liquidity for tokens
 - Freezing investor to prevent any non-allowed actions _(for SEC regulatory purposes, or other reasons applicable by law)_.
 - Management of on-chain investor data _(the ability exists to add to, or include additional data as needed)_.
   - Identification Hash
   - Accreditation Date
   - Domicile
 - Removal of investors

The Broker-Dealer Registry contract implements the Broker-Dealer Registry interface for the token.

* **[Variables](#variables)**
  * [Global Constants](#globalconstants)
  * [Global Variables](#globalvariables)
* **[Modifiers](#modifiers)**
    * [onlyCustodian](#modifieronlycustodian)
    * [onlyNewAccount](#modifieronlynewaccount)
    * [onlyBrokerDealersCustodian](#modifieronlybrokerdealerscustodian)
    * [onlyAccountCustodian](#modifieronlyaccountscustodian)
* **[Setters](#setters)**
    * [setStorage](#settersetstorage)
    * [add](#setteradd)
    * [remove](#setterremove)
    * [addAccount](#setteraddaccount)
    * [removeAccount](#setterremoveaccount)
    * [setFrozen](#settersetfrozen)


____
<a id="variables"></a>
### Variables

<a id="globalconstants"></a>
##### Global Constants
Parameter           | Type       | Visibility    | Value   | Description
--------------------------- | ------- | ------------- | --------------- | ----------------
`CUSTODIAN`                 | uint8   | private       | 1               |
`CUSTODIAL_ACCOUNT`         | uint8   | private       | 2               |
`BROKER_DEALER    `         | uint8   | private       | 3               |

____

<a id="globalvariables"></a>
##### Global Variables
Parameter           | Type       | Visibility    | Value   | Description
------------------- | ---------- | ------------- | ------- | -----------------------
`store`             | Storage    | public        |         |
____

<a id="modifiers"></a>
##### Modifiers
<a id="modifieronlycustodian"></a>
`onlyCustodian`:
> Checks that the message sender exists as a Custodian.  
> Checks that the custodian is not frozen.  

<a id="modifieronlynewaccount"></a>
`onlyNewAccount`:
> Checks that the account does not already exist in store.
>
> @param account address - the address to check

<a id="modifieronlybrokerdealerscustodian"></a>
`onlyBrokerDealersCustodian`:
> Checks that the `msg.sender` account exists as a Custodian.  
> Checks that the `msg.sender` parent is a Broker-Dealer.
> Checks that the CUSTODIAN is not frozen.
>
> @param brokerDealer address - The broker dealer address to check  

<a id="modifieronlyaccountscustodian"></a>
`onlyAccountsCustodian`:
> Checks that the account exists as a `CUSTODIAL_ACCOUNT`.  
> Checks that `msg.sender` parent account (broker-dealer) has a custodian parent.  
> Checks if the Custodian is not frozen.
>
> @param account address - The custodial account address to check


-----
<a id="setters"></a>
### Setters

<a id="settersetstorage"></a>
`setStorage`:
> Sets the contract address for the Storage Contract.
>
> @param s Storage - The Storage object


<a id="setteradd"></a>
`add`:
>  Adds a broker dealer to the registry.
>  Upon successful addition, the contract must emit `Broker DealerAdded(custodian)`.  
>  THROWS if the address has already been added, or is zero.
>
>  @param brokerDealer address - The address of the brokerDealer


<a id="setterremove"></a>
`remove`:
>  Removes a broker dealer from the registry  
>  Upon successful removal, the contract must emit `BrokerDealerRemoved(brokerDealer)`  
>  THROWS if the address doesn't exist, or is zero  
>
>  @param brokerDealer address - The address of the broker dealer

<a id="setteraddaccount"></a>
`addAccount`:
>  Adds an account for the broker-dealer, using the account as the destination address
>
>  @param brokerDealer The broker-dealer to add the account for  
>  @param account The account, and destination, to add for the broker-dealer


<a id="setterremoveaccount"></a>
`removeAccount`:
>  Removes the account, along with destination, from the broker-dealer
>
>  @param account The account to remove



<a id="settersetfrozen"></a>
`setFrozen`:
>  Sets whether or not a broker-dealer is frozen  
>  Upon status change, the contract must emit `BrokerDealerFrozen(brokerDealer, frozen, owner)`  
>
>  @param brokerDealer - The broker dealer address that is being updated  
>  @param frozen Whether or not the broker daeler is frozen
