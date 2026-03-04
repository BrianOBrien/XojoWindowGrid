#tag Module
Protected Module WindowLayout
	#tag Method, Flags = &h0
		Sub Pack(Extends w As DesktopWindow, layout As TableLayout)
		  
		  If layout Is Nil Then Return
		  
		  layout.Owner = w
		  layout.ApplyLayout
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Row(ParamArray names() As String) As LayoutRow
		  
		  Var r As New LayoutRow
		  
		  For Each n As String In names
		    r.AddCell(n)
		  Next
		  
		  Return r
		  
		End Function
	#tag EndMethod


	#tag Note, Name = README.md
		First create a window property.
		Private layout As TableLayout
		
		
		In the  window opening event
		
		Var layout As New TableLayout
		layout.Columns = 3
		
		layout.Rows.Add(Row("Button1","Button2","Button3"))
		layout.Rows.Add(Row("Button4","Button5","Button6"))
		
		Var r As LayoutRow
		r = Row("Button1","Button2")   ' start with plain
		r.Cells(0).ColSpan = 2         ' or just build via AddCell(name, colspan, rowspan)
		layout.Rows.Add(r)
		
		Self.Pack(layout)
		
		
		in the window resized event
		if layout <> Nil then Self.Pack(layout) 
		
		For Debug, in Paint....
		If layout <> Nil Then
		  layout.DrawDebug(g)
		End If
		
	#tag EndNote


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
