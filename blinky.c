#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

#include "bsp.h"

int main(void) {
  int i;

  LED_INIT();
  LED_ON();

  rcc_clock_setup_in_hsi48_out_48mhz(); /* Assume USB clock is present */

  LED_OFF();

  while (1) {
    LED_FLIP();

    for (i = 0; i < 1000000; i++) {
      __asm__("nop");
    }
  }

  return 0;
}
