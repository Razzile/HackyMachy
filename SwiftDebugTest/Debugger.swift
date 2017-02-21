//
//  Debugger.swift
//  SwiftDebugTest
//
//  Created by callum taylor on 20/02/2017.
//  Copyright © 2017 Satori. All rights reserved.
//

import Foundation
import Darwin.Mach

typealias PThreadFunc = @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?

@_silgen_name("catch_mach_exception_raise") func catch_mach_exception_raise_(exception_port: mach_port_t, thread: mach_port_t, task: mach_port_t, exception: exception_type_t, code: mach_exception_data_t, codeCnt: mach_msg_type_number_t) -> kern_return_t {
    print("reached")
    return KERN_FAILURE
}

class Debugger {
    init() {
        func exc_thread_(p: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
            let x: @convention(c) (UnsafeMutablePointer<mach_msg_header_t>?, UnsafeMutablePointer<mach_msg_header_t>?) -> boolean_t = { mach_exc_server($0, $1) }
            
            let exc_port: mach_port_t = p.bindMemory(to: UInt32.self, capacity: 1).pointee
            var kr: kern_return_t = 0
            
            while (true) {
                if ((mach_msg_server_once(x, 4096, exc_port, 0)) !=
                    KERN_SUCCESS) {
                    // error here
                }
            }
            return nil;
        }
    
        
        let exception_mask: UInt32 =
            (1 << UInt32(EXC_BAD_ACCESS))
            | (1 << UInt32(EXC_BAD_INSTRUCTION))
            | (1 << UInt32(EXC_ARITHMETIC))
            | (1 << UInt32(EXC_EMULATION))
            | (1 << UInt32(EXC_SOFTWARE))
            | (1 << UInt32(EXC_BREAKPOINT))
            | (1 << UInt32(EXC_SYSCALL))
            | (1 << UInt32(EXC_MACH_SYSCALL))
            | (1 << UInt32(EXC_RPC_ALERT))
            | (1 << UInt32(EXC_CRASH))

        let self_port: mach_port_t = mach_task_self_
        var exc_port: mach_port_t = 0
        var exception_thread: pthread_t? = nil
        
        var maskCount: mach_msg_type_number_t = 1;
        var mask: exception_mask_t! = exception_mask_t()
        var handler: exception_handler_t! = exception_handler_t()
        var behavior: exception_behavior_t! = exception_behavior_t()
        var flavor: thread_state_flavor_t! = thread_state_flavor_t()
        
        mach_port_allocate(self_port, MACH_PORT_RIGHT_RECEIVE, &exc_port)
        
        task_get_exception_ports(self_port, exception_mask, &mask!, &maskCount,
                                 &handler!, &behavior!, &flavor!)
        
        mach_port_insert_right(self_port, exc_port, exc_port,
                               mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND))
        
        
        pthread_create(&exception_thread, nil, exc_thread_,
                       &exc_port)
        
        task_set_exception_ports(self_port, (UInt32(1) << UInt32(EXC_BREAKPOINT)), exc_port,
                                 Int32(EXCEPTION_DEFAULT) | Int32(bitPattern: MACH_EXCEPTION_CODES), flavor!)
        
    }
}
