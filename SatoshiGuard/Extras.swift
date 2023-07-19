//
//  Extras.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation
import BitcoinDevKit

extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

enum ActiveAlert {
    case success, error
}

extension TransactionDetails: Comparable {
    public static func <(lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {

        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;

        return lhs_timestamp < rhs_timestamp
    }
}

extension TransactionDetails: Equatable {
    public static func ==(lhs: TransactionDetails, rhs: TransactionDetails) -> Bool {

        let lhs_timestamp: UInt64 = lhs.confirmationTime?.timestamp ?? UInt64.max;
        let rhs_timestamp: UInt64 = rhs.confirmationTime?.timestamp ?? UInt64.max;

        return lhs_timestamp == rhs_timestamp
    }
}
