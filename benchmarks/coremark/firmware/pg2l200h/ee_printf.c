#include <stdarg.h>
#include "core_portme.h"

#define UART_TX     (*(volatile unsigned int *)0x10000000u)
#define UART_STATUS (*(volatile unsigned int *)0x10000004u)

static void putc_uart(char c)
{
    while (UART_STATUS & 1u) { }
    UART_TX = (unsigned char)c;
}

static int print_u32(unsigned int value, unsigned int base, unsigned int width, char pad)
{
    char buf[16];
    unsigned int n = 0;
    int out = 0;
    do { unsigned int d = value % base; buf[n++] = (char)(d < 10 ? '0' + d : 'a' + d - 10); value /= base; } while (value);
    while (n < width) { putc_uart(pad); ++out; --width; }
    while (n) { putc_uart(buf[--n]); ++out; }
    return out;
}

int ee_printf(const char *fmt, ...)
{
    va_list ap;
    int out = 0;
    va_start(ap, fmt);
    while (*fmt) {
        unsigned int width = 0;
        char pad = '0';
        if (*fmt != '%') { putc_uart(*fmt++); ++out; continue; }
        ++fmt;
        if (*fmt == '%') { putc_uart(*fmt++); ++out; continue; }
        if (*fmt == '0') ++fmt; else pad = ' ';
        while (*fmt >= '0' && *fmt <= '9') width = width * 10u + (unsigned int)(*fmt++ - '0');
        if (*fmt == 'l') ++fmt;
        switch (*fmt++) {
        case 's': { const char *s = va_arg(ap, const char *); while (*s) { putc_uart(*s++); ++out; } break; }
        case 'c': putc_uart((char)va_arg(ap, int)); ++out; break;
        case 'd': { int v = va_arg(ap, int); if (v < 0) { putc_uart('-'); ++out; out += print_u32(0u - (unsigned int)v, 10, width ? width - 1u : 0u, pad); } else out += print_u32((unsigned int)v, 10, width, pad); break; }
        case 'u': out += print_u32(va_arg(ap, unsigned int), 10, width, pad); break;
        case 'x': case 'X': out += print_u32(va_arg(ap, unsigned int), 16, width, pad); break;
        default: putc_uart('?'); ++out; break;
        }
    }
    va_end(ap);
    return out;
}
