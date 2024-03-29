// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IERC721Receiver} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import {RewardToken} from "./RewardToken.sol";
import {NFT} from "./NFT.sol";

contract NftStake is IERC721Receiver, Ownable2Step {
    struct Stake {
        // packed to 256 (160 + 96)
        address staker;
        uint96 lastClaim;
    }

    event StakeSubmitted(address indexed staker, uint256 indexed tokenId);
    event StakeWithdrawn(address indexed staker, uint256 indexed tokenId);
    event RewardsClaimed(address indexed staker, uint256 rewards);

    uint256 public constant REWARD_AMOUNT = 10 ether;
    uint256 public constant REWARD_DURATION = 1 days;

    RewardToken public immutable rewardToken;
    NFT public immutable stakedNft;
    mapping(uint256 tokenId => Stake) internal stakes;

    constructor(
        address _rewardToken,
        address _stakedNft,
        address owner
    ) Ownable(owner) {
        rewardToken = RewardToken(_rewardToken);
        stakedNft = NFT(_stakedNft);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) public returns (bytes4) {
        require(msg.sender == address(stakedNft), "ONLY STAKED NFT");
        require(stakes[tokenId].staker == address(0), "TOKEN ALREADY STAKED");
        require(stakedNft.ownerOf(tokenId) == address(this), "NOT SENT");

        stakes[tokenId] = Stake({
            staker: from,
            lastClaim: uint96(block.timestamp)
        });

        emit StakeSubmitted(from, tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

    function stake(uint256 tokenId) public {
        stakedNft.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function withdraw(uint256 tokenId) public {
        claimRewards(tokenId);
        delete stakes[tokenId];

        stakedNft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit StakeWithdrawn(msg.sender, tokenId);
    }

    function claimRewards(uint256 tokenId) public {
        uint256 rewards = getMyRewards(tokenId);
        require(rewards > 0, "NO REWARDS");

        stakes[tokenId].lastClaim = uint96(block.timestamp);
        rewardToken.mint(msg.sender, rewards);

        emit RewardsClaimed(msg.sender, rewards);
    }

    function getMyRewards(uint256 tokenId) public view returns (uint256) {
        Stake memory _stake = stakes[tokenId];
        require(_stake.staker == msg.sender, "NOT THE OWNER");

        uint256 rewards = ((block.timestamp - _stake.lastClaim) *
            REWARD_AMOUNT) / REWARD_DURATION;

        return rewards;
    }
}
