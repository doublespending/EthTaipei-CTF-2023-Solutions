// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {Pool, PoolBase} from "src/ETHTaipeiWarRoomNFT/Pool.sol";
import {WarRoomNFT} from "src/ETHTaipeiWarRoomNFT/NFT.sol";

contract PoolTest is Test {
    Pool public pool;
    WarRoomNFT public nft;
    PoolBase public base;
    uint256 times = 0;

    function setUp() public {
        uint256 startTime = block.timestamp + 60;
        uint256 endTime = startTime + 60;
        uint256 fullScore = 100;
        base = new PoolBase(startTime, endTime, fullScore);
        base.setup();
    }

    function testExploit() public {}

    function onERC721Received(address, address, uint256 tokenId, bytes memory) external returns (bytes4) {}
}
