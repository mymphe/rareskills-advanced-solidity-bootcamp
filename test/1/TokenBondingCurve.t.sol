// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {TokenBondingCurve} from "src/1/TokenBondingCurve.sol";


contract TokenBondingCurveTest is Test {
    TokenBondingCurve token;

    address admin = vm.addr(0x1);
    address alice = vm.addr(0x2);
    address bob = vm.addr(0x3);
    address charlie = vm.addr(0x4);

    uint256 constant initialPrice = 1 ether;
    uint256 constant priceIncrement = 0.1 ether;

    uint256 constant initialBalance = 1000 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        token = new TokenBondingCurve("TokenBondingCurve", "TBC", initialPrice, priceIncrement);
        vm.deal(alice, initialBalance);
        vm.deal(bob, initialBalance);
    }

    function test_getBuyCost() public {
        assertEq(token.getBuyCost(1e18), initialPrice);
    }

    function test_Buy() public {
        uint256 tokensToBuy = 10 ether;  
        uint256 expectedCost = 14.5 ether; // 1 + 1.1 + 1.2 + 1.3 + ... + 1.9 = 14.5

        vm.prank(alice);
        token.buy{value: expectedCost}(tokensToBuy);

        assertEq(alice.balance, initialBalance - expectedCost);
        assertEq(token.balanceOf(alice), tokensToBuy);
        assertEq(token.getBuyCost(1 ether), 2 ether);

        tokensToBuy = 15 ether;
        expectedCost = 40.5 ether; // 2 + 2.1 + 2.2 + 2.3 + ... + 3.4 = 40.5

        vm.prank(bob);
        token.buy{value: expectedCost}(tokensToBuy);

        assertEq(bob.balance, initialBalance - expectedCost);
        assertEq(token.balanceOf(bob), tokensToBuy);
    }

    function test_BuyRefundsExcessEther() public {
        uint256 tokensToBuy = 10 ether;
        uint256 expectedCost = 14.5 ether;
        uint256 excess = 0.5 ether;

        vm.prank(alice);
        token.buy{value: expectedCost + excess}(tokensToBuy);

        assertEq(alice.balance, initialBalance - expectedCost);
        assertEq(token.balanceOf(alice), tokensToBuy);
    }

    function test_Sell() public {
        test_Buy();

        uint256 tokensToSell = 10 ether;
        uint256 expectedRefund = 29.5 ether;
        uint256 aliceBalance = alice.balance;

        vm.prank(alice);
        token.sell(tokensToSell, expectedRefund);

        assertEq(alice.balance, aliceBalance + expectedRefund);
        assertEq(token.balanceOf(alice), 0);
    }
}
