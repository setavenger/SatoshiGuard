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
    @EnvironmentObject var walletManager: WalletManager
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            Spacer()
            Text("Enter 12 or 24 Words")
            TextEditor(text: $inputText)
                .scrollContentBackground(.hidden)
                .frame(height: 200)
                .padding()
                .border(Color.gray, width: 2)
                .padding()
                .disableAutocorrection(true)
                .background(Color.clear)

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
                            } catch {
                                print("\(error)")
                            }
                        }) {
                            Text("Recover")
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
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
    }
}


func generateMnemonic() -> String {
    return Mnemonic(wordCount: .words12).asString()
}
