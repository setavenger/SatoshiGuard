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
            HStack {
//                NavigationLink(destination: InputView(walletManager: walletManager)) {
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
            NavigationLink(destination: TxsView(walletManager: walletManager)) {
                Text("Transactions")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.top, 50)
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
                walletManager.sync()
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

