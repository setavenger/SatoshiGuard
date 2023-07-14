//
//  WalletManager.swift
//  BDKTests
//
//  Created by Setor Blagogee on 10.07.23.
//

import Foundation
import SwiftUI
import BitcoinDevKit


// Wallet Data Transfer Object
struct WalletDTO: Codable {
    var id: String = ""
    var name: String = ""

    var xpub1: String = ""
    var xpub2: String = ""
    var threshold: UInt8 = 1
    var networkStr: String = "testnet"
}

class WalletManager: ObservableObject {

    var id: String = ""
    var walletDTO: WalletDTO

    var name: String = ""
    var xpub1: String = ""
    var xpub2: String = ""
    var threshold: UInt8 = 1
    var networkStr: String = "testnet"
    var network: Network = Network.testnet

    var multisigDescriptor: String = ""
    var xpub = ""
    var xprv = "" // might need to be published
    var blockchain: Blockchain?

    private(set) var wallet: Wallet?
    private(set) var balance: UInt64 = 21_210_210
    @Published private(set) var balanceText: String = "Setup Keys"
    @Published private(set) var transactions: [BitcoinDevKit.TransactionDetails] = []

    init() {
        if id == "" {
            self.id = UUID().uuidString
        }
        updateWalletDTO()
    }

    func updateWalletDTO() {
        walletDTO.id = id
        walletDTO.name = name
        walletDTO.xpub1 = xpub1
        walletDTO.xpub2 = xpub2
        walletDTO.threshold = threshold
        walletDTO.networkStr = networkStr
    }

    public func buildMultiSigDescriptor() {
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

    func Broadcast(psbt: PartiallySignedTransaction) throws -> String {
        let tx = psbt.extractTx()
        try blockchain!.broadcast(transaction: tx)
        let txid = psbt.txid()
        print(txid)
        return txid
    }

    func updateMultiSigDetails(xpub1: String, xpub2: String, threshold: UInt8) {
        self.xpub1 = xpub1
        self.xpub2 = xpub2
        self.threshold = threshold
        updateWalletDTO()

        buildMultiSigDescriptor()

    }

    public func LoadWords(words: String) throws -> Void {
        do {
            let mnemonic = try Mnemonic.fromString(mnemonic: words)
            let descriptorNew = DescriptorSecretKey(network: self.network, mnemonic: mnemonic, password: "")

            self.xprv = descriptorNew.asString().replacingOccurrences(of: "/*", with: "")

            try self.storeXprvKey(xprvKeyData: self.xprv)
            try computeXpub()

            print(self.xpub)
            if xpub1 != "" && xpub2 != "" {
                self.buildMultiSigDescriptor()
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

            self.wallet = try Wallet(descriptor: Descriptor.init(descriptor: multisigDescriptor, network: self.network), changeDescriptor: nil, network: self.network, databaseConfig: db)
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
        let status = saveToKeyChain(key: "com.snblago.SatoshiGuard.\(id)", data: xprvKeyData.data(using: .utf8)!)
        guard status == errSecSuccess else {
            throw MyError.storingFailed
        }
    }

    func loadXprvKey() throws {
        // todo: introduce proper key management to store and get several keys
        let result = loadFromKeyChain(key: "com.snblago.SatoshiGuard.\(id)")
        if result == nil {
            return
        }
        xprv = String(data: result!, encoding: .utf8)!
        try computeXpub()
    }

    func computeXpub() throws {
        let descriptor = try DescriptorSecretKey.fromString(secretKey: "\(xprv)/*")
        xpub = try descriptor.derive(path: DerivationPath(path: "m/84'/1'/0'/0")).asPublic().asString()
    }

    func serializeWallet() throws -> Data {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(walletDTO)
        return jsonData
    }

    func loadWalletFromWalletDTO(walletDTO: Data) throws -> WalletManager {
        let decoder = JSONDecoder()
        let walletDataDTO = try decoder.decode(WalletDTO.self, from: walletDTO)
        let walletManager = WalletManager()
        walletManager.id = walletDataDTO.id
        walletManager.name = walletDataDTO.name
        walletManager.xpub1 = walletDataDTO.xpub1
        walletManager.xpub2 = walletDataDTO.xpub2
        walletManager.threshold = walletDataDTO.threshold
        walletManager.networkStr = walletDataDTO.networkStr

        switch networkStr {
        case "bitcoin":
            walletManager.network = Network.bitcoin
        case "testnet":
            walletManager.network = Network.testnet
        case "regtest":
            walletManager.network = Network.regtest
        case "signet":
            walletManager.network = Network.signet
        default:
            walletManager.network = Network.testnet
        }
        try walletManager.loadXprvKey()
        walletManager.buildMultiSigDescriptor()
        try walletManager.load()
        walletManager.sync()

        return walletManager
    }
}

class WalletCoordinator {
    @AppStorage("walletids") var walletIdsData: Data
    var walletIdsStr: [String]

    init() throws {
        do {
            walletIdsStr = try JSONDecoder().decode([String].self, from: walletIdsData)
        }
    }
    deinit {
        do {
            let data = try JSONEncoder().encode(walletIdsStr)
            walletIdsData = data
        } catch {
            print("\(error)")
        }
    }

    var wallets: [WalletManager] = []

    func loadWallets() throws {

    }

    func createNewWallet() -> WalletManager {
        let newWallet = WalletManager()
        wallets.append(newWallet)
    }
}


extension TransactionDetails: Comparable {
    public static func <(lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {

        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;

        return lhs_timestamp < rhs_timestamp
    }
}

extension TransactionDetails: Equatable {
    public static func ==(lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {

        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;

        return lhs_timestamp == rhs_timestamp
    }
}
