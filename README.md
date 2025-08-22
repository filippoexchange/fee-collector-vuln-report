# fee-collector-vuln-report
Proof of Concept and Fix for FeeCollector sweepToEscrow vulnerability(loss of funds).
README.md
FeeCollector Vulnerability Report & Fix
Overview
Il contratto originale FeeCollector.sol presentava una vulnerabilità critica:
chiunque poteva chiamare la funzione sweepToEscrow e trasferire arbitrariamente tutti i fondi verso un indirizzo scelto.

Questo comporta una loss of funds totale.

⚠ Vulnerable Code
function sweepToEscrow(address escrow, uint256 amount) external {
    stable.transfer(escrow, amount);
}
Nessun onlyGovernor
Nessun controllo su amount
Nessuna validazione escrow != 0x0
Proof of Concept (PoC)
File: test/FeeCollector_poc.spec.ts

Riproduzione exploit:

// Attacker riesce a sweepare USDC verso il proprio wallet
await fee.connect(attacker).sweepToEscrow(attacker.address, ethers.parseUnits("500", 6));
Test dimostra che un attacker può svuotare il contratto.

Fix
File: contracts/FeeCollectorSafe.sol

modifier onlyGovernor() {
    require(msg.sender == governor, "Not governor");
    _;
}

function sweepToEscrow(address escrow, uint256 amount) external onlyGovernor {
    require(escrow != address(0), "Invalid escrow");
    require(amount > 0, "Invalid amount");
    require(stable.balanceOf(address(this)) >= amount, "Insufficient balance");
    bool ok = stable.transfer(escrow, amount);
    require(ok, "Transfer failed");
}
 Verification of Fix
File: test/FeeCollector_fix.spec.ts

Attacker non riesce → revert con "Not governor".
Governor riesce → fondi trasferiti correttamente.
npx hardhat test
Output atteso:

FeeCollectorSafe
   Permette solo al governor di sweepare (500ms)
 Repo Structure
contracts/
 ├─ FeeCollector.sol          # Vulnerable
 └─ FeeCollectorSafe.sol      # Fixed
test/
 ├─ FeeCollector_poc.spec.ts  # PoC exploit
 └─ FeeCollector_fix.spec.ts  # Verification of fix
README.md                     # This file
Recommendation
Usare Safe multisig come governor.
Aggiungere event logging su ogni sweep.
Integrare controlli su cap giornaliero e kill-switch per mitigare rischi operativi futuri.
