//
//  XpubInputView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct InputView: View {
    @EnvironmentObject var walletManager: WalletManager

    @AppStorage("xpub1") var xpub1: String = ""
    @AppStorage("xpub2") var xpub2: String = ""
    
    @AppStorage("threshold") var threshold: Int = 1

    @State private var showAlert = false

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                TextField("xpub 1", text: $xpub1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)

                TextField("xpub 2", text: $xpub2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)

                
                Picker(selection: $threshold, label: Text("Select a number")) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                }
                .padding()
                
                Text("Policy: \(threshold) of 3")
                    .font(.headline)
                
            }
            .padding(.bottom, 20)
            
       
            Button(action: {
                walletManager.buildMultiSigDescriptor(xpub1: xpub1, xpub2: xpub2, threshold: threshold)
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
