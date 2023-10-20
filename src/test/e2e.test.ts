import {
  PXE,
  createPXEClient,
  createDebugLogger,
  getSandboxAccountsWallets,
  waitForSandbox,
  AccountWalletWithPrivateKey,
} from "@aztec/aztec.js";

import { MyNoteTestContract } from "../../types/MyNoteTest.js";

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
  describe.only("submit_question(..)", () => {
    // Store the address two as mock data
    it("Deploys the contract", async () => {
      testContract = await MyNoteTestContract.deploy(
        pxe,
        addressTwo.getAddress()
      )
        .send()
        .deployed();
    });

    // This call will fails
    it("Tx to submit_question is mined", async () => {
      const receipt = await testContract
        .withWallet(addressOne)
        .methods.test_uses_my_note()
        .send()
        .wait();

      expect(receipt.status).toBe("mined");
    });
  });
});
