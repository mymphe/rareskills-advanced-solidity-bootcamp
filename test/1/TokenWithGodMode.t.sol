// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenWithGodMode} from "src/1/TokenWithGodMode.sol";

contract TokenWithGodModeTest is Test {
    TokenWithGodMode token;

    address admin = vm.addr(0x1);
    address alice = vm.addr(0x2);
    address bob = vm.addr(0x3);
    address charlie = vm.addr(0x4);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        token = new TokenWithGodMode(admin, "TokenWithGodMode", "TGM");
    }

    function test_Mint() public {
        vm.prank(admin);
        vm.expectEmit();
        emit Transfer(address(0), alice, 1);
        token.mint(alice, 1);
        assertEq(token.balanceOf(alice), 1);
    }

    function test_Burn() public {
        test_Mint();

        vm.prank(admin);
        vm.expectEmit();
        emit Transfer(alice, address(0), 1);
        token.burn(alice, 1);
        assertEq(token.balanceOf(alice), 0);
    }

    function test_AdminCanTransferTokensWithoutAllowance() public {
        test_Mint();

        assertEq(token.allowance(alice, admin), 0);
        vm.prank(admin);
        vm.expectEmit();
        emit Transfer(alice, bob, 1);
        token.transferFrom(alice, bob, 1);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 1);
    }
}
