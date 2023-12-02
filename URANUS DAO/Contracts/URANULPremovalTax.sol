// URANUS LP removal tax

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPoolStaking {
    address public admin;
    IERC20 public lpToken;
    uint256 public totalStaked;
    uint256 public constant REWARD_RATE = 333; // 0.333%
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dead;

    struct UserInfo {
        uint256 stakedAmount;
        uint256 lastStakeTime;
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
            lpToken.transfer(DEAD_ADDRESS, pendingReward);
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

        uint256 pendingReward = calculatePendingReward(msg.sender);
        lpToken.transfer(DEAD_ADDRESS, pendingReward);

        userInfo[msg.sender].stakedAmount -= _amount;
        totalStaked -= _amount;

        lpToken.transfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    function calculatePendingReward(address _user) internal view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 elapsedTime = block.timestamp - user.lastStakeTime;
        return (user.stakedAmount * elapsedTime * REWARD_RATE) / (1000000 * 1 days);
    }
}