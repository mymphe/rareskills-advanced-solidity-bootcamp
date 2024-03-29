// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NFTEnumerable} from "src/2/NFTEnumerable.sol";
import {PrimeCounter} from "src/2/PrimeCounter.sol";

contract NFTEnumerableTest is Test {
    NFTEnumerable nft;
    PrimeCounter primeCounter;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);

    function setUp() public {
        nft = new NFTEnumerable(alice);
        primeCounter = new PrimeCounter(address(nft));

        vm.deal(alice, 10000 ether);
    }

    function test_Mint20Tokens() public {
        vm.startPrank(alice);

        for (uint256 i = 0; i < 20; i++) {
            nft.mint();
        }

        assertEq(nft.balanceOf(alice), 20);
    }

    function test_CountPrimesTokenIdsOf() public {
        test_Mint20Tokens();

        assertEq(primeCounter.countPrimeTokenIdsOf(alice), 8);
    }

    function test_IsPrime() public {
        assertFalse(primeCounter.isPrime(1));
        assertFalse(primeCounter.isPrime(18));
        assertFalse(primeCounter.isPrime(100));
        assertFalse(primeCounter.isPrime(256));
        assertFalse(primeCounter.isPrime(1000));

        assertTrue(primeCounter.isPrime(2));
        assertTrue(primeCounter.isPrime(17));
        assertTrue(primeCounter.isPrime(137));
        assertTrue(primeCounter.isPrime(449));
        assertTrue(primeCounter.isPrime(1153));
    }
}
