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

#tag Property, Flags = &h0
Public ColumnPercents() As Double
#tag EndProperty

#tag Property, Flags = &h0
Public ResizeHitZone As Integer = 6
#tag EndProperty

#tag Property, Flags = &h21
Private ResizeMode_ As Integer = 0
#tag EndProperty

#tag Property, Flags = &h21
Private ResizeIndex_ As Integer = -1
#tag EndProperty

#tag Property, Flags = &h21
Private DragStartX_ As Double
#tag EndProperty

#tag Property, Flags = &h21
Private DragStartY_ As Double
#tag EndProperty

#tag Property, Flags = &h21
Private StartColumnPercents_() As Double
#tag EndProperty

#tag Property, Flags = &h21
Private StartRowPercents_() As Double
#tag EndProperty

#tag Property, Flags = &h21
Private ColWidths_() As Double
#tag EndProperty

#tag Property, Flags = &h21
Private RowHeights_() As Double
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

If availW <= 0 Then Return
If availH <= 0 Then Return

ComputeColumnWidths_(availW)
ComputeRowHeights_(availH)

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

    Var x As Double = Padding
    For i As Integer = 0 To cStart-1
      x = x + ColWidths_(i) + Gap
    Next

    Var y As Double = Padding
    For i As Integer = 0 To r-1
      y = y + RowHeights_(i) + Gap
    Next

    Var w As Double = 0
    For i As Integer = cStart To cStart + cs - 1
      w = w + ColWidths_(i)
    Next
    w = w + (Gap*(cs-1))

    Var h As Double = 0
    For i As Integer = r To r + rs - 1
      h = h + RowHeights_(i)
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
Public Function BeginResize(mouseX As Integer, mouseY As Integer) As Boolean

If Owner Is Nil Then Return False
If Rows.Count = 0 Then Return False

ApplyLayout
EnsureColumnPercents_
EnsureRowPercents_

Var idx As Integer = HitTestColumnDivider_(mouseX, mouseY)
If idx >= 0 Then
  ResizeMode_ = 2
  ResizeIndex_ = idx
  DragStartX_ = mouseX
  DragStartY_ = mouseY
  StartColumnPercents_.RemoveAll
  For Each p As Double In ColumnPercents
    StartColumnPercents_.Add(p)
  Next
  Return True
End If

idx = HitTestRowDivider_(mouseX, mouseY)
If idx >= 0 Then
  ResizeMode_ = 1
  ResizeIndex_ = idx
  DragStartX_ = mouseX
  DragStartY_ = mouseY
  StartRowPercents_.RemoveAll
  For Each lr As LayoutRow In Rows
    StartRowPercents_.Add(lr.HeightPercent)
  Next
  Return True
End If

Return False

End Function
#tag EndMethod


#tag Method, Flags = &h0
Public Sub DragResize(mouseX As Integer, mouseY As Integer)

If Owner Is Nil Then Return
If ResizeMode_ = 0 Then Return

Var rowCount As Integer = Rows.Count
Var cols As Integer = Columns

Var availW As Double = Owner.Width - (Padding*2) - (Gap*(cols-1))
Var availH As Double = Owner.Height - (Padding*2) - (Gap*(rowCount-1))

If ResizeMode_ = 2 Then

  If ResizeIndex_ < 0 Or ResizeIndex_ >= ColumnPercents.Count-1 Then Return
  If availW <= 0 Then Return

  Var delta As Double = mouseX - DragStartX_
  Var deltaPct As Double = 100.0 * delta / availW
  Var minPct As Double = 100.0 * 24.0 / availW

  Var a As Double = StartColumnPercents_(ResizeIndex_) + deltaPct
  Var b As Double = StartColumnPercents_(ResizeIndex_+1) - deltaPct

  If a < minPct Then
    a = minPct
    b = StartColumnPercents_(ResizeIndex_) + StartColumnPercents_(ResizeIndex_+1) - a
  End If

  If b < minPct Then
    b = minPct
    a = StartColumnPercents_(ResizeIndex_) + StartColumnPercents_(ResizeIndex_+1) - b
  End If

  ColumnPercents(ResizeIndex_) = a
  ColumnPercents(ResizeIndex_+1) = b

