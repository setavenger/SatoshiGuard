
# Satoshi Guard
This is a work in progress iOS app to create and manage Bitcoin mulitsignature wallets. The app was created using the Bitcoin Development Kit (BDK) and was heavily inspired by the [BDKSwiftSample](https://github.com/futurepaul/BdkSwiftSample) app.

### Technical Details
Currently a multisignature wallet is created from three keys so an m-of-3 wallet is created in the app. In the future it will be possible to create a multisignature wallet with any number of keys. 
Private keys are created from a 12 or 24 word mnemonic seed. The extended public keys are derived at the derivation path `m/84'/1'/0'/0`. For the multisignatue wallet the descriptor is `wsh(sortedmulti(<threshold>,<xprv>/84'/1'/0'/0/*,<xpub_1>,<...>,<xpub_n>))`. An example xpub looks like this `[f633291d/84'/1'/0'/0]tpubDFRv1ZiyjayHHiJgzFtf18nTdCC94Ga2hbLXmz77JiHJNvDgRjuEFBHezZGsbWe4o2jiWp5xCSi3mz3Gqdqnqm22Wu8aevGvTuQjg423J3z/*` and a possible extended private key (xprv) will look like this `tprv8ZgxMBicQKsPctqTQfSWzH3Gf7rbQymf3shwKBidXjdzFivui85uKgMJTjc1Er73QtAErKCVvwYwUiekbQxKAB7mSuJLFG34foKnG7dQUNF`. Keep in mind that these are testnet keys. The wallets can be recovered using any descriptor based wallet software (e.g. [bdk-cli](https://github.com/bitcoindevkit/bdk-cli)).


## Todos
- [x] Activate mainnet capabilities
- [x] Enable flexible number of m-of-n multisig wallets
- [ ] Better handling of change utxos in balance
- [ ] Fix thread blocking syncs when switching to receive view to fast after opening home view
- [ ] Improve error handling
- [ ] Write tests


## Caveats
Currently the balance display is not optimal. The change from a sending transaction is counted as untrusted and is therefor not counted into the balance. So if a wallet only has one utxo and sends a transaction the balance will be temporarily displayed as zero. The reason is that the one utxo that the wallet held is spent and the change is not yet reconized as settled. A better handling of this situation is on the todo list. 
