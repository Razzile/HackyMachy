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
typealias CatchMachExceptionRaise = catch_mach_exception_raise_cb
@_silgen_name("set_catch_mach_exception_raise_cb") func set_catch_mach_exception_raise_cb(fp: CatchMachExceptionRaise)

class Debugger {
    init() {
        func exc_thread_(p: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
            return p
        }
        
        func catch_mach_exception_raise_(exception_port: mach_port_t, thread: mach_port_t, task: mach_port_t, exception: exception_type_t, code: mach_exception_data_t, codeCnt: mach_msg_type_number_t) {
            
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
        
        let exc_thread = unsafeBitCast(exc_thread_, to: PThreadFunc.self)
        let catch_mach_exception_raise = unsafeBitCast(catch_mach_exception_raise_, to: CatchMachExceptionRaise.self)
        
        set_catch_mach_exception_raise_cb(catch_mach_exception_raise)
        
        let self_port: mach_port_t = mach_task_self_
        var exc_port: mach_port_t = 0
        var exception_thread: pthread_t? = nil
        
        var maskCount: mach_msg_type_number_t = 1;
        var mask: exception_mask_t? = nil
        var handler: exception_handler_t? = nil
        var behavior: exception_behavior_t? = nil
        var flavor: thread_state_flavor_t? = nil
        
        mach_port_allocate(self_port, MACH_PORT_RIGHT_RECEIVE, &exc_port)
        
        task_get_exception_ports(self_port, exception_mask, &mask!, &maskCount,
                                 &handler!, &behavior!, &flavor!)
        
        mach_port_insert_right(self_port, exc_port, exc_port,
                               mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND))
        
        
        pthread_create(&exception_thread, nil, exc_thread,
                       &exc_port)
        
        task_set_exception_ports(self_port, (UInt32(1) << UInt32(EXC_BREAKPOINT)), exc_port,
                                 Int32(EXCEPTION_DEFAULT) | Int32(bitPattern: MACH_EXCEPTION_CODES), flavor!)
        
    }
}
