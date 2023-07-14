//
//  WalletManager.swift
//  BDKTests
//
//  Created by Setor Blagogee on 10.07.23.
//

import Foundation
import SwiftUI
import BitcoinDevKit


class WalletManager: ObservableObject {
    
    @AppStorage("multisigDescriptor") var multisigDescriptor: String = ""
    @AppStorage("xprvbool") var xprvBool: Bool = false
    
    @AppStorage("xpub1") var xpub1: String = ""
    @AppStorage("xpub2") var xpub2: String = ""
    @AppStorage("threshold") var threshold: Int = 1
//    @AppStorage("network") var networkStr: String = "testnet"
//
//    var network: Network = .testnet
    private(set) var wallet: Wallet?
    private(set) var balance: UInt64 = 21_210_210
    @Published private(set) var balanceText: String = "Setup Keys"
    @Published private(set) var transactions: [BitcoinDevKit.TransactionDetails] = []
    
    var blockchain: Blockchain?
    @Published var xprv = ""
    var xpub = ""
    
    
//    init() {
//        switch networkStr {
//        case "bitcoin":
//            network = Network.bitcoin
//        case "testnet":
//            network = Network.testnet
//        case "regtest":
//            network = Network.regtest
//        case "signet":
//            network = Network.signet
//        default:
//            network = Network.testnet
//        }
//    }
    
    public func buildMultiSigDescriptor(xpub1: String, xpub2: String, threshold: Int) {
        self.multisigDescriptor = "wsh(sortedmulti(\(threshold),\(xprv)/84'/1'/0'/0/*,\(xpub1),\(xpub2)))"
//        print(self.multisigDescriptor)
    }
    
    public func SignPSBT(psbtString: String) throws -> PartiallySignedTransaction {
        
            let psbt = try PartiallySignedTransaction(psbtBase64: psbtString)
            let _ = try self.wallet!.sign(psbt: psbt, signOptions: nil)
            
            return psbt
    }
    
    func createTransaction(recipient: String, amount: UInt64, txFee: Double) throws -> PartiallySignedTransaction {
        do {
            let address = try Address(address: recipient)
            let script = address.scriptPubkey()
            var txBuilder = TxBuilder().addRecipient(script: script, amount: amount)
            txBuilder = txBuilder.enableRbf()
            print(Float(txFee))
            txBuilder = txBuilder.feeRate(satPerVbyte: Float(txFee))
            print(txBuilder.self)
            let details = try txBuilder.finish(wallet: wallet!)
            let _ = try wallet!.sign(psbt: details.psbt, signOptions: nil)
            
            return details.psbt
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func Broadcast(psbt: PartiallySignedTransaction) throws-> String {
        let tx = psbt.extractTx()
        try blockchain!.broadcast(transaction: tx)
        let txid = psbt.txid()
        print(txid)
        return txid
    }
    
    public func LoadWords(words: String) throws -> Void {
        do {
            let mnemonic = try Mnemonic.fromString(mnemonic: words)
            let descriptorNew = DescriptorSecretKey(network: Network.testnet, mnemonic: mnemonic, password: "")
            
            self.xprv = descriptorNew.asString().replacingOccurrences(of: "/*", with: "")
            xprvBool = true
            
            try self.storeXprvKey(xprvKeyData: self.xprv)
            try computeXpub()
            
            print(self.xpub)
            if xpub1 != "" && xpub2 != "" {
                self.buildMultiSigDescriptor(xpub1: xpub1, xpub2: xpub2, threshold: threshold)
                try self.load()
            }
        } catch {
            print("\(error)")
        }
    }
    
    func load() throws {
        if multisigDescriptor == "" {
//            throw Error("no multi sig descriptor built yet")
            return
        }
        let db = DatabaseConfig.memory

        do {
            try self.loadXprvKey()

            let electrum = ElectrumConfig(url: "ssl://electrum.blockstream.info:60002", socks5: nil, retry: 5, timeout: nil, stopGap: 10, validateDomain: true)
            let blockchainConfig = BlockchainConfig.electrum(config: electrum)
            self.blockchain = try Blockchain(config: blockchainConfig)

            self.wallet = try Wallet(descriptor: Descriptor.init(descriptor: multisigDescriptor, network: Network.testnet), changeDescriptor: nil, network: Network.testnet, databaseConfig: db)
        } catch {
            print("\(error)")
            throw error
        }
    }
    
    func sync() {
        if multisigDescriptor == "" {
//            throw Error("no multi sig descriptor built yet")
            return
        }
        if self.balanceText == "Setup Keys" {
            self.balanceText = "syncing"
        }

        DispatchQueue.global().async {
            print("syncing started")

            do {
                // TODO use this progress update to show "syncing"
                try self.wallet!.sync(blockchain: self.blockchain!, progress: nil)
                let balance = try self.wallet!.getBalance().confirmed
                let wallet_transactions: [TransactionDetails] = try self.wallet!.listTransactions(includeRaw: false)

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal // this is what adds the thousands separators

                DispatchQueue.main.async {
                    self.balance = balance
                    if let formattedString = formatter.string(from: NSNumber(value: self.balance)) {
                        print(formattedString)
                        self.balanceText = formattedString // Prints "1,234,567,890" in U.S. locale
                    } else {
                        self.balanceText = "error"
                    }
                    
                    self.transactions = wallet_transactions.sorted().reversed()
                }
                
            } catch let error {
                print(error)
                DispatchQueue.main.async {
//                    self.syncState = .failed(error)
                }
            }
        }
    }
    
    func storeXprvKey(xprvKeyData: String) throws {
        // todo: introduce proper key management to store and get several keys
        //  might also want to store descriptor for easier handling of completely different wallets
        let status = saveToKeyChain(key: "com.snblago.BTCMulti.xprv", data: xprvKeyData.data(using: .utf8)!)
        guard status == errSecSuccess else { throw MyError.storingFailed }
    }
    
    func loadXprvKey() throws {
        // todo: introduce proper key management to store and get several keys
        let result = loadFromKeyChain(key: "com.snblago.BTCMulti.xprv")
        if result == nil {
            return
        }
        self.xprv = String(data: result!, encoding: .utf8)!
        try computeXpub()
    }
    
    func computeXpub() throws {
        let descriptor = try DescriptorSecretKey.fromString(secretKey: "\(xprv)/*")
        self.xpub = try descriptor.derive(path: DerivationPath(path: "m/84'/1'/0'/0")).asPublic().asString()
    }
    
}

extension TransactionDetails: Comparable {
    public static func < (lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {
        
        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;
        
        return lhs_timestamp < rhs_timestamp
    }
}

extension TransactionDetails: Equatable {
    public static func == (lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {
        
        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;
        
        return lhs_timestamp == rhs_timestamp
    }
}
