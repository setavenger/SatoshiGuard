//
//  ContentView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 10.07.23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var walletCoordinator: WalletCoordinator
    
    var body: some View {
        NavigationView {
            OverviewView(walletCoordinator: walletCoordinator)
        }.onAppear {
            do {
                try walletCoordinator.loadWallets()
            } catch {
                print("\(error)")
            }
        }
    }
}


