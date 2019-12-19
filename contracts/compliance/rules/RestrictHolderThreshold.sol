pragma solidity >=0.5.0 <0.6.0;


import "../../libs/lifecycle/Destroyable.sol";
import "../../libs/registry/InvestorData.sol";
import "../ComplianceRule.sol";


contract RestrictHolderThreshold is ComplianceRule, Destroyable {
    using InvestorData for IRegistry;

    string public name = "Restrict Holder Threshold";

    string private constant LIMIT_KEY = "RestrictHolderThreshold.limit";
    string private constant NONACCREDITED_LIMIT_KEY = "RestrictHolderThreshold.nonaccreditedLimit";
    string private constant NONACCREDITED_KEY = "RestrictHolderThreshold.nonaccredited";
    string private constant NONACCREDITED_COUNT_KEY = "RestrictHolderThreshold.nonaccreditedCount";

    /**
     *  Add/remove non-accredited investor
     *  @param c The compliance address
     *  @param limit The total investor upper limit
     */
    function setTotalLimit(ICompliance c, string memory symbol, uint256 limit)
    public {
        c.store().setUint256(keccak256(abi.encodePacked(LIMIT_KEY, symbol)), limit);
    }

    /**
     *  Add/remove non-accredited investor
     *  @param c The compliance address
     *  @param limit The non-accredited investor upper limit
     */
    function setNonAccreditedInvestorLimit(ICompliance c, string memory symbol, uint256 limit)
    public {
        c.store().setUint256(keccak256(abi.encodePacked(NONACCREDITED_LIMIT_KEY, symbol)), limit);
    }

    /**
     *  Add/remove non-accredited investor
     *  @param c The compliance address
     *  @param addr The address to update non-accredited status
     *  @param adding Whether the addr is being added/removed as a non-accredited investor
     */
    function updateNonAccreditedInvestor(ICompliance c, string memory symbol, address addr, bool adding)
    public {
        IComplianceStorage s = c.store();
        if (s.getBool(keccak256(abi.encodePacked(NONACCREDITED_KEY, symbol, addr))) != adding) {
            uint256 count = s.getUint256(keccak256(abi.encodePacked(NONACCREDITED_COUNT_KEY, symbol)));
            count = adding ? count + 1 : count - 1;
            s.setUint256(keccak256(abi.encodePacked(NONACCREDITED_COUNT_KEY, symbol)), count);
            s.setBool(keccak256(abi.encodePacked(NONACCREDITED_KEY, symbol, addr)), adding);
        }
    }

    /**
     *  Blocks the transfer when the transfer would result in a shareholder count greater than the set threshold
     *  @param token The token contract
     *  @param initiator The address initiating the transfer.
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred.
     */
    function check(IT0ken token, address initiator, address from, address to, uint256 tokens)
    senderHasStoragePermission
    external {
        // Skip when the recipient is a current holder
        if (token.isHolder(to)) {
            return;
        }

        // Cache compliance-storage and token symbol
        IComplianceStorage s = complianceStore();
        string memory symbol = token.symbol();

        // Ensure the new shareholder doesn't exceed the threshold
        uint256 limit = s.getUint256(keccak256(abi.encodePacked(LIMIT_KEY, symbol)));
        require(limit > token.holders(), "Shareholder threshold reached");

        // If the new shareholder is non-accredited
        bool exists = s.getBool(keccak256(abi.encodePacked(NONACCREDITED_KEY, symbol, to)));
        if (!exists && registry().isAccredited(to) == false) {
            // Ensure we don't exceed the non-accredited threshold
            uint256 count = s.getUint256(keccak256(abi.encodePacked(NONACCREDITED_COUNT_KEY, symbol)));
            limit = s.getUint256(keccak256(abi.encodePacked(NONACCREDITED_LIMIT_KEY, symbol)));
            require(limit > count, "Non-accredited shareholder threshold reached");

            // Add to non-accredited list
            updateNonAccreditedInvestor(ICompliance(msg.sender), symbol, to, true);

            // If sender is non-accredited and sending all their tokens, remove them from the non-accredited mapping
            if (token.balanceOf(from) == tokens) {
                updateNonAccreditedInvestor(ICompliance(msg.sender), symbol, from, false);
            }
        } else if (exists && registry().isAccredited(to) == true) {
            // If "to" address was non-accredited, but is now accredited, remove from non-accredited mapping
            updateNonAccreditedInvestor(ICompliance(msg.sender), symbol, to, false);
        } else if (s.getBool(keccak256(abi.encodePacked(NONACCREDITED_KEY, symbol, from))) && registry().isAccredited(from) == true) {
            // If "from" address was non-accredited, but is now accredited, remove from non-accredited mapping
            updateNonAccreditedInvestor(ICompliance(msg.sender), symbol, from, false);
        }
    }

    /**
     *  Tests if a transfer can occur between the from/to addresses and returns an error string when it would fail
     *  @param compliance The Compliance address
     *  @param token The address of the token that triggered the check
     *  @param initiator The address initiating the transfer
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param tokens The number of tokens being transferred
     *  @return The error message
     */
    function test(ICompliance compliance, IT0ken token, address initiator, address from, address to, uint256 tokens)
    external
    view
    returns (string memory s) {
        if (token.isHolder(to)) return s;

        // Cache compliance-storage and token symbol
        IComplianceStorage store = compliance.store();
        string memory symbol = token.symbol();

        // Ensure the new shareholder doesn't exceed the threshold
        uint256 limit = store.getUint256(keccak256(abi.encodePacked(LIMIT_KEY, symbol)));
        if (!(limit > token.holders())) return "Shareholder threshold reached";

        bool exists = store.getBool(keccak256(abi.encodePacked(NONACCREDITED_KEY, symbol, to)));
        if (!exists && compliance.registry().isAccredited(to) == false) {
            // Ensure we don't exceed the non-accredited threshold
            uint256 count = store.getUint256(keccak256(abi.encodePacked(NONACCREDITED_COUNT_KEY, symbol)));
            limit = store.getUint256(keccak256(abi.encodePacked(NONACCREDITED_LIMIT_KEY, symbol)));
            if (!(limit > count)) return "Non-accredited shareholder threshold reached";
        }

        return s;
    }
}
