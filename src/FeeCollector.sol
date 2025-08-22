// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract FeeCollector {
    IERC20 public immutable stable;
    address public immutable governor;

    constructor(address _stable, address _governor) {
        stable = IERC20(_stable);
        governor = _governor;
    }

    // VULNERABILE: nessun controllo accessi
    function sweepToEscrow(address escrow, uint256 amount) external {
        require(escrow != address(0), "escrow=0");
        require(amount > 0, "amount=0");
        require(stable.transfer(escrow, amount), "transfer failed");
    }
}
