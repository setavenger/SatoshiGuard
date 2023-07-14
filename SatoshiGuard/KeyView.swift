//
//  KeyView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct KeyView: View {
    @EnvironmentObject var walletManager: WalletManager

    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                Divider()
                VStack(alignment: .leading, spacing: -10){
                    Text("xprv:").padding(.horizontal)
                    HStack {
                        Text(String(repeating: "*", count: walletManager.xprv.count)) // Obfuscated xprv
                            .lineLimit(1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Button(action: {
                            UIPasteboard.general.string = walletManager.xprv
                        }) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                }
                .cornerRadius(10)
                Divider()
                VStack(alignment: .leading, spacing: -10){
                    Text("xpub:").padding(.horizontal)
                    HStack {
                        Text(String(walletManager.xpub))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            UIPasteboard.general.string = walletManager.xpub
                        }) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                }
                Divider()
            }
            Spacer()
            NavigationLink(destination: RecoverView()) {
                Text("Change Wallet")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.orange)
                    .background(Color("Shadow"))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
    }
}
