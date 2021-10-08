pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Portfolio is Ownable {
 struct Token {
    IERC20 token_;
    string symbol;
    address address_;
    bool exists;
    uint256 balance;
  }

  // Maps a token symbol to various metadatas about that token
  mapping(address => mapping(string => Token)) private PortfolioMap;

  function addToken(address address_) internal {
   IERC20 token = IERC20(address_);
   string memory symbol = IERC20Metadata(address_).symbol();
   PortfolioMap[msg.sender][symbol] = Token(token, symbol, address(token), true, 0);
  }

  function deposit(address address_, string calldata symbol, uint amount) external returns (bool){
   addToken(address_);
   require(amount > 0, 'Deposit Amount Cannot Be 0!');
   require(keccak256(abi.encodePacked(symbol)) != keccak256(abi.encodePacked('')), 'Token Symbol Cannot Be Blank!');
   Token memory tokenMeta = PortfolioMap[msg.sender][symbol];
   require(tokenMeta.exists, 'Token Not in Portfolio!');
   IERC20 token = tokenMeta.token_;
   bool success = token.transferFrom(msg.sender, address(this), amount);
   tokenMeta.balance = amount;
   return success;
  }

  function withdraw(string calldata symbol, uint amount) external returns (bool){
   require(amount > 0, 'Withdraw Amount Cannot Be 0!');
   require(keccak256(abi.encodePacked(symbol)) != keccak256(abi.encodePacked('')), 'Token Symbol Cannot Be Blank!');
   Token memory tokenMeta = PortfolioMap[msg.sender][symbol];
   require(tokenMeta.exists, 'Token Not in Portfolio!');
   IERC20 token = tokenMeta.token_;
   bool success = token.transferFrom(address(this), msg.sender, amount);
   return success;
  }

  function balances(string calldata symbol) public returns (string[] memory){
   // iterate through mapping and return a list of tuples (SYMBOL, BALANCE)
  }

  function withdrawAll() public returns (bool[] memory){
   // iterate through mapping, execute a transfer for each token in mapping, add a success or fail to the array, return it
  }

}