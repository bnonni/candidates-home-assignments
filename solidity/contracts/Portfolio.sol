pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Portfolio is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter TokenCounter;

    struct Token {
        string symbol;
        address tokenAddress;
        uint256 balance;
        bool exists;
    }
    mapping(address => mapping(uint256 => Token)) private PortfolioMap;
    mapping(string => uint256) TokenTracker;
    mapping(address => uint256) UserPortfolioSize;

    function _addToken(address tokenAddress) internal {
        string memory symbol = IERC20Metadata(tokenAddress).symbol();
        TokenCounter.increment();
        uint256 newTokenId = TokenCounter.current();
        PortfolioMap[msg.sender][newTokenId] = Token(
            symbol,
            tokenAddress,
            0,
            true
        );
        TokenTracker[symbol] = newTokenId;
        UserPortfolioSize[msg.sender] += 1;
    }

    function deposit(
        uint256 amount,
        address tokenAddress,
        string calldata symbol
    ) external returns (bool) {
        require(amount > 0, "Deposit Amount Cannot Be 0!");
        // check if symbol is valid
        // require(keccak256(abi.encodePacked(symbol)) != keccak256(abi.encodePacked("")),"Token Symbol Cannot Be Blank!");
        // check if address exists
        // require(address(tokenAddress), "");
        _addToken(tokenAddress);
        uint256 tokenId = TokenTracker[symbol];
        // Token memory tokenMeta = PortfolioMap[msg.sender][tokenId];
        // require(tokenMeta.exists, "Token Not in Portfolio!");
        IERC20 token = IERC20(tokenAddress);
        bool success = token.transferFrom(msg.sender, address(this), amount);
        PortfolioMap[msg.sender][tokenId].balance += amount;
        return success;
    }

    // function withdraw(string calldata symbol, uint256 amount)
    //     external
    //     returns (bool)
    // {
    //     require(amount > 0, "Withdraw Amount Cannot Be 0!");
    //     require(
    //         keccak256(abi.encodePacked(symbol)) !=
    //             keccak256(abi.encodePacked("")),
    //         "Token Symbol Cannot Be Blank!"
    //     );
    //     Token memory tokenMeta = PortfolioMap[msg.sender][symbol];
    //     require(tokenMeta.exists, "Token Not in Portfolio!");
    //     IERC20 token = tokenMeta.token_;
    //     bool success = token.transferFrom(address(this), msg.sender, amount);
    //     return success;
    // }

    // function balances(string calldata symbol) public returns (string[] memory) {
    //     // iterate through mapping and return a list of tuples (SYMBOL, BALANCE)
    //     PortfolioMap[msg.sender];
    // }

    // function withdrawAll() public returns (bool[] memory) {
    //     // iterate through mapping, execute a transfer for each token in mapping, add a success or fail to the array, return it
    // }
}
