// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/FeeCollectorSafe.sol";
import "../src/mocks/MockUSDC.sol";

contract FeeCollectorSafeTest is Test {
    FeeCollectorSafe fee;
    MockUSDC usdc;

    address governor = address(0xA11CE);
    address attacker = address(0xBEEF);
    address escrow   = address(0xf44C81dbab89941173d0d49C1CEA876950eDCfd3);

    function setUp() public {
        usdc = new MockUSDC();
        fee  = new FeeCollectorSafe(address(usdc), governor);
        usdc.mint(address(fee), 500e6);
    }

    function testAttackerBlocked() public {
        vm.startPrank(attacker);
        vm.expectRevert(bytes("Not governor"));
        fee.sweepToEscrow(escrow, 100e6);
        vm.stopPrank();

        assertEq(usdc.balanceOf(escrow), 0);
        assertEq(usdc.balanceOf(address(fee)), 500e6);
    }

    function testGovernorCanSweep() public {
        vm.prank(governor);
        fee.sweepToEscrow(escrow, 120e6);
        assertEq(usdc.balanceOf(escrow), 120e6);
        assertEq(usdc.balanceOf(address(fee)), 380e6);
    }
}
