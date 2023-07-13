//
//  IDNA.swift
//  Stay
//
//  Created by ris on 2023/7/12.
//

import Foundation
import Punycode

@objcMembers class IDNA : NSObject{
    static func encode(input: String) -> String{
        return input.idnaEncoded!
    }
    
    static func decode(input: String) -> String{
        return input.idnaDecoded!
    }
    
}
