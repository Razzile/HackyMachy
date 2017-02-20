//
//  Breakpoint.swift
//  SwiftDebugTest
//
//  Created by callum taylor on 18/02/2017.
//  Copyright © 2017 Satori. All rights reserved.
//

import Foundation

class Breakpoint {
    enum BreakpointArch : Int {
        case x86 = 0
        case x64 = 1
        
        static var currentArch: BreakpointArch {
            if (MemoryLayout<UInt>.size == 4) {
               return .x86
            }
            else {
                return .x64
            }
        }
    }
    
    enum BreakpointType : Int {
        case Software = 0
        case Hardware = 1
    }
    
    let arch: BreakpointArch
    let type: BreakpointType
    let address: UInt
    
    init(_ address: UInt, _ arch: BreakpointArch = .currentArch, _ type: BreakpointType = .Software) {
        (self.address, self.type, self.arch) = (address, type, arch)
    }
    
    func install() -> Bool {
        print("installing breakpoint at \(String(format: "0x%X", self.address))")
        
        return true
    }
    
}
