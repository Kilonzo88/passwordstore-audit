### [S-#] Storing the password on-chain makes it visible to anyone and no longer private

**Description:**  All data stored on chain is public and visible to anyone. The `PasswordStore::s_password` variable is intended to be hidden and only accessible by the owner through the `PasswordStore::getPassword` function.
​
I show one such method of reading any data off chain below.

**Impact:** Anyone is able to read the private password, severely breaking the functionality of the protocol.

**Proof of Concept:** The below test case shows how anyone could read the password directly from the blockchain. We use foundry's cast tool to read directly from the storage of the contract, without being the owner.
Create a locally running chain

make anvil
Deploy the contract to the chain

make deploy
Run the storage tool

We use 1 because that's the storage slot of s_password in the contract.

cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
You'll get an output that looks like this:

0x6d7950617373776f726400000000000000000000000000000000000000000014
You can then parse that hex to a string with:

cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
And get an output of:

myPassword

**Recommended Mitigation:** The current architecture is fundamentally insecure as it stores sensitive data in plaintext on a public ledger. A more robust approach involves off-chain encryption: the user encrypts their password locally and only stores the ciphertext on-chain. This ensures that even though the storage is public, the data remains unreadable without a private decryption key held only by the user.

Furthermore, you should remove the getPassword() view function entirely. While view functions are intended for gasless "calls," there is a significant risk of user error. If a user—or a poorly configured frontend—accidentally submits a transaction to this function instead of a simple call, the following occurs:

- Mempool Exposure: The request, potentially including parameters or the intent to decrypt, is broadcast to public nodes before it is even mined.

- On-Chain Logging: The transaction is recorded in the blockchain's history. If the function returns the decrypted password as a result of a state-changing transaction, that value can be leaked in the transaction's execution trace.

- Permanent Record: Once the decryption request is "sent" as a transaction, it exists forever in the block history, effectively "doxing" the secret you were trying to protect.

By removing the function, you force the user to retrieve the encrypted data directly from storage and decrypt it locally on their own machine, ensuring the sensitive decryption process never touches the network.