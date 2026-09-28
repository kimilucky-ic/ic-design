/* MODIFIED: XiaoYanjin PG2L200H port uses the 27 MHz cycle-counter MMIO and UART reporting. */
#include "coremark.h"
#include "core_portme.h"

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#elif PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0;
volatile ee_s32 seed2_volatile = 0;
volatile ee_s32 seed3_volatile = 0x66;
#else
volatile ee_s32 seed1_volatile = 8;
volatile ee_s32 seed2_volatile = 8;
volatile ee_s32 seed3_volatile = 8;
#endif
volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;

static volatile ee_u32 * const cycle_counter = (volatile ee_u32 *)0x10000008u;
static ee_u32 start_tick, stop_tick;
ee_u32 default_num_contexts = 1;

void start_time(void) { start_tick = *cycle_counter; }
void stop_time(void) { stop_tick = *cycle_counter; }
CORE_TICKS get_time(void) { return stop_tick - start_tick; }
secs_ret time_in_secs(CORE_TICKS ticks) { return ticks / EE_TICKS_PER_SEC; }

void portable_init(core_portable *p, int *argc, char *argv[])
{
    (void)argc;
    (void)argv;
    if (sizeof(ee_ptr_int) != sizeof(ee_u8 *) || sizeof(ee_u32) != 4)
        for (;;) { }
    p->portable_id = 1;
}

void portable_fini(core_portable *p)
{
    ee_u32 elapsed = stop_tick - start_tick;
    ee_u32 score_milli = (ee_u32)(((uint64_t)(ee_u32)ITERATIONS * 1000000000ULL) / elapsed);
    ee_printf("COREMARK_RAW_TICKS=%u ITERATIONS=%u\r\n", elapsed, (ee_u32)ITERATIONS);
    ee_printf("COREMARK_CM_MHZ_MILLI=%u\r\n", score_milli);
    p->portable_id = 0;
}
