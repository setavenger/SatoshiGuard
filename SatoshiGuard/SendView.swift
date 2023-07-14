//
//  SendView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//
import SwiftUI
import CodeScanner
import Combine


struct SendView: View {
    @EnvironmentObject var walletManager: WalletManager

    @State var to: String = ""
    @State var amount: String = "0"
    @State private var isShowingScanner = false
    @State private var psbtSigned: String = ""
    @State private var txFeeString: String = "1"

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
                            .keyboardType(.decimalPad)
                    }
                    Section(header: Text("Fees (sat/vB)").textStyle(BasicTextStyle(white: true))) {
                        TextField("Transaction Fee", text: $txFeeString)
                            .modifier(BasicTextFieldStyle())
                            .keyboardType(.numberPad)
                            .keyboardType(.decimalPad)
                    }
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
               
                if psbtSigned != "" {
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
                Spacer()
                BasicButton(action: { self.isShowingScanner = true}, text: "Scan Address", colorBg: .orange)
                BasicButton(action: {
                    do {
                        let psbt = try walletManager.createTransaction(recipient: to, amount: UInt64(amount)!, txFee: Double(txFeeString)!)
                        psbtSigned = psbt.serialize()
                    } catch {
                        print("\(error)")
                    }
                }, text: "Generate PSBT", colorBg: .blue)
                    .padding(.bottom, 50)
            }
        }
        .navigationTitle("Send")
        .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Testing1234", completion: self.handleScan)
        }.onTapGesture {
            self.endTextEditing()
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

struct SendView_Previews: PreviewProvider {
    static func onSend(to: String, amount: UInt64) {
        
    }
    static var previews: some View {
        SendView()
    }
}
