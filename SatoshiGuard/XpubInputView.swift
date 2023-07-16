//
//  XpubInputView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct InputView: View {
    @ObservedObject var walletManager: WalletManager

    @State private var showAlert = false
    
    init(walletManager: WalletManager) {
        self.walletManager = walletManager
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                TextField("xpub 1", text: $walletManager.xpub1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)

                TextField("xpub 2", text: $walletManager.xpub2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)

                
                Picker(selection: $walletManager.threshold, label: Text("Select a number")) {
                    Text("1").tag(UInt8(1))
                    Text("2").tag(UInt8(2))
                    Text("3").tag(UInt8(3))
                }
                .padding()
                
                Text("Policy: \(walletManager.threshold) of 3")
                    .font(.headline)
                
            }
            .padding(.bottom, 20)
            
       
            Button(action: {
                walletManager.updateMultiSigDetails(xpub1: walletManager.xpub1, xpub2: walletManager.xpub2, threshold: walletManager.threshold)
                self.showAlert = true
            }) {
                Text("Confirm")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .background(.orange)
                .cornerRadius(10)
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Success"),
                      message: Text("Your action was successful."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}
