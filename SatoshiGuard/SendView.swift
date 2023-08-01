//
//  SendView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//
import SwiftUI
import CodeScanner
import Combine
import AVFoundation


struct SendView: View {
    @ObservedObject var walletManager: WalletManager

    @State var to: String = ""
    @State var amount: String = "0"
    @State private var isShowingScanner = false
    @State private var psbtSigned: String = ""
    @State private var txFeeString: String = "1"

    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .success
    @State private var errorMessage: String = ""

    @State private var isShowingQRCode = false

    init(wallet: WalletManager) {
        self.walletManager = wallet
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        if case let .success(result) = result {
            to = result.string.removingPrefix("bitcoin:")
        }
        self.isShowingScanner = false
        
    }
    var body: some View {
        VStack {
            VStack {
                Form {
                    Section(header: Text("Recipient").textStyle(BasicTextStyle(white: true))) {
                        TextField("Address", text: $to)
                            .modifier(BasicTextFieldStyle())
                    }
                    Section(header: Text("Amount (sats)").textStyle(BasicTextStyle(white: true))) {
                        TextField("Amount", text: $amount)
                            .modifier(BasicTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Fees (sat/vB)").textStyle(BasicTextStyle(white: true))) {
                        TextField("Transaction Fee", text: $txFeeString)
                            .modifier(BasicTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    to = pasteboard.string ?? ""
                    print(pasteboard.string ?? "no value")
                }) {
                    Text("Paste Address")
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
//                            .foregroundColor(.orange)
                            .padding()
                    }
                }
//                BasicButton(action: { self.isShowingScanner = true}, text: "Scan Address", colorBg: .orange, fontCol: Color("Shadow"))
                BasicButton(action: {
                    do {
                        let psbt = try walletManager.createTransaction(recipient: to, amount: UInt64(amount)!, txFee: Double(txFeeString)!)
                        psbtSigned = psbt.serialize()
                    } catch {
                        print("\(error)")
                        errorMessage = "\(error)"
                        activeAlert = .error
                        showAlert = true
                    }
                }, text: "Generate PSBT", colorBg: .blue, fontCol: Color("Shadow"))
                    .padding(.bottom, 50)
            }
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .success:
                return Alert(title: Text("Success"), message: Text("Success"), dismissButton: .default(Text("OK")))
            case .error:
                return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Send")
//        .sheet(isPresented: $isShowingScanner) {
//            CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", videoCaptureDevice: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),completion: self.handleScan)
//        }
        .sheet(isPresented: $isShowingQRCode) {
            PSBTQRView(psbt: psbtSigned)
        }
        .onTapGesture {
            self.endTextEditing()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}


func prepareJSONData(signature: String, psbt: String) -> URL? {
    let transfer: TransferPSBT = TransferPSBT(signature: signature, psbt: psbt)

    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(transfer)
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("Signed PSBT Transfer").appendingPathExtension("sgpsbt")
        try data.write(to: targetURL)
        
        return targetURL
    } catch {
        print("Error converting JSON to Data: \(error)")
        return nil
    }
}

//extension UIViewController: UIDocumentInteractionControllerDelegate {
//    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//        return self
//    }
//}
