//
//  Startview.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI
import BitcoinDevKit



struct RecoverView: View {
    @ObservedObject var walletManager: WalletManager
    @State private var inputText: String = ""
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success

    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(walletManager: WalletManager) {
        self.walletManager = walletManager
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Enter 12 or 24 Words")
            if #available(iOS 16.0, *) {
                TextEditor(text: $inputText)
                    .textInputAutocapitalization(.never)
                    .scrollContentBackground(.hidden)
                    .frame(height: 200)
                    .padding()
                    .border(Color.gray, width: 2)
                    .padding()
                    .disableAutocorrection(true)
                    .background(Color.clear)
            } else {
                TextEditor(text: $inputText)
                    .textInputAutocapitalization(.never)
                    .background(Color.clear)
                    .frame(height: 200)
                    .padding()
                    .border(Color.gray, width: 2)
                    .padding()
                    .disableAutocorrection(true)
                    .background(Color.clear)
            }
            Button(action: {
                let pasteboard = UIPasteboard.general
                inputText = pasteboard.string ?? ""
            }) {
                Text("Paste Mnemonic Phrase")
                    .font(.headline)
                    .padding()
            }
            GeometryReader { geometry in
                VStack{
                    HStack(spacing: 10) {
                        Button(action: {
                            inputText = generateMnemonic()
                        }) {
                            Text("Generate")
                                .frame(width: geometry.size.width/2 - 15, height: 50)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .background(Color("Shadow"))
                                .cornerRadius(10)
                        }
                        Button(action: {
                            do {
                                try walletManager.LoadWords(words: inputText)
                                activeAlert = .success
                                showAlert = true
                            } catch {
                                print("\(error)")
                                activeAlert = .error
                                showAlert = true
//                                errorMessage = error.localizedDescription
                            }
                        }) {
                            Text("Set Key")
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
            
            Spacer()
        }

        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return Alert(title: Text("Success"), message: Text("Successfully set new Private Key"), dismissButton: .default(Text("OK")){
                    presentationMode.wrappedValue.dismiss()
                })
            case .error:
                return Alert(title: Text("Error"), message: Text("Make sure you enter a valid Key of 12 or 24 words"), dismissButton: .default(Text("OK")))
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            self.endTextEditing()
        }
    }
}


func generateMnemonic() -> String {
    return Mnemonic(wordCount: .words12).asString()
}
