// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MemeToken.sol"; // Import the MemeToken contract template

contract MemeTokenFactory {
    address public admin;
    mapping(address => address[]) public userTokens;

    constructor() {
        admin = msg.sender;
    }

    function createMemeToken(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint8 _decimals,
        uint256 _titaniaSpent,
        bool _hasBuyTax,
        bool _hasSellTax,
        bool _hasBurnRate
    ) external {
        require(_titaniaSpent > 0, "TITANIA must be spent");

        // Calculate value based on _titaniaSpent and _initialSupply
        uint256 tokenValue = (_titaniaSpent * (10**18)) / _initialSupply; // Adjust this formula

        // Deploy MemeToken contract
        MemeToken newToken = new MemeToken(
            _name,
            _symbol,
            _initialSupply,
            _decimals,
            tokenValue,
            _hasBuyTax,
            _hasSellTax,
            _hasBurnRate
        );

        // Store the address of the newly deployed token contract
        userTokens[msg.sender].push(address(newToken));
    }
}
