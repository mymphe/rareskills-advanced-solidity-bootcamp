// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NftStake} from "src/2/NftStake.sol";
import {NFT} from "src/2/NFT.sol";
import {RewardToken} from "src/2/RewardToken.sol";

contract NftStakeTest is Test {
    NftStake nftStake;
    NFT nft;
    RewardToken token;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);
    address charlie = vm.addr(0x3);

    event StakeSubmitted(address indexed staker, uint256 indexed tokenId);
    event StakeWithdrawn(address indexed staker, uint256 indexed tokenId);
    event RewardsClaimed(address indexed staker, uint256 rewards);

    function setUp() public {
        nft = new NFT("");
        token = new RewardToken(alice);
        nftStake = new NftStake(address(token), address(nft), alice);

        vm.prank(alice);
        token.setMinter(address(nftStake));

        vm.deal(alice, 10000 ether);
        vm.deal(bob, 10000 ether);

        vm.prank(alice);
        nft.mint{value: 1 ether}();
        assertEq(nft.ownerOf(0), alice);
    }

    function test_Stake() public {
        vm.startPrank(alice);
        nft.approve(address(nftStake), 0);

        vm.expectEmit();
        emit StakeSubmitted(alice, 0);
        nftStake.stake(0);
        assertEq(nft.ownerOf(0), address(nftStake));
        assertEq(nftStake.getMyRewards(0), 0);
    }

    function test_StakeFailsIfAlreadyStaked() public {
        test_Stake();

        vm.startPrank(address(nftStake));
        vm.expectRevert("TOKEN ALREADY STAKED");
        nftStake.stake(0);
    }

    function test_ClaimRewards() public {
        test_Stake();

        vm.warp(block.timestamp + nftStake.REWARD_DURATION());

        uint256 balanceBefore = token.balanceOf(alice);

        vm.startPrank(alice);
        vm.expectEmit();
        emit RewardsClaimed(alice, nftStake.REWARD_AMOUNT());
        nftStake.claimRewards(0);

        assertEq(
            token.balanceOf(alice) - balanceBefore,
            nftStake.REWARD_AMOUNT()
        );
        assertEq(nftStake.getMyRewards(0), 0);
    }

    function test_ClaimRewardsAfter8Hours() public {
        test_Stake();

        vm.warp(block.timestamp + 8 hours);

        uint256 balanceBefore = token.balanceOf(alice);

        vm.startPrank(alice);
        vm.expectEmit();
        emit RewardsClaimed(alice, (nftStake.REWARD_AMOUNT() / 3));
        nftStake.claimRewards(0);

        assertEq(
            token.balanceOf(alice) - balanceBefore,
            (nftStake.REWARD_AMOUNT() / 3)
        );
        assertEq(nftStake.getMyRewards(0), 0);
    }

    function test_Withdraw() public {
        test_Stake();

        vm.warp(block.timestamp + nftStake.REWARD_DURATION());
        uint256 balanceBefore = token.balanceOf(alice);
        assertEq(nftStake.getMyRewards(0), nftStake.REWARD_AMOUNT());
        vm.startPrank(alice);
        vm.expectEmit();
        emit StakeWithdrawn(alice, 0);
        nftStake.withdraw(0);
        assertEq(
            token.balanceOf(alice) - balanceBefore,
            nftStake.REWARD_AMOUNT()
        );
        assertEq(nft.ownerOf(0), alice);
    }
}
