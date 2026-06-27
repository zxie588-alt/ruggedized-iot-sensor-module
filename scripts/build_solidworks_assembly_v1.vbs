Option Explicit

Const swDocPART = 1
Const swSaveAsOptions_Silent = 1

Dim fso, projectRoot, asmTemplate, cadDir, asciiCadDir, exportDir, imageDir
Dim lowerPath, lidPath, gasketPath, pcbPath, batteryPath, asmPath
Dim swApp

Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetAbsolutePathName(".")
asmTemplate = "C:\ProgramData\SOLIDWORKS\SOLIDWORKS 2018\templates\gb_assembly.asmdot"
cadDir = projectRoot & "\cad\solidworks"
asciiCadDir = "C:\sw_iot_build"
exportDir = projectRoot & "\exports"
imageDir = projectRoot & "\images"

If Not fso.FolderExists(asciiCadDir) Then fso.CreateFolder asciiCadDir

lowerPath = asciiCadDir & "\iot_lower_enclosure_v1.SLDPRT"
lidPath = asciiCadDir & "\iot_lid_v1.SLDPRT"
gasketPath = asciiCadDir & "\iot_gasket_v1.SLDPRT"
pcbPath = asciiCadDir & "\iot_pcb_populated_placeholder_v1.SLDPRT"
batteryPath = asciiCadDir & "\iot_battery_placeholder_v1.SLDPRT"
asmPath = asciiCadDir & "\iot_sensor_module_exploded_v1.SLDASM"

CopyPart cadDir & "\iot_lower_enclosure_v1.SLDPRT", lowerPath
CopyPart cadDir & "\iot_lid_v1.SLDPRT", lidPath
CopyPart cadDir & "\iot_gasket_v1.SLDPRT", gasketPath
CopyPart cadDir & "\iot_pcb_populated_placeholder_v1.SLDPRT", pcbPath
CopyPart cadDir & "\iot_battery_placeholder_v1.SLDPRT", batteryPath

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

OpenPart lowerPath
OpenPart lidPath
OpenPart gasketPath
OpenPart pcbPath
OpenPart batteryPath

Dim model, assy
Set model = swApp.NewDocument(asmTemplate, 0, 0, 0)
If model Is Nothing Then Fail "Could not create assembly document."
Set assy = swApp.ActiveDoc

AddAssemblyComponent assy, lowerPath, 0, 0, 0, "lower enclosure"
AddAssemblyComponent assy, pcbPath, 0, 0, Mm(7), "populated PCB"
AddAssemblyComponent assy, batteryPath, Mm(0), Mm(-16), Mm(8), "battery pack"
AddAssemblyComponent assy, gasketPath, 0, 0, Mm(30), "gasket"
AddAssemblyComponent assy, lidPath, 0, 0, Mm(47), "raised lid"

model.ShowNamedView2 "*Isometric", 7
model.ViewZoomtofit2
model.ForceRebuild3 False

model.SaveAs3 asmPath, 0, swSaveAsOptions_Silent
If Not fso.FileExists(asmPath) Then Fail "Could not save assembly: " & asmPath

model.SaveAs3 exportDir & "\iot_sensor_module_exploded_v1.STEP", 0, swSaveAsOptions_Silent
model.SaveAs3 imageDir & "\iot_sensor_module_exploded_v1.png", 0, swSaveAsOptions_Silent

fso.CopyFile asmPath, cadDir & "\iot_sensor_module_exploded_v1.SLDASM", True
WScript.Echo "Saved assembly: " & cadDir & "\iot_sensor_module_exploded_v1.SLDASM"
WScript.Echo "DONE: SolidWorks V1 assembly generated."

Sub CopyPart(sourcePath, targetPath)
  If Not fso.FileExists(sourcePath) Then Fail "Missing source part: " & sourcePath
  fso.CopyFile sourcePath, targetPath, True
End Sub

Sub OpenPart(componentPath)
  Dim attempt, ok
  ok = False
  For attempt = 1 To 5
    On Error Resume Next
    Err.Clear
    swApp.OpenDoc componentPath, swDocPART
    If Err.Number = 0 Then ok = True
    On Error GoTo 0
    If ok Then Exit For
    WScript.Sleep 2500
  Next
  If Not ok Then Fail "Could not open component: " & componentPath
End Sub

Sub AddAssemblyComponent(assy, componentPath, x, y, z, label)
  Dim comp
  Set comp = assy.AddComponent5(componentPath, 0, "", False, "", x, y, z)
  If comp Is Nothing Then
    Fail "Component not inserted: " & label & " -> " & componentPath
  End If
  WScript.Echo "Inserted component: " & label
End Sub

Function Mm(valueMm)
  Mm = CDbl(valueMm) / 1000
End Function

Sub Fail(message)
  WScript.Echo "ERROR: " & message
  WScript.Quit 1
End Sub
