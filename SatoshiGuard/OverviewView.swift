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

struct NewWalletView: View {
    @ObservedObject var walletCoordinator: WalletCoordinator
    @State var newWalletName: String = ""
    @State var network: Network = Network.testnet
    @State private var showSuccessAlert = false
    
    init(walletCoordinator: WalletCoordinator) {
        self.walletCoordinator = walletCoordinator
    }
    
    var body: some View {
        VStack{
            Form {
                Section(header: Text("Wallet Name:").textStyle(BasicTextStyle(white: true))) {
                    TextField("Your Wallet Name", text: $newWalletName)
                        .modifier(BasicTextFieldStyle())
                }
                Section(header: Text("Network:").textStyle(BasicTextStyle(white: true))) {
                    Picker(selection: $network, label: Text("Select a Network")) {
                        Text("bitcoin").tag(Network.bitcoin)
                        Text("testnet").tag(Network.testnet)
                    }
                    .padding()
                }
                
                Button(action: {
                    do {
                        _ = try walletCoordinator.createNewWallet(name: newWalletName, network: network)
                        showSuccessAlert = true
                        print(walletCoordinator.wallets.count)
                    } catch {
//                         todo show alert
                        print("\(error)")
                    }
                    
                }) {
                    Text("Add new wallet")
                        .font(.system(size: 14, design: .monospaced))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .foregroundColor(Color(.orange))
                        .padding(10)
                        .background(Color("Shadow"))
                        .cornerRadius(10.0)
                }
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"),
                      message: Text("Successfully added wallet"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("New Wallet")
    }
}
