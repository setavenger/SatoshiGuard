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
    var xpubs: [String] = [""]
    
    var threshold: UInt8 = 1
    var networkStr: String = "testnet"
    var unsignedPSBT: UnsignedPSBT?
    var walletSignature: String?
}

struct UnsignedPSBT: Codable {
    var psbt: String
    var shared_at: UInt
    var signed: Bool
}

class WalletManager: ObservableObject,Identifiable {

    var walletDTO: WalletDTO = WalletDTO()
    
    @Published var id: UUID
    @Published var name: String = ""
    @Published var xpub1: String = ""
    @Published var xpub2: String = ""
    @Published var xpubs: [String] = [""]
    @Published var unsignedPSBT: UnsignedPSBT?
    @Published var walletSignature: String = ""
    
    
    @Published var threshold: UInt8 = 1
    var networkStr: String = "testnet"
    var network: Network = Network.testnet

    var multisigDescriptor: String = ""
    @Published var xpub = ""
    @Published var xprv = ""
    var blockchain: Blockchain?

    private(set) var wallet: Wallet? = nil
    
    private(set) var balance: UInt64 = 21_210_210
    @Published private(set) var balanceText: String = "Setup Keys"
    @Published private(set) var transactions: [BitcoinDevKit.TransactionDetails] = []
    @Published private(set) var lastTransaction: String = "never"

    @Published private(set) var nextReceiveAddress: String = ""
    
    init() {
        id = UUID() // Creates a new UUID if one isn't supplied.
    }
    
    init?(uuid: UUID) {
        id = uuid
    }

    func updateWalletDTO() {
        walletDTO.id = id.uuidString
        walletDTO.name = name
        walletDTO.xpub1 = xpub1
        walletDTO.xpub2 = xpub2
        walletDTO.xpubs = xpubs
        
        walletDTO.threshold = threshold
        walletDTO.networkStr = networkStr
        walletDTO.unsignedPSBT = unsignedPSBT
        walletDTO.walletSignature = walletSignature
    }
    
    func setNetwork(network: Network) {
        self.network = network
        
        switch network {
        case Network.bitcoin:
            networkStr = "bitcoin"
        case Network.testnet:
            networkStr = "testnet"
        case Network.regtest:
            networkStr = "regtest"
        case Network.signet:
            networkStr = "signet"
        }
    }

    public func buildMultiSigDescriptor() {
        self.multisigDescriptor = "wsh(sortedmulti(\(threshold),\(xprv)/84'/1'/0'/0/*,\(xpubs.joined(separator: ","))))"
        var sigXpubs = xpubs
        sigXpubs.append(xpub)
        self.walletSignature = "wsh(sortedmulti(\(threshold),\(sigXpubs.sorted().joined(separator: ","))))"
        
        do {
            try storeWalletDTO()
        } catch {
            print("\(error)")
        }
    }

    public func SignPSBT(psbtString: String) throws -> PartiallySignedTransaction {

        let psbt = try PartiallySignedTransaction(psbtBase64: psbtString)
        do {
            let _ = try self.wallet!.sign(psbt: psbt, signOptions: nil)
        } catch {
            print("\(error)")
            throw error
        }
        
        return psbt
    }

    func createTransaction(recipient: String, amount: UInt64, txFee: Double) throws -> PartiallySignedTransaction {
        do {
            let address = try Address(address: recipient)
            let script = address.scriptPubkey()
            var txBuilder = TxBuilder().addRecipient(script: script, amount: amount)
            txBuilder = txBuilder.enableRbf()
            txBuilder = txBuilder.feeRate(satPerVbyte: Float(txFee))
            let details = try txBuilder.finish(wallet: wallet!)
            let _ = try wallet!.sign(psbt: details.psbt, signOptions: nil)

            return details.psbt
        } catch let error {
            print(error)
            throw error
        }
    }

    func Broadcast(psbt: PartiallySignedTransaction) throws -> String {
        do {
            let tx = psbt.extractTx()
            try blockchain!.broadcast(transaction: tx)
            let txid = psbt.txid()
            print(txid)
            return txid
        } catch {
            print("\(error)")
            throw error
        }
    }