ElseIf ResizeMode_ = 1 Then

  If ResizeIndex_ < 0 Or ResizeIndex_ >= Rows.Count-1 Then Return
  If availH <= 0 Then Return

  Var delta As Double = mouseY - DragStartY_
  Var deltaPct As Double = 100.0 * delta / availH
  Var minPct As Double = 100.0 * 24.0 / availH

  Var a As Double = StartRowPercents_(ResizeIndex_) + deltaPct
  Var b As Double = StartRowPercents_(ResizeIndex_+1) - deltaPct

  If a < minPct Then
    a = minPct
    b = StartRowPercents_(ResizeIndex_) + StartRowPercents_(ResizeIndex_+1) - a
  End If

  If b < minPct Then
    b = minPct
    a = StartRowPercents_(ResizeIndex_) + StartRowPercents_(ResizeIndex_+1) - b
  End If

  Rows(ResizeIndex_).HeightPercent = a
  Rows(ResizeIndex_+1).HeightPercent = b

End If

End Sub
#tag EndMethod


#tag Method, Flags = &h0
Public Sub EndResize()
ResizeMode_ = 0
ResizeIndex_ = -1
StartColumnPercents_.RemoveAll
StartRowPercents_.RemoveAll
End Sub
#tag EndMethod


#tag Method, Flags = &h0
Public Function IsResizing() As Boolean
Return ResizeMode_ <> 0
End Function
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
Private Sub ComputeColumnWidths_(availW As Double)

ColWidths_.RemoveAll

If ColumnPercents.Count = Columns Then

  Var totalColPercent As Double = 0
  For Each p As Double In ColumnPercents
    totalColPercent = totalColPercent + p
  Next

  If totalColPercent > 0 Then
    For Each p As Double In ColumnPercents
      ColWidths_.Add(availW * p / totalColPercent)
    Next
  Else
    For i As Integer = 0 To Columns-1
      ColWidths_.Add(availW / Columns)
    Next
  End If

Else

  For i As Integer = 0 To Columns-1
    ColWidths_.Add(availW / Columns)
  Next

End If

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Sub ComputeRowHeights_(availH As Double)

RowHeights_.RemoveAll

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
  RowHeights_.Add(availH * p / 100.0)
Next

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Sub EnsureColumnPercents_()

If Columns <= 0 Then Return

If ColumnPercents.Count <> Columns Then
  ColumnPercents.RemoveAll
  For i As Integer = 0 To Columns-1
    ColumnPercents.Add(100.0 / Columns)
  Next
  Return
End If

Var total As Double = 0
For Each p As Double In ColumnPercents
  total = total + p
Next

If total <= 0 Then
  ColumnPercents.RemoveAll
  For i As Integer = 0 To Columns-1
    ColumnPercents.Add(100.0 / Columns)
  Next
End If

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Sub EnsureRowPercents_()

If Rows.Count = 0 Then Return

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
  If lr.HeightPercent <= 0 Then
    lr.HeightPercent = defaultPercent
  End If
Next

End Sub
#tag EndMethod


#tag Method, Flags = &h21
Private Function HitTestColumnDivider_(mouseX As Integer, mouseY As Integer) As Integer

If Columns <= 1 Then Return -1
If ColWidths_.Count <> Columns Then Return -1

Var x As Double = Padding

For i As Integer = 0 To Columns-2
  x = x + ColWidths_(i)

  Var leftEdge As Double = x - ResizeHitZone
  Var rightEdge As Double = x + Gap + ResizeHitZone

  If mouseX >= leftEdge And mouseX <= rightEdge Then
    Return i
  End If

  x = x + Gap
Next

Return -1

End Function
#tag EndMethod


#tag Method, Flags = &h21
Private Function HitTestRowDivider_(mouseX As Integer, mouseY As Integer) As Integer

If Rows.Count <= 1 Then Return -1
If RowHeights_.Count <> Rows.Count Then Return -1

Var y As Double = Padding

For i As Integer = 0 To Rows.Count-2
  y = y + RowHeights_(i)

  Var topEdge As Double = y - ResizeHitZone
  Var bottomEdge As Double = y + Gap + ResizeHitZone

  If mouseY >= topEdge And mouseY <= bottomEdge Then
    Return i
  End If

  y = y + Gap
Next

Return -1

End Function
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
