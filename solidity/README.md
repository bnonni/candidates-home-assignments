# Amun solidity/vyper engineer task

An exercise in implementing smart contract logic

## How to use it:

- `$ npm install`

This repo uses [hardhat](https://hardhat.org/). Feel free to use it to as template for your task.

1. Fork this repo
2. Work on one of the tasks
3. Create a pull request and add Amun engineers as reviewers

Tasks (Choose one):

A. Create a ERC20 tokens smart contract portfolio

- User is able to deposit a token, withdraw a token, emergency withdraw all tokens, show list of his tokens with their balances
- Be able to transfer his deposited tokens for another user on the portifolio smart contract
- Bonus: add support for EIP-2612 compliant tokens for single transaction deposits

B. Build a token fund.

This fund works as following.

- When a user deposits USDC or USDT, it converts 50% of the amount into LINK and the other 50% into WETH.

- When user wants to withdraw, it converts the tokens back to USDC or USDT.

- Bonus: Connect the smart contract you create to at least to two Dexes, for example Uniswap and Sushi, so as to get the best price when coverting stable coin to LINK or WETH.

## How to submit your solution

Bundle all your changes into a single git patch file. Zip it and send over to `dev@amun.com` with the subject `"[Solidity task solution] - _your_name_here_"`
