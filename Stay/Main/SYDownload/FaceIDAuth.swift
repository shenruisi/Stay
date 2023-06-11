//
//  FaceIDAuth.swift
//  Stay
//
//  Created by Jin on 2023/6/10.
//

import Foundation
import LocalAuthentication

@objc
class FaceIDAuth : NSObject {
    
    public static let hardwareString: String = {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, nil, 0)

        var hardware: String = String(cString: hw_machine)

        // Check for simulator
        if hardware == "x86_64" || hardware == "i386" {
            if let deviceID = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
                hardware = deviceID
            }
        }

        return hardware
    }()
    
    public static let isSupported: Bool = {
        #if FC_IOS
        if hardwareString.starts(with: "iPhone8,")
            || hardwareString.starts(with: "iPhone9,")
            || hardwareString.starts(with: "iPhone10,1")
            || hardwareString.starts(with: "iPhone10,2")
            || hardwareString.starts(with: "iPhone10,4")
            || hardwareString.starts(with: "iPhone10,5")
            || hardwareString.starts(with: "iPad5,")
            || hardwareString.starts(with: "iPad6,")
            || hardwareString.starts(with: "iPad7,") {
            return false
        }
        
        return true
        #else
        return false
        #endif
    }()
    
    @objc
    public static var isEnable: Bool {
        if isSupported {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return context.biometryType == .faceID
            }
        }
        
        return false
    }
    
    @objc
    public static func evaluate(localizedReason: String, completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
}
