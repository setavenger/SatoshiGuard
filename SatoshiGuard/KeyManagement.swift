//
//  KeyManagement.swift
//  BDKTests
//
//  Created by Setor Blagogee on 13.07.23.
//

import Foundation

func saveToKeyChain(key: String, data: Data) -> OSStatus {
    let query = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key,
        kSecValueData as String   : data ] as [String : Any]
    
    SecItemDelete(query as CFDictionary)
    
    return SecItemAdd(query as CFDictionary, nil)
}

func loadFromKeyChain(key: String) -> Data? {
    let query = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

    var dataTypeRef: AnyObject? = nil

    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

    if status == noErr {
        return dataTypeRef as! Data?
    } else {
        return nil
    }
}

extension Data {

    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}


enum MyError: Error {
    case retrievalFailed
    case storingFailed

    var localizedDescription: String {
        switch self {
        case .retrievalFailed:
            return "Retrieving didn't work"
        case .storingFailed:
            return "Storing didn't work"
        }
    }
}
