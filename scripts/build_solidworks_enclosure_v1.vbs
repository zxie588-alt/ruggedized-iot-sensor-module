Option Explicit

Const swDocPART = 1
Const swDocASSEMBLY = 2
Const swSaveAsOptions_Silent = 1

Dim fso, projectRoot, partTemplate, asmTemplate, cadDir, asciiCadDir, exportDir, imageDir
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetAbsolutePathName(".")
partTemplate = "C:\ProgramData\SOLIDWORKS\SOLIDWORKS 2018\templates\gb_part.prtdot"
asmTemplate = "C:\ProgramData\SOLIDWORKS\SOLIDWORKS 2018\templates\gb_assembly.asmdot"
cadDir = projectRoot & "\cad\solidworks"
asciiCadDir = "C:\sw_iot_build"
exportDir = projectRoot & "\exports"
imageDir = projectRoot & "\images"

If Not fso.FileExists(partTemplate) Then Fail "Missing SolidWorks part template: " & partTemplate
If Not fso.FileExists(asmTemplate) Then Fail "Missing SolidWorks assembly template: " & asmTemplate
EnsureAsciiCadDir asciiCadDir

Dim swApp
Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

WScript.Echo "SolidWorks revision: " & swApp.RevisionNumber
WScript.Echo "Project root: " & projectRoot

Dim lowerPath, lidPath, gasketPath, pcbPath, batteryPath, asmPath
Dim lowerAsmPath, lidAsmPath, gasketAsmPath, pcbAsmPath, batteryAsmPath, asmBuildPath
lowerPath = cadDir & "\iot_lower_enclosure_v1.SLDPRT"
lidPath = cadDir & "\iot_lid_v1.SLDPRT"
gasketPath = cadDir & "\iot_gasket_v1.SLDPRT"
pcbPath = cadDir & "\iot_pcb_populated_placeholder_v1.SLDPRT"
batteryPath = cadDir & "\iot_battery_placeholder_v1.SLDPRT"
asmPath = cadDir & "\iot_sensor_module_exploded_v1.SLDASM"
lowerAsmPath = asciiCadDir & "\iot_lower_enclosure_v1.SLDPRT"
lidAsmPath = asciiCadDir & "\iot_lid_v1.SLDPRT"
gasketAsmPath = asciiCadDir & "\iot_gasket_v1.SLDPRT"
pcbAsmPath = asciiCadDir & "\iot_pcb_populated_placeholder_v1.SLDPRT"
batteryAsmPath = asciiCadDir & "\iot_battery_placeholder_v1.SLDPRT"
asmBuildPath = asciiCadDir & "\iot_sensor_module_exploded_v1.SLDASM"

CloseProjectDocs
BuildLowerEnclosure lowerPath
BuildLid lidPath
BuildGasket gasketPath
BuildPCB pcbPath
BuildBattery batteryPath
CopyPartsToAsciiCadDir
RunAssemblyScript

WScript.Echo "DONE: SolidWorks V1 enclosure model generated."

Sub BuildLowerEnclosure(path)
  Dim model
  Set model = NewPart("iot_lower_enclosure_v1")
  AddCustomProps model, "Lower enclosure - early CAD V1", "PC-ABS concept"

  ' Bottom plate: 110 x 70 x 2.5 mm rounded rectangle.
  BeginFrontSketch model
  DrawRoundedRectangle model, 0, 0, 110, 70, 7
  ExtrudeBoss model, 2.5, "bottom_plate_2p5mm", True

  ' Four straight wall segments, leaving the inside open for PCB and battery placeholders.
  AddRectBoss model, -53.5, 0, 3, 58, 24, "left_side_wall_3mm"
  AddRectBoss model, 53.5, 0, 3, 58, 24, "right_side_wall_3mm"
  AddRectBoss model, 0, 33.5, 110, 3, 24, "rear_side_wall_3mm"
  AddRectBoss model, 0, -33.5, 110, 3, 24, "front_side_wall_3mm"

  ' Corner screw bosses and PCB standoffs.
  AddCylinderBoss model, -42, -22, 4.5, 18, "boss_M3_front_left"
  AddCylinderBoss model, 42, -22, 4.5, 18, "boss_M3_front_right"
  AddCylinderBoss model, -42, 22, 4.5, 18, "boss_M3_rear_left"
  AddCylinderBoss model, 42, 22, 4.5, 18, "boss_M3_rear_right"

  AddCylinderBoss model, -32, -16, 2.4, 6, "pcb_standoff_1"
  AddCylinderBoss model, 32, -16, 2.4, 6, "pcb_standoff_2"
  AddCylinderBoss model, -32, 16, 2.4, 6, "pcb_standoff_3"
  AddCylinderBoss model, 32, 16, 2.4, 6, "pcb_standoff_4"

  SavePartAndExports model, path, "iot_lower_enclosure_v1"
