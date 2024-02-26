// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TokenWithGodMode is ERC20, Ownable {
    constructor(address admin, string memory name, string memory symbol) ERC20(name, symbol) Ownable(admin) {}

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (_msgSender() == owner()) {
            super._transfer(from, to, value);
            return true;
        }

        return super.transferFrom(from, to, value);
    }

    function mint(address account, uint256 value) external onlyOwner {
        super._mint(account, value);
    }

    function burn(address account, uint256 value) external onlyOwner {
        super._burn(account, value);
    }
}
