#include "ExpKpru.h"
#include <mach/mach.h>
#include "vouncher_swap/voucher_swap.h"

// This file was built for future reuse.

mach_port_t grab_this_tfp0(void) {
    mach_port_t tfp0 = voucher_swap_go();
    return tfp0;
}
