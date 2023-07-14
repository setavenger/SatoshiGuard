//
//  ContentView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 10.07.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var walletManager: WalletManager
    @AppStorage("xprvbool") var xprvBool: Bool = false
    
    
    var body: some View {
        NavigationView {
            if xprvBool {
                HomeView()
            } else {
                RecoverView()
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var goToSend = false
    @State private var goToReceive = false
    @AppStorage("network") var networkStr: String = "testnet"
    let balance: Int = 0

    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: InputView()) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.orange)
                }
                Spacer()
//                Picker(selection: $networkStr, label: Text("Select a Network")) {
//                    Text("bitcoin").tag("bitcoin")
//                    Text("testnet").tag("testnet")
//                }
//                .padding()
//                Spacer()
                NavigationLink(destination: KeyView()) {
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
            NavigationLink(destination: TxsView()) {
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
                    NavigationLink(destination: ReceiveView()) {
                        Text("Receive")
                            .frame(width: geometry.size.width - 20, height: 50)
                            .font(.headline)
                            .foregroundColor(.black)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    HStack(spacing: 10) {
                        NavigationLink(destination: SendView()) {
                            Text("Create Tx")
                                .frame(width: geometry.size.width/2 - 15, height: 50)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .background(Color("Shadow"))
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: SignView()) {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
