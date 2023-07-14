//
//  SingleTxView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 11.07.23.
//

import SwiftUI
import BitcoinDevKit

struct SingleTxView: View {
    var transactionDetails: TransactionDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if transactionDetails.confirmationTime == nil {
                HStack {
                    Text("Received:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.received)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Sent:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.sent)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Fees:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.fee ?? 0)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Txid:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(transactionDetails.txid).textStyle(BasicTextStyle(white: true))
                }
            } else {
                HStack {
                    Text("Confirmed:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text((Date(timeIntervalSince1970: TimeInterval(transactionDetails.confirmationTime!.timestamp)).getFormattedDate(format: "yyyy-MM-dd HH:mm:ss"))).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Block:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.confirmationTime!.height)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Received:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.received)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Sent:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.sent)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Fees:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(String(transactionDetails.fee ?? 0)).textStyle(BasicTextStyle(white: true))
                }
                HStack {
                    Text("Txid:").textStyle(BasicTextStyle(white: true, bold: true))
                    Text(transactionDetails.txid).textStyle(BasicTextStyle(white: true))
                }
            }
        }
        .padding(10)
        .background(Color("Shadow")).cornerRadius(5)
        .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = transactionDetails.txid}) {
                        Text("Copy TXID")
                    }
            }
        .padding(.vertical, 10)
    }
}


struct BasicTextStyle: ViewModifier {
    var big = false
    var white = false
    var bold = false
    func body(content: Content) -> some View {
        content
            .font(.system(size: big ? 32 : 14, design: .monospaced).weight(bold ? .bold : .regular))
            .foregroundColor(white ? Color.white : Color("Shadow"))
    }
}

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

struct BasicTextStyle_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello").textStyle(BasicTextStyle())
    }
}

struct SingleTxView_Previews: PreviewProvider {
    static var previews: some View {
        SingleTxView(transactionDetails: TransactionDetails(transaction: nil, fee: 250, received: 1000, sent: 10000, txid: "some-other-tx-id", confirmationTime: BlockTime(height: 20087, timestamp: 1635863544)))
    }
}
