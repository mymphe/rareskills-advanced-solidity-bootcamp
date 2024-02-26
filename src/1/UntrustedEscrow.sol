// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "forge-std/console.sol";

contract UntrustedEscrow {
    using SafeERC20 for IERC20;

    struct Escrow {
        bytes32 id;
        address from;
        address to;
        address token;
        uint256 amount;
        uint256 timestamp;
        uint256 timelock;
    }

    mapping(bytes32 => Escrow) private escrows;

    function getEscrow(address from, address to, address token) public view returns (Escrow memory escrow) {
        bytes32 escrowId = keccak256(abi.encodePacked(from, to, token));
        escrow = escrows[escrowId];
    }

    function pay(address to, address token, uint256 amount, uint256 timelock) external {
        require(to != address(0), "Invalid recipient");
        require(token != address(0), "Invalid token");
        require(amount > 0, "Amount must be non-zero");
        require(timelock > 0, "Timelock must be non-zero");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        bytes32 escrowId = keccak256(abi.encodePacked(msg.sender, to, token));

        escrows[escrowId] = Escrow({
            id: escrowId,
            from: msg.sender,
            to: to,
            token: token,
            amount: amount,
            timestamp: block.timestamp,
            timelock: timelock
        });
    }

    function withdraw(address from, address token) external {
        bytes32 escrowId = keccak256(abi.encodePacked(from, msg.sender, token));

        Escrow memory escrow = getEscrow(from, msg.sender, token);
        require(escrow.id == escrowId, "Escrow does not exist or withdrawn");
        require(block.timestamp >= escrow.timestamp + escrow.timelock, "Too early to withdraw");
        delete escrows[escrow.id];

        IERC20(escrow.token).safeTransfer(msg.sender, escrow.amount);
    }
}
