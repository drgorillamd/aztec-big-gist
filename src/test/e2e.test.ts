import { createSandbox } from "@aztec/aztec-sandbox";
import {
  AccountWallet,
  CheatCodes,
  Fr,
  L2BlockL2Logs,
  NotePreimage,
  PXE,
  UnencryptedL2Log,
  computeMessageSecretHash,
  createAccount,
  createPXEClient,
  createDebugLogger,
  getSandboxAccountsWallets,
  waitForSandbox,
  AztecAddress,
  AccountWalletWithPrivateKey,
  EthAddress,
  computeAuthWitMessageHash,
  TxHash,
} from "@aztec/aztec.js";
import { toBigIntBE } from "@aztec/foundation/bigint-buffer";
import { format } from "util";

import { MyNoteTestContract } from "../../types/MyNoteTest.js";

let pxe: PXE;
let testContract: MyNoteTestContract;

let addressOne: AccountWalletWithPrivateKey;
let addressTwo: AccountWalletWithPrivateKey;

const logger = createDebugLogger("oracle");

// Setup: Set the sandbox
beforeAll(async () => {
  const { SANDBOX_URL = "http://localhost:8080" } = process.env;
  pxe = createPXEClient(SANDBOX_URL);
  await waitForSandbox(pxe);

  const nodeInfo = await pxe.getNodeInfo();

  logger(format("Aztec Sandbox Info ", nodeInfo));

  [addressOne, addressTwo] = await getSandboxAccountsWallets(pxe);
}, 30_000);

describe("E2E Private Oracle", () => {
  describe.only("submit_question(..)", () => {
    // Store the address two as mock data
    it("Deploys the contract", async () => {
      // Deploy the oracle
      testContract = await MyNoteTestContract.deploy(
        pxe,
        addressTwo.getAddress()
      )
        .send()
        .deployed();
    });

    // Test: is the tx successful
    it("Tx to submit_question is mined", async () => {
      const receipt = await testContract
        .withWallet(addressOne)
        .methods.test()
        .send()
        .wait();

      expect(receipt.status).toBe("mined");
    });
  });
});
