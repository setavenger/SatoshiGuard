//
//  PSBTQRView.swift
//  SatoshiGuard
//
//  Created by Setor Blagogee on 18.07.23.
//

import Foundation
import SwiftUI

struct PSBTQRView: View{
    @State var psbt: String
    
    init(psbt: String) {
        self.psbt = psbt
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
            Image(uiImage: generateQRCode(dataStr: "\(psbt)"))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
            Spacer()
        }
    }
}

struct BasicTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .textInputAutocapitalization(.never)
    }
}
