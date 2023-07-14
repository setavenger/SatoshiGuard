//
//  TxsView.swift
//  BDKTests
//
//  Created by Setor Blagogee on 11.07.23.
//

import SwiftUI
import BitcoinDevKit

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

struct TxsView: View {

    @EnvironmentObject var walletManager: WalletManager
    
    var body: some View {
        VStack {
            ScrollView {
                if walletManager.transactions.isEmpty {
                    Text("No transactions yet.").padding()
                } else {
                    ForEach(walletManager.transactions, id: \.self.txid) { transaction in
                        SingleTxView(transactionDetails: transaction)
                    }
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom))
        .navigationTitle("Transactions")
    }
}
