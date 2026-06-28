import csv
import json
import math
from pathlib import Path


OUTPUT_DIR = Path("data/thermal_exposure_model_v1")

# Concept model constants. Units are noted in the report and JSON output.
DURATION_MIN = 240
TIME_STEP_S = 60
AMBIENT_START_C = 20.0
AMBIENT_PEAK_C = 32.0
SOLAR_PEAK_W = 4.8
ELECTRONICS_BASE_W = 0.08
ELECTRONICS_TX_W = 0.45
TX_PERIOD_MIN = 30
TX_DURATION_MIN = 2
THERMAL_CAPACITANCE_J_PER_C = 420.0
THERMAL_RESISTANCE_C_PER_W = 9.5
TEMPERATURE_WARNING_C = 55.0


def ambient_temperature_c(minute):
    phase = math.pi * min(max(minute / DURATION_MIN, 0.0), 1.0)
    return AMBIENT_START_C + (AMBIENT_PEAK_C - AMBIENT_START_C) * math.sin(phase)


def solar_input_w(minute):
    phase = math.pi * min(max(minute / DURATION_MIN, 0.0), 1.0)
    return SOLAR_PEAK_W * max(math.sin(phase), 0.0)


def electronics_power_w(minute):
    in_tx_window = (minute % TX_PERIOD_MIN) < TX_DURATION_MIN
    return ELECTRONICS_TX_W if in_tx_window else ELECTRONICS_BASE_W


def simulate():
    rows = []
    internal_c = AMBIENT_START_C
    for minute in range(0, DURATION_MIN + 1, int(TIME_STEP_S / 60)):
        ambient_c = ambient_temperature_c(minute)
        solar_w = solar_input_w(minute)
        electronics_w = electronics_power_w(minute)
        heat_loss_w = (internal_c - ambient_c) / THERMAL_RESISTANCE_C_PER_W
        net_heat_w = solar_w + electronics_w - heat_loss_w
        if minute > 0:
            internal_c += (net_heat_w * TIME_STEP_S) / THERMAL_CAPACITANCE_J_PER_C
        rows.append(
            {
                "minute": minute,
                "ambient_C": ambient_c,
                "solar_input_W": solar_w,
                "electronics_power_W": electronics_w,
                "net_heat_W": net_heat_w,
                "internal_C": internal_c,
                "margin_to_warning_C": TEMPERATURE_WARNING_C - internal_c,
            }
        )
    return rows


def write_csv(rows):
    path = OUTPUT_DIR / "thermal_exposure_simulation_v1.csv"
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    return path


def write_json(summary):
    path = OUTPUT_DIR / "thermal_exposure_summary_v1.json"
    with path.open("w") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
    return path


def scale(value, source_min, source_max, target_min, target_max):
    if source_max == source_min:
        return (target_min + target_max) / 2.0
    ratio = (value - source_min) / (source_max - source_min)
    return target_min + ratio * (target_max - target_min)


def polyline(points):
    return " ".join("{:.1f},{:.1f}".format(x, y) for x, y in points)


def write_svg(rows, summary):
    path = OUTPUT_DIR / "thermal_exposure_plot_v1.svg"
    width = 1200
    height = 720
    left = 90
    right = 60
    top = 90
    bottom = 90
    plot_w = width - left - right
    plot_h = height - top - bottom
    max_minute = max(row["minute"] for row in rows)
    temp_values = [row["ambient_C"] for row in rows] + [row["internal_C"] for row in rows]
    temp_min = math.floor(min(temp_values) - 2)
    temp_max = math.ceil(max(temp_values) + 3)
    ambient_points = []
    internal_points = []
    warning_points = []
    for row in rows:
        x = scale(row["minute"], 0, max_minute, left, left + plot_w)
        ambient_points.append((x, scale(row["ambient_C"], temp_min, temp_max, top + plot_h, top)))
        internal_points.append((x, scale(row["internal_C"], temp_min, temp_max, top + plot_h, top)))
        warning_points.append((x, scale(TEMPERATURE_WARNING_C, temp_min, temp_max, top + plot_h, top)))

    lines = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="{0}" height="{1}" viewBox="0 0 {0} {1}">'.format(
            width,
            height,
        ),
        '<rect width="1200" height="720" fill="#f8fafc"/>',
        '<text x="60" y="55" font-family="Arial" font-size="32" font-weight="700" fill="#14213d">Thermal Exposure Simulation V1</text>',
        '<text x="60" y="86" font-family="Arial" font-size="16" fill="#526070">Lumped RC concept model for sealed outdoor IoT enclosure: ambient ramp, solar/lamp input and electronics heat.</text>',
        '<rect x="{0}" y="{1}" width="{2}" height="{3}" fill="#ffffff" stroke="#cbd5e1"/>'.format(left, top, plot_w, plot_h),
    ]
    for tick in range(int(temp_min), int(temp_max) + 1, 5):
        y = scale(tick, temp_min, temp_max, top + plot_h, top)
        lines.append('<line x1="{0}" y1="{1:.1f}" x2="{2}" y2="{1:.1f}" stroke="#e2e8f0"/>'.format(left, y, left + plot_w))
        lines.append('<text x="42" y="{0:.1f}" font-family="Arial" font-size="13" fill="#475569">{1}C</text>'.format(y + 4, tick))
    for minute in range(0, DURATION_MIN + 1, 60):
        x = scale(minute, 0, max_minute, left, left + plot_w)
        lines.append('<line x1="{0:.1f}" y1="{1}" x2="{0:.1f}" y2="{2}" stroke="#e2e8f0"/>'.format(x, top, top + plot_h))
        lines.append('<text x="{0:.1f}" y="{1}" font-family="Arial" font-size="13" fill="#475569">{2} min</text>'.format(x - 22, top + plot_h + 26, minute))
    lines.extend(
        [
            '<polyline points="{0}" fill="none" stroke="#2563eb" stroke-width="4"/>'.format(polyline(internal_points)),
            '<polyline points="{0}" fill="none" stroke="#0f766e" stroke-width="3"/>'.format(polyline(ambient_points)),
            '<polyline points="{0}" fill="none" stroke="#f97316" stroke-width="2" stroke-dasharray="8 8"/>'.format(polyline(warning_points)),
            '<rect x="815" y="118" width="310" height="118" rx="8" fill="#ffffff" stroke="#cbd5e1"/>',
            '<circle cx="842" cy="148" r="7" fill="#2563eb"/><text x="860" y="153" font-family="Arial" font-size="15" fill="#14213d">Internal enclosure temperature</text>',
            '<circle cx="842" cy="178" r="7" fill="#0f766e"/><text x="860" y="183" font-family="Arial" font-size="15" fill="#14213d">Ambient temperature</text>',
            '<line x1="835" y1="207" x2="850" y2="207" stroke="#f97316" stroke-width="3" stroke-dasharray="5 5"/><text x="860" y="212" font-family="Arial" font-size="15" fill="#14213d">55C warning reference</text>',
            '<rect x="90" y="650" width="780" height="42" rx="8" fill="#eef6ff" stroke="#bfdbfe"/>',
            '<text x="110" y="676" font-family="Arial" font-size="16" fill="#14213d">Peak internal: {0:.1f}C | Peak ambient: {1:.1f}C | Minimum margin to warning: {2:.1f}C | Evidence boundary: simulation only, no measured thermal test.</text>'.format(
                summary["peak_internal_C"],
                summary["peak_ambient_C"],
                summary["minimum_margin_to_warning_C"],
            ),
            "</svg>",
        ]
    )
    path.write_text("\n".join(lines) + "\n")
    return path


def write_report(summary):
    path = OUTPUT_DIR / "thermal_exposure_report_v1.md"
    lines = [
        "# Thermal Exposure Simulation - Concept Model V1",
        "",
        "## Purpose",
        "",
        "This model screens sealed-enclosure thermal risk before hardware exists. It is designed to show thermal reasoning, not to claim measured temperature performance.",
        "",
        "## Model Setup",
        "",
        "- Model type: lumped thermal RC model.",
        "- Duration: {0} minutes with {1} second step.".format(DURATION_MIN, TIME_STEP_S),
        "- Ambient profile: {0:.1f} C to {1:.1f} C sinusoidal ramp.".format(AMBIENT_START_C, AMBIENT_PEAK_C),
        "- Peak solar/lamp input: {0:.1f} W.".format(SOLAR_PEAK_W),
        "- Electronics power: {0:.2f} W baseline, {1:.2f} W transmit-boundary pulse.".format(
            ELECTRONICS_BASE_W,
            ELECTRONICS_TX_W,
        ),
        "- Thermal capacitance: {0:.0f} J/C.".format(THERMAL_CAPACITANCE_J_PER_C),
        "- Thermal resistance to ambient: {0:.1f} C/W.".format(THERMAL_RESISTANCE_C_PER_W),
        "- Warning reference: {0:.1f} C internal temperature.".format(TEMPERATURE_WARNING_C),
        "",
        "## Results",
        "",
        "- Peak internal temperature: {0:.1f} C.".format(summary["peak_internal_C"]),
        "- Peak ambient temperature: {0:.1f} C.".format(summary["peak_ambient_C"]),
        "- Minimum margin to warning reference: {0:.1f} C.".format(summary["minimum_margin_to_warning_C"]),
        "- Time of peak internal temperature: {0} minutes.".format(summary["peak_internal_minute"]),
        "",
        "## Interpretation",
        "",
        "The model creates a first-pass estimate for whether the sealed enclosure could experience elevated internal temperature under a warm ambient ramp and external heat input. It also links firmware duty cycle to thermal load through the transmit-boundary power pulse.",
        "",
        "## Design Actions Suggested By This Result",
        "",
        "- Treat direct solar exposure as a design risk for the sealed enclosure.",
        "- Prefer light-coloured or UV-stable enclosure material for exposed installations.",
        "- Reduce radio transmit duty cycle and LED duty cycle during high-temperature operation.",
        "- Consider a shaded mounting location, vent membrane or heat-spreading insert before any physical prototype test.",
        "- Add internal temperature logging to the future hardware test plan.",
        "",
        "## Evidence Boundary",
        "",
        "Simulation only. No physical thermal logging, solar calibration, material emissivity measurement, contact resistance measurement or environmental chamber result is claimed.",
        "",
        "## Generated Files",
        "",
        "- `thermal_exposure_simulation_v1.csv`",
        "- `thermal_exposure_summary_v1.json`",
        "- `thermal_exposure_plot_v1.svg`",
    ]
    path.write_text("\n".join(lines) + "\n")
    return path


def build_summary(rows):
    peak_internal = max(rows, key=lambda row: row["internal_C"])
    peak_ambient = max(rows, key=lambda row: row["ambient_C"])
    minimum_margin = min(row["margin_to_warning_C"] for row in rows)
    return {
        "model": "lumped thermal RC concept model",
        "duration_min": DURATION_MIN,
        "time_step_s": TIME_STEP_S,
        "ambient_start_C": AMBIENT_START_C,
        "ambient_peak_C": AMBIENT_PEAK_C,
        "solar_peak_W": SOLAR_PEAK_W,
        "electronics_base_W": ELECTRONICS_BASE_W,
        "electronics_transmit_W": ELECTRONICS_TX_W,
        "tx_period_min": TX_PERIOD_MIN,
        "tx_duration_min": TX_DURATION_MIN,
        "thermal_capacitance_J_per_C": THERMAL_CAPACITANCE_J_PER_C,
        "thermal_resistance_C_per_W": THERMAL_RESISTANCE_C_PER_W,
        "warning_reference_C": TEMPERATURE_WARNING_C,
        "peak_internal_C": peak_internal["internal_C"],
        "peak_internal_minute": peak_internal["minute"],
        "peak_ambient_C": peak_ambient["ambient_C"],
        "peak_ambient_minute": peak_ambient["minute"],
        "minimum_margin_to_warning_C": minimum_margin,
        "evidence_boundary": "Simulation only; no measured thermal logging is claimed.",
    }


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = simulate()
    summary = build_summary(rows)
    write_csv(rows)
    write_json(summary)
    write_svg(rows, summary)
    write_report(summary)
    print(json.dumps(summary, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
