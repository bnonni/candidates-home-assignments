// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Portfolio {
    using Counters for Counters.Counter;
    Counters.Counter TokenCounter;

    struct Token {
        address tokenAddress;
        string symbol;
        uint256 balance;
        bool exists;
    }

    mapping(address => uint256) PortfolioSizes;
    mapping(address => uint256) Tokens;
    mapping(address => mapping(uint256 => Token)) private Portfolios;

    function _addToken(address tokenAddress) internal {
        string memory symbol = IERC20Metadata(tokenAddress).symbol();
        uint256 newTokenId = TokenCounter.current();
        TokenCounter.increment();
        Portfolios[msg.sender][newTokenId] = Token(
            tokenAddress,
            symbol,
            0,
            true
        );
        Tokens[tokenAddress] = newTokenId;
        PortfolioSizes[msg.sender] += 1;
    }
    /**
        Portfolios: { investorAddress => { tokenAddress => Token() } }
        E.g.
        {
            0x122234: { 0: Token("0x6677", "SYM", 10, true) },
            0x992347: { 0: Token("0x6677", "SYM", 40, true), 1: Token("0x7788", "MYS", 10, true) }
            0x679119: { 0: Token("0x6677", "SYM", 20, true), 1: Token("0x7788", "MYS", 20, true), Token("0x5558", "SIM", 20, true) }
        }
        Tokens: { tokenAddress => int }
        E.g.
        {
            0x6677: 0,
            0x7788: 1,
            0x5558: 2
        }
        PortfolioSizes: { investorAddress => int }
        E.g.
        {
            0x122234: 1,
            0x992347: 2,
            0x679119: 3
        }
     */

    function depositTokens(
        uint256 amount,
        address tokenAddress
    ) external returns (bool) {
        // check if amount is valid above 0
        require(amount > 0, "Deposit Amount Cannot Be 0!");
        _addToken(tokenAddress);
        uint256 tokenId = Tokens[tokenAddress];
        IERC20 token = IERC20(tokenAddress);
        if(token.allowance(msg.sender, address(this)) < amount) {
            require(token.approve(address(this), amount), "Allowance Approval Failed! Please Try Again!");
        }
        require(token.transferFrom(msg.sender, address(this), amount), "Deposit Failed! Please Try Again!");
        Portfolios[msg.sender][tokenId].balance += amount;
        return true;
    }

    function withdrawTokens(uint256 amount, address tokenAddress)
        external
        returns (bool)
    {
        require(amount > 0, "Withdraw Amount Cannot Be 0!");
        uint256 tokenId = Tokens[tokenAddress];
        Token memory portfolioToken = Portfolios[msg.sender][tokenId];
        require(portfolioToken.exists, "Token Not in Portfolio!");
        require(portfolioToken.balance > 0, "No Tokens to Withdraw!");
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(address(this), msg.sender, amount), "Withdraw Failed! Please Try Again!");
        portfolioToken.balance -= amount;
        return true;
    }

    function getBalances(address investor) public view returns (Token[] memory) {
        require(msg.sender == investor, "You Can Only View Your Own Portfolio Balances!");
        // get all token balances for a users portfolio
        uint256 userPortfolioSize = PortfolioSizes[investor];
        Token[] memory tokens = new Token[](userPortfolioSize);
        for(uint256 i = 0; i < userPortfolioSize - 1; i++){
            tokens[i] = Portfolios[investor][i];
        }
        return tokens;
    }

    function withdrawAll(address investor) public returns (bool[] memory) {
        require(msg.sender == investor, "You Can Only Withdraw Your Own Portfolio!");
        uint256 userPortfolioSize = PortfolioSizes[investor];
        bool[] memory successfulTransfers;
        for(uint256 i = 0; i < userPortfolioSize - 1; i++){
            Token memory portfolioToken = Portfolios[investor][i];
            IERC20 token = IERC20(portfolioToken.tokenAddress);
            successfulTransfers[i] = token.transfer(investor, portfolioToken.balance);
        }
        return successfulTransfers;
    }
}
