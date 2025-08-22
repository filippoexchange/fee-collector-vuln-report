import { expect } from "chai";
import { ethers } from "hardhat";

describe("FeeCollectorSafe", function () {
  it("Permette solo al governor di sweepare", async function () {
    const [deployer, governor, escrow, attacker] = await ethers.getSigners();

    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const usdc = await MockUSDC.deploy("MockUSDC", "mUSDC", 6);
    await usdc.mint(deployer.address, ethers.parseUnits("1000", 6));

    const FeeCollectorSafe = await ethers.getContractFactory("FeeCollectorSafe");
    const fee = await FeeCollectorSafe.deploy(await usdc.getAddress(), governor.address);

    // Manda fondi al FeeCollectorSafe
    await usdc.transfer(await fee.getAddress(), ethers.parseUnits("500", 6));

    // ❌ Attacker prova a sweepare
    await expect(
      fee.connect(attacker).sweepToEscrow(escrow.address, ethers.parseUnits("100", 6))
    ).to.be.revertedWith("Not governor");

    // ✅ Governor riesce
    await expect(
      fee.connect(governor).sweepToEscrow(escrow.address, ethers.parseUnits("100", 6))
    ).to.emit(usdc, "Transfer").withArgs(await fee.getAddress(), escrow.address, ethers.parseUnits("100", 6));

    const balance = await usdc.balanceOf(escrow.address);
    expect(balance).to.equal(ethers.parseUnits("100", 6));
  });
});
