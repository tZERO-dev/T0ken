pragma solidity >=0.5.0 <0.6.0;


import "../collections/AddressMap.sol";


/**
 *  @title MultiAdministrable
 *  @dev Provides a modifier that requires the caller to be the owner or an admin of the contract.
 */
contract MultiAdministrable {

    struct ballot {
        uint8 yeas;         //   8───┐
        uint8 nays;         //   8   │
        uint8 incumbent;    //   8   ├─ 1st Block (216 bits)
        uint32 creation;    //  32   │
        address challenger; // 160───┘
        uint256 votes;      // ──────── 2nd Block
    }

    ballot private b;

    uint256 public ballotDuration;
    uint256 public voteThreshold;

    using AddressMap for AddressMap.Data;
    AddressMap.Data public admins;

    event ElectionCreated(address indexed incumbent, address indexed challenger);
    event ElectionClosed(address indexed incumbent, address indexed challenger, bool indexed passed, uint256 margin);
    event VoteCast(address indexed incumbent, address indexed challenger);

    modifier onlyAdmins {
        require(admins.exists(msg.sender), "Admin required");
        _;
    }

    /**
     *  Initializes with the given admin addresses and voting threshold.
     *
     *  @param adminAddresses The addresses that will be admins.
     *  @param threshold The number of yea/nay votes that determine finality of an election.
     *  @param duration The number days an election is valid.
     */
    function init(address[] memory adminAddresses, uint256 threshold, uint256 duration)
    internal {
        require(admins.count == 0, "Already initialized");
        require(adminAddresses.length > 1 && adminAddresses.length < 256, "Admins outside of bounds");
        require(threshold > 1 && threshold <= adminAddresses.length, "Invalid threshold");
        require(duration > 0 && duration < 366, "Invalid duration");

        // Set admins
        for (uint256 i = 0; i < adminAddresses.length; i++) {
            admins.append(adminAddresses[i]);
        }
        voteThreshold = threshold;
        ballotDuration = duration * 1 days;
    }

    /**
     *  Returns if the address is an admin.
     *
     *  @param addr The address to check.
     *  @return Whether or not the address is an admin.
     */
    function isAdmin(address addr)
    external
    view
    returns(bool) {
        return admins.exists(addr);
    }

    /**
     *  Retrieves the admin at the given index.
     *  THROWS when the index is invalid.
     *
     *  @param index The index of the item to retrieve.
     *  @return The address of the item at the given index.
     */
    function adminAt(int256 index)
    external
    view
    returns(address) {
        return admins.at(index);
    }

    /**
     *  Checks if the voter has cast a vote for thte current ballot.
     *
     *  @param voter The address of the voter.
     *  @return If the voter has cast their vote.
     */
    function hasVoted(address voter)
    external
    view
    returns(bool) {
        int256 i = admins.indexOf(voter);
        if (i < 0) {
            return false;
        }
        return uint8(b.votes >> i) & 0x1 == 1;
    }

    /**
     *  Gets election poll information.
     *
     *  @return Returns incumbent, challenger, yea votes, nay votes, and days left to vote.
     */
    function electionResults()
    external
    view
    returns(uint8, address, uint8, address, uint256) {
        uint256 timeLeft = now - b.creation;
        if (b.creation == 0 || timeLeft > ballotDuration) {
            return (0, address(0), 0, address(0), 0);
        }

        timeLeft = (ballotDuration - timeLeft) / 1 days;
        return(b.nays, admins.at(b.incumbent), b.yeas, b.challenger, timeLeft);
    }

    /**
     *  Creates an election for the incumbent vs challenger.
     *
     *  No current election may be in progress, unless it has exceeded the number of days for polling.
     *  @param incumbent The existin admin.
     *  @param challenger The proposed admin.
     */
    function createElection(address incumbent, address challenger)
    external
    onlyAdmins {
        require(now - b.creation > ballotDuration, "Election in process");
        int256 i = admins.indexOf(incumbent);
        require(i >= 0 && !admins.exists(challenger), "Invalid candidates");

        b = ballot(0, 0, uint8(i), uint32(now), challenger, 0);
        emit ElectionCreated(incumbent, challenger);
    }

    /**
     *  If a ballot exists, cast the sender's vote, otherwise create a new ballot.
     *  If this vote hits the vote threshold, the poll is closed and the election results are processed.
     *
     *  @param incumbent The existing admin.
     *  @param challenger The proposed admin.
     *  @param yea If the vote is for the challenger, nay for the incumbent
     */
    function vote(address incumbent, address challenger, bool yea)
    external
    onlyAdmins {
        require(now - b.creation <= ballotDuration, "No ballot");
        require(b.challenger == challenger && admins.at(b.incumbent) == incumbent, "Invalid candidates");
        uint256 i = uint256(admins.indexOf(msg.sender));
        require(uint8(b.votes >> i) & 0x1 == 0, "Already voted");

        // Count vote
        if (yea) {
            b.yeas += 1;
        } else {
            b.nays += 1;
        }

        // Mark sender as having voted
        b.votes |= uint256(1) << i;
        emit VoteCast(incumbent, challenger);

        // Close election
        if (b.yeas >= voteThreshold || b.nays >= voteThreshold || b.yeas + b.nays == admins.count) {
            int256 margin = int256(b.yeas) - b.nays;
            b = ballot(0, 0, 0, 0, address(0), 0);
            if (margin > 0) {
                admins.remove(incumbent);
                admins.append(challenger);
                emit ElectionClosed(incumbent, challenger, true, uint256(margin));
            } else {
                emit ElectionClosed(incumbent, challenger, false, uint256(~margin + 1)); // take 2's complement
            }
        }
    }
}
