Attribute VB_Name = "Module1"
Sub FormatData()
Attribute FormatData.VB_Description = "Iterate through sheets, selecting all data ranges starting at A1, format as tables, and resize associated columns to fit contents."
Attribute FormatData.VB_ProcData.VB_Invoke_Func = "F\n14"
'
' FormatData Macro
' Iterate through sheets, selecting all data ranges starting at A1, format as tables, and resize associated columns to fit contents.
'
' Keyboard Shortcut: Ctrl+Shift+F
'
    Range("A1", Range("A1").End(xlDown).End(xlToRight)).Select
    Application.CutCopyMode = False
    ActiveSheet.ListObjects.Add(xlSrcRange, Selection, xlYes).Name = "Table1"
    Range("Table1[#All]").Select
    ActiveSheet.ListObjects("Table1").TableStyle = "TableStyleLight8"
    Range("A1", Range("A1").End(xlToRight)).Select
    Selection.ClearFormats
    Selection.EntireColumn.AutoFit
    Range("A1").Select
    ActiveSheet.ListObjects("Table1").Name = Trim(ActiveSheet.Name) & " Table"
    ActiveSheet.Next.Select
End Sub
