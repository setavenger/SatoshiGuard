//
//  SignView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct SignView: View {

    @EnvironmentObject var walletManager: WalletManager
    @State private var psbtString: String = ""
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    
    @State private var errorMessage: String = ""
    @State private var psbtSigned: String = ""
    
    @State private var successTXID: String = ""
    
    
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
                        } catch {
                            print("\(error)")
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
                            self.showSuccessAlert = true
                        } catch {
                            errorMessage = error.localizedDescription.description
                            print("\(error)")
                            self.showErrorAlert = true
                        }
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
            }.alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"),
                      message: Text("Are you sure the PSBT is signed by enough parties?"),
                      dismissButton: .default(Text("OK")))
            }.alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"),
                      message: Text("Successfully broadcasted transaction"),
                      dismissButton: .default(Text("OK")))
            }
        }
        
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Sign and Broadcast")
        .onTapGesture {
            self.endTextEditing()
        }
    }
}

struct Sign_Previews: PreviewProvider {
    static var previews: some View {
        SignView()
    }
}


