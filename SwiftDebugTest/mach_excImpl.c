//
//  mach_excImpl.c
//  SwiftDebugTest
//
//  Created by callum taylor on 20/02/2017.
//  Copyright © 2017 Satori. All rights reserved.
//

#include "mach_exc.h"
#include "mach_excImpl.h"

extern kern_return_t catch_mach_exception_raise_state(
                                                          mach_port_t exception_port, exception_type_t exception,
                                                          exception_data_t code, mach_msg_type_number_t code_count, int *flavor,
                                                          thread_state_t in_state, mach_msg_type_number_t in_state_count,
                                                          thread_state_t out_state, mach_msg_type_number_t *out_state_count) {
    return KERN_FAILURE;
}

extern kern_return_t catch_mach_exception_raise_state_identity(
                                                                   mach_port_t exception_port, mach_port_t thread, mach_port_t task,
                                                                   exception_type_t exception, exception_data_t code,
                                                                   mach_msg_type_number_t code_count, int *flavor, thread_state_t in_state,
                                                                   mach_msg_type_number_t in_state_count, thread_state_t out_state,
                                                                   mach_msg_type_number_t *out_state_count) {
    return KERN_FAILURE;
}

//kern_return_t catch_mach_exception_raise(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt) {
//    return cb(exception_port, thread, task, exception, code, codeCnt);
//}
//
//void set_catch_mach_exception_raise_cb(catch_mach_exception_raise_cb callback) {
//    cb = callback;
//}
