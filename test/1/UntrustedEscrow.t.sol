// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {UntrustedEscrow} from "src/1/UntrustedEscrow.sol";
import {TokenBannable} from "src/1/TokenBannable.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow escrow;
    TokenBannable token;

    address admin = vm.addr(0x1);
    address alice = vm.addr(0x2);
    address bob = vm.addr(0x3);
    address charlie = vm.addr(0x4);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        escrow = new UntrustedEscrow();
        token = new TokenBannable(admin, "Token", "TKN");

        vm.prank(admin);
        token.mint(alice, 100 ether);
    }

    function test_Pay() public {
        assertEq(token.balanceOf(alice), 100 ether);

        vm.startPrank(alice);
        vm.expectEmit();
        emit Approval(alice, address(escrow), 1 ether);
        token.approve(address(escrow), 1 ether);
        emit Transfer(alice, address(escrow), 1 ether);
        escrow.pay(bob, address(token), 1 ether, 3 days);

        assertEq(token.balanceOf(alice), 99 ether);
        assertEq(token.balanceOf(address(escrow)), 1 ether);
        assertEq(token.balanceOf(bob), 0 ether);

        UntrustedEscrow.Escrow memory _escrow = escrow.getEscrow(alice, bob, address(token));
        assertEq(_escrow.id, keccak256(abi.encodePacked(alice, bob, token)));
        assertEq(_escrow.from, alice);
        assertEq(_escrow.to, bob);
        assertEq(_escrow.token, address(token));
        assertEq(_escrow.amount, 1 ether);
        assertEq(_escrow.timestamp, block.timestamp);
        assertEq(_escrow.timelock, 3 days);

        vm.stopPrank();
    }

    function test_Withdraw() public {
        test_Pay();

        skip(3 days);

        vm.prank(bob);
        vm.expectEmit();
        emit Transfer(address(escrow), bob, 1 ether);
        escrow.withdraw(alice, address(token));

        assertEq(token.balanceOf(alice), 99 ether);
        assertEq(token.balanceOf(address(escrow)), 0);
        assertEq(token.balanceOf(bob), 1 ether);

        // reverts when attempted to withdraw again
        vm.prank(bob);
        vm.expectRevert("Escrow does not exist or withdrawn");
        escrow.withdraw(alice, address(token));
    }

    function test_WithdrawFailsWhenAttemptedByStranger() public {
        test_Pay();

        skip(3 days);

        vm.prank(charlie);
        vm.expectRevert("Escrow does not exist or withdrawn");
        escrow.withdraw(alice, address(token));
    }

    function test_WithdrawFailsWhenTooEarly() public {
        test_Pay();

        skip(3 days - 1);

        vm.prank(bob);
        vm.expectRevert("Too early to withdraw");
        escrow.withdraw(alice, address(token));
    }
}
