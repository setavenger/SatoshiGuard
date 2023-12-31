//
//  KeyView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI

struct KeyView: View {
    @ObservedObject var walletManager: WalletManager

    @State var isShowingSheet: Bool = false
    
    init(walletManager: WalletManager) {
        self.walletManager = walletManager
//        print(walletManager)
    }
    
    var body: some View {
        VStack{
            Spacer()
            VStack(alignment: .center){
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
                Button(action:{
                    isShowingSheet = true
                }) {
                    Text("Show QR Code")
                }
                Divider()
            }
            Spacer()
            NavigationLink(destination: RecoverView(walletManager: walletManager)) {
                Text("Set Private Key")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.orange)
                    .background(Color("Shadow"))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .navigationTitle("Keys")
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $isShowingSheet) {
            XpubQRView(xpub: walletManager.xpub)
        }
    }
}

struct XpubQRView: View{
    @State var xpub: String
    
    init(xpub: String) {
        self.xpub = xpub
    }
    
    func generateQRCode(dataStr: String) -> UIImage {
        let data = Data(dataStr.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        VStack{
            Spacer()
            Image(uiImage: generateQRCode(dataStr: "\(xpub)"))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Spacer()
        }
    }
}
