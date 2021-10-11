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
    }

    mapping(address => uint256) PortfolioSizes;
    mapping(address => uint256) Tokens;
    mapping(address => mapping(uint256 => Token)) private Portfolios;
    
    function _addTokenToPortfolio(address tokenAddress) internal {
        TokenCounter.increment();
        string memory symbol = IERC20Metadata(tokenAddress).symbol();
        uint256 newTokenId = TokenCounter.current();
        Portfolios[msg.sender][newTokenId] = Token(
            tokenAddress,
            symbol,
            0
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
        require(amount > 0, "Deposit Amount Cannot Be 0!");
        if(Tokens[tokenAddress] == 0){
            _addTokenToPortfolio(tokenAddress);
        }
        uint256 tokenId = Tokens[tokenAddress];
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Deposit Failed! Please Try Again!");
        Portfolios[msg.sender][tokenId].balance += amount;
        return true;
    }

    function withdrawTokens(uint256 amount, address tokenAddress)
        external
        returns (bool)
    {
        require(amount > 0, "Withdraw Amount Cannot Be 0!");
        require(Tokens[tokenAddress] != 0, "Token Not In Portfolio!");
        uint256 tokenId = Tokens[tokenAddress];
        uint256 balance = Portfolios[msg.sender][tokenId].balance;
        require(balance > 0, "No Tokens to Withdraw!");
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, amount), "Withdraw Failed! Please Try Again!");
        Portfolios[msg.sender][tokenId].balance -= amount;
        return true;
    }

    function getBalances() public view returns (string[] memory, uint256[] memory) {
        uint256 userPortfolioSize = PortfolioSizes[msg.sender];
        uint256[] memory balances = new uint256[](userPortfolioSize);
        string[] memory symbols = new string[](userPortfolioSize);
        uint256 j = 0;
        for(uint256 i = 1; i <= userPortfolioSize; i++){
            symbols[j] = Portfolios[msg.sender][i].symbol;
            balances[j] = Portfolios[msg.sender][i].balance;
            j++;
        }
        return (symbols, balances);
    }

    function withdrawAll() public returns (bool) {
        uint256 userPortfolioSize = PortfolioSizes[msg.sender];
        for(uint256 i = 1; i <= userPortfolioSize; i++){
            address tokenAddress = Portfolios[msg.sender][i].tokenAddress;
            uint256 balance = Portfolios[msg.sender][i].balance;
            IERC20 token = IERC20(tokenAddress);
            token.transfer(msg.sender, balance);
            uint256 tokenId = Tokens[tokenAddress];
            Portfolios[msg.sender][tokenId].balance -= balance;
        }
        return true;
    }
    
    function getTokenCount() public view returns (uint256){
        return TokenCounter.current();
    }
    
    function portfolioSize() public view returns (uint256){
        return PortfolioSizes[msg.sender];
    }
    
    function tokenBalance(address tokenAddress) public view returns (uint256){
        uint256 tokenId = Tokens[tokenAddress];
        return Portfolios[msg.sender][tokenId].balance;
    }
}
