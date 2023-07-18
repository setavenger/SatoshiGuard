//
//  SignView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct SignView: View {

    @ObservedObject var walletManager: WalletManager
    @State private var psbtString: String = ""

    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success

    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    
    @State private var psbtSigned: String = ""
    
    @State private var successTXID: String = ""
    
    
    init(wallet: WalletManager) {
        walletManager = wallet
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                Spacer()
                VStack{
                    Text("Enter PSBT below:")
                        .foregroundColor(.white)
                    TextEditor(text: $psbtString)
                        .scrollContentBackground(.hidden)
                        .frame(height: 200)
                        .padding()
                        .border(Color.gray, width: 2)
                        .padding()
                        .disableAutocorrection(true)
                        .background(Color.clear)
                    Button(action: {
                        let pasteboard = UIPasteboard.general
                        psbtString = pasteboard.string ?? ""
                    }) {
                        Text("Paste PSBT")
                            .font(.headline)
//                            .foregroundColor(.orange)
                            .padding()
                    }
                    if psbtSigned != "" {
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = psbtSigned
                        }) {
                            Text("Copy Signed PSBT to Clipboard")
                                .font(.headline)
                                .padding()
                        }
                    }
                    if successTXID != "" {
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = successTXID
                        }) {
                            Text(successTXID)
                                .font(.headline)
                                .padding()
                        }
                    }
                }
                VStack{
                    Button(action: {
                        do {
                            let psbt = try walletManager.SignPSBT(psbtString: psbtString)
                            psbtSigned = psbt.serialize()
//                            self.successMessage = "PSBT was signed successfully"
//                            self.activeAlert = .success
//                            self.showAlert = true
                        } catch {
                            errorMessage = "\(error)"
                            print("\(error)")
                            self.activeAlert = .error
                            self.showAlert = true
                        }
                    }) {
                        Text("Sign")
                            .font(.headline)
                            .padding()
                            .frame(width: geometry.size.width - 30, height: 50)
                            .foregroundColor(.black)
                            .background(Color.orange)
                            .cornerRadius(10)
                            .padding()
                    }

                    Button(action: {
                        do {
                            let psbt = try walletManager.SignPSBT(psbtString: psbtString)
                            successTXID = try walletManager.Broadcast(psbt: psbt)
                            self.successMessage = "Successfully broadcasted transaction"
                            self.activeAlert = .success
                            self.showAlert = true
                        } catch {
                            errorMessage = "\(error)"
                            print("\(error)")
                            self.activeAlert = .error
                            self.showAlert = true                        }
                    }) {
                        Text("Sign and Broadcast")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: geometry.size.width - 30, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width)
                Spacer()
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .success:
                    return Alert(title: Text("Success"),message: Text(successMessage),dismissButton: .default(Text("OK")))
                case .error:
                    return Alert(title: Text("Error"),message: Text(errorMessage),dismissButton: .default(Text("OK")))
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Sign and Broadcast")
        .onTapGesture {
            self.endTextEditing()
        }
    }
}


