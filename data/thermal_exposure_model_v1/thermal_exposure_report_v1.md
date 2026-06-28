# Thermal Exposure Simulation - Concept Model V1

## Purpose

This model screens sealed-enclosure thermal risk before hardware exists. It is designed to show thermal reasoning, not to claim measured temperature performance.

## Model Setup

- Model type: lumped thermal RC model.
- Duration: 240 minutes with 60 second step.
- Ambient profile: 20.0 C to 32.0 C sinusoidal ramp.
- Peak solar/lamp input: 4.8 W.
- Electronics power: 0.08 W baseline, 0.45 W transmit-boundary pulse.
- Thermal capacitance: 420 J/C.
- Thermal resistance to ambient: 9.5 C/W.
- Warning reference: 55.0 C internal temperature.

## Results

- Peak internal temperature: 66.6 C.
- Peak ambient temperature: 32.0 C.
- Minimum margin to warning reference: -11.6 C.
- Time of peak internal temperature: 169 minutes.

## Interpretation

The model creates a first-pass estimate for whether the sealed enclosure could experience elevated internal temperature under a warm ambient ramp and external heat input. It also links firmware duty cycle to thermal load through the transmit-boundary power pulse.

## Design Actions Suggested By This Result

- Treat direct solar exposure as a design risk for the sealed enclosure.
- Prefer light-coloured or UV-stable enclosure material for exposed installations.
- Reduce radio transmit duty cycle and LED duty cycle during high-temperature operation.
- Consider a shaded mounting location, vent membrane or heat-spreading insert before any physical prototype test.
- Add internal temperature logging to the future hardware test plan.

## Evidence Boundary

Simulation only. No physical thermal logging, solar calibration, material emissivity measurement, contact resistance measurement or environmental chamber result is claimed.

## Generated Files

- `thermal_exposure_simulation_v1.csv`
- `thermal_exposure_summary_v1.json`
- `thermal_exposure_plot_v1.svg`
