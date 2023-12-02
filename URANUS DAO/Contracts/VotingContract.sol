// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VotingContract {
    address public admin;
    IERC20 public titaniaToken;

    struct Proposal {
        string name;
        uint256 startTime;
        uint256 endTime;
        mapping(address => uint256) votes;
    }

    Proposal[] public proposals;
    mapping(address => uint256) public userVoteLock; // User's locked voting amount
    mapping(address => uint256) public userVotedProposal; // User's voted proposal index

    event Voted(address indexed user, uint256 proposalIndex, uint256 amount);

    constructor(address _titaniaToken) {
        admin = msg.sender;
        titaniaToken = IERC20(_titaniaToken);
    }

    function createProposal(string memory _name, uint256 _startTime, uint256 _endTime) external {
        require(msg.sender == admin, "Only admin can create proposals");
        require(_endTime > _startTime, "Invalid proposal time range");
        proposals.push(Proposal(_name, _startTime, _endTime));
    }

    function vote(uint256 _proposalIndex, uint256 _amount) external {
        require(_proposalIndex < proposals.length, "Invalid proposal index");
        require(proposals[_proposalIndex].startTime <= block.timestamp, "Voting has not started");
        require(proposals[_proposalIndex].endTime >= block.timestamp, "Voting has ended");
        require(_amount > 0, "Amount must be greater than zero");
        require(titaniaToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        // Lock the user's voting amount for the proposal
        userVoteLock[msg.sender] = _amount;
        userVotedProposal[msg.sender] = _proposalIndex;

        // Transfer the voting tokens from the user to the contract
        titaniaToken.transferFrom(msg.sender, address(this), _amount);

        // Increment the vote count for the proposal and user
        proposals[_proposalIndex].votes[msg.sender] += _amount;

        emit Voted(msg.sender, _proposalIndex, _amount);
    }

    function finalizeProposal(uint256 _proposalIndex) external {
        require(_proposalIndex < proposals.length, "Invalid proposal index");
        require(proposals[_proposalIndex].endTime < block.timestamp, "Voting has not ended");

        uint256 totalVotes = 0;
        uint256 winningVotes = 0;
        address winner;

        // Find the proposal with the most votes
        for (uint256 i = 0; i < proposals.length; i++) {
            totalVotes += proposals[_proposalIndex].votes[i];
            if (proposals[_proposalIndex].votes[i] > winningVotes) {
                winningVotes = proposals[_proposalIndex].votes[i];
                winner = i;
            }
        }

        // Transfer the locked tokens to the dead address
        titaniaToken.transfer(address(0x000000000000000000000000000000000000dead), userVoteLock[winner]);

        // Reset the user's vote lock and voted proposal
        userVoteLock[winner] = 0;
        userVotedProposal[winner] = 0;
    }
}