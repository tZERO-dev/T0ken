pragma solidity >=0.5.0 <0.6.0;


import "../registry/IRegistry.sol";
import "../token/IT0ken.sol";
import "./ICompliance.sol";
import "./IComplianceStorage.sol";
import "./IComplianceRule.sol";


contract ComplianceRule is IComplianceRule {

    modifier senderHasStoragePermission() {
        require(ICompliance(msg.sender).store().permissionExists(msg.sender), "Requires storage permission");
        _;
    }

    /**
     *  Gets the registry of the msg.sender
     *  @dev Only call this when `msg.sender` is a Compliance contract
     *  @return The registry of compliance
     */
    function registry()
    internal
    view
    returns (IRegistry) {
        return ICompliance(msg.sender).registry();
    }

    /**
     *  Gets the compliance-storage of the msg.sender
     *  @dev Only call this when `msg.sender` is a Compliance contract
     *  @return The compliance-storage of compliance
     */
    function complianceStore()
    internal
    view
    returns (IComplianceStorage) {
        return ICompliance(msg.sender).store();
    }

}