End Sub

Sub BuildLid(path)
  Dim model
  Set model = NewPart("iot_lid_v1")
  AddCustomProps model, "Upper lid - early CAD V1", "UV-stabilised PC-ABS concept"

  BeginFrontSketch model
  DrawRoundedRectangle model, 0, 0, 112, 72, 7.5
  ExtrudeBoss model, 3, "lid_plate_3mm", True

  ' Raised sensor/membrane zone and screw pads.
  AddCylinderBoss model, 0, 0, 12, 5, "raised_sensor_membrane_boss"
  AddCylinderBoss model, 0, 0, 8, 6.2, "sensor_membrane_cap_placeholder"

  AddCylinderBoss model, -42, -22, 4.8, 4.2, "screw_pad_front_left"
  AddCylinderBoss model, 42, -22, 4.8, 4.2, "screw_pad_front_right"
  AddCylinderBoss model, -42, 22, 4.8, 4.2, "screw_pad_rear_left"
  AddCylinderBoss model, 42, 22, 4.8, 4.2, "screw_pad_rear_right"

  ' Underside alignment lip represented as visible internal rails for V1.
  AddRectBoss model, -47, 0, 2, 54, 5.5, "internal_alignment_lip_left"
  AddRectBoss model, 47, 0, 2, 54, 5.5, "internal_alignment_lip_right"
  AddRectBoss model, 0, 27, 94, 2, 5.5, "internal_alignment_lip_rear"
  AddRectBoss model, 0, -27, 94, 2, 5.5, "internal_alignment_lip_front"

  SavePartAndExports model, path, "iot_lid_v1"
End Sub

Sub BuildGasket(path)
  Dim model
  Set model = NewPart("iot_gasket_v1")
  AddCustomProps model, "Compression gasket - early CAD V1", "Silicone/EPDM concept"

  AddRectBoss model, -48, 0, 2.2, 56, 1.8, "gasket_left_run"
  AddRectBoss model, 48, 0, 2.2, 56, 1.8, "gasket_right_run"
  AddRectBoss model, 0, 28, 96, 2.2, 1.8, "gasket_rear_run"
  AddRectBoss model, 0, -28, 96, 2.2, 1.8, "gasket_front_run"
  AddCylinderBoss model, -48, -28, 2.4, 1.8, "gasket_corner_front_left"
  AddCylinderBoss model, 48, -28, 2.4, 1.8, "gasket_corner_front_right"
  AddCylinderBoss model, -48, 28, 2.4, 1.8, "gasket_corner_rear_left"
  AddCylinderBoss model, 48, 28, 2.4, 1.8, "gasket_corner_rear_right"

  SavePartAndExports model, path, "iot_gasket_v1"
End Sub

Sub BuildPCB(path)
  Dim model
  Set model = NewPart("iot_pcb_populated_placeholder_v1")
  AddCustomProps model, "Populated PCB envelope placeholder - early CAD V1", "FR4 board with envelope components"

  BeginFrontSketch model
  DrawRoundedRectangle model, 0, 0, 86, 44, 3
  ExtrudeBoss model, 1.6, "fr4_board_1p6mm", True

  AddRectBoss model, -20, 0, 18, 18, 5, "mcu_module_envelope"
  AddRectBoss model, 13, 0, 20, 12, 4, "sensor_power_module_envelope"
  AddRectBoss model, 35, 0, 10, 28, 3.5, "connector_zone_envelope"
  AddRectBoss model, 0, 18, 54, 3, 2.4, "antenna_keepout_marker"

  SavePartAndExports model, path, "iot_pcb_populated_placeholder_v1"
