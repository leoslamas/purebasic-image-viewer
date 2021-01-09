InitSprite()
InitKeyboard()
ExamineDesktops()

UseJPEG2000ImageDecoder()
UseJPEGImageDecoder()
UsePNGImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()

height = DesktopHeight(0)/2
width = DesktopWidth(0)/2
OpenWindow(0,0,0,width,height,"IMG VWR",#PB_Window_BorderLess|#PB_Window_SizeGadget)
If Not OpenWindowedScreen(WindowID(0),0,0,width,height,1,0,0,#PB_Screen_NoSynchronization)
	MessageRequester("Erro!", "Nao foi possivel iniciar o DirectX!",#PB_MessageRequester_Ok|#MB_ICONERROR)
EndIf
SmartWindowRefresh(0,1)

Declare.s InputPass(titulo.s,texto.s)

;----------------------------------------------------------------------
If Not OpenPreferences("pref.ini")
	CreatePreferences("pref.ini")
	;senha.s = InputRequester("Voce nao possui uma senha cadastrada!", "Digite nova senha , ou digite 'sair' para encerrar.", "")
	senha.s = InputPass("Voce nao possui uma senha cadastrada!", "Digite nova senha , ou digite 'sair' para encerrar.")
	If senha = ""		
		ClosePreferences()
		DeleteFile("pref.ini")
		End
	EndIf
	
	If senha = "sair"
		ClosePreferences()
		DeleteFile("pref.ini")
		End
	EndIf
	
	PreferenceGroup("Pass")
	senha_enc.s = Space(1024)
	Base64Encoder(@senha, StringByteLength(senha), @senha_enc,1024)
	WritePreferenceString("var",senha_enc)
	PreferenceGroup("Path")
	
	dir.s = PathRequester("Escolha a pasta","C:\")
	If dir = "C:\"
		MessageRequester("Erro!", "Voce nao escolheu uma pasta ou a pasta nao e valida!")
		ClosePreferences()
		DeleteFile("pref.ini")
		End
	EndIf
	
	dir_enc.s = Space(1024)
	Base64Encoder(@dir,StringByteLength(dir),@dir_enc,1024)
	WritePreferenceString("var",dir_enc)
	ClosePreferences()
	If OpenPreferences("pref.ini")
		ClosePreferences()
	Else 
		MessageRequester("Erro!","Talvez voce nao tenha permissao para salvar suas preferencias..."+Chr(#PB_Key_Return)+"Reinicie o programa com permissoes de administrador!")
		End
	EndIf	
Else
	;-=============================================================
	For xxx = 1 To 3
		;senha.s = InputRequester("Acesso (digite 'sair' para fechar)","Digite sua senha! "+Str(xxx)+"a tentativa...","")
		senha.s = InputPass("Acesso (digite 'sair' para fechar)","Digite sua senha! "+Str(xxx)+"a tentativa...")
		If LCase(senha) = "sair"
			End
		ElseIf senha = ""
			Continue
		EndIf
		
		senha_enc.s = Space(1024)
		Base64Encoder(@senha,StringByteLength(senha),@senha_enc,1024)
		PreferenceGroup("Pass")
		If senha_enc = ReadPreferenceString("var","")
			MessageRequester("Ok!","Senha Correta!")
			aaa = 1
			Break
		Else
			MessageRequester("Erro!","Senha incorreta!")
			aaa = 0
		EndIf
	Next
	If aaa = 0 
		End
	EndIf

	dir_dec.s = Space(1024)
	dir.s = Space(1024)
	PreferenceGroup("Path")
	PokeS(@dir_dec,ReadPreferenceString("var",""))
	Base64Decoder(@dir_dec,StringByteLength(dir_dec),@dir,1024)
EndIf
ClosePreferences()

senha = #NULL$
senha_enc = #NULL$
dir_dec = #NULL$
dir_enc = #NULL$

AddKeyboardShortcut(0,#PB_Shortcut_Left,1)
AddKeyboardShortcut(0,#PB_Shortcut_Right,2)

AddKeyboardShortcut(0,#PB_Shortcut_Return,3)
AddKeyboardShortcut(0,#PB_Shortcut_Back,4)

AddKeyboardShortcut(0,#PB_Shortcut_Up,5)
AddKeyboardShortcut(0,#PB_Shortcut_Down,6)

AddKeyboardShortcut(0,#PB_Shortcut_Pad8,7)
AddKeyboardShortcut(0,#PB_Shortcut_Pad5,8)
AddKeyboardShortcut(0,#PB_Shortcut_Pad4,9)
AddKeyboardShortcut(0,#PB_Shortcut_Pad6,10)
AddKeyboardShortcut(0,#PB_Shortcut_Space,11)
AddKeyboardShortcut(0,#PB_Shortcut_Home,12)
AddKeyboardShortcut(0,#PB_Shortcut_End,13)
AddKeyboardShortcut(0,#PB_Shortcut_Delete,14)
AddKeyboardShortcut(0,#PB_Shortcut_PageDown,15)

;//////////////////////////////////////////////////////////////////

Structure str
	id.l
	file.s
EndStructure

Declare back()
Declare random_pic()
Declare prev_pic()
Declare next_pic()
Declare ListFilesRecursive(Dir.s, List Files.str())

Global NewList F.str()
Global NewList B()
Global id,resize.f = 1,posY = 0,posX = 0

ListFilesRecursive(dir,F())
dir = #NULL$

Global index = 1
ForEach F()
	If F()\id = index
		LoadImage(0,F()\file)
	EndIf
Next


;///////////////////////////////
Repeat
	Delay(1)
	ExamineKeyboard()

	Select WaitWindowEvent()
		Case #PB_Event_CloseWindow
			End

		Case #PB_Event_Menu
			Select EventMenu()
				Case 1
					prev_pic()
					
				Case 2
					next_pic()
					
				Case 3
					random_pic()
					
				Case 4
					back()
					
				Case 5
					resize + 0.1
					posY-40
				Case 6
					If resize > 0
						resize - 0.1
						posY+40
					EndIf
					
				Case 7, 12
					posY+50
				Case 8, 13 
					posY-50
				Case 9, 14
					posX+50
				Case 10, 15
				  posX-50
				Case 11
				  End
					
			EndSelect
	EndSelect
	
;////////////////////// DRAW	
	ClearScreen(#Black)
	
	wi=ImageWidth(0)
	he=ImageHeight(0)
	propY = height
	propX = (propY * wi) / he
	propX * resize
	propY * resize
	StartDrawing(ScreenOutput())
	DrawImage(ImageID(0),(width/2)-(propX/2)+posX,posY,propX,propY)
	StopDrawing()
	
	FlipBuffers()
;///////////////////STOP DRAW	
Until KeyboardPushed(#PB_Key_Escape)
End

;-----------------------------------------------------------------------------------------

Procedure.s InputPass(titulo.s, texto.s)
	dica.s = ""
	esc = 0
	OpenWindow(1,0,0,300,100,titulo,#PB_Window_WindowCentered|#PB_Window_Tool, WindowID(0))
	ButtonGadget(21,120,80,60,20,"OK")
	StringGadget(22,10,45,280,20,"",#PB_String_Password)
	TextGadget(23,10,10,280,20,texto)
	AddKeyboardShortcut(1,#PB_Shortcut_Escape,10)
	AddKeyboardShortcut(1,#PB_Shortcut_Return,11)
	SetActiveGadget(22)
	Repeat
		Delay(1)
		
		Select WaitWindowEvent()
			Case #PB_Event_Gadget
				Select EventGadget()
					Case 21
						dica = GetGadgetText(22)
						RemoveKeyboardShortcut(1,#PB_Shortcut_Escape)
						CloseWindow(1)
						esc = 1
				EndSelect
				
			Case #PB_Event_Menu
				Select EventMenu()
					Case 11
						dica = GetGadgetText(22)
						RemoveKeyboardShortcut(1,#PB_Shortcut_Escape)
						CloseWindow(1)
						esc = 1
				
					Case 10
						RemoveKeyboardShortcut(1,#PB_Shortcut_Escape)
						CloseWindow(1)
						esc = 1
				EndSelect
		EndSelect
		
	Until esc = 1
	
	ProcedureReturn dica
EndProcedure
;//////////////////////////////////////////////////
Procedure back()
	resize = 1
	posX = 0
	posY = 0
	If ListSize(B()) > 0
		index = B()
	EndIf
	If ListSize(B()) > 1
		DeleteElement(B(),1)
	EndIf
	ForEach F()
		If F()\id = index
			LoadImage(0,F()\file)
		EndIf
	Next
	Debug index
EndProcedure
;///////////////////////////////////
Procedure random_pic()
	resize = 1
	posX = 0
	posY = 0
	AddElement(B())
	B() = index
	index = Random(id-1)+1
	ForEach F()
		If F()\id = index
			LoadImage(0,F()\file)
		EndIf
	Next
	Debug index
EndProcedure
;//////////////////////////////////
;//////////////////////////////////
Procedure prev_pic()
	resize = 1
	posX = 0
	posY = 0
	ClearList(B())
	If index > 1
		index-1
		ForEach F()
			If F()\id = index
				LoadImage(0,F()\file)
			EndIf
		Next
	Else
		index = ListSize(F())
		ForEach F()
			If F()\id = index
				LoadImage(0,F()\file)
			EndIf
		Next
	EndIf
	Debug index
EndProcedure
;//////////////////////////////////
;//////////////////////////////////
Procedure next_pic()
	resize = 1
	posX = 0
	posY = 0
	ClearList(B())
	If index < ListSize(F())
		index + 1
		ForEach F()
			If F()\id = index
				LoadImage(0,F()\file)
			EndIf
		Next
	Else
		index = 1
		ForEach F()
			If F()\id = index
				LoadImage(0,F()\file)
			EndIf
		Next
	EndIf
	Debug index
EndProcedure
;//////////////////////////////////
;//////////////////////////////////
Procedure ListFilesRecursive(Dir.s, List Files.str())
	NewList Directories.s()
	If Right(Dir, 1) <> "\"
		Dir + "\"
	EndIf
	If ExamineDirectory(0, Dir, "")
		While NextDirectoryEntry(0)
			Select DirectoryEntryType(0)
				Case #PB_DirectoryEntry_File
					Select LCase(GetExtensionPart(DirectoryEntryName(0)))
						Case "jpg","jpeg","bmp","tiff","tga"
							AddElement(Files())
							id + 1
							Files()\id = id
							Files()\file = Dir + DirectoryEntryName(0)
					EndSelect
				Case #PB_DirectoryEntry_Directory
					Select DirectoryEntryName(0)
						Case ".", ".."
							Continue
						Default
							AddElement(Directories())
							Directories() = Dir + DirectoryEntryName(0)
					EndSelect
			EndSelect
		Wend
		FinishDirectory(0)
	EndIf
	
	ForEach Directories()
		ListFilesRecursive(Directories(), Files())
	Next
EndProcedure


; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 186
; FirstLine = 153
; Folding = --
; EnableOnError
; Executable = ..\..\..\Documentos\UTIL\IMG.exe
; DisableDebugger
; EnablePurifier
; EnableCompileCount = 239
; EnableBuildCount = 26
; EnableExeConstant