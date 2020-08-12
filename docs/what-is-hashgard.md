# What is Infinitefuture?

`infinitefuture` is the name of the Infinitefuture SDK application for the Infinitefuture Hub. It comes with 2 main entrypoints:

- `infinitefutured`: The Infinitefuture Daemon, runs a full-node of the `infinitefuture` application.
- `infinitefuturecli`: The Infinitefuture command-line interface, which enables interaction with a Infinitefuture full-node.

`infinitefuture` is built on the Infinitefuture SDK using the following modules:

- `x/auth`: Accounts and signatures.
- `x/bank`: Token transfers.
- `x/staking`: Staking logic.
- `x/mint`: Inflation logic.
- `x/distribution`: Fee distribution logic.
- `x/slashing`: Slashing logic.
- `x/gov`: Governance logic.
- `x/ibc`: Inter-blockchain transfers.
- `x/params`: Handles app-level parameters.

>About the Infinitefuture Hub: The Infinitefuture Hub is the first Hub to be launched in the Infinitefuture Network. The role of a Hub is to facilitate transfers between blockchains. If a blockchain connects to a Hub via IBC, it automatically gains access to all the other blockchains that are connected to it. The Infinitefuture Hub is a public Proof-of-Stake chain. Its staking token is called the Gard.

Next, learn how to [install Infinitefuture](./installation.md).
