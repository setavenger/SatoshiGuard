//
//  Extras.swift
//  BDKTests
//
//  Created by Setor Blagogee on 12.07.23.
//

import Foundation

extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
