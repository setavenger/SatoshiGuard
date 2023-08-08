//
//  NewWalletView.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 28.07.23.
//

import Foundation
import SwiftUI
import BitcoinDevKit

struct NewWalletView: View {
    @ObservedObject var walletCoordinator: WalletCoordinator
    @State var newWalletName: String = ""
    @State var network: Network = Network.testnet
    @State private var showSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

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
                        if newWalletName != "" {
                            _ = try walletCoordinator.createNewWallet(name: newWalletName, network: network)
                            showSuccessAlert = true
                        } else {
                            // todo add error for this. wallet needs a name
                        }
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
                      dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("New Wallet")
    }
}