End Sub

Sub BuildBattery(path)
  Dim model
  Set model = NewPart("iot_battery_placeholder_v1")
  AddCustomProps model, "Battery pack placeholder - early CAD V1", "2-cell Li-ion envelope concept"

  BeginFrontSketch model
  DrawRoundedRectangle model, 0, 0, 58, 32, 3
  ExtrudeBoss model, 10, "battery_pack_envelope_58x32x10", True

  SavePartAndExports model, path, "iot_battery_placeholder_v1"
End Sub

Sub BuildAssembly(path, lowerPath, lidPath, gasketPath, pcbPath, batteryPath)
  Dim model, assy
  OpenPartForAssembly lowerPath
  OpenPartForAssembly lidPath
  OpenPartForAssembly gasketPath
  OpenPartForAssembly pcbPath
  OpenPartForAssembly batteryPath

  Set model = swApp.NewDocument(asmTemplate, 0, 0, 0)
  If model Is Nothing Then Fail "Could not create assembly document."
  Set assy = swApp.ActiveDoc

  AddAssemblyComponent assy, lowerPath, 0, 0, 0, "lower enclosure"
  AddAssemblyComponent assy, pcbPath, 0, 0, Mm(7), "populated PCB"
  AddAssemblyComponent assy, batteryPath, Mm(0), Mm(-16), Mm(8), "battery pack"
  AddAssemblyComponent assy, gasketPath, 0, 0, Mm(30), "gasket"
  AddAssemblyComponent assy, lidPath, 0, 0, Mm(47), "raised lid"

  model.ViewZoomtofit2
  model.ShowNamedView2 "*Isometric", 7
  model.ForceRebuild3 False

  model.SaveAs3 path, 0, swSaveAsOptions_Silent
  If Not fso.FileExists(path) Then Fail "Could not save assembly: " & path
  model.SaveAs3 exportDir & "\iot_sensor_module_exploded_v1.STEP", 0, swSaveAsOptions_Silent
  model.SaveAs3 imageDir & "\iot_sensor_module_exploded_v1.png", 0, swSaveAsOptions_Silent
  swApp.CloseDoc model.GetTitle
  CloseProjectDocs
  fso.CopyFile path, cadDir & "\iot_sensor_module_exploded_v1.SLDASM", True
  WScript.Echo "Saved assembly: " & path
End Sub

Sub OpenPartForAssembly(componentPath)
  Dim attempt, ok
  ok = False
  For attempt = 1 To 3
    On Error Resume Next
    Err.Clear
    swApp.OpenDoc componentPath, swDocPART
    If Err.Number = 0 Then ok = True
    On Error GoTo 0
    If ok Then Exit For
    WScript.Sleep 2000
  Next
  If Not ok Then Fail "Could not open component for assembly: " & componentPath
End Sub

Sub AddAssemblyComponent(assy, componentPath, x, y, z, label)
  Dim comp
  Set comp = assy.AddComponent5(componentPath, 0, "", False, "", x, y, z)
  If comp Is Nothing Then
    WScript.Echo "WARN: component not inserted: " & label & " -> " & componentPath
  Else
    WScript.Echo "Inserted component: " & label
  End If
End Sub

Function NewPart(title)
  Dim model
  Set model = swApp.NewDocument(partTemplate, 0, 0, 0)
  If model Is Nothing Then Fail "Could not create part document: " & title
  Set model = swApp.ActiveDoc
  model.SetTitle2 title
  Set NewPart = model
End Function

Sub AddCustomProps(model, description, materialNote)
  Dim mgr
  Set mgr = model.Extension.CustomPropertyManager("")
  mgr.Add3 "Project", 30, "Ruggedized Outdoor IoT Sensor Module", 2
  mgr.Add3 "Description", 30, description, 2
  mgr.Add3 "Material note", 30, materialNote, 2
  mgr.Add3 "Design status", 30, "Concept CAD V1 - dimensions and validation pending", 2
End Sub