    func updateMultiSigDetails(xpubs: [String], threshold: UInt8) {
        self.xpubs = xpubs
        self.threshold = threshold

        buildMultiSigDescriptor()
        do {
            try storeWalletDTO()
        } catch {
            print("\(error)")
        }
    }

    public func LoadWords(words: String) throws -> Void {
        do {
            let mnemonic = try Mnemonic.fromString(mnemonic: words)
            let descriptorNew = DescriptorSecretKey(network: self.network, mnemonic: mnemonic, password: "")

            self.xprv = descriptorNew.asString().replacingOccurrences(of: "/*", with: "")

            try self.storeXprvKey(xprvKeyData: self.xprv)
            try self.storeWalletDTO()
            try computeXpub()

            if xpubs != [""] {
                self.buildMultiSigDescriptor()
                try self.load()
            }
        } catch {
            throw error
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
            let electrumURL = network == .bitcoin ? "ssl://electrum.blockstream.info:50002" : "ssl://electrum.blockstream.info:60002"
            let electrum = ElectrumConfig(url: electrumURL, socks5: nil, retry: 5, timeout: nil, stopGap: 10, validateDomain: true)
            let blockchainConfig = BlockchainConfig.electrum(config: electrum)
            self.blockchain = try Blockchain(config: blockchainConfig)

            self.wallet = try Wallet(descriptor: Descriptor.init(descriptor: multisigDescriptor, network: self.network), changeDescriptor: nil, network: self.network, databaseConfig: db)
        } catch {
            print("\(error)")
            throw error
        }
    }

    func sync(background: Bool) {
        if multisigDescriptor == "" {
//            throw Error("no multi sig descriptor built yet")
            return
        }
        
        if !background || self.balanceText == "Setup Keys" {
            self.balanceText = "syncing"
        }

        DispatchQueue.global().async {
            print("syncing started")
            do {
                // TODO find out why this blocks receive view while syncing
                try self.wallet!.sync(blockchain: self.blockchain!, progress: nil)
                let balance = try self.wallet!.getBalance().confirmed
                let wallet_transactions: [TransactionDetails] = try self.wallet!.listTransactions(includeRaw: false)

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal

                DispatchQueue.main.async {
                    self.balance = balance
                    if let formattedString = formatter.string(from: NSNumber(value: self.balance)) {
                        print(formattedString)
                        self.balanceText = formattedString
                    } else {
                        self.balanceText = "error"
                    }

                    self.transactions = wallet_transactions.sorted().reversed()
                    self.computeLastTransaction()
                    self.newAddress()
                }
            } catch let error {
                print(error)
                DispatchQueue.main.async {
                    self.balanceText = "error"
                }
            }
        }
    }
    
    func newAddress() {
        do {
            let addressInfo = try wallet!.getAddress(addressIndex: AddressIndex.new)
            self.nextReceiveAddress = addressInfo.address.asString()
        } catch {
            self.nextReceiveAddress = "ERROR"
        }
    }

    func storeXprvKey(xprvKeyData: String) throws {
        let status = saveToKeyChain(key: "com.snblago.SatoshiGuard.\(id)", data: xprvKeyData.data(using: .utf8)!)
        guard status == errSecSuccess else {
            throw MyError.storingFailed
        }
    }

