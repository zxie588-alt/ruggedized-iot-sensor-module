Option Explicit

Dim swApp
On Error Resume Next
Set swApp = CreateObject("SldWorks.Application")
If Err.Number <> 0 Then
  WScript.Echo "ERROR: cannot create SldWorks.Application: " & Err.Description
  WScript.Quit 1
End If
On Error GoTo 0

WScript.Echo "SolidWorks COM object created."

On Error Resume Next
WScript.Echo "Revision: " & swApp.RevisionNumber
If Err.Number <> 0 Then
  WScript.Echo "Revision unavailable: " & Err.Description
  Err.Clear
End If
On Error GoTo 0
