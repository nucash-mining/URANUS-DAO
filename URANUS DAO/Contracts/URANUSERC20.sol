// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UranusToken is ERC20 {
    constructor() ERC20("URANUS", "URANUS") {
        uint256 totalSupply = 2_900_000_000 * 10**18; // 2.9 billion tokens with 18 decimal places
        _mint(msg.sender, totalSupply);
    }
}