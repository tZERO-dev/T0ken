# The Storage Contract
The Storage contract handles accounts, data, and permissions.

* **[Libraries](#libraries)**
    * [Account Map](#libaccountmap)
    * [Address Map](#libaddressmap)
* **[Variables](#variables)**
    * [Global Constants](#globalconstants)
    * [Global Variables](#globalvariables)
* **[Modifiers](#modifiers)**
    * [isAllowed](#modifierisallowed)
* **[Getters](#getters)**
    * [Address Getters](#addressgetters)
        * [accountAt](#getteraccountat)
        * [accountGet](#getteraccountget)
        * [accountParent](#getteraccountparent)
        * [accountKind](#getteraccountkind)
        * [accountFrozen](#getteraccountfrozen)
        * [accountIndexOf](#getteraccountindexof)
        * [accountExists](#getteraccountexists1)
        * [accountExists](#getteraccountexists2)
    * [Permission Getters](#permissiongetters)
        * [permissionAt](#getterpermissionat)
        * [permissionIndexOf](#getterpermissionindexof)
        * [permissionExists](#getterpermissionexists)
* **[Setters](#setters)**
    * [addAccount](#setteraddaccount)
    * [setAccountFrozen](#settersetaccountfrozen)
    * [removeAccount](#setterremoveaccount)
    * [setAccountData](#setteraccountdata)
    * [grantPermission](#settergrantpermissions)
    * [revokePermission](#setterrevokepermission)

____

<a id="libraries"></a>
### Libraries
<a id="libaccountmap"></a>
[Account Map](../../contracts/libs/collections/AccountMap.sol)
> Account mapping structure

<a id="libaddressmap"></a>
[AddressMap](../../contracts/libs/collections/AddressMap.sol)
> Address mapping structure

____
<a id="variables"></a>
### Variables

<a id="globalconstants"></a>
##### Global Constants

Parameter           |Type    | Visibility    | Value           | Description
------------------- | ------- | ------------- | --------------- | ----------------
`MAX_DATA`      | uint8   | public        | 30              | Number of data slots available for accounts

<br>

<a id="globalvariables"></a>
##### Global Variables


Parameter           |Type    | Visibility    | Value           | Description
------------------- | ---------- | ------------- | ------- | -----------------------
`accounts`          | AccountMap | public        |     -    |
`data`              | mapping    | public        |    -     | `mapping(address => mapping(uint8 => bytes32))`
`permissions`       | mapping    | public        |     -    | `mapping(uint8 => AddressMap.Data)`

____

<a id="modifiers"></a>
### Modifiers
<a id="isAllowed"></a>
`isAllowed`:
>  Ensures the `msg.sender` has permission for the given kind/type of account.  
> The `owner` account is always allowed.  
> Addresses/Contracts must have a corresponding entry, for the given kind  
>
> @param uint8 kind -


-----
<a id="getters"></a>
### Getters

<a id="addressgetters"></a>
#### Address Getters

<a id="gettersaddress"></a>
<a id="getteraccountat"></a>
`accountAt`:
> Gets the account at the given index
> THROWS when the index is out-of-bounds
>
> @param index - The index of the item to retrieve  
> @return The address, kind, frozen status, and parent of the account at the given index

<a id="getteraccountget"></a>
`accountGet`:
>  Gets the account for the given address  
>  THROWS when the account doesn't exist
>
>  @param addr The address of the item to retrieve  
>  @return The address, kind, frozen status, and parent of the account at the given index

<a id="getteraccountparent"></a>
`accountParent`:
>  Gets the parent address for the given account address  
>  THROWS when the account doesn't exist
>
>  @param addr The address of the account  
>  @return The parent address

<a id="getteraccountkind"></a>
`accountKind`:
>  Gets the account kind, for the given account address
>  THROWS when the account doesn't exist
>
>  @param addr The address of the account  
>  @return The kind of account

<a id="getteraccountfrozen"></a>
`accountFrozen`:
>  Gets the frozen status of the account  
>  THROWS when the account doesn't exist
>
>  @param addr - The address of the account  
>  @return The frozen status of the account


<a id="getteraccountindexof"></a>
`accountIndexOf`:
>  Gets the index of the account  
>  Returns -1 for missing accounts
>
>  @param addr - The address of the account to get the index for  
>  @return The index of the given account address

<a id="getteraccountexists1"></a>
`accountExists`:
>  Returns wether or not the given address exists
>
>  @param addr - The account address
>  @return If the given address exists

<a id="getteraccountexists2"></a>
`accountExists`:
>  Returns wether or not the given address exists for the given kind
>
>  @param addr - The account address  
>  @param kind - The kind of address
>  @return If the given address exists with the given kind

<a id="permissiongetters"></a>
#### Permission Getters

<a id="getterpermissionat"></a>
`permissionAt`:
>  Retrieves the permission address at the index for the given type  
>  THROWS when the index is out-of-bounds
>
>  @param kind The kind of permission  
>  @param index The index of the item to retrieve  
>  @return The permission address of the item at the given index

<a id="getterpermissionindexof"></a>
`permissionIndexOf`:
>  Gets the index of the permission address for the given type  
>  Returns -1 for missing permission  

>  @param kind The kind of perission  
>  @param addr The address of the permission to get the index for  
>  @return The index of the given permission address


<a id="getterpermissionexists"></a>
`permissionExists`:
>  Returns wether or not the given permission address exists for the given type
>
>  @param kind The kind of permission  
>  @param addr The address to check for permission  
>  @return If the given address has permission or not


---
<a id="setters"></a>
### Setters

<a id="setteraddaccount"></a>
`addAccount`:
>  Adds an account to storage  
>  THROWS when `msg.sender` doesn't have permission  
>  THROWS when the account already exists  
>  @param addr The address of the account  
>  @param kind The kind of account  
>  @param isFrozen The frozen status of the account  
>  @param parent The account parent/owner


<a id="settersetaccountfrozen"></a>
`setAccountFrozen`:
>  Sets an account's frozen status  
>  THROWS when the account doesn't exist   
>  @param addr The address of the account  
>  @param frozen The frozen status of the account

<a id="setterremoveaccount"></a>
`removeAccount`:
> Removes an account from storage  
> THROWS when the account doesn't exist    
> @param addr The address of the account
>

<a id="settersetaccountdata"></a>
`setAccountData`:
> Sets data for an address/caller  
> THROWS when the account doesn't exist  
>  @param addr The address  
>  @param index The index of the data  
>  @param customData The data store set  

<a id="settergrantpermissions"></a>
`grantPermissions`:
> Grants the address permission for the given kind  
> @param kind The kind of address  
> @param addr The address

<a id="setterrevokepermission"></a>
`revokePermission`:
> Revokes the address permission for the given kind  
> @param kind The kind of address  
> @param addr The address