Sub BeginFrontSketch(model)
  Dim ok, cnFrontPlane, cnFrontPlaneAlt
  cnFrontPlane = ChrW(&H524D) & ChrW(&H89C6) & ChrW(&H57FA) & ChrW(&H51C6) & ChrW(&H9762)
  cnFrontPlaneAlt = ChrW(&H524D) & ChrW(&H57FA) & ChrW(&H51C6) & ChrW(&H9762)
  model.ClearSelection2 True
  ok = model.Extension.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
  If Not ok Then
    ok = model.Extension.SelectByID2(cnFrontPlane, "PLANE", 0, 0, 0, False, 0, Nothing, 0)
  End If
  If Not ok Then
    ok = model.Extension.SelectByID2(cnFrontPlaneAlt, "PLANE", 0, 0, 0, False, 0, Nothing, 0)
  End If
  If Not ok Then
    ok = model.Extension.SelectByID2("Plane1", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
  End If
  If Not ok Then
    Fail "Could not select Front Plane in " & model.GetTitle
  End If
  model.SketchManager.InsertSketch True
End Sub

Sub DrawRoundedRectangle(model, cxMm, cyMm, wMm, hMm, rMm)
  Dim sm, cx, cy, hw, hh, r, k
  Set sm = model.SketchManager
  cx = Mm(cxMm): cy = Mm(cyMm): hw = Mm(wMm / 2): hh = Mm(hMm / 2): r = Mm(rMm)
  k = r / Sqr(2)

  sm.CreateLine cx - hw + r, cy + hh, 0, cx + hw - r, cy + hh, 0
  sm.Create3PointArc cx + hw - r, cy + hh, 0, cx + hw, cy + hh - r, 0, cx + hw - r + k, cy + hh - r + k, 0
  sm.CreateLine cx + hw, cy + hh - r, 0, cx + hw, cy - hh + r, 0
  sm.Create3PointArc cx + hw, cy - hh + r, 0, cx + hw - r, cy - hh, 0, cx + hw - r + k, cy - hh + r - k, 0
  sm.CreateLine cx + hw - r, cy - hh, 0, cx - hw + r, cy - hh, 0
  sm.Create3PointArc cx - hw + r, cy - hh, 0, cx - hw, cy - hh + r, 0, cx - hw + r - k, cy - hh + r - k, 0
  sm.CreateLine cx - hw, cy - hh + r, 0, cx - hw, cy + hh - r, 0
  sm.Create3PointArc cx - hw, cy + hh - r, 0, cx - hw + r, cy + hh, 0, cx - hw + r - k, cy + hh - r + k, 0
End Sub

Sub AddRectBoss(model, cxMm, cyMm, wMm, hMm, depthMm, featureName)
  BeginFrontSketch model
  model.SketchManager.CreateCenterRectangle Mm(cxMm), Mm(cyMm), 0, Mm(cxMm + wMm / 2), Mm(cyMm + hMm / 2), 0
  ExtrudeBoss model, depthMm, featureName, True
End Sub

Sub AddCylinderBoss(model, cxMm, cyMm, radiusMm, depthMm, featureName)
  BeginFrontSketch model
  model.SketchManager.CreateCircleByRadius Mm(cxMm), Mm(cyMm), 0, Mm(radiusMm)
  ExtrudeBoss model, depthMm, featureName, True
End Sub

Sub ExtrudeBoss(model, depthMm, featureName, mergeResult)
  Dim feat
  Set feat = model.FeatureManager.FeatureExtrusion2(True, False, False, 0, 0, Mm(depthMm), 0, False, False, False, False, 0, 0, False, False, False, False, mergeResult, True, True, 0, 0, False)
  If feat Is Nothing Then Fail "Extrude failed: " & featureName & " in " & model.GetTitle
  feat.Name = featureName
  model.ClearSelection2 True
  model.ForceRebuild3 False
End Sub

Sub SavePartAndExports(model, path, baseName)
  model.ViewZoomtofit2
  model.ShowNamedView2 "*Isometric", 7
  model.ForceRebuild3 False
  model.SaveAs3 path, 0, swSaveAsOptions_Silent
  If Not fso.FileExists(path) Then Fail "Could not save part: " & path
  model.SaveAs3 exportDir & "\" & baseName & ".STEP", 0, swSaveAsOptions_Silent
  model.SaveAs3 exportDir & "\" & baseName & ".STL", 0, swSaveAsOptions_Silent
  swApp.CloseDoc model.GetTitle
  WScript.Echo "Saved part: " & path
End Sub

Sub CloseProjectDocs()
  On Error Resume Next
  swApp.CloseDoc "iot_lower_enclosure_v1.SLDPRT"
  swApp.CloseDoc "iot_lid_v1.SLDPRT"
  swApp.CloseDoc "iot_gasket_v1.SLDPRT"
  swApp.CloseDoc "iot_pcb_populated_placeholder_v1.SLDPRT"
  swApp.CloseDoc "iot_battery_placeholder_v1.SLDPRT"
  swApp.CloseDoc "iot_sensor_module_exploded_v1.SLDASM"
  swApp.CloseDoc "iot_lower_enclosure_v1"
  swApp.CloseDoc "iot_lid_v1"
  swApp.CloseDoc "iot_gasket_v1"
  swApp.CloseDoc "iot_pcb_populated_placeholder_v1"
  swApp.CloseDoc "iot_battery_placeholder_v1"
  swApp.CloseDoc "iot_sensor_module_exploded_v1"
  On Error GoTo 0
End Sub

Sub EnsureAsciiCadDir(path)
  If Not fso.FolderExists(path) Then fso.CreateFolder path
End Sub

Sub CopyPartsToAsciiCadDir()
  fso.CopyFile lowerPath, lowerAsmPath, True
  fso.CopyFile lidPath, lidAsmPath, True
  fso.CopyFile gasketPath, gasketAsmPath, True
  fso.CopyFile pcbPath, pcbAsmPath, True
  fso.CopyFile batteryPath, batteryAsmPath, True
  WScript.Echo "Copied part files to ASCII SolidWorks build directory: " & asciiCadDir
End Sub

Sub RunAssemblyScript()
  Dim shell, command, result
  WScript.Echo "Launching independent assembly build script..."
  On Error Resume Next
  swApp.ExitApp
  On Error GoTo 0
  WaitForSolidWorksExit 40

  Set shell = CreateObject("WScript.Shell")
  shell.CurrentDirectory = projectRoot
  command = "cscript //nologo " & Chr(34) & projectRoot & "\scripts\build_solidworks_assembly_v1.vbs" & Chr(34)
  result = shell.Run(command, 1, True)
  If result <> 0 Then Fail "Assembly build script failed with exit code " & result
End Sub

Sub WaitForSolidWorksExit(maxSeconds)
  Dim elapsed
  elapsed = 0
  Do While SolidWorksProcessCount() > 0 And elapsed < maxSeconds
    WScript.Sleep 1000
    elapsed = elapsed + 1
  Loop
  If SolidWorksProcessCount() > 0 Then
    WScript.Echo "SolidWorks did not exit cleanly; terminating the build-owned SolidWorks process."
    TerminateSolidWorksProcesses
    WScript.Sleep 3000
  End If
End Sub

Function SolidWorksProcessCount()
  Dim service, processes, process, count
  count = 0
  Set service = GetObject("winmgmts:\\.\root\cimv2")
  Set processes = service.ExecQuery("SELECT * FROM Win32_Process WHERE Name='SLDWORKS.exe'")
  For Each process In processes
    count = count + 1
  Next
  SolidWorksProcessCount = count
End Function

Sub TerminateSolidWorksProcesses()
  Dim service, processes, process
  Set service = GetObject("winmgmts:\\.\root\cimv2")
  Set processes = service.ExecQuery("SELECT * FROM Win32_Process WHERE Name='SLDWORKS.exe'")
  For Each process In processes
    process.Terminate
  Next
End Sub

Sub RestartSolidWorks()
  WScript.Echo "Restarting SolidWorks before assembly build..."
  On Error Resume Next
  swApp.ExitApp
  On Error GoTo 0
  WScript.Sleep 5000
  Set swApp = CreateObject("SldWorks.Application")
  swApp.Visible = True
  WScript.Sleep 2000
  CloseProjectDocs
End Sub

Function Mm(valueMm)
  Mm = CDbl(valueMm) / 1000
End Function

Sub Fail(message)
  WScript.Echo "ERROR: " & message
  WScript.Quit 1
End Sub
