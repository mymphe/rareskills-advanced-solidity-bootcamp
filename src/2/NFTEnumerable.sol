// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract NFTEnumerable is ERC721Enumerable, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant PRICE = 1 ether;
    uint256 public nextTokenId = 1;

    constructor(address owner) ERC721("NFT", "NFT") Ownable(owner) {}

    function mint() public onlyOwner {
        require(MAX_SUPPLY <= 100, "MAX SUPPLY REACHED");
        super._safeMint(msg.sender, nextTokenId);
        nextTokenId++;
    }
}
