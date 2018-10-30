
# The Investor Contracts
An investor falls underneath its managing broker-dealer. Only the investor's parent (the broker-dealer) may remove or modify the investor.
Both the broker-dealer and broker-dealer's parent (the custodian) may freeze the investor from performing any actions.

The Investor Registry contract implements the Investor Registry Interface for the token.


* **[Variables](#variables)**
  * [Global Constants](#globalconstants)
  * [Global Variables](#globalvariables)
* **[Modifiers](#modifiers)**
    * [isInvestor](#modifierisinvestor)
    * [onlyBrokerDealer](#modifieronlybrokerdealer)
    * [onlyInvestorsBrokerDealer](#modifieronlyinvestorsbrokerdealer)
    * [onlyInvestorsBrokerDealerOrCustodian](#modifieronlyinvestorsbrokerdealerorcustodian)
* **[Getters](#getters)**
    * [getHash](#gettersgethash)
    * [getAccreditation](#gettersgetaccreditation)
    * [getCountry](#gettersgetcountry)
* **[Setters](#setters)**
    * [setStorage](#settersetstorage)
    * [add](#settersadd)
    * [remove](#settersremove)
    * [setHash](#setterssethash)
    * [setAccreditation](#setterssetaccreditation)
    * [setCountry](#setterssetcountry)
    * [setFrozen](#setterssetfrozen)
    * [updatedData](#settersupdateddata)


____
<a id="variables"></a>
### Variables

<a id="globalconstants"></a>
#### Global Constants
Parameter           | Type       | Visibility    | Default | Description
--------------------------- | ------- | ------------- | ------------------------------- | ----------------
`BROKER_DEALER`             | uint8   | private       | 3                               |
`INVESTOR`                  | uint8   | private       | 4                               |
`HASH_INDEX`                | uint8   | private       | 0                               |
`DATA_INDEX`                | uint8   | private       | 1                               |
`MASK_ACCR`                 | uint8   | private       | `uint256(0xffffffffffff)<<16`   | bitshift mask
`MASK_CTRY`                 | uint8   | private       | `uint256(0xffff)`               | bitshift mask

____

<a id="globalvariables"></a>
#### Global Variables
Parameter           | Type       | Visibility    | Default | Description
------------------- | ---------- | ------------- | ------- | -----------------------
`store`             | Storage    | public        |         |
____

<a id="modifiers"></a>
### Modifiers
<a id="modifierisinvestor"></a>
`isInvestor`:
> Checks that the address provided is of type INVESTOR
>
> @param addr address - The address to check for investor type

<a id="modifieronlybrokerdealer"></a>
`onlyBrokerDealer()`:
> Checks that the `msg.sender` is of type BROKER_DEALER  
> Checks that the `msg.sender` account is not frozen.  
> Checks that the BrokerDealer's parent (CUSTODIAN) is not frozen
>
> @param account address - the address to check

<a id="modifieronlyinvestorsbrokerdealer"></a>
`onlyInvestorsBrokerDealer`:
> Checks that the `msg.sender` account exists as a BROKER_DEALER.  
> Checks that the `msg.sender` is the parent of the `investor`  
> Checks that the broker dealer is not frozen  
> checks that the broker dealers parent (CUSTODIAN) is not frozen
>
> @param investor address - The address to check the `msg.sender` as Broker Dealer against

<a id="modifieronlyinvestorsbrokerdealerorcustodian"></a>
`onlyInvestorsBrokerDealerOrCustodian`:
> Checks `msg.sender` is the investors parent or grandparent (Broker Dealer or Custodian)  
> Checks that investors broker dealer is not Frozen  
> Checks that investors's broker dealer's custodian is not frozen.
>
> @param investor address - The investor address to check


-----
<a id="getters"></a>
### Getters
<a id="gettersgethash"></a>
`getHash`
> Retrieves the data hash for a given investor
>
> @param addr address - The address to retrieve investor data hash  
> @return bytes32

<a id="gettersgetaccreditation"></a>
`getAccreditation`
> Retrieves the accreditation for a given investor
>
> @param addr address - The address to retrieve investor accreditation
> @return uint48

<a id="gettersgetcountry"></a>
`getCountry`
> Retrieves the country data for a given investor
>
> @param addr address - The address to retrieve country data for
> @return bytes2

-----
<a id="setters"></a>
##### Setters

<a id="setterssetstorage"></a>
`setStorage`:
> Sets the contract address for the Storage Contract
>
> @param s Storage - The Storage object


<a id="settersadd"></a>
`add`:
>  Adds an investor dealer to the registry
>
>  @param investor address - The address of the investor  
>  @param hash bytes32 - 32 byte hash of the investors data  
>  @param country bytes2 - 2 Byte country code for investor   
>  @param accreditation uint48 - The epoch timestamp investors accreditation expires



<a id="settersremove"></a>
`remove`:
>  Removes a investor from the registry
>
>  @param investor address - The address of the investor to remove

<a id="settersaddaccount"></a>
`addAccount`:
>  Adds an account for the broker-dealer, using the account as the destination address
>
>  @param brokerDealer The broker-dealer to add the account for  
>  @param account The account, and destination, to add for the broker-dealer


<a id="setterssethash"></a>
`setHash`:
>  Set's the data hash for the given investor
>
>  @param investor address - The account to set the hash for  
>  @param hash bytes32 - The 32 byte hash of the investors data


<a id="setterssetaccreditation"></a>
`setAccreditation`:
>  Set's the accreditation data for the given investor
>
>  @param investor address - The account to set the hash for  
>  @param accreditation uint48 - The accreditation date for the investor


<a id="setterssetcountry"></a>
`setCountry`:
>  Set's the country data for the given investor
>
>  @param investor address - The account to set the country for  
>  @param country bytes2 - 2 byte country data for the investor


<a id="setterssetfrozen"></a>
`setFrozen`:
>  Sets whether or not an investor is frozen
>
>  @param investor - The investor address that is being updated  
>  @param frozen Whether or not the investor is frozen

<a id="settersupdateddata"></a>
`updatedData`
> Given existing data and a data mask, update the investor data to the new value and return.
>
> @param data uint256 - The existing data  
> @param value uint256 - The value being updated in the existing data  
> @param mask uint256 - The data mask used for bitshifting  
> @param shift uint8 - The shift
> @return uint256
