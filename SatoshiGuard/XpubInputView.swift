//
//  XpubInputView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct DynamicTextFieldView: View {
    @ObservedObject var walletManager: WalletManager

//    @State private var textFields: [String] = [""]
    @State private var pickerSelection: UInt8 = 1
    @State private var showAlert = false

    var body: some View {
        
        VStack(alignment: .center) {
            ScrollView{
                ForEach(Array(walletManager.xpubs.indices), id: \.self) { index in
                    HStack {
                        TextField("Xpub \(index + 1)", text: $walletManager.xpubs[index])
                        Spacer()
                        Button(action: {
                            if index == walletManager.xpubs.count - 1 {
                                // If it's the last text field, add a new one.
                                walletManager.xpubs.append("")
                            } else {
                                // If it's not the last one, remove this text field.
                                walletManager.xpubs.remove(at: index)
                            }
                            walletManager.threshold = min(walletManager.threshold, UInt8(walletManager.xpubs.count+1))

                        }) {
                            Image(systemName: index == walletManager.xpubs.count - 1 ? "plus.circle" : "minus.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                        }
                    }
                }
                Picker("Policy", selection: $walletManager.threshold) {
                    ForEach(1...walletManager.xpubs.count+1, id: \.self) { num in
                        Text("\(num)").tag(UInt8(num))
                    }
                }
                .pickerStyle(.automatic)
                Text("Policy: \(walletManager.threshold) of \(walletManager.xpubs.count+1)")
                    .font(.headline)
                Button(action: {
                    walletManager.updateMultiSigDetails(xpubs: walletManager.xpubs, threshold: walletManager.threshold)
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
                Spacer()
                
            }
            .padding()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
    }
}


//struct InputView: View {
//    @ObservedObject var walletManager: WalletManager
//
//    @State private var showAlert = false
//
//    init(walletManager: WalletManager) {
//        self.walletManager = walletManager
//    }
//
//    var body: some View {
//        VStack {
//            Spacer()
//            VStack(spacing: 10) {
//                TextField("xpub 1", text: $walletManager.xpub1)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .disableAutocorrection(true)
//
//                TextField("xpub 2", text: $walletManager.xpub2)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .disableAutocorrection(true)
//
//
//                Picker(selection: $walletManager.threshold, label: Text("Select a number")) {
//                    Text("1").tag(UInt8(1))
//                    Text("2").tag(UInt8(2))
//                    Text("3").tag(UInt8(3))
//                }
//                .padding()
//
//                Text("Policy: \(walletManager.threshold) of 3")
//                    .font(.headline)
//
//            }
//            .padding(.bottom, 20)
//
//
//            Button(action: {
//                walletManager.updateMultiSigDetails(xpub1: walletManager.xpub1, xpub2: walletManager.xpub2, threshold: walletManager.threshold)
//                self.showAlert = true
//            }) {
//                Text("Confirm")
//                .font(.headline)
//                .foregroundColor(.black)
//                .padding()
//                .background(.orange)
//                .cornerRadius(10)
//            }.alert(isPresented: $showAlert) {
//                Alert(title: Text("Success"),
//                      message: Text("Your action was successful."),
//                      dismissButton: .default(Text("OK")))
//            }
//            Spacer()
//        }.background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
//    }
//}
