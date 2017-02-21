//
//  Debugger.swift
//  SwiftDebugTest
//
//  Created by callum taylor on 20/02/2017.
//  Copyright © 2017 Satori. All rights reserved.
//

import Foundation
import Darwin.Mach

struct ExceptionType : OptionSet {
    var rawValue: Int32
    
    static let badAccess = ExceptionType(rawValue: EXC_BAD_ACCESS)
    static let badInstruction = ExceptionType(rawValue: EXC_BAD_INSTRUCTION)
    static let arithmetic = ExceptionType(rawValue: EXC_ARITHMETIC)
    static let emulation = ExceptionType(rawValue: EXC_EMULATION)
    static let software = ExceptionType(rawValue: EXC_SOFTWARE)
    static let breakpoint = ExceptionType(rawValue: EXC_BREAKPOINT)
    static let syscall = ExceptionType(rawValue: EXC_SYSCALL)
    static let machSyscall = ExceptionType(rawValue: EXC_MACH_SYSCALL)
    static let rpcAlert = ExceptionType(rawValue: EXC_RPC_ALERT)
    static let crash = ExceptionType(rawValue: EXC_CRASH)
    
    static var all: ExceptionType {
        return [.badAccess, .badInstruction, .arithmetic,
                .emulation, .software, .breakpoint, . syscall,
                .machSyscall, .rpcAlert, .crash]

    }
    
    var mask: UInt32 {
        return 1 << UInt32(self.rawValue)
    }
    
}

class Debugger {
    private let port: NSMachPort?
    
    init(_ port: mach_port_t = mach_task_self_) {
        self.port = NSMachPort(machPort: port)
        
        let exceptionMask = ExceptionType.all.mask
        

        var exc_port: UInt32 = 0
        var exception_thread: pthread_t? = nil
        
        var maskCount: mach_msg_type_number_t = 1;
        var mask: exception_mask_t = exception_mask_t()
        var handler: exception_handler_t = exception_handler_t()
        var behavior: exception_behavior_t = exception_behavior_t()
        var flavor: thread_state_flavor_t = thread_state_flavor_t()
        
        mach_port_allocate(port, MACH_PORT_RIGHT_RECEIVE, &exc_port)
        
        task_get_exception_ports(port, exceptionMask, &mask, &maskCount,
                                 &handler, &behavior, &flavor)
        
        mach_port_insert_right(port, exc_port, exc_port,
                               mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND))
        
        
        pthread_create(&exception_thread, nil, exc_thread,
                       &exc_port)
        
        task_set_exception_ports(port, ExceptionType.breakpoint.mask, exc_port,
                                 Int32(EXCEPTION_DEFAULT) | Int32(bitPattern: MACH_EXCEPTION_CODES), flavor)
        
    }
}

// hacky C like implementations

@_silgen_name("catch_mach_exception_raise")
func catch_mach_exception_raise(exception_port: mach_port_t, thread: mach_port_t, task: mach_port_t, exception: exception_type_t, code: mach_exception_data_t, codeCnt: mach_msg_type_number_t) -> kern_return_t {
    print("reached")
    return KERN_FAILURE
}

func exc_thread(p: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    let x: @convention(c) (UnsafeMutablePointer<mach_msg_header_t>?, UnsafeMutablePointer<mach_msg_header_t>?) -> boolean_t = { mach_exc_server($0, $1) }
    
    let exc_port: mach_port_t = p.bindMemory(to: UInt32.self, capacity: 1).pointee
    
    while (true) {
        if ((mach_msg_server_once(x, 4096, exc_port, 0)) !=
            KERN_SUCCESS) {
            // error here
        }
    }
}
