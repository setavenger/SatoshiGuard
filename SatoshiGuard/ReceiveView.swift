//
//  ReceiveView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 11.07.23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import BitcoinDevKit

let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

struct ReceiveView: View {
    @ObservedObject var walletManager: WalletManager
    
    init(wallet: WalletManager) {
        self.walletManager = wallet
    }
    
    func splitAddress(address: String) -> (String, String) {
        let length = address.count
        
        return (String(address.prefix(length / 2)), String(address.suffix(length / 2)))
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(uiImage: generateQRCode(from: "bitcoin:\(self.walletManager.nextReceiveAddress)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
                Text(splitAddress(address: self.walletManager.nextReceiveAddress).0).textStyle(BasicTextStyle(white: true))
                Text(splitAddress(address: self.walletManager.nextReceiveAddress).1).textStyle(BasicTextStyle(white: true))
                    .onTapGesture(count: 1) {
                        UIPasteboard.general.string = self.walletManager.nextReceiveAddress
                    }
                Spacer()
            }.contextMenu {
                Button(action: {
                    UIPasteboard.general.string = self.walletManager.nextReceiveAddress}) {
                        Text("Copy to clipboard")
                    }
            }
            Spacer()
            BasicButton(action: walletManager.newAddress, text: "Generate new address", colorBg: .orange, fontCol: Color("Shadow"))
        }
//        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Receive Address")
    }
}

struct BasicButton: View {
    var action: () -> Void
    var text: String
    var colorBg: Color
    var fontCol: Color
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 30)
                .foregroundColor(fontCol)
                .padding(10)
                .background(colorBg)
                .cornerRadius(10.0)
        }
    }
}

struct BasicButtonStyle: ButtonStyle {
    var bgColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: 40)
            .foregroundColor(Color("Shadow"))
            .background(Color(.orange))
            .cornerRadius(10.0)
            .shadow(color: Color("Shadow"), radius: 1, x: 5, y: 5)
            .padding(20)
    }
}

