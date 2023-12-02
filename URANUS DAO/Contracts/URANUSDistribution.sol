// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract UranusToken is ERC20 {
    address public admin;
    uint256 public totalSupply;
    uint256 public constant TOKEN_DECIMALS = 18;

    // Token allocations
    uint256 public constant TEAM_ADVISORS_ALLOCATION = 580 * (10**6) * (10**TOKEN_DECIMALS); // 580 million
    uint256 public constant COMMUNITY_REWARDS_ALLOCATION = 580 * (10**6) * (10**TOKEN_DECIMALS); // 580 million
    uint256 public constant LIQUIDITY_POOL_REWARDS_ALLOCATION = 580 * (10**6) * (10**TOKEN_DECIMALS); // 580 million
    uint256 public constant STRATEGIC_PARTNERSHIPS_ALLOCATION = 290 * (10**6) * (10**TOKEN_DECIMALS); // 290 million
    uint256 public constant AIRDROPS_ALLOCATION = 290 * (10**6) * (10**TOKEN_DECIMALS); // 290 million
    uint256 public constant TREASURY_ALLOCATION = 290 * (10**6) * (10**TOKEN_DECIMALS); // 290 million
    uint256 public constant ECOSYSTEM_FUND_ALLOCATION = 290 * (10**6) * (10**TOKEN_DECIMALS); // 290 million

    uint256 public constant VESTING_DURATION = 2 years;

    // Vesting details for team and advisors
    mapping(address => uint256) public vestingStart;
    mapping(address => uint256) public vestedAmount;

    constructor() ERC20("URANUS", "URANUS") {
        admin = msg.sender;
        totalSupply = 2_900_000_000 * (10**TOKEN_DECIMALS); // 2.9 billion tokens

        // Mint tokens to the contract deployer
        _mint(admin, totalSupply);

        // Distribute tokens to allocations
        _transfer(admin, admin, TEAM_ADVISORS_ALLOCATION);
        _transfer(admin, admin, COMMUNITY_REWARDS_ALLOCATION);
        _transfer(admin, admin, LIQUIDITY_POOL_REWARDS_ALLOCATION);
        _transfer(admin, admin, STRATEGIC_PARTNERSHIPS_ALLOCATION);
        _transfer(admin, admin, AIRDROPS_ALLOCATION);
        _transfer(admin, admin, TREASURY_ALLOCATION);
        _transfer(admin, admin, ECOSYSTEM_FUND_ALLOCATION);
    }

    // Function to handle vesting for team and advisors
    function vestTokens() external {
        require(vestingStart[msg.sender] == 0, "Tokens already vested");
        vestingStart[msg.sender] = block.timestamp;
    }

    function claimVestedTokens() external {
        require(vestingStart[msg.sender] > 0, "Vesting not started yet");
        require(block.timestamp >= vestingStart[msg.sender] + VESTING_DURATION, "Vesting period not over");

        uint256 totalVested = vestingStart[msg.sender] + VESTING_DURATION;
        if (block.timestamp >= totalVested) {
            vestedAmount[msg.sender] = TEAM_ADVISORS_ALLOCATION;
        } else {
            uint256 timePassed = block.timestamp - vestingStart[msg.sender];
            vestedAmount[msg.sender] = (timePassed * TEAM_ADVISORS_ALLOCATION) / VESTING_DURATION;
        }

        // Transfer vested tokens to the user
        _transfer(admin, msg.sender, vestedAmount[msg.sender]);
    }
}