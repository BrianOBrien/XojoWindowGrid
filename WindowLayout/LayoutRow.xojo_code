#tag Class
Protected Class LayoutRow
#tag Property, Flags = &h0
Public Cells() As LayoutCell
#tag EndProperty

#tag Property, Flags = &h0
Public HeightPercent As Double = 0.0
#tag EndProperty

#tag Method, Flags = &h0
Sub AddCell(name As String, colSpan As Integer = 1, rowSpan As Integer = 1)
Cells.Add(New LayoutCell(name, colSpan, rowSpan))
End Sub
#tag EndMethod
End Class
#tag EndClass
