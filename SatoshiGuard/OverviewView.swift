//
//  OverviewView.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 14.07.23.
//

import Foundation
import SwiftUI
import BitcoinDevKit

struct OverviewView: View {
    @ObservedObject var walletCoordinator: WalletCoordinator
    
    init(walletCoordinator: WalletCoordinator) {
        self.walletCoordinator = walletCoordinator
    }

    var body: some View {
        VStack {
            HStack{
                Spacer()
                NavigationLink(destination: NewWalletView(walletCoordinator: walletCoordinator)) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                }
            }
            if walletCoordinator.wallets.count == 0 {
                Spacer()
                Text("Welcome, create your first wallet!")
                    .font(.headline)
                    .padding()
                Spacer()
            }
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 20){
                        ForEach(walletCoordinator.wallets, id: \.id) { wallet in
                            WalletView(wallet: wallet, width: geometry.size.width * 0.9)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                    }
                    .frame(width: geometry.size.width, alignment: .center)
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Wallets")
    }
}

struct WalletView: View {
    @StateObject var wallet: WalletManager
    var width: CGFloat

    var body: some View {
        NavigationLink(destination: HomeView(wallet: wallet)) {
            VStack(alignment: .leading) {
                Text(wallet.name)
                    .font(.headline)
                    .padding(.bottom, 2)
                Text("\(wallet.balanceText) Sats")
                    .font(.headline)
                    .padding(.bottom, 2)
                Text("Last Transaction:")
                    .font(.subheadline)
//                    .padding(.bottom, 2)
                Text("\(wallet.lastTransaction)")
                    .font(.subheadline)
            }
            .foregroundColor(wallet.network == .testnet ? Color("Shadow") : .orange)
            .frame(width: width, alignment: .leading)
            .padding()
            .background(wallet.network == .testnet ? .orange : Color("Shadow"))
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

