# System Architecture

## Mechanical Architecture

- Upper enclosure shell with ribs, screw bosses and external fillets.
- Lower enclosure shell with PCB standoffs, battery pocket and gasket groove.
- Elastomer gasket compressed by perimeter screws.
- Sealed service/debug port cover.
- Strap/bracket mount designed as a primary load path.
- Optional pressure vent or membrane placeholder.

## Electronics Architecture

Planned Proteus-level model:

- MCU placeholder: ESP32 class or STM32 class module.
- Environmental sensor placeholder: temperature/RH/pressure or generic field sensor.
- Battery placeholder.
- Voltage regulator / protection block.
- Status LED.
- Debug/programming port.
- Optional wake button or reed switch.

Proteus is used for architecture and packaging support, not as a final PCB manufacturing release.

## Firmware Architecture

Planned Keil / embedded C states:

- Sleep / low-power wait.
- Wake and sensor read.
- Data validation.
- Transmit or log event.
- Fault state for low battery, sensor missing or enclosure-open input.
- Service/debug mode.

## Validation Architecture

- Strap pull fixture validates mount load path.
- Drop orientation fixture defines repeatable impact orientations.
- Spray stand supports future water-ingress observation.
- Thermal logging setup records internal/external temperature trend.
- Evidence gap register prevents overclaiming before physical testing.
