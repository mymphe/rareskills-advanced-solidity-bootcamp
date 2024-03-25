// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable2Step {
    address public minter;

    modifier onlyMinter() {
        require(msg.sender == minter, "ONLY MINTER");
        _;
    }

    constructor(address owner) ERC20("Reward Token", "RWD") Ownable(owner) {
        minter = owner;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

    function setMinter(address newMinter) external onlyOwner {
        minter = newMinter;
    }
}
