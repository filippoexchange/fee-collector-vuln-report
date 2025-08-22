# fee-collector-vuln-report
Proof of concept and solution for the FeeCollector sweepToEscrow vulnerability (money loss).
README.md
Overview of the FeeCollector Vulnerability Report and Fix
A critical vulnerability existed in the original FeeCollector.sol contract: Chiunque could call the sweepToEscrow function and transfer all funds arbitrarily to a chosen destination.

Questo has a total financial loss.

The function sweepToEscrow (address escrow, uint256 amount) external { stable.transfer(escrow, amount);} is vulnerable.
Only Governor Nessun
Nessun regulates the amount
Escrow validation!= 0x0 Proof of Concept (PoC)
Test/FeeCollector_poc.spec.ts is the file.

Exploitation of reproduction:

// The attacker tries to transfer USDC to the victim's wallet and waits for fee.connect (attacker).sweepToEscrow(attacker.address, ethers.parseUnits("500", 6)); the test illustrates how an attacker could breach the contract.

Fix File: contracts/FeeCollectorSafe.sol

modifier onlyGovernor() { require(msg.sender == governor, "Not governor"); }
function sweepToEscrow(address escrow, uint256 amount) that is only externalThe governor { require(escrow!= address(0), "Invalid escrow"); require(amount > 0, "Invalid amount"); require(stable.balanceOf(address(this)) >= amount, "Insufficient balance"); bool ok = stable.transfer(escrow, amount); require(ok, "Transfer failed"); }
 Fix File Verification: test/FeeCollector_fix.spec.ts

Attacker not riesce → returns "Not governor."
Governor Riesce → Fondi trasferiti apropretamente.
The npx hardhat test
Atteso output:

FeeCollectorSafe
   Permette solely the sweepare governor (500ms)
 Repo Structure contracts/ ├─ FeeCollector.sol └─ # Vulnerable └─ FeeCollectorSafe.sol └─ # Fixed test/ ├─ FeeCollector_poc.spec.ts # PoC exploit └─ FeeCollector_fix.spec.ts # Fix verification
README.md # This document
Suggestion
Usare Safe multisig becomes the governor.
Add event logging to your ogni sweep.
Integrate kill-switch and cap-giornalier controls to reduce future operational risks.
