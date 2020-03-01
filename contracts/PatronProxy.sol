pragma solidity ^0.5.0;

import {UniswapExchangeInterface} from "./interfaces/Uniswap.sol";
import {
    IERC20
} from "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

import {
    Counters
} from "@openzeppelin/contracts-ethereum-package/contracts/drafts/Counters.sol";
import {
    SafeMath
} from "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

contract PatronProxy {
    // Namespaces declaration
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    event Initialized(bool success);

    address owner;
    Counters.Counter nonce;

    address daiTokenAddress;
    IERC20 daiToken;

    address uniswapExchangeAddress;
    UniswapExchangeInterface uniswap;

    constructor(
        address _owner,
        address _daiTokenAddress,
        address _uniswapAddress,
        address _factoryAddress
    ) public {
        uint256 startGas = gasleft();
        owner = _owner;

        daiTokenAddress = _daiTokenAddress;
        daiToken = IERC20(_daiTokenAddress);

        uniswapExchangeAddress = _uniswapAddress;
        uniswap = UniswapExchangeInterface(_uniswapAddress);

        require(
            msg.sender != tx.origin,
            "PatronProxy::PatronProxy only the proxy factory can initialize a new proxy"
        );

        require(
            msg.sender == _factoryAddress,
            "PatronProxy::PatronProxy invalid initializer"
        );

        uint256 daiGasRefund = uniswap.getTokenToEthOutputPrice(
            ((startGas - gasleft() + 100000) * tx.gasprice) / 1 ether
        );

        daiToken.transfer(msg.sender, daiGasRefund);
    }

    // Forward Tx
    function forwardTx(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        uint256 startGas = gasleft();

        bytes32 messageHash = calculateMessageHash(
            address(this),
            to,
            value,
            data,
            nonce.current()
        );
        require(
            ecrecover(messageHash, _v, _r, _s) == owner,
            "PatronProxy::forwardTx signature mismatch"
        );
        require(execute(to, value, data), "Transaction failed");

        uint256 daiGasRefund = uniswap.getTokenToEthOutputPrice(
            ((startGas - gasleft() + 100000) * tx.gasprice) / 1 ether
        );

        daiToken.transfer(msg.sender, daiGasRefund);
    }

    // Executor

    function execute(address to, uint256 value, bytes memory data)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function calculateMessageHash(
        address from,
        address to,
        uint256 value,
        bytes memory data,
        uint256 currentNonce
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(from, to, value, keccak256(data), currentNonce)
            );
    }

}
