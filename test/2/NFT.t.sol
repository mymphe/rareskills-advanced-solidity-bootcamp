// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Merkle} from "lib/murky/src/Merkle.sol";
import {NFT} from "src/2/NFT.sol";

contract NFTTest is Test {
    NFT nft;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);
    address charlie = vm.addr(0x3);

    function setUp() public {
        bytes32 root;
        (root, , , ) = getMerkleData();

        nft = new NFT(root);

        vm.deal(alice, 10000 ether);
        vm.deal(bob, 10000 ether);
    }

    function test_Mint() public {
        uint256 balanceBefore = alice.balance;
        vm.prank(alice);
        nft.mint{value: 1 ether}();

        assertEq(nft.ownerOf(nft.tokenId() - 1), alice);
        assertEq(alice.balance, balanceBefore - 1 ether);
    }

    function test_MintWithChange() public {
        uint256 balanceBefore = alice.balance;
        vm.prank(alice);
        nft.mint{value: 1.1 ether}();

        assertEq(nft.ownerOf(nft.tokenId() - 1), alice);
        assertEq(alice.balance, balanceBefore - 1 ether);
    }

    function test_MintFailsMaxSupplyReached() public {
        for (uint256 i = 0; i < 1000; i++) {
            test_Mint();
        }

        assertEq(nft.tokenId(), nft.MAX_SUPPLY());

        vm.prank(alice);
        vm.expectRevert("MAX SUPPLY REACHED");
        nft.mint{value: 1 ether}();
    }

    function test_MintFailsPriceMismatch() public {
        vm.prank(alice);
        vm.expectRevert("PRICE MISMATCH");
        nft.mint{value: 1 ether - 1}();
    }

    function test_MintWithDiscount() public {
        bytes32[] memory bobsProof;
        uint256 bobsIndex;
        (, , bobsProof, bobsIndex) = getMerkleData();

        vm.prank(bob);
        nft.mintWithDiscount{value: 0.9 ether}(bobsProof, bobsIndex);
        assertEq(nft.ownerOf(nft.tokenId() - 1), bob);
    }

    function test_MintWithDiscountFailsToDoubleBuy() public {
        test_MintWithDiscount();

        bytes32[] memory bobsProof;
        uint256 bobsIndex;
        (, , bobsProof, bobsIndex) = getMerkleData();

        vm.prank(bob);
        vm.expectRevert("ALREADY CLAIMED");
        nft.mintWithDiscount{value: 0.9 ether}(bobsProof, bobsIndex);
        assertEq(nft.ownerOf(nft.tokenId() - 1), bob);
    }

    function getMerkleData()
        internal
        returns (
            bytes32 root,
            bytes32[] memory leaves,
            bytes32[] memory bobsProof,
            uint256 bobsIndex
        )
    {
        leaves = new bytes32[](2);

        leaves[0] = keccak256(bytes.concat(keccak256(abi.encode(bob, 0))));
        leaves[1] = keccak256(bytes.concat(keccak256(abi.encode(charlie, 1))));

        Merkle m = new Merkle();
        root = m.getRoot(leaves);

        bobsIndex = 0;
        bobsProof = m.getProof(leaves, bobsIndex);
    }
}
