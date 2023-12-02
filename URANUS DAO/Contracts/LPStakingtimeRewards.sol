// Staking time rewards

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPoolStaking {
    address public admin;
    IERC20 public lpToken;
    uint256 public totalStaked;
    uint256 public constant REWARD_RATE = 333; // 0.333%
    uint256 public constant BONUS_RATE = 3333; // 3.33%
    uint256 public constant BONUS_DURATION = 333 days;
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dead;

    struct UserInfo {
        uint256 stakedAmount;
        uint256 lastStakeTime;
        uint256 pendingBonus;
    }

    mapping(address => UserInfo) public userInfo;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _lpToken) {
        admin = msg.sender;
        lpToken = IERC20(_lpToken);
    }

    function stakeTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(lpToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");

        UserInfo storage user = userInfo[msg.sender];
        if (user.stakedAmount > 0) {
            uint256 pendingReward = calculatePendingReward(msg.sender);
            user.pendingBonus += pendingReward;
        }

        user.stakedAmount += _amount;
        user.lastStakeTime = block.timestamp;
        totalStaked += _amount;

        lpToken.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function unstakeTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(userInfo[msg.sender].stakedAmount >= _amount, "Insufficient staked amount");

        UserInfo storage user = userInfo[msg.sender];
        uint256 pendingReward = calculatePendingReward(msg.sender);
        user.pendingBonus += pendingReward;

        if (block.timestamp >= user.lastStakeTime + BONUS_DURATION) {
            // User gets the bonus as a reward
            uint256 bonusAmount = (user.stakedAmount * user.pendingBonus * BONUS_RATE) / (1000000 * 10000);
            lpToken.transfer(msg.sender, _amount + bonusAmount);
        } else {
            // User loses the staked amount
            lpToken.transfer(DEAD_ADDRESS, _amount);
        }

        totalStaked -= _amount;
        user.stakedAmount -= _amount;
        user.pendingBonus = 0;

        emit Withdrawn(msg.sender, _amount);
    }

    function calculatePendingReward(address _user) internal view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 elapsedTime = block.timestamp - user.lastStakeTime;
        return (user.stakedAmount * elapsedTime * REWARD_RATE) / (1000000 * 1 days);
    }
}