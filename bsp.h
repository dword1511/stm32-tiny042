#ifndef __STM32_TINY042__
#define __STM32_TINY042__

#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

#define RCC_LED  RCC_GPIOA
#define PORT_LED GPIOA
#define PIN_LED  GPIO14

#define LED_INIT() {\
  rcc_periph_clock_enable(RCC_LED); \
  gpio_mode_setup(PORT_LED, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, PIN_LED); \
}

#define LED_ON() {\
  gpio_set(PORT_LED, PIN_LED); \
}

#define LED_OFF() {\
  gpio_clear(PORT_LED, PIN_LED); \
}

#define LED_FLIP() {\
  gpio_toggle(PORT_LED, PIN_LED); \
}

#endif /* __STM32_TINY042__ */
