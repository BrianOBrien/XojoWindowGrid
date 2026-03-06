#tag Class
Protected Class TableLayout

#tag Property, Flags = &h0
Public Owner As DesktopWindow
#tag EndProperty

#tag Property, Flags = &h0
Public Rows() As LayoutRow
#tag EndProperty

#tag Property, Flags = &h0
Public Columns As Integer = 1
#tag EndProperty

#tag Property, Flags = &h0
Public Padding As Integer = 8
#tag EndProperty

#tag Property, Flags = &h0
Public Gap As Integer = 8
#tag EndProperty

#tag Property, Flags = &h0
Public CellRects() As Rect
#tag EndProperty


#tag Method, Flags = &h0
Public Sub ApplyLayout()

If Owner Is Nil Then Return
If Rows.Count = 0 Then Return

Var rowCount As Integer = Rows.Count
Var cols As Integer = Columns
If cols <= 0 Then Return

Var occupied(0,0) As Boolean
ReDim occupied(rowCount-1, cols-1)

Var availW As Double = Owner.Width - (Padding*2) - (Gap*(cols-1))
Var availH As Double = Owner.Height - (Padding*2) - (Gap*(rowCount-1))

Var colW As Double = availW / cols

' -------- Row Height Calculation --------

Var rowHeights() As Double
Var totalSpecified As Double = 0.0
Var unspecifiedCount As Integer = 0

For Each lr As LayoutRow In Rows
  If lr.HeightPercent > 0 Then
    totalSpecified = totalSpecified + lr.HeightPercent
  Else
    unspecifiedCount = unspecifiedCount + 1
  End If
Next

Var remainingPercent As Double = 100.0 - totalSpecified
If remainingPercent < 0 Then remainingPercent = 0

Var defaultPercent As Double = 0
If unspecifiedCount > 0 Then
  defaultPercent = remainingPercent / unspecifiedCount
End If

For Each lr As LayoutRow In Rows
  Var p As Double = lr.HeightPercent
  If p <= 0 Then p = defaultPercent
  rowHeights.Add(availH * p / 100.0)
Next

' ----------------------------------------

CellRects.RemoveAll

For r As Integer = 0 To rowCount-1

  Var lr As LayoutRow = Rows(r)
  Var cStart As Integer = 0

  For Each cell As LayoutCell In lr.Cells

    cStart = NextFreeCol_(occupied,r,cStart,cols)
    If cStart >= cols Then Exit For

    Var cs As Integer = cell.ColSpan
    If cs < 1 Then cs = 1
    cs = Min(cs, cols-cStart)

    Var rs As Integer = cell.RowSpan
    If rs < 1 Then rs = 1
    rs = Min(rs, rowCount-r)

    While cStart < cols And Not RectFree_(occupied,r,cStart,rs,cs)
      cStart = NextFreeCol_(occupied,r,cStart+1,cols)
    Wend

    If cStart >= cols Then Exit For

    Var x As Double = Padding + cStart*(colW+Gap)

    Var y As Double = Padding
    For i As Integer = 0 To r-1
      y = y + rowHeights(i) + Gap
    Next

    Var w As Double = (colW*cs) + (Gap*(cs-1))

    Var h As Double = 0
    For i As Integer = r To r + rs - 1
      h = h + rowHeights(i)
    Next
    h = h + (Gap*(rs-1))

    Var rc As New Rect
    rc.Left = x
    rc.Top = y
    rc.Width = w
    rc.Height = h
    CellRects.Add(rc)

    Var ctrl As DesktopUIControl = ControlByName_(cell.Name)

    If ctrl <> Nil Then
      PlaceInCell_(ctrl, x, y, w, h)
    End If

    MarkRect_(occupied,r,cStart,rs,cs)
    cStart = cStart + cs

  Next
Next

End Sub
#tag EndMethod


#tag Method, Flags = &h0
Public Sub DrawDebug(g As Graphics)

g.DrawingColor = Color.RGB(90,0,140)
g.PenSize = 1

For Each rc As Rect In CellRects
  g.DrawRectangle(rc.Left, rc.Top, rc.Width, rc.Height)
Next

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Sub PlaceInCell_(ctrl As DesktopUIControl, x As Double, y As Double, w As Double, h As Double)

Var newW As Double = ctrl.Width
Var newH As Double = ctrl.Height

If ctrl.LockLeft And ctrl.LockRight Then
  newW = w
End If

If ctrl.LockTop And ctrl.LockBottom Then
  newH = h
End If

Var newLeft As Double
If ctrl.LockLeft And Not ctrl.LockRight Then
  newLeft = x
ElseIf ctrl.LockRight And Not ctrl.LockLeft Then
  newLeft = (x + w) - newW
ElseIf ctrl.LockLeft And ctrl.LockRight Then
  newLeft = x
Else
  newLeft = x + (w - newW)/2
End If

Var newTop As Double
If ctrl.LockTop And Not ctrl.LockBottom Then
  newTop = y
ElseIf ctrl.LockBottom And Not ctrl.LockTop Then
  newTop = (y + h) - newH
ElseIf ctrl.LockTop And ctrl.LockBottom Then
  newTop = y
Else
  newTop = y + (h - newH)/2
End If

ctrl.Left = newLeft
ctrl.Top = newTop
ctrl.Width = newW
ctrl.Height = newH

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Function ControlByName_(n As String) As DesktopUIControl

For i As Integer = 0 To Owner.ControlCount-1
  Var v As Variant = Owner.ControlAt(i)
  If v IsA DesktopUIControl Then
    Var c As DesktopUIControl = DesktopUIControl(v)
    If c.Name = n Then Return c
  End If
Next

Return Nil

End Function
#tag EndMethod


#tag Method, Flags = &h21
Private Function NextFreeCol_(ByRef occ(,) As Boolean,r As Integer,startCol As Integer,cols As Integer) As Integer

Var c As Integer = startCol
If c < 0 Then c = 0

While c < cols And occ(r,c)
  c = c + 1
Wend

Return c

End Function
#tag EndMethod


#tag Method, Flags = &h21
Private Function RectFree_(ByRef occ(,) As Boolean,r As Integer,c As Integer,rs As Integer,cs As Integer) As Boolean

For rr As Integer = r To r+rs-1
  For cc As Integer = c To c+cs-1
    If occ(rr,cc) Then Return False
  Next
Next

Return True

End Function
#tag EndMethod


#tag Method, Flags = &h21
Private Sub MarkRect_(ByRef occ(,) As Boolean,r As Integer,c As Integer,rs As Integer,cs As Integer)

For rr As Integer = r To r+rs-1
  For cc As Integer = c To c+cs-1
    occ(rr,cc) = True
  Next
Next

End Sub
#tag EndMethod

End Class
#tag EndClass