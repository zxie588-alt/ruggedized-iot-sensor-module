(* Ruggedized IoT Sensor Module - Test Fixture Controller
   IEC 61131-3 Structured Text concept implementation.
   Portfolio evidence only: not commissioned on a physical PLC. *)

TYPE FixtureStep :
(
    STEP_IDLE := 0,
    STEP_PRECHECK := 10,
    STEP_SPRAY := 20,
    STEP_THERMAL := 30,
    STEP_COOLDOWN := 40,
    STEP_COMPLETE := 50,
    STEP_FAULT := 90
);
END_TYPE

VAR
    E_STOP_OK : BOOL;
    DOOR_CLOSED : BOOL;
    CLAMP_CLOSED : BOOL;
    DUT_PRESENT : BOOL;
    LEAK_SENSOR : BOOL;
    TEMP_HIGH : BOOL;
    LOGGER_READY : BOOL;
    START_CMD : BOOL;
    STOP_CMD : BOOL;
    RESET_CMD : BOOL;

    PUMP_ENABLE : BOOL;
    LAMP_ENABLE : BOOL;
    DUT_POWER : BOOL;
    LOGGER_TRIGGER : BOOL;
    PASS_LIGHT : BOOL;
    FAIL_LIGHT : BOOL;
    BUZZER : BOOL;
    VENT_FAN : BOOL;

    SPRAY_TIME_SP : TIME := T#120s;
    THERMAL_TIME_SP : TIME := T#300s;
    COOLDOWN_TIME_SP : TIME := T#180s;

    Step : FixtureStep := STEP_IDLE;
    FaultCode : INT := 0;
    MasterOK : BOOL;
    EntryPulse : BOOL;
    LastStep : FixtureStep := STEP_IDLE;

    SprayTimer : TON;
    ThermalTimer : TON;
    CooldownTimer : TON;
END_VAR

MasterOK := E_STOP_OK AND DOOR_CLOSED AND NOT LEAK_SENSOR AND NOT TEMP_HIGH;
EntryPulse := Step <> LastStep;
LastStep := Step;

PUMP_ENABLE := FALSE;
LAMP_ENABLE := FALSE;
DUT_POWER := FALSE;
LOGGER_TRIGGER := FALSE;
PASS_LIGHT := FALSE;
FAIL_LIGHT := FALSE;
BUZZER := FALSE;
VENT_FAN := FALSE;

IF NOT E_STOP_OK THEN
    FaultCode := 101;
    Step := STEP_FAULT;
ELSIF (Step <> STEP_IDLE) AND (Step <> STEP_FAULT) AND NOT DOOR_CLOSED THEN
    FaultCode := 102;
    Step := STEP_FAULT;
ELSIF (Step <> STEP_IDLE) AND (Step <> STEP_FAULT) AND NOT CLAMP_CLOSED THEN
    FaultCode := 103;
    Step := STEP_FAULT;
ELSIF LEAK_SENSOR THEN
    FaultCode := 104;
    Step := STEP_FAULT;
ELSIF TEMP_HIGH THEN
    FaultCode := 105;
    Step := STEP_FAULT;
ELSIF STOP_CMD THEN
    Step := STEP_IDLE;
END_IF;

CASE Step OF
    STEP_IDLE:
        FaultCode := 0;
        IF START_CMD AND MasterOK AND DUT_PRESENT AND CLAMP_CLOSED AND LOGGER_READY THEN
            Step := STEP_PRECHECK;
        ELSIF START_CMD AND NOT DUT_PRESENT THEN
            FaultCode := 107;
            Step := STEP_FAULT;
        END_IF;

    STEP_PRECHECK:
        DUT_POWER := TRUE;
        LOGGER_TRIGGER := EntryPulse;
        IF NOT LOGGER_READY THEN
            FaultCode := 106;
            Step := STEP_FAULT;
        ELSE
            Step := STEP_SPRAY;
        END_IF;

    STEP_SPRAY:
        DUT_POWER := TRUE;
        PUMP_ENABLE := MasterOK;
        SprayTimer(IN := TRUE, PT := SPRAY_TIME_SP);
        IF SprayTimer.Q THEN
            SprayTimer(IN := FALSE);
            Step := STEP_THERMAL;
        END_IF;

    STEP_THERMAL:
        DUT_POWER := TRUE;
        LAMP_ENABLE := MasterOK;
        LOGGER_TRIGGER := EntryPulse;
        ThermalTimer(IN := TRUE, PT := THERMAL_TIME_SP);
        IF ThermalTimer.Q THEN
            ThermalTimer(IN := FALSE);
            Step := STEP_COOLDOWN;
        END_IF;

    STEP_COOLDOWN:
        DUT_POWER := TRUE;
        VENT_FAN := TRUE;
        CooldownTimer(IN := TRUE, PT := COOLDOWN_TIME_SP);
        IF CooldownTimer.Q THEN
            CooldownTimer(IN := FALSE);
            Step := STEP_COMPLETE;
        END_IF;

    STEP_COMPLETE:
        PASS_LIGHT := TRUE;
        LOGGER_TRIGGER := EntryPulse;
        IF RESET_CMD THEN
            Step := STEP_IDLE;
        END_IF;

    STEP_FAULT:
        FAIL_LIGHT := TRUE;
        BUZZER := TRUE;
        VENT_FAN := TEMP_HIGH;
        IF RESET_CMD AND MasterOK AND CLAMP_CLOSED THEN
            FaultCode := 0;
            Step := STEP_IDLE;
        END_IF;
END_CASE;
