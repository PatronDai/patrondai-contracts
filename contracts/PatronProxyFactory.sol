pragma solidity ^0.5.0;

import {PatronProxy} from "./PatronProxy.sol";

contract PatronProxyFactory {
    event Deployed(address addr, uint256 salt);

    address daiAddress;
    address uniswapAddress;

    constructor(address _daiAddress, address _uniswapAddress) public {
        daiAddress = _daiAddress;
        uniswapAddress = _uniswapAddress;
    }

    function deployProxy(uint256 _salt) external {
        address addr;
        bytes memory bytecode = abi.encodePacked(
            type(PatronProxy).creationCode,
            abi.encode(daiAddress, uniswapAddress, address(this))
        );

        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, _salt);
    }
}
