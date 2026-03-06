#tag Class
Protected Class LayoutRow
	#tag Method, Flags = &h0
		Sub AddCell(name As String, colSpan As Integer = 1, rowSpan As Integer = 1)
		  Cells.Add(New LayoutCell(name, colSpan, rowSpan))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Cells() As LayoutCell
	#tag EndProperty

	#tag Property, Flags = &h0
		HeightPercent As Integer = 0
	#tag EndProperty


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
End Class
#tag EndClass
