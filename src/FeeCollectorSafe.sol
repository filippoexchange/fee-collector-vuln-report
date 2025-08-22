// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract FeeCollectorSafe {
    IERC20 public stable;
    address public governor;

    modifier onlyGovernor() {
        require(msg.sender == governor, "Not governor");
        _;
    }

    constructor(address _stable, address _governor) {
        stable = IERC20(_stable);
        governor = _governor;
    }

    function sweepToEscrow(address escrow, uint256 amount) external onlyGovernor {
        require(escrow != address(0), "Invalid escrow");
        require(amount > 0, "Invalid amount");
        require(stable.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(stable.transfer(escrow, amount), "Transfer failed");
    }
}
