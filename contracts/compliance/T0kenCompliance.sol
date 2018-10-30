pragma solidity >=0.4.24 <0.5.0;


import "t0ken/libs/lifecycle/LockableDestroyable.sol";

import "./ComplianceRule.sol";
import "./Compliance.sol";


contract T0kenCompliance is Compliance, Ownable, LockableDestroyable {

    uint8 constant MAX_RULES = 25;

    Storage public store;
    bool public affiliateFreeze = true;
    mapping(address => bool) public addressFreezes; // list of addresses frozen for just this token
    mapping(address => bool) public affiliates;
    mapping(uint8 => ComplianceRule[]) private complianceRules;

//----------------------------- Modifiers ----------------------------
    /**
     *  Checks if the given address is an affiliate in a frozen status
     *  @param addr The address of the 'from' affiliate
     */
    modifier affiliateNotFrozen(address addr) {
        if(affiliateFreeze) {
            require(affiliates[addr] == false, "Affiliate is frozen.");
        }
        _;
    }

    /**
     *  Checks if the given addresses are frozen for this token
     *  @param from The sender address to check
     *  @param to The receiver address to check
     */
    modifier addressesNotFrozen(address to, address from) {
        require(addressFreezes[to] == false, "Receiver is frozen at the token.");
        require(addressFreezes[from] == false, "Sender is frozen at the token.");
        _;
    }

//----------------------------- Getters ----------------------------


    /**
     *  Returns all of the current compliance rules for this token
     *  @param kind The bucket of rules to get
     *  @return List of all compliance rules
     */
    function getRules(uint8 kind)
    external
    view
    returns(ComplianceRule[]) {
        return complianceRules[kind];
    }


      /**
       *  Checks if a transfer can occur between the from/to addresses.
       *  Both addresses must be valid, unfrozen, and pass all compliance rule checks.
       *  @param from The address of the sender.
       *  @param to The address of the receiver.
       *  @return If a transfer can occur between the from/to addresses.
       */
      function canTransfer(address from, address to)
      affiliateNotFrozen(from)
      addressesNotFrozen(from, to)
      external
      view
      returns(bool) {
          uint8 fromKind;
          uint8 toKind;
          bool fromFrozen;
          bool toFrozen;

          (fromKind, fromFrozen,) = store.accountGet(from);
          (toKind, toFrozen,) = store.accountGet(to);
          if(!fromFrozen && !toFrozen) {
              fromFrozen = checkFrozen(from);
              toFrozen = checkFrozen(to);
          }

          if(fromFrozen || toFrozen) {
              return false;
          }

          ComplianceRule[] storage rules = complianceRules[fromKind];
          for (uint8 i = 0; i < rules.length; i++) {
              if (!rules[i].canTransfer(from, to, toKind, store)) {
                  return false;
              }
          }
          return true;
      }

      /**
       *  Checks the cascading frozen status of an address.
       *  @param addr The address
       *  @return The frozen status of the addr
       */
      function checkFrozen(address addr)
      internal
      view
      returns(bool) {
          bool frozen;
          address parent;
          uint8 kind;

          (kind, frozen, parent) = store.accountGet(addr);
          if (kind > 1 && !frozen) {
              return checkFrozen(parent);
          }
          return frozen;
      }

//----------------------------- Setters ----------------------------

    /**
     *  Replaces all of the existing rules with the given ones.
     *  @param kind The bucket of rules to set
     *  @param rules New compliance rules
     */
    function setRules(uint8 kind, ComplianceRule[] rules)
    onlyOwner
    external {
        require(rules.length <= MAX_RULES, "Too many rules");
        complianceRules[kind] = rules;
    }

    /**
     *  Sets the internal storage/registry contract.
     *  @param s The storage contract
     */
    function setStorage(Storage s)
    onlyOwner
    external {
        store = s;
    }

    /**
     *  Sets an address affiliate status for this token.
     *  @param addr The address to set affiliate status for
     *  @param status Whether the address is an affiliate, or not
     */
    function setAffiliate(address addr, bool status)
    onlyOwner
    external {
        affiliates[addr] = status;
    }


    /**
     *  Sets this token frozen status for all affiliates
     *  @param freeze Whether affiliates are frozen.
     */
    function setAffiliateFreeze(bool freeze)
    onlyOwner
    external {
        affiliateFreeze = freeze;
    }

    /**
     *  Sets an address frozen status for this token.
     *  @param addr The address for which to update frozen status
     *  @param freeze Frozen status of the address
     */
    function setAddressFrozen(address addr, bool freeze)
    onlyOwner
    external {
        addressFreezes[addr] = freeze;

        emit AddressFrozen(addr, freeze, msg.sender);
    }


}
