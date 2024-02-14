// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenBannable} from "src/1/TokenBannable.sol";

contract TokenBannableTest is Test {
    TokenBannable token;

    address admin = vm.addr(0x1);
    address alice = vm.addr(0x2);
    address bob = vm.addr(0x3);
    address charlie = vm.addr(0x4);

    error AccountBanned(address account);

    event Banned(address indexed account);
    event Unbanned(address indexed account);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        token = new TokenBannable(admin, "TokenBannable", "TBN");
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

    function test_Ban() public {
        vm.prank(admin);
        vm.expectEmit();
        emit Banned(alice);
        token.ban(alice);
        assertTrue(token.isBanned(alice));
    }

    function test_Unban() public {
        test_Ban();

        vm.prank(admin);
        vm.expectEmit();
        emit Unbanned(alice);
        token.unban(alice);

        assertFalse(token.isBanned(alice));
    }

    function test_TransferFailsIfSenderIsBanned() public {
        test_Ban();

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(AccountBanned.selector, alice));
        token.transfer(bob, 0);
    }

    function test_TransferFailsIfRecipientIsBanned() public {
        test_Ban();

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(AccountBanned.selector, alice));
        token.transfer(alice, 0);
    }

    function test_TransferFromFailsIfOwnerIsBanned() public {
        test_Ban();

        vm.prank(alice);
        token.approve(charlie, 1);

        vm.prank(charlie);
        vm.expectRevert(abi.encodeWithSelector(AccountBanned.selector, alice));
        token.transferFrom(alice, bob, 0);
    }

    function test_TransferFromFailsIfRecipientIsBanned() public {
        test_Ban();

        vm.prank(bob);
        token.approve(charlie, 1);

        vm.prank(charlie);
        vm.expectRevert(abi.encodeWithSelector(AccountBanned.selector, alice));
        token.transferFrom(bob, alice, 0);
    }
}
