//
//  SignView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import SwiftUI
import CodeScanner
import AVFoundation


struct SignView: View {

    @ObservedObject var walletManager: WalletManager
    @State private var psbtString: String = ""

    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success

    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    
    @State private var psbtSigned: String = ""
    @State private var successTXID: String = ""
    
    @State private var isShowingScanner = false
    @State private var isShowingQRCode = false

    init(wallet: WalletManager) {
        walletManager = wallet
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        if case let .success(result) = result {
            psbtString = result.string
        }
        self.isShowingScanner = false
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                VStack (spacing: -10) {
                    Text("Enter PSBT below:")
                        .foregroundColor(.white)
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $psbtString)
                            .textInputAutocapitalization(.never)
                            .scrollContentBackground(.hidden)
                            .frame(height: 200)
                            .padding()
                            .border(Color.gray, width: 2)
                            .padding()
                            .disableAutocorrection(true)
                            .background(Color.clear)
                    } else {
                        TextEditor(text: $psbtString)
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
                        psbtString = pasteboard.string ?? ""
                    }) {
                        Text("Paste from Clipboard")
                            .font(.headline)
                            .padding()
                    }
                    Spacer()
                    if psbtSigned != "" {
                        Button(action: {
                            if let fileUrl = prepareJSONData(signature: walletManager.walletSignature, psbt: psbtSigned) {
                                guard let rootVC = UIApplication.shared.connectedScenes
                                        .filter({$0.activationState == .foregroundActive})
                                        .map({$0 as? UIWindowScene})
                                        .compactMap({$0})
                                        .first?.windows
                                        .filter({$0.isKeyWindow}).first?.rootViewController else {
                                    print("Cannot find root view controller.")
                                    return
                                }
                                
                                let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                                rootVC.present(activityViewController, animated: true, completion: nil)

                            } else {
                                print("Error preparing data for sharing.")
                            }
                        }) {
                            Text("Share PSBT")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding()
                        }
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = psbtSigned
                        }) {
                            Text("Copy Signed PSBT to Clipboard")
                                .font(.headline)
                                .padding()
                        }
                    }
                    if successTXID != "" {
                        Button(action: {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = successTXID
                        }) {
                            Text(successTXID)
                                .font(.headline)
                                .padding()
                        }
                    }
                }
                VStack {
                    HStack{
                        BasicButton(action: {
                            if let optionalPSBT = walletManager.unsignedPSBT {
                                psbtString = optionalPSBT.psbt
                            }

                        }, text: "Received PSBT", colorBg: .blue, fontCol: Color("Shadow"))
                            .frame(width: geometry.size.width/2 - 25 )
                        BasicButton(action: {
                            do {
                                let psbt = try walletManager.SignPSBT(psbtString: psbtString)
                                psbtSigned = psbt.serialize()
    //                            self.successMessage = "PSBT was signed successfully"
    //                            self.activeAlert = .success
    //                            self.showAlert = true
                                if let optionalPSBT = walletManager.unsignedPSBT {
                                    if psbtString == optionalPSBT.psbt {
                                        walletManager.unsignedPSBT = nil
                                        try walletManager.storeWalletDTO()
                                    }
                                }
                            } catch {
                                errorMessage = "\(error)"
                                print("\(error)")
                                self.activeAlert = .error
                                self.showAlert = true
                            }
                        }, text: "Sign", colorBg: Color("Shadow"), fontCol: .orange)
                            .frame(width: geometry.size.width/2 - 25 )
                    }
                    
                    BasicButton(action: {
                        do {
                            let psbt = try walletManager.SignPSBT(psbtString: psbtString)
                            successTXID = try walletManager.Broadcast(psbt: psbt)
                            if let optionalPSBT = walletManager.unsignedPSBT {
                                if psbtString == optionalPSBT.psbt {
                                    walletManager.unsignedPSBT = nil
                                    try walletManager.storeWalletDTO()
                                }
                            }
                            self.successMessage = "Successfully broadcasted transaction"
                            self.activeAlert = .success
                            self.showAlert = true
                        } catch {
                            errorMessage = "\(error)"
                            print("\(error)")
                            self.activeAlert = .error
                            self.showAlert = true
                        }
                    }, text: "Sign and Broadcast", colorBg: .orange, fontCol: Color("Shadow"))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .frame(width: geometry.size.width)
            }
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .success:
                    return Alert(title: Text("Success"),message: Text(successMessage),dismissButton: .default(Text("OK")))
                case .error:
                    return Alert(title: Text("Error"),message: Text(errorMessage),dismissButton: .default(Text("OK")))
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Sign and Broadcast")
        .onTapGesture {
            self.endTextEditing()
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", videoCaptureDevice: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), completion: self.handleScan)
        }
        .sheet(isPresented: $isShowingQRCode) {
            PSBTQRView(psbt: psbtSigned)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


