//
//  WalletHomeView.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 15.07.23.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @ObservedObject var walletManager: WalletManager
    @State private var goToSend = false
    @State private var goToReceive = false
    
    let balance: Int = 0

    init (wallet: WalletManager) {
        walletManager = wallet
    }
    
    var body: some View {
        VStack {
            HStack{
                Spacer ()
                Text("\(walletManager.name)")
                    .font(.headline)
                if walletManager.network == .testnet {
                    Text("\(walletManager.networkStr)")
                        .font(.headline)
                        .foregroundColor(.red)
                } else {
                    Text("\(walletManager.networkStr)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Spacer ()
            }
            HStack {
                NavigationLink(destination: DynamicTextFieldView(walletManager: walletManager)) {
                
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.orange)
                }
                Spacer()
                NavigationLink(destination: KeyView(walletManager: walletManager)) {
                    Image(systemName: "key.horizontal.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            
            Spacer(minLength: 10)
            
            HStack {
                Text("\(walletManager.balanceText)")
                    .font(.system(size: 50))
                Text("Sats")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)
            }.padding(.top)
            
            GeometryReader { geometry in
                HStack(spacing: 10) {
                    Spacer()
                    NavigationLink(destination: TxsView(walletManager: walletManager)) {
                        Text("Transactions")
                            .frame(width: geometry.size.width/2 - 15, height: 50)
                            .font(.headline)
                            .foregroundColor(.black)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    Spacer()
                }.padding(.horizontal, 10)
            }
            .frame(height: 50)
            .padding(.bottom, 75)
            
            Spacer()
            Spacer()
            
            GeometryReader { geometry in
                VStack{
                    NavigationLink(destination: ReceiveView(wallet: walletManager)) {
                        Text("Receive")
                            .frame(width: geometry.size.width - 20, height: 50)
                            .font(.headline)
                            .foregroundColor(.black)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    HStack(spacing: 10) {
                        NavigationLink(destination: SendView(wallet: self.walletManager)) {
                            Text("Create Tx")
                                .frame(width: geometry.size.width/2 - 15, height: 50)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .background(Color("Shadow"))
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: SignView(wallet: self.walletManager)) {
                            Text("Sign PSBT")
                                .frame(width: geometry.size.width/2 - 15, height: 50)
                                .font(.headline)
                                .foregroundColor(.black)
                                .background(Color.orange)
                                .cornerRadius(10)
//                            if walletManager.unsignedPSBT == nil {
//                                Text("!")
//                                    .font(.headline)
//                                    .foregroundColor(Color("Shadow"))
//                                    .padding(10)
//                                    .background(Circle().fill(Color.red))
//                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 50)
            .padding(.bottom, 75)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .onAppear{
            do {
                try walletManager.loadXprvKey()
                try walletManager.load()
                walletManager.sync(background: true)
            } catch {
                print("\(error)")
            }
        }
    }
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),to: nil, from: nil, for: nil)
  }
}

