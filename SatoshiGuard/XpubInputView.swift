//
//  XpubInputView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI
import CodeScanner
import AVFoundation

let maxXpubs = 2

struct DynamicTextFieldView: View {
    @ObservedObject var walletManager: WalletManager

    @State private var localXpubs: [String]
    @State private var pickerSelection: UInt8 = 1

    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success
    @State private var errorMessage: String = ""
    
    @State private var isShowingScanner: Bool = false
    
    
    init (walletManager: WalletManager) {
        self.walletManager = walletManager
        localXpubs = walletManager.xpubs
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        if case let .success(result) = result {
            for (index, _) in localXpubs.enumerated() {
                if localXpubs[index] == "" {
                    localXpubs[index] = result.string
                    self.isShowingScanner = false
                    return
                }
            }
            if localXpubs.count < maxXpubs {
                localXpubs.append(result.string)
            } else {
                errorMessage = "Only up to 2 xpubs allowed at the moment"
                activeAlert = .error
                showAlert = true
            }
        }
        self.isShowingScanner = false
        
    }
    var body: some View {
        
        VStack(alignment: .center) {
            ScrollView{
//                Spacer()
                VStack{
                    ForEach(Array(localXpubs.indices), id: \.self) { index in
                        HStack {
                            TextField("Xpub \(index + 1)", text: $localXpubs[index])
                            Spacer()
                            if index < maxXpubs - 1 {
                                Button(action: {
                                    if index == localXpubs.count - 1 {
                                        // If it's the last text field, add a new one.
                                        localXpubs.append("")
                                    } else {
                                        // If it's not the last one, remove this text field.
                                        localXpubs.remove(at: index)
                                    }
                                    walletManager.threshold = min(walletManager.threshold, UInt8(localXpubs.count+1))

                                }) {
                                    Image(systemName: index == localXpubs.count - 1 ? "plus.circle" : "minus.circle")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding()
                                }
                            }
                        }
                    }
                    Picker("Policy", selection: $walletManager.threshold) {
                        ForEach(1...localXpubs.count+1, id: \.self) { num in
                            Text("\(num)").tag(UInt8(num))
                        }
                    }
                    .pickerStyle(.automatic)
                    
                    Text("Policy: \(walletManager.threshold) of \(localXpubs.count+1)")
                        .font(.headline)

                }
            }
            .padding()
            Divider()
            VStack{
                BasicButton(action: { self.isShowingScanner = true}, text: "Scan XPUB QR", colorBg: .blue, fontCol: Color("Shadow"))
                BasicButton(action: {
                    errorMessage = verifyValidXpubs(xpubs: localXpubs)
                    if errorMessage == "" {
                        walletManager.updateMultiSigDetails(xpubs: localXpubs, threshold: walletManager.threshold)
                        self.activeAlert = .success
                        self.showAlert = true
                    } else {
                        self.activeAlert = .error
                        self.showAlert = true
                    }
                }, text: "Confirm", colorBg: .orange, fontCol: Color("Shadow"))
            }.padding()
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return Alert(title: Text("Success"), message: Text("xpubs successfully updated"), dismissButton: .default(Text("OK")))
            case .error:
                return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Xpubs")
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", videoCaptureDevice: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), completion: self.handleScan)
        }.onTapGesture {
            self.endTextEditing()
        }
    }
}


func verifyValidXpubs(xpubs: [String]) -> String {
    if xpubs.contains("") {
        return "please remove empty xpubs"
    }
    for xpub in xpubs {
        if xpub.count != 135 {
            return "invalid XPUB detected"
        }
    }
    return ""
}

