// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {UniswapV2Factory} from "src/3/UniswapV2Factory.sol";
import {UniswapV2Pair} from "src/3/UniswapV2Pair.sol";
import {TokenWithGodMode} from "src/1/TokenWithGodMode.sol";

contract UniswapV2FactoryTest is Test {
    event PairCreated(address pair);

    UniswapV2Factory public factory;

    address public tokenA;
    address public tokenB;

    address alice = vm.addr(0x1);

    function setUp() external {
        factory = new UniswapV2Factory(alice);

        tokenA = address(new TokenWithGodMode(alice, "TokenA", "TKA"));
        tokenB = address(new TokenWithGodMode(alice, "TokenB", "TKB"));
    }

    function test_CreatePair() public {
        address pair = factory.createPair(tokenA, tokenB);

        assertEq(factory.getPair(tokenA, tokenB), pair);
    }

    function test_CreatePairFailsWithZeroAddress() public {
        vm.expectRevert("ZERO ADDRESS");
        factory.createPair(address(0), tokenB);
    }

    function test_CreatePairFailsWithSameToken() public {
        vm.expectRevert("SAME TOKEN");
        factory.createPair(tokenA, tokenA);
    }

    function test_CreatePairFailsIfPairExists() public {
        address pair = factory.createPair(tokenA, tokenB);
        assertEq(factory.getPair(tokenA, tokenB), pair);

        vm.expectRevert("PAIR EXISTS");
        factory.createPair(tokenA, tokenB);
    }
}
