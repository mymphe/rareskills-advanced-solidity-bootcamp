// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TokenBannable is ERC20, Ownable {
    error AccountBanned(address account);

    event Banned(address indexed account);
    event Unbanned(address indexed account);

    mapping(address account => bool isBanned) private _banned;

    constructor(address admin, string memory name, string memory symbol)
        ERC20(name, symbol)
        Ownable(admin)
    {}

    modifier onlyNotBanned(address account) {
        if (isBanned(account)) revert AccountBanned(account);
        _;
    }

    function isBanned(address account) public view returns(bool) {
        return _banned[account];
    }

    function ban(address account) external onlyOwner() {
        _banned[account] = true;
        emit Banned(account);
    }

    function unban(address account) external onlyOwner() {
        _banned[account] = false;
        emit Unbanned(account);
    }

    function transfer(address to, uint256 value)
        public
        override
        onlyNotBanned(msg.sender)
        onlyNotBanned(to)
        returns(bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override
        onlyNotBanned(from)
        onlyNotBanned(to)
        returns(bool)
    {
        return super.transferFrom(from, to, value);
    }

    function mint(address account, uint256 value) external onlyOwner() {
        super._mint(account, value);
    }

    function burn(address account, uint256 value) external onlyOwner() {
        super._burn(account, value);
    }
}
