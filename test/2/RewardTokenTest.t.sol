// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {RewardToken} from "src/2/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken token;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);

    function setUp() public {
        token = new RewardToken(alice);
        vm.prank(alice);
        token.setMinter(alice);

        vm.deal(alice, 10000 ether);
        vm.deal(bob, 10000 ether);
    }

    function test_Mint() public {
        vm.prank(alice);
        token.mint(bob, 1);
        assertEq(token.balanceOf(bob), 1);
    }

    function test_MintFailsIfCalledByStranger() public {
        vm.prank(bob);
        vm.expectRevert("ONLY MINTER");
        token.mint(bob, 1);
    }

    function test_SetMiner() public {
        assertEq(token.minter(), alice);
        vm.prank(alice);
        token.setMinter(bob);
        assertEq(token.minter(), bob);
    }
}
