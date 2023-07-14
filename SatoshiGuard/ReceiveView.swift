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
    @EnvironmentObject var walletManager: WalletManager
    @State private var address: String = ""
    
    func splitAddress(address: String) -> (String, String) {
        let length = address.count
        
        return (String(address.prefix(length / 2)), String(address.suffix(length / 2)))
    }
    
    func getAddress() {
        do {
            let addressInfo = try walletManager.wallet!.getAddress(addressIndex: AddressIndex.new)
            address = addressInfo.address.asString()
        } catch {
            address = "ERROR"
        }
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
                Image(uiImage: generateQRCode(from: "bitcoin:\(address)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
                Text(splitAddress(address: address).0).textStyle(BasicTextStyle(white: true))
                Text(splitAddress(address:  address).1).textStyle(BasicTextStyle(white: true))
                    .onTapGesture(count: 1) {
                        UIPasteboard.general.string = address
                    }
                Spacer()
            }.contextMenu {
                Button(action: {
                    UIPasteboard.general.string = address}) {
                        Text("Copy to clipboard")
                    }
            }
            Spacer()
            BasicButton(action: getAddress, text: "Generate new address", colorBg: .orange)
        }
        .navigationTitle("Receive Address")
        .onAppear(perform: getAddress)
    }
}

struct BasicButton: View {
    var action: () -> Void
    var text: String
    var colorBg: Color

    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, design: .monospaced))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .foregroundColor(Color(.white))
                .padding(10)
                .background(colorBg)
                .cornerRadius(10.0)
                .shadow(color: Color("Shadow"), radius: 1, x: 5, y: 5)
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

