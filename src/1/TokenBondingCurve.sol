// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract TokenBondingCurve is ERC20 {
    uint256 public immutable initialPrice;
    uint256 public immutable priceIncrement;
    uint256 private constant precision = 1e18;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialPrice_,
        uint256 priceIncrement_
    )
        ERC20(name, symbol)
    {
        initialPrice = initialPrice_;
        priceIncrement = priceIncrement_;
    }

    function getPriceAt(uint256 sold) internal view returns(uint256) {
        return initialPrice + (sold * priceIncrement / precision);
    }

    function getBuyCost(uint256 amount) public view returns(uint256) {
        uint256 lowestPrice = getPriceAt(totalSupply());
        uint256 highestPrice = getPriceAt(totalSupply() + amount - 1 ether);
        uint256 average = (lowestPrice + highestPrice) / 2;
        uint256 total  = (amount * average) / precision; 

        return total;
    }

    function getSellCost(uint256 amount) public view returns(uint256) {
        uint256 highestPrice = getPriceAt(totalSupply() - 1 ether);
        uint256 lowestPrice = getPriceAt(totalSupply() - amount);
        uint256 average = (lowestPrice + highestPrice) / 2;
        uint256 total  = (amount * average) / precision; 

        return total;
    }

    function buy(uint256 amount) external payable {
        uint256 totalCost = getBuyCost(amount);
        require(msg.value >= totalCost, "Not enough ether");

        _mint(_msgSender(), amount);

        uint256 unspent = msg.value - totalCost;

        if (unspent > 0) {
            (bool success,) = payable(_msgSender()).call{value: unspent}("");
            require(success, "Failed to return unspent ether");
        }
    }

    function sell(uint256 amount, uint256 minTotalSupply) external payable {
        require(balanceOf(_msgSender()) >= amount, "Not enough tokens");
        require(totalSupply() >= minTotalSupply, "Current total supply is too low");

        // this should never be false
        assert(totalSupply() >= amount);

        uint256 sellCost = getSellCost(amount);
        require(sellCost <= address(this).balance, "Not enough ether for refund");

        _burn(_msgSender(), amount);

        (bool success,) = payable(_msgSender()).call{value: sellCost}("");
        require(success);
    }
}
