import {
  PXE,
  createPXEClient,
  createDebugLogger,
  getSandboxAccountsWallets,
  waitForSandbox,
  AccountWalletWithPrivateKey,
  Contract,
  Fr,
  NotePreimage,
  AztecAddress,
  TxReceipt,
} from "@aztec/aztec.js";

import { MyNoteTestContract } from "../../types/MyNoteTest.js";
import { DeploySentTx } from "node_modules/@aztec/aztec.js/dest/contract_deployer/deploy_sent_tx.js";
import { FieldsOf } from "@aztec/foundation/types";

let pxe: PXE;
let testContract: MyNoteTestContract;

let addressOne: AccountWalletWithPrivateKey;
let addressTwo: AccountWalletWithPrivateKey;

// Setup: Set the sandbox
beforeAll(async () => {
  const { SANDBOX_URL = "http://localhost:8080" } = process.env;
  pxe = createPXEClient(SANDBOX_URL);
  await waitForSandbox(pxe);
  [addressOne, addressTwo] = await getSandboxAccountsWallets(pxe);
}, 30_000);

describe("E2E test immutable singleton", () => {
  describe("submit_question(..)", () => {
    let receipt: FieldsOf<TxReceipt>;

    // Store the address two as mock data
    it("Deploys the contract", async () => {
      // Deploy and init singletong to address(69)
      let receipt = MyNoteTestContract.deploy(
        pxe,
        AztecAddress.fromBigInt(69n)
      ).send();

      testContract = await receipt.deployed();

      // Add note to pxe
      await pxe.addNote(
        addressOne.getAddress(),
        testContract.address,
        new Fr(1),
        new NotePreimage([new Fr(69)]),
        await receipt.getTxHash()
      );
    });

    // Do whatever which uses this singleton
    it("Test", async () => {
      const receipt2 = await testContract
        .withWallet(addressTwo)
        .methods.test_uses_my_note()
        .send()
        .wait();

      expect(receipt2.status).toBe("mined");
    });
  });
});
