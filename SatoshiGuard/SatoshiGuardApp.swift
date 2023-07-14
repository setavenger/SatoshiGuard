//
//  SatoshiGuardApp.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 14.07.23.
//

import SwiftUI

@main
struct SatoshiGuardApp: App {
    @StateObject var walletManager = WalletManager();

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(walletManager).preferredColorScheme(.dark)
        }
    }
}