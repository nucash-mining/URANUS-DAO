// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingContract {
    uint256 public constant INITIAL_BLOCK_REWARD = 333 * (10**18); // 333 tokens per block
    uint256 public constant BLOCKS_PER_REDUCTION = 333_333_333; // 333,333,333 blocks for each reduction
    uint256 public constant REDUCTION_FACTOR = 3; // The factor by which the block reward decreases (1/3)

    uint256 public totalBlocksMined;
    uint256 public currentBlockReward;

    string public rewardsTokenName = "Titania"; // The name of the rewards token

    constructor() {
        totalBlocksMined = 0;
        currentBlockReward = INITIAL_BLOCK_REWARD;
    }

    function stakeTokens(uint256 _amount) external {
        // Staking logic goes here
    }

    function unstakeTokens() external {
        // Unstaking logic goes here
    }

    function getBlockReward() external view returns (uint256) {
        return currentBlockReward;
    }

    function mineBlock() external {
        // Miner logic goes here
        // Increment totalBlocksMined
        totalBlocksMined++;

        // Check if a reduction in block reward is required
        if (totalBlocksMined % BLOCKS_PER_REDUCTION == 0) {
            currentBlockReward = currentBlockReward / REDUCTION_FACTOR;
        }
    }
}