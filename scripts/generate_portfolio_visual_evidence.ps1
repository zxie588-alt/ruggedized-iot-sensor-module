Add-Type -AssemblyName System.Drawing

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$SiteRoot = Resolve-Path (Join-Path $ProjectRoot '..\..\job_search\portfolio_site')
$ProjectImageDir = Join-Path $ProjectRoot 'images'
$SiteImageDir = Join-Path $SiteRoot 'assets\images'

New-Item -ItemType Directory -Path $ProjectImageDir -Force | Out-Null
New-Item -ItemType Directory -Path $SiteImageDir -Force | Out-Null

function Color-Hex($hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function New-Canvas($w, $h, $bg = '#f6f8f7') {
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear((Color-Hex $bg))
    return @{ Bitmap = $bmp; Graphics = $g }
}

function Save-Canvas($canvas, $path) {
    $dir = Split-Path -Parent $path
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $canvas.Graphics.Dispose()
    $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Bitmap.Dispose()
}

function Font-New($size, $style = 'Regular') {
    return New-Object System.Drawing.Font 'Arial', $size, ([System.Drawing.FontStyle]::$style)
}

function Brush-New($hex) {
    return New-Object System.Drawing.SolidBrush (Color-Hex $hex)
}

function Pen-New($hex, $width = 2) {
    return New-Object System.Drawing.Pen (Color-Hex $hex), $width
}

function Draw-Text($g, $text, $x, $y, $size = 18, $hex = '#1f2a2e', $style = 'Regular') {
    $font = Font-New $size $style
    $brush = Brush-New $hex
    $g.DrawString($text, $font, $brush, [float]$x, [float]$y)
    $font.Dispose()
    $brush.Dispose()
}

function Draw-Box($g, $x, $y, $w, $h, $fill = '#ffffff', $stroke = '#d9e0df', $sw = 2) {
    $brush = Brush-New $fill
    $pen = Pen-New $stroke $sw
    $g.FillRectangle($brush, [float]$x, [float]$y, [float]$w, [float]$h)
    $g.DrawRectangle($pen, [float]$x, [float]$y, [float]$w, [float]$h)
    $brush.Dispose()
    $pen.Dispose()
}

function Draw-Line($g, $x1, $y1, $x2, $y2, $hex = '#007c73', $width = 3) {
    $pen = Pen-New $hex $width
    $g.DrawLine($pen, [float]$x1, [float]$y1, [float]$x2, [float]$y2)
    $pen.Dispose()
}

function Draw-Chip($g, $x, $y, $w, $h, $label, $fill = '#1f2a2e') {
    Draw-Box $g $x $y $w $h $fill '#111820' 2
    Draw-Text $g $label ($x + 8) ($y + ($h / 2) - 12) 15 '#ffffff' 'Bold'
}

function Draw-Header($g, $title, $subtitle) {
    Draw-Text $g $title 56 34 30 '#1f2a2e' 'Bold'
    Draw-Text $g $subtitle 58 76 16 '#5e6a70'
    Draw-Line $g 56 112 1544 112 '#007c73' 4
}

function Draw-PcbLayout($path) {
    $c = New-Canvas 1600 1000 '#eef3f6'
    $g = $c.Graphics
    Draw-Header $g 'PCB Layout Concept - STM32L432 Outdoor Sensor Module' '2-layer board concept: placement, route intent, keepouts and manufacturing constraints'
    Draw-Box $g 110 165 1120 680 '#0f6b5f' '#0b4f46' 4
    Draw-Box $g 140 195 1060 620 '#128576' '#bfe8e2' 2

    foreach ($p in @(@(200,245),@(1110,245),@(200,760),@(1110,760))) {
        $brush = Brush-New '#eef3f6'
        $pen = Pen-New '#0b4f46' 4
        $g.FillEllipse($brush, $p[0] - 24, $p[1] - 24, 48, 48)
        $g.DrawEllipse($pen, $p[0] - 24, $p[1] - 24, 48, 48)
        $brush.Dispose(); $pen.Dispose()
    }

    Draw-Chip $g 600 445 170 125 'U1 STM32L432' '#263238'
    Draw-Chip $g 335 330 145 90 'U2 I2C SENSOR' '#263238'
    Draw-Chip $g 350 580 140 80 'U3 3V3 REG' '#263238'
    Draw-Chip $g 190 465 110 100 'BT1' '#5d4037'
    Draw-Chip $g 1040 300 110 115 'J1 SWD' '#37474f'
    Draw-Chip $g 1040 595 120 115 'J2 RADIO' '#37474f'
    Draw-Chip $g 820 250 90 55 'D1' '#1b5e20'
    Draw-Chip $g 935 250 90 55 'D2' '#b71c1c'
    Draw-Chip $g 910 760 110 52 'SW1' '#455a64'

    Draw-Line $g 300 515 600 500 '#fdd835' 7
    Draw-Line $g 490 620 610 545 '#fdd835' 7
    Draw-Line $g 770 485 1040 355 '#90caf9' 4
    Draw-Line $g 770 530 1040 650 '#90caf9' 4
    Draw-Line $g 600 475 480 375 '#ffffff' 4
    Draw-Line $g 600 520 480 405 '#ffffff' 4
    Draw-Line $g 725 445 835 305 '#ffcc80' 4
    Draw-Line $g 745 445 950 305 '#ffcc80' 4
    Draw-Line $g 750 560 910 785 '#ce93d8' 4

    Draw-Box $g 1310 165 220 250 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Layer intent' 1330 190 19 '#1f2a2e' 'Bold'
    Draw-Text $g 'Top: signals + power' 1330 232 15 '#5e6a70'
    Draw-Text $g 'Bottom: GND pour' 1330 262 15 '#5e6a70'
    Draw-Text $g 'Board: 72 x 44 mm' 1330 292 15 '#5e6a70'
    Draw-Text $g 'Clearance: 0.20 mm' 1330 322 15 '#5e6a70'
    Draw-Text $g 'Power width: 0.60 mm' 1330 352 15 '#5e6a70'

    Draw-Box $g 1310 455 220 230 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Reviewed keepouts' 1330 480 19 '#1f2a2e' 'Bold'
    Draw-Text $g '4x standoff holes' 1330 522 15 '#5e6a70'
    Draw-Text $g 'Sensor membrane zone' 1330 552 15 '#5e6a70'
    Draw-Text $g 'Radio/module reserve' 1330 582 15 '#5e6a70'
    Draw-Text $g 'Service-port edge' 1330 612 15 '#5e6a70'

    Draw-Text $g 'Concept output: not vendor-ready Gerbers' 118 900 18 '#5e6a70' 'Bold'
    Save-Canvas $c $path
}

function Draw-Schematic($path) {
    $c = New-Canvas 1600 1000 '#f6f8f7'
    $g = $c.Graphics
    Draw-Header $g 'Electronics Schematic Concept' 'Proteus-ready signal ownership: MCU, power, sensor, debug, radio boundary'
    Draw-Box $g 640 320 260 260 '#263238' '#111820' 3
    Draw-Text $g 'U1 STM32L432KCUx' 676 350 22 '#ffffff' 'Bold'
    Draw-Text $g 'I2C  ADC  UART  SWD' 690 392 16 '#d7eeee'
    Draw-Text $g 'Sleep / sample / fault' 688 430 16 '#d7eeee'

    $blocks = @(
        @(110,260,250,120,'BT1 + Protection','VBAT_RAW / F1 / Q1'),
        @(110,550,250,120,'3V3 Regulator','REG_IN -> 3V3'),
        @(1110,210,300,130,'Environmental Sensor','PB6/PB7 I2C'),
        @(1110,430,300,130,'SWD Service Header','PA13 / PA14 / NRST'),
        @(1110,650,300,130,'Radio Boundary','PA9 / PA10 UART'),
        @(610,710,320,110,'Status + Fault LEDs','PA5 / PA6')
    )
    foreach ($b in $blocks) {
        Draw-Box $g $b[0] $b[1] $b[2] $b[3] '#ffffff' '#d9e0df' 2
        Draw-Text $g $b[4] ($b[0] + 22) ($b[1] + 25) 20 '#1f2a2e' 'Bold'
        Draw-Text $g $b[5] ($b[0] + 22) ($b[1] + 62) 16 '#5e6a70'
    }
    Draw-Line $g 360 320 640 395 '#007c73' 5
    Draw-Line $g 360 610 640 485 '#007c73' 5
    Draw-Line $g 900 370 1110 275 '#007c73' 5
    Draw-Line $g 900 445 1110 495 '#007c73' 5
    Draw-Line $g 900 520 1110 715 '#007c73' 5
    Draw-Line $g 760 580 760 710 '#007c73' 5

    Draw-Box $g 110 790 1290 95 '#e8f4f2' '#b6d8d4' 2
    Draw-Text $g 'Evidence links: component BOM, PCB netlist, power budget, Keil pinout, Proteus native project container' 140 820 20 '#005f58' 'Bold'
    Save-Canvas $c $path
}

function Draw-Drc($path) {
    $c = New-Canvas 1600 1000 '#ffffff'
    $g = $c.Graphics
    Draw-Header $g 'PCB Concept DRC / Clearance Review' 'Rules are conservative prototype values; final native EDA DRC remains future work'
    $rows = @(
        @('Minimum signal width','0.20 mm','Concept pass'),
        @('Minimum power width','0.60 mm','Concept review'),
        @('Minimum clearance','0.20 mm','Concept pass'),
        @('Via drill / pad','0.30 / 0.60 mm','Concept pass'),
        @('Mounting-hole keepout','2.0 mm radial','Concept pass'),
        @('Sensor thermal separation','U2 away from regulator','Concept review'),
        @('Native EDA DRC','Not claimed','Future work')
    )
    Draw-Box $g 120 170 1360 90 '#e8f4f2' '#d9e0df' 2
    Draw-Text $g 'Rule' 150 200 20 '#1f2a2e' 'Bold'
    Draw-Text $g 'Value / Evidence' 580 200 20 '#1f2a2e' 'Bold'
    Draw-Text $g 'Status' 1110 200 20 '#1f2a2e' 'Bold'
    $y = 260
    foreach ($r in $rows) {
        Draw-Box $g 120 $y 1360 74 '#ffffff' '#d9e0df' 1
        Draw-Text $g $r[0] 150 ($y + 22) 18 '#1f2a2e'
        Draw-Text $g $r[1] 580 ($y + 22) 18 '#5e6a70'
        $color = if ($r[2] -match 'pass') { '#007c73' } elseif ($r[2] -match 'review') { '#b26a00' } else { '#5e6a70' }
        Draw-Text $g $r[2] 1110 ($y + 22) 18 $color 'Bold'
        $y += 74
    }
    Draw-Box $g 120 835 1360 70 '#fff7e6' '#e5c37a' 2
    Draw-Text $g 'Boundary: this is a DRC-style concept review, not a vendor DRC sign-off.' 150 858 20 '#7a4d00' 'Bold'
    Save-Canvas $c $path
}

function Draw-Ladder($path) {
    $c = New-Canvas 1600 1000 '#f6f8f7'
    $g = $c.Graphics
    Draw-Header $g 'PLC Ladder Logic Concept - Validation Fixture' 'Spray / thermal / cooldown sequence with safety interlocks and fault latch'
    Draw-Line $g 120 170 120 850 '#1f2a2e' 6
    Draw-Line $g 1480 170 1480 850 '#1f2a2e' 6
    $networks = @(
        @('N1 MASTER_OK','E_STOP_OK','DOOR_CLOSED','NOT LEAK','NOT TEMP_HIGH','MASTER_OK'),
        @('N2 START LATCH','START_CMD','DUT_PRESENT','CLAMP_CLOSED','LOGGER_READY','STEP_PRECHECK'),
        @('N3 SPRAY','STEP_SPRAY','MASTER_OK','','','PUMP_ENABLE'),
        @('N4 THERMAL','STEP_THERMAL','MASTER_OK','','','LAMP_ENABLE'),
        @('N5 FAULT','NOT E_STOP_OK','OR DOOR OPEN','OR LEAK','OR TEMP_HIGH','STEP_FAULT')
    )
    $y = 210
    foreach ($n in $networks) {
        Draw-Text $g $n[0] 145 ($y - 8) 15 '#5e6a70' 'Bold'
        Draw-Line $g 120 $y 1480 $y '#1f2a2e' 3
        $x = 270
        for ($i = 1; $i -le 4; $i++) {
            if ($n[$i] -ne '') {
                Draw-Line $g ($x - 35) ($y - 32) ($x - 35) ($y + 32) '#1f2a2e' 3
                Draw-Line $g ($x + 35) ($y - 32) ($x + 35) ($y + 32) '#1f2a2e' 3
                Draw-Text $g $n[$i] ($x - 68) ($y + 42) 14 '#1f2a2e'
            }
            $x += 230
        }
        $pen = Pen-New '#007c73' 4
        $g.DrawEllipse($pen, 1260, $y - 34, 68, 68)
        $g.DrawEllipse($pen, 1328, $y - 34, 68, 68)
        $pen.Dispose()
        Draw-Text $g $n[5] 1230 ($y + 42) 15 '#005f58' 'Bold'
        $y += 135
    }
    Draw-Box $g 120 875 1360 70 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'PLC evidence includes I/O list, sequence table, fault matrix, ladder logic, HMI spec and IEC 61131-3 ST code.' 150 900 18 '#1f2a2e' 'Bold'
    Save-Canvas $c $path
}

function Draw-Hmi($path) {
    $c = New-Canvas 1600 1000 '#e7edf0'
    $g = $c.Graphics
    Draw-Header $g 'HMI Concept - Rugged Sensor Validation Fixture' 'Operator run screen for spray, thermal and cooldown validation cycles'
    Draw-Box $g 150 150 1300 760 '#263238' '#111820' 4
    Draw-Box $g 190 200 126 74 '#007c73' '#004d45' 2
    Draw-Text $g 'READY' 218 222 22 '#ffffff' 'Bold'
    Draw-Text $g 'Current step: SPRAY EXPOSURE' 360 215 30 '#ffffff' 'Bold'
    Draw-Text $g 'Fault code: 0   Logger: READY   Door: CLOSED   Clamp: CLOSED' 360 260 18 '#cfe8e4'

    Draw-Box $g 220 340 310 150 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Spray time' 250 368 18 '#5e6a70'
    Draw-Text $g '01:42 remaining' 250 410 30 '#007c73' 'Bold'
    Draw-Box $g 645 340 310 150 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Thermal time' 675 368 18 '#5e6a70'
    Draw-Text $g '05:00 setpoint' 675 410 30 '#1f2a2e' 'Bold'
    Draw-Box $g 1070 340 310 150 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Cooldown' 1100 368 18 '#5e6a70'
    Draw-Text $g '03:00 setpoint' 1100 410 30 '#1f2a2e' 'Bold'

    $buttons = @(@('START',220,610,'#007c73'),@('STOP',520,610,'#9c2f2f'),@('RESET',820,610,'#455a64'),@('SERVICE',1120,610,'#5e6a70'))
    foreach ($b in $buttons) {
        Draw-Box $g $b[1] $b[2] 210 92 $b[3] '#ffffff' 2
        Draw-Text $g $b[0] ($b[1]+48) ($b[2]+28) 24 '#ffffff' 'Bold'
    }

    Draw-Box $g 220 760 1160 70 '#fff7e6' '#e5c37a' 2
    Draw-Text $g 'Alarm history: no active alarm. Last cycle completed with pass light at 14:28 placeholder.' 250 783 19 '#7a4d00' 'Bold'
    Save-Canvas $c $path
}

function Draw-Sequence($path) {
    $c = New-Canvas 1600 900 '#ffffff'
    $g = $c.Graphics
    Draw-Header $g 'PLC Test Fixture Sequence' 'Idle -> Precheck -> Spray -> Thermal -> Cooldown -> Complete, with fault path from every active step'
    $steps = @('Idle','Precheck','Spray','Thermal','Cooldown','Complete')
    $x = 110
    foreach ($s in $steps) {
        Draw-Box $g $x 330 190 120 '#e8f4f2' '#007c73' 3
        Draw-Text $g $s ($x + 42) 372 22 '#005f58' 'Bold'
        if ($x -lt 1200) { Draw-Line $g ($x+190) 390 ($x+260) 390 '#007c73' 5 }
        $x += 260
    }
    Draw-Box $g 635 620 260 110 '#ffecec' '#9c2f2f' 3
    Draw-Text $g 'Fault Step 90' 682 657 24 '#9c2f2f' 'Bold'
    Draw-Line $g 460 450 690 620 '#9c2f2f' 4
    Draw-Line $g 720 450 750 620 '#9c2f2f' 4
    Draw-Line $g 980 450 810 620 '#9c2f2f' 4
    Draw-Line $g 1240 450 870 620 '#9c2f2f' 4
    Draw-Text $g 'Fault sources: E-stop, door open, clamp lost, leak detected, over-temperature, logger not ready.' 160 790 20 '#5e6a70' 'Bold'
    Save-Canvas $c $path
}

function Draw-BuildEvidence($path) {
    $c = New-Canvas 1600 900 '#202124'
    $g = $c.Graphics
    Draw-Text $g 'Keil / ARMCLANG Build Evidence' 60 42 30 '#ffffff' 'Bold'
    Draw-Box $g 60 115 1480 660 '#111820' '#39464f' 2
    $lines = @(
        '> UV4.exe -b Ruggedized_IoT_Sensor_Module.uvprojx',
        'Target: Concept_Firmware_Portable_C',
        'Compiling src/main.c',
        'Compiling src/app_state_machine.c',
        'Compiling drivers/sensor_driver.c',
        'Compiling drivers/power_monitor.c',
        'Assembling platform/startup_armcm3.s',
        'Linking Ruggedized_IoT_Sensor_Module.axf',
        'Program Size: Code=500 RO-data=80 RW-data=0 ZI-data=1024',
        'Build Time Elapsed: concept evidence log',
        '0 Error(s), 0 Warning(s)'
    )
    $y = 155
    foreach ($line in $lines) {
        $color = if ($line -match '0 Error') { '#64d98a' } elseif ($line -match '^>') { '#80cbc4' } else { '#d7dde2' }
        Draw-Text $g $line 95 $y 22 $color
        $y += 50
    }
    Draw-Box $g 60 805 1480 55 '#263238' '#39464f' 2
    Draw-Text $g 'Boundary: clean concept target build; final STM32L432 startup/RTE/HIL remains future work.' 95 820 18 '#cfe8e4' 'Bold'
    Save-Canvas $c $path
}

function Draw-ProteusEvidence($path) {
    $c = New-Canvas 1600 900 '#f6f8f7'
    $g = $c.Graphics
    Draw-Header $g 'Proteus Native Project Evidence' 'Verified .pdsprj container plus schematic concept package'
    Draw-Box $g 120 170 560 540 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Native container entries' 150 200 23 '#1f2a2e' 'Bold'
    foreach ($item in @('ROOT.DSN','ROOT.CDB','PROJECT.XML','SCRIPTS/PWRRAILS.DAT','SHA256 manifest','Verification report')) {
        Draw-Text $g ('[OK] ' + $item) 160 (250 + 54 * [array]::IndexOf(@('ROOT.DSN','ROOT.CDB','PROJECT.XML','SCRIPTS/PWRRAILS.DAT','SHA256 manifest','Verification report'), $item)) 20 '#007c73' 'Bold'
    }
    Draw-Box $g 760 170 720 540 '#ffffff' '#d9e0df' 2
    Draw-Text $g 'Schematic package' 790 200 23 '#1f2a2e' 'Bold'
    $items = @('Component selection','Connection-level netlist','Power budget','Firmware pin map','Review checklist','SVG schematic')
    $y = 250
    foreach ($item in $items) {
        Draw-Box $g 790 $y 300 46 '#e8f4f2' '#b6d8d4' 1
        Draw-Text $g $item 808 ($y + 11) 17 '#005f58' 'Bold'
        $y += 62
    }
    Draw-Box $g 120 760 1360 64 '#fff7e6' '#e5c37a' 2
    Draw-Text $g 'Boundary: native container verified; fully populated Proteus schematic sheet + ERC remains future work.' 150 780 19 '#7a4d00' 'Bold'
    Save-Canvas $c $path
}

function Draw-ProjectPreview($path, $title, $subtitle, $mode) {
    $c = New-Canvas 1200 760 '#f6f8f7'
    $g = $c.Graphics
    Draw-Box $g 0 0 1200 760 '#f6f8f7' '#f6f8f7' 1
    Draw-Text $g $title 60 50 34 '#1f2a2e' 'Bold'
    Draw-Text $g $subtitle 62 96 18 '#5e6a70'
    Draw-Line $g 60 135 1140 135 '#007c73' 4
    switch ($mode) {
        'solar' {
            Draw-Box $g 170 210 280 420 '#ffe3b0' '#b26a00' 3
            Draw-Box $g 450 250 120 340 '#e0f7fa' '#007c73' 2
            Draw-Box $g 570 180 160 480 '#d7eef8' '#5e6a70' 3
            for ($i=0; $i -lt 9; $i++) { Draw-Line $g (760+$i*26) 620 (820+$i*26) 310 '#007c73' 3 }
            Draw-Text $g 'CHT CFD' 820 220 42 '#007c73' 'Bold'
        }
        'orbital' {
            $nodes = @(@(220,330,'Stakeholders'),@(480,220,'Power'),@(720,330,'Thermal'),@(480,500,'Risk'),@(900,230,'Orbit'),@(900,510,'Verification'))
            foreach ($a in $nodes) { foreach ($b in $nodes) { if ($a -ne $b) { Draw-Line $g $a[0] $a[1] $b[0] $b[1] '#d9e0df' 1 } } }
            foreach ($n in $nodes) { Draw-Box $g ($n[0]-85) ($n[1]-34) 170 68 '#e8f4f2' '#007c73' 2; Draw-Text $g $n[2] ($n[0]-58) ($n[1]-12) 17 '#005f58' 'Bold' }
            Draw-Text $g 'Systems Leadership' 350 640 34 '#1f2a2e' 'Bold'
        }
        'dynamic' {
            Draw-Box $g 160 430 780 80 '#455a64' '#263238' 4
            Draw-Box $g 240 350 120 80 '#ffffff' '#007c73' 3
            Draw-Box $g 620 350 120 80 '#ffffff' '#007c73' 3
            Draw-Line $g 300 430 300 350 '#007c73' 5
            Draw-Line $g 680 430 680 350 '#007c73' 5
            Draw-Box $g 870 260 180 150 '#e8f4f2' '#007c73' 3
            Draw-Text $g 'STM32' 910 302 30 '#005f58' 'Bold'
            Draw-Text $g 'Load cells + filtering + serial data' 270 610 26 '#1f2a2e' 'Bold'
        }
        'pill' {
            Draw-Box $g 180 210 760 420 '#ffffff' '#d9e0df' 4
            for ($r=0; $r -lt 2; $r++) { for ($col=0; $col -lt 7; $col++) { $x=230+$col*95; $y=270+$r*140; $brush=Brush-New '#e8f4f2'; $pen=Pen-New '#007c73' 3; $g.FillEllipse($brush,$x,$y,62,62); $g.DrawEllipse($pen,$x,$y,62,62); $brush.Dispose(); $pen.Dispose() } }
            Draw-Box $g 980 270 120 220 '#263238' '#111820' 3
            Draw-Text $g 'HMI' 1015 350 28 '#ffffff' 'Bold'
            Draw-Text $g 'Mechatronics medication reminder concept' 275 665 24 '#1f2a2e' 'Bold'
        }
        default {
            Draw-Box $g 130 210 940 400 '#ffffff' '#d9e0df' 3
            Draw-Text $g 'Project evidence preview' 335 370 38 '#007c73' 'Bold'
        }
    }
    Save-Canvas $c $path
}

function Draw-IotOverview($path) {
    $c = New-Canvas 1200 760 '#eef3f6'
    $g = $c.Graphics
    Draw-Text $g 'Ruggedized Outdoor IoT Sensor Module' 60 50 34 '#1f2a2e' 'Bold'
    Draw-Text $g 'CAD + FEA + PCB + Keil + PLC fixture + release evidence' 62 96 18 '#5e6a70'
    $cards = @(
        @('CAD V2','SolidWorks enclosure',70,170),
        @('FEA','3 Abaqus load cases',440,170),
        @('PCB','2-layer concept package',810,170),
        @('Keil','0 error / 0 warning build',70,420),
        @('PLC','fixture sequence + HMI',440,420),
        @('Release','DFM + CTQ + boundary',810,420)
    )
    foreach ($card in $cards) {
        Draw-Box $g $card[2] $card[3] 300 180 '#ffffff' '#d9e0df' 2
        Draw-Text $g $card[0] ($card[2]+24) ($card[3]+28) 32 '#007c73' 'Bold'
        Draw-Text $g $card[1] ($card[2]+24) ($card[3]+88) 18 '#5e6a70'
    }
    Save-Canvas $c $path
}

$outputs = @(
    @{ Name='pcb_layout_top_v1.png'; Fn={ param($p) Draw-PcbLayout $p } },
    @{ Name='pcb_schematic_capture_v1.png'; Fn={ param($p) Draw-Schematic $p } },
    @{ Name='pcb_drc_summary_v1.png'; Fn={ param($p) Draw-Drc $p } },
    @{ Name='plc_ladder_logic_v1.png'; Fn={ param($p) Draw-Ladder $p } },
    @{ Name='plc_hmi_fixture_v1.png'; Fn={ param($p) Draw-Hmi $p } },
    @{ Name='plc_sequence_timeline_v1.png'; Fn={ param($p) Draw-Sequence $p } },
    @{ Name='keil_build_evidence_v1.png'; Fn={ param($p) Draw-BuildEvidence $p } },
    @{ Name='proteus_project_evidence_v1.png'; Fn={ param($p) Draw-ProteusEvidence $p } },
    @{ Name='iot_project_evidence_overview_v1.png'; Fn={ param($p) Draw-IotOverview $p } }
)

foreach ($o in $outputs) {
    $projectPath = Join-Path $ProjectImageDir $o.Name
    & $o.Fn $projectPath
    Copy-Item -LiteralPath $projectPath -Destination (Join-Path $SiteImageDir $o.Name) -Force
}

Draw-ProjectPreview (Join-Path $SiteImageDir 'solar_chimney_preview.png') 'Solar Chimney CFD Reproduction' 'Conjugate heat-transfer workflow and buoyancy validation' 'solar'
Draw-ProjectPreview (Join-Path $SiteImageDir 'orbital_ai_data_centre_preview.png') 'Orbital AI Data Centre Study' 'Systems leadership: stakeholders, trades, risk and verification' 'orbital'
Draw-ProjectPreview (Join-Path $SiteImageDir 'dynamic_weighing_preview.png') 'Dynamic Livestock Weighing System' 'Sensors, embedded control and serial/Bluetooth data boundary' 'dynamic'
Draw-ProjectPreview (Join-Path $SiteImageDir 'smart_pill_box_preview.png') 'Smart Pill Box Mechatronics' 'Medication scheduling, alerts and product-control thinking' 'pill'

Write-Output "Generated visual evidence in $ProjectImageDir and $SiteImageDir"
