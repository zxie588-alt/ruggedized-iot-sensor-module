# HMI Screen Specification V1

## Screen 1 - Operator Run Screen

Displayed information:

- Current step: Idle / Precheck / Spray / Thermal / Cooldown / Complete / Fault.
- Safety permissive status.
- DUT present and clamp status.
- Spray time remaining.
- Thermal time remaining.
- Cooldown time remaining.
- Logger ready / logging active.
- Active fault code and message.

Operator controls:

- Start cycle.
- Stop cycle.
- Reset fault.
- Service mode request.

## Screen 2 - Recipe Screen

Editable setpoints:

- Spray duration.
- Thermal duration.
- Cooldown duration.
- Logger trigger mode.
- DUT power mode during cooldown.

All recipe changes require supervisor acknowledgement before cycle start.

## Screen 3 - Maintenance Screen

Manual commands:

- Jog pump.
- Jog lamp with timeout limit.
- Jog vent fan.
- Toggle DUT power.
- Pulse logger trigger.

Manual commands require:

- E-stop chain healthy.
- Door closed or service override active.
- No leak fault.

## Screen 4 - Alarm History

The alarm screen records:

- Fault code.
- Timestamp placeholder.
- Step when fault occurred.
- Operator reset status.
- Recommended corrective action.

## Boundary

This is an HMI concept specification. It is not a compiled WinCC/TIA Portal project. It supports portfolio evidence for operator workflow, fixture safety and manufacturing-test thinking.
