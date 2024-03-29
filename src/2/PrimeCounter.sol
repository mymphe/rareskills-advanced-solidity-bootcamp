// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeCounter {
    ERC721Enumerable public immutable NFT;

    constructor(address nft) {
        NFT = ERC721Enumerable(nft);
    }

    function countPrimeTokenIdsOf(
        address owner
    ) public view returns (uint256 count) {
        uint256 balance = NFT.balanceOf(owner);
        uint256 tokenId;

        for (uint256 i = 0; i < balance; i++) {
            tokenId = NFT.tokenOfOwnerByIndex(owner, i);
            if (isPrime(tokenId)) {
                count++;
            }
        }
    }

    function isPrime(uint256 number) public pure returns (bool) {
        // 0 and 1 are not prime numbers
        if (number < 2) return false;

        // 2 is the only even prime number
        if (number == 2) return true;

        // All other even numbers are not prime
        if (number % 2 == 0) return false;

        // Check every odd number up to the square root of the number
        // Only need to check up to the square root of the number
        for (uint i = 3; i * i <= number; i += 2) {
            if (number % i == 0) {
                return false;
            }
        }

        // If no divisors were found, the number is prime
        return true;
    }
}
