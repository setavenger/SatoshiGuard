//
//  SatoshiGuardApp.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 14.07.23.
//

import SwiftUI

@main
struct SatoshiGuardApp: App {
    @StateObject var walletCoordinator = WalletCoordinator();
    
    var body: some Scene {
        WindowGroup {
            ContentView(walletCoordinator: walletCoordinator).preferredColorScheme(.dark).onOpenURL { url in

                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let transferObj = try decoder.decode(TransferPSBT.self, from: data)
                    
//                    try walletCoordinator.loadWallets()
                    
                    for i in 0..<walletCoordinator.wallets.count {
//                        print("----")
//                        print(walletCoordinator.wallets[i].id)
//                        print(walletCoordinator.wallets[i].walletSignature)
//                        print(transferObj.signature)
                        if walletCoordinator.wallets[i].walletSignature == transferObj.signature {
//                            print(walletCoordinator.wallets[i].id)
//                            print(walletCoordinator.wallets[i].unsignedPSBTs.count)
                            walletCoordinator.wallets[i].unsignedPSBT = UnsignedPSBT(psbt: transferObj.psbt, shared_at: UInt(Date().timeIntervalSince1970), signed: false)
//                            print(walletCoordinator.wallets[i].unsignedPSBTs.count)
                            try walletCoordinator.wallets[i].storeWalletDTO()
                            walletCoordinator.objectWillChange.send()
                        }
                    }
                } catch {
                    // Handle the error
                    print("Error loading or decoding file: \(error)")
                }
            }
        }
    }
}


