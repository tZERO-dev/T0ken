
# The Custodian Contract

The financial institution that may hold a broker-dealer's or investor's securities for a variety of reasons _(e.g. transfer, withdrawal, safekeeping)_.

A custodian may also perform settlements, interest payments, and dividend
collection/payments, depending on the type of security token offered.

##### On-chain Responsibilities

 - Onboarding of broker-dealers
 - Assignment of custodial-accounts of broker-dealers
 - Freezing, from performing any related actions, of a broker-dealer  
   _(for SEC regulatory purposes, or other reasons applicable by law)_
 - Freezing, from performing any related actions, of an investor  
   _(for SEC regulatory purposes, or other reasons applicable by law)_
 - Removal of broker-dealers


 A custodial-account is managed by the custodian, added and bound to a broker-dealer, and used to hold custody of tokens on behalf of an investor belonging to the broker-dealer.

 These are simply holding accounts used for the sole purpose of performing transfers and withdrawals of tokens to, and from, investors, to broker-dealers and custodians.

The Custodian Registry contract implements the Custodian Registry Interface for the tZERO token.

* **[Variables](#variables)**
  * [Global Constants](#globalconstants)
  * [Global Variables](#globalvariables)
* **[Modifiers](#modifiers)**
    * [isAllowed](#modifierisallowed)
* **[Setters](#setters)**
    * [setStorage](#setterssetstorage)
    * [setAffiliate](#setterssetaffiliate)
    * [setAddressFrozen](#setterssetaddressfrozen)
    * [setRules](#setterssetrules)


____

<a id="variables"></a>
### Variables

<a id="globalconstants"></a>
##### Global Constants
Parameter           | Type    | Visibility    | Value           | Description
------------------- | ------- | ------------- | --------------- | ----------------
`CUSTODIAN`         | uint8   | private       | 1               |

____

<a id="globalvariables"></a>
##### Global Variables
Parameter           | Type    | Visibility    | Value           | Description
------------------- | ---------- | ------------- | ------- | -----------------------
`store`             | Storage    | public        |         |
____

<a id="modifiers"></a>
### Modifiers
<a id="modifierisallowed"></a>
`isAllowed`:
> Checks if the Custodian permission exists for `msg.sender`.


-----
<a id="setters"></a>
### Setters

<a id="setterssetstorage"></a>
`setStorage`:
> Sets the contract address for the Storage Contract
>
> @param s Storage - The Storage object


<a id="settersadd"></a>
`add`:
>  Adds a custodian to the registry.  
>  Upon successful addition, the contract must emit `CustodianAdded(custodian)`.  
>  THROWS if the address has already been added, or is zero.
>
>  @param custodian - The address of the custodian


<a id="settersremove"></a>
`remove`:
>  Removes a custodian from the registry.  
>  Upon successful removal, the contract must emit `CustodianRemoved(custodian)`.  
>  THROWS if the address doesn't exist, or is zero.  
>
>  @param custodian The address of the custodian


<a id="setterssetfrozen"></a>
`setFrozen`:
>  Sets whether or not a custodian is frozen.
>  Upon status change, the contract must emit `CustodianFrozen(custodian, frozen, owner)`.
>
>  @param custodian - The custodian address that is being updated  
>  @param frozen -  Whether or not the custodian is frozen
