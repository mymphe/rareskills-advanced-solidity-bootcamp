// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract NFT is ERC721, ERC2981, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant PRICE = 1 ether;
    uint256 public constant DISCOUNTED_PRICE = 0.9 ether;
    uint256 public constant ROYALTY_PERCENT = 250; // 2.5%
    uint256 public constant BASIS_POINTS = 10_000;

    bytes32 public immutable discountsRoot;

    BitMaps.BitMap private discountBitMap;
    uint256 public tokenId = 0;

    constructor(
        bytes32 _discountsRoot
    ) ERC721("NFT", "NFT") Ownable(msg.sender) {
        discountsRoot = _discountsRoot;
    }

    function mint() external payable {
        _mint(PRICE);
    }

    function mintWithDiscount(
        bytes32[] calldata proof,
        uint256 index
    ) external payable {
        require(!discountBitMap.get(tokenId), "TOKEN ALREADY CLAIMED");
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, index)))
        );
        require(
            MerkleProof.verify(proof, discountsRoot, leaf),
            "DISCOUNT NOT FOUND"
        );
        discountBitMap.set(tokenId);

        _mint(DISCOUNTED_PRICE);
    }

    function _mint(uint256 price) internal {
        require(tokenId < 1000, "MAX SUPPLY REACHED");
        require(msg.value == price, "PRICE MISMATCH");
        super._safeMint(msg.sender, tokenId, "");
        tokenId++;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC2981) returns (bool) {
        return
            interfaceId == type(ERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
