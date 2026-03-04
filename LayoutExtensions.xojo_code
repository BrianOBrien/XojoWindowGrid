#tag Module
Protected Module LayoutExtensions

#tag Method, Flags = &h0
Public Sub Pack(Extends w As DesktopWindow, layout As TableLayout)

If layout Is Nil Then Return

layout.Owner = w
layout.ApplyLayout

End Sub
#tag EndMethod

#tag Method, Flags = &h0
Public Function Row(ParamArray names() As String) As LayoutRow

Var r As New LayoutRow

For Each n As String In names
r.AddCell(n)
Next

Return r

End Function
#tag EndMethod

End Module
#tag EndModule