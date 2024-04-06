// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.21;

import {UniswapV2Pair} from "./UniswapV2Pair.sol";

contract UniswapV2Factory {
    event PairCreated(address pair);

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) private pairMap;
    address[] public pairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        require(tokenA != tokenB, "SAME TOKEN");

        // asc sort tokens by address
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        // token0 address is always a smaller number, so we only need to check token0
        require(token0 != address(0), "ZERO ADDRESS");

        require(pairMap[token0][token1] == address(0), "PAIR EXISTS");

        pair = address(
            new UniswapV2Pair{
                salt: keccak256(abi.encodePacked(token0, token1))
            }()
        );

        UniswapV2Pair(pair).initialize(token0, token1);

        pairMap[token0][token1] = pair;
        pairMap[token1][token0] = pair;
        pairs.push(pair);

        emit PairCreated(pair);
    }

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address) {
        return pairMap[tokenA][tokenB];
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "ONLY FEE_TO_SETTER");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "ONLY FEE_TO_SETTER");
        feeToSetter = _feeToSetter;
    }
}
