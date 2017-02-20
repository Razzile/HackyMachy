//
//  mach_excImpl.h
//  SwiftDebugTest
//
//  Created by callum taylor on 20/02/2017.
//  Copyright © 2017 Satori. All rights reserved.
//

#ifndef mach_excImpl_h
#define mach_excImpl_h

typedef kern_return_t (*catch_mach_exception_raise_cb)(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt);

extern catch_mach_exception_raise_cb cb;

void set_catch_mach_exception_raise_cb(catch_mach_exception_raise_cb callback);

#endif /* mach_excImpl_h */
