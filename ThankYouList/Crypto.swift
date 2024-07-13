//
//  Crypto.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2018/07/24.
//  Copyright © 2018 Aika Yamada. All rights reserved.
//

import Foundation

import Foundation
import CoreFoundation
import Security

import RNCryptor
import CryptoSwift

class Crypto {
    
    func encryptString(plainText: String, key: String) -> String {
        let encrypt = try! plainText.aesEncrypt(key)
        return encrypt
    }
    
    func decryptString(encryptText: String, key: String) -> String {
        let decrypt = try! encryptText.aesDecrypt(key)
        return decrypt
    }
}


extension String {
    func aesEncrypt(_ key: String) throws -> String {
        let data = self.data(using: String.Encoding.utf8)
        let aes = try AES(key: key.bytes, blockMode: ECB(), padding: .pkcs5)
        let encrypted = try! aes.encrypt(Array(data!))
        let encryptedData = Data(encrypted)
        print("encryption")
        return encryptedData.base64EncodedString()
    }
    
    func aesDecrypt(_ key: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let aes = try AES(key: key.bytes, blockMode: ECB(), padding: .pkcs5)
        let decrypted = try! aes.decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
        
    }
}