    func loadXprvKey() throws {
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

//    todo decide on where to call this function. Avoid double calling in builddescriptor and update xpubs
    func storeWalletDTO() throws {
        updateWalletDTO()

        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(walletDTO) {
            UserDefaults.standard.set(jsonData, forKey: "\(id)")
            print("stored data to user defaults")
        } else {
            throw MyError.storingFailed
        }
    }

    public static func loadWalletById(id: String) throws -> WalletManager? {
        do {
            let data = UserDefaults.standard.data(forKey: id)
            if data == nil {
                return nil
            }
            return try loadWalletFromWalletDTO(walletDTO: data!)
        } catch {
            print("Error decoding Data to array: \(error)")
            throw MyError.genericError
        }
    }

    public static func loadWalletFromWalletDTO(walletDTO: Data) throws -> WalletManager {
        let decoder = JSONDecoder()
        print(walletDTO)
        let walletDataDTO = try decoder.decode(WalletDTO.self, from: walletDTO)
        let walletManager = WalletManager()
        walletManager.id = UUID(uuidString: walletDataDTO.id)!
        walletManager.name = walletDataDTO.name
        walletManager.xpub1 = walletDataDTO.xpub1
        walletManager.xpub2 = walletDataDTO.xpub2
        walletManager.threshold = walletDataDTO.threshold
        
//        in order to support legacy storing and pulling of data
        if walletDataDTO.xpubs == [""] {
            walletManager.xpubs = [walletDataDTO.xpub1, walletDataDTO.xpub2]
        } else {
            walletManager.xpubs = walletDataDTO.xpubs
        }
        
        if let unsignedPSBT = walletDataDTO.unsignedPSBT {
            walletManager.unsignedPSBT = unsignedPSBT
        }
        if let walletSignature = walletDataDTO.walletSignature {
            walletManager.walletSignature = walletSignature
        }
        
        
        switch walletDataDTO.networkStr {
        case "bitcoin":
            walletManager.setNetwork(network: Network.bitcoin)
        case "testnet":
            walletManager.setNetwork(network: Network.testnet)
        case "regtest":
            walletManager.setNetwork(network: Network.regtest)
        case "signet":
            walletManager.setNetwork(network: Network.signet)
        default:
            walletManager.setNetwork(network: Network.testnet)
        }
        
        do {
            try walletManager.loadXprvKey()
            walletManager.buildMultiSigDescriptor()

            try walletManager.load()
            walletManager.sync(background: true)

        } catch {
            print("\(error)")
        }

        return walletManager
    }
    
    public func computeLastTransaction() {
        if let lastElement = transactions.first {
            if lastElement.confirmationTime == nil {
                lastTransaction = "unconfirmed"
            } else {
                lastTransaction = Date(timeIntervalSince1970: TimeInterval(lastElement.confirmationTime!.timestamp)).getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
            }
        }
        return
    }
}

class WalletCoordinator: ObservableObject {
    @AppStorage("walletids") var walletIdsData: Data?
    @Published var wallets: [WalletManager] = []

    lazy var walletIdsStr: [String] = {
        do {
            if let walletData = walletIdsData {
                return try JSONDecoder().decode([String].self, from: walletData)
            }
        } catch {
            print("Error decoding walletIdsData: \(error)")
        }
        return [String]()
    }()
    
    deinit {
        do {
            let data = try JSONEncoder().encode(walletIdsStr)
            walletIdsData = data
        } catch {
            print("\(error)")
        }
    }

    func loadWallets() throws {
        for walletId in walletIdsStr {
            do {
                let wallet = try WalletManager.loadWalletById(id: walletId)
                if wallet == nil {
                    print("nothing found")
                    continue
                }
                wallets.append(wallet!)
            } catch {
                print("\(error)")
                continue
            }
        }
    }

    func createNewWallet(name: String, network: Network) throws -> WalletManager {
        let newWallet = WalletManager()
        appendIfNotContains(value: newWallet.id.uuidString)  //append before so lazy var is loaded before adding to list of wallets.
        newWallet.name = name
        newWallet.setNetwork(network: network)
        
        wallets.append(newWallet)
        objectWillChange.send()
        print("New wallet created and added with id: \(newWallet.id.uuidString)")
        let data = try JSONEncoder().encode(walletIdsStr)
        walletIdsData = data
        return newWallet
    }
    
    func appendIfNotContains(value: String) {
        if !walletIdsStr.contains(value) {
            walletIdsStr.append(value)
        }
        do {
            let data = try JSONEncoder().encode(walletIdsStr)
            walletIdsData = data
        } catch {
            print("\(error)")
        }
    }
}
