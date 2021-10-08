// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";

contract TokenFund {
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    function convertUsdcToLink(address USDC, address LINK) public payable {
      address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = LINK;
        uint amountOut = 1 ether;
        uint amountIn = uniswapRouter.getAmountsIn(
            amountOut,
            path
        )[0];
        IERC20(USDC).approve(address(uniswapRouter), amountIn);
        uniswapRouter.swapExactTokensForTokens(amountIn, amountOut, path, msg.sender, (block.timestamp + 10));
      }
}