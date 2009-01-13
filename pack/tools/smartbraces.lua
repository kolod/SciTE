-- SciTE Smart braces
-- Version: 1.2.1
-- Author: Dmitry Maslov, Julgo
---------------------------------------------------
-- ��������, ����:
--
--  ��������� � ������������
--  � ���������� ����������� braces.autoclose = 1 
--  � ���������� ����������� braces.open = ������������� ������
--  � ���������� ����������� braces.close = ������������� ������
--  ������������ ������ � ������� ������ ��-�� ����������� ������� OnKey
--
---------------------------------------------------
-- ����������:
--
--  ������������ ������
--  ������������ ����������� ������ � ������
--  ������ ��������� { � } � cpp: ��������� ������ ������
--
---------------------------------------------------
-- ������ ������:
--
--  ������ ����������� ������ ���� braces.autoclose = 1
--
--  ���� �� ������ ������ �� braces.open, �� ������������� �����������
--  ��� ���� �� braces.close, ����� �������, ������ ����������� ����� ������
--
--  ���� �� ������ ������������� ������ �� braces.close � ��������� ������
--  ��� �� ������������� ������, �� ���� �������������� � ������ �������������
--  ������ �� ����������
--
--  ���� � ��� ������� ����� � �� ������ ������ �� braces.open
--  �� ����� ����������� ��������� braces.open - braces.close
--  ���� �� ��� ��� �������� ���������, �� ��� ���������,
--  ��� ���� ����������� ������ �������� ������, �.�. ���� ����������
--  ����� ������������ ��������� ������, �� ������ ����������� �� ��������
--  ������
--
--  ���� �� ������ ������ { ��� �������������� ����� cpp ��� css, �� �������������
--  ����������� ������� ������ ��� ����, � ����� } - ������ ��� ���� �����������
--  � ��������, �.�. ����� ������� �������� ������, ��� ������� �����������
--
--  ���� �� ��������� ������ } ��� �������������� ����� cpp ��� css, �� ������
--  ������������� ����������� �� ����
--
--  ���� �� ������ ��� �������� ������ ���������, �� ����� ����
--  ��� �������� BACK_SPACE ��������� ����������� ������, �.�.
--  ����������� ��� DEL, � �� ��� BACK_SPACE
--
--  ���� ��������� ������ � ������� braces.open == braces.close
--  �� ����������� ���� ������ ���� ����� ������ ����� � ������
--
---------------------------------------------------

-- ���������� ������� ������ �������� ������
local function GetEOL()
	local eol = "\r\n"
	if editor.EOLMode == SC_EOL_CR then
		eol = "\r"
	elseif editor.EOLMode == SC_EOL_LF then
		eol = "\n"
	end
	return eol
end

-- ������� ����� �������� ��� ������
-- (���������� ������������� ��������� ��������)
local function MakeFind( text )
	local strres = ''
	local symbol
	for i = 1, string.len(text), 1 do
		symbol = string.format( '%c', string.byte( text, i ) )
		if	( symbol == "(" )
			or
			( symbol == "[" )
			or
			( symbol == "." )
			or
			( symbol == "%" )
			or
			( symbol == "*" )
			or
			( symbol == "/" )
			or
			( symbol == "-" )
			or
			( symbol == ")" )
			or
			( symbol == "]" )
			or
			( symbol == "?" )
			or
			( symbol == "+" )
		then
			symbol = string.format( "%%%s", symbol )
		end
		strres = strres..symbol
	end
	return strres
end

local function FindCount( text, textToFind )
	local count = 0;
	for w in string.gmatch( text, MakeFind( textToFind ) )
	do
		count = count + 1
	end
	return count
end

-- ������� ��� ������ ������ (�������� ������)
local function IsLineStartPos( pos )
	return ( editor.LineIndentPosition[editor:LineFromPosition(pos)] == pos )
end

-- �������� ����� ������� ������
local function GetCurrLineNumber()
	return editor:LineFromPosition( editor.CurrentPos )
end

-- �������� ������ � ������
local function GetLineIndentation( num_line )
	if ( num_line < 0 ) then num_line = 0 end
	if ( num_line >= editor.LineCount ) then num_line = editor.LineCount - 1 end
	return ( editor.LineIndentation[num_line] / editor.Indent )
end

-- ��������� � ������ ?
local function IsInLineEnd( num_line, text )
	local endpos = editor.LineEndPosition[num_line]
	if	( endpos >= string.len( text ) )
		and
		string.find( editor:textrange( editor:PositionBefore( endpos - string.len( text ) + 1 ), endpos ), MakeFind( text ) )
	then
		return true
	end
	return false
end

-- ��������� ������ � ������ - ����� ������?
local function IsEOLlast( text )
	-- � ��� ����� ������ ������ ���� ������
	if string.find( text, GetEOL(), string.len( text ) - 1 ) then
		return true
	end
	return false
end

-- ��������� �� �������� ����� == text ?
local function nextIs(pos, text)
	if ( string.find( editor:textrange( pos, editor:PositionAfter( pos + string.len( text ) - 1 ) ), MakeFind( text ) ) ) then
		return true
	end
	return false
end

-- ��������� ������ ������� ����� ������?
local function nextIsEOL(pos)
	if	( pos == editor.Length )
		or
		( nextIs( pos, GetEOL() ) )
	then
		return true
	end
	return false
end

local function BlockBraces( bracebegin, braceend )
	local text, lenght = editor:GetSelText()
	local selbegin = editor.SelectionStart
	local selend = editor.SelectionEnd
	local b, e = string.find(text, MakeFind( bracebegin ) )
	local b2, e2
	local add = ''
	if IsEOLlast( text ) then
		b2, e2 = string.find( text, MakeFind( braceend ), 
			string.len( text ) - string.len( braceend..GetEOL() ) )
		add = GetEOL()
	else
		b2, e2 = string.find( text, MakeFind( braceend ), 
			string.len( text ) - string.len( braceend ) )
	end
	editor:BeginUndoAction()
	if (b and b2) then
		text = string.sub( text, e+1, b2-1 )
		editor:ReplaceSel( text..add )
		editor:SetSel( selbegin, selbegin + string.len( text..add ) )
	else
		editor:insert( selend - string.len( add ), braceend )
		editor:insert( selbegin, bracebegin )
		editor:SetSel( selbegin, selend + string.len( bracebegin..braceend ) )
	end
	editor:EndUndoAction()
	return true
end

local function GetIndexFindCharInProps( value, findchar )
	if findchar then
		local resIndex = string.find( props[value], MakeFind( findchar ), 1 )
		if	( resIndex ~= nil )
			and
			( string.sub( props[value], resIndex,resIndex ) == findchar )
		then
			return resIndex
		end
	end
	return nil
end

local function GetCharInProps( value, index )
	return string.sub( props[value], index, index )
end

-- ���������� ������������� ������ � ������������� ������
-- �� ��������� �������, �.�. ��������,
-- ���� �� ����� ')' �� �� ������ '(' ')'
-- ���� �� ����� '(' �� �� ������ '(' ')'
local function GetBraces( char )
	local braceOpen = ''
	local braceClose = ''
	local symE = ''
	local brIdx = GetIndexFindCharInProps( 'braces.open', char )
	if ( brIdx ~= nil ) then
		symE = GetCharInProps( 'braces.close', brIdx )
		if ( symE ~= nil ) then 
			braceOpen = char
			braceClose = symE
		end
	else
		brIdx = GetIndexFindCharInProps( 'braces.close', char )
		if ( brIdx ~= nil ) then
			symE = GetCharInProps( 'braces.open', brIdx )
			if ( symE ~= nil ) then 
				braceOpen = symE
				braceClose = char
			end
		end
	end
	return braceOpen, braceClose
end

local g_isPastedBraceClose = false

-- "����� ������/�������" 
-- ���������� true ����� ������������ ������ ������ �� �����
local function SmartBraces( char )
	if ( props['braces.autoclose'] == '1' ) then
		local isSelection = editor.SelectionStart ~= editor.SelectionEnd
		-- ������� ������ ������
		local braceOpen, braceClose = GetBraces(char)
		if ( braceOpen ~= '' and braceClose ~= '' ) then
			-- ��������� ������� �� � ��� ����� ���� �����
			if ( isSelection == true ) then
				-- ������ ��������� �� ������������ ������ ��������
				return BlockBraces( braceOpen, braceClose )
			else
				-- ���� ��������� ������ ������������� ������
				-- � �� �� ������, �� ���� ������������
				local nextsymbol = string.format( "%c", editor.CharAt[editor.CurrentPos] )
				if	( GetIndexFindCharInProps( 'braces.close', nextsymbol ) ~= nil )
					and
					( nextsymbol == char )
				then 
					editor:CharRight()
					return true
				end
				-- ���� �� ������ ������������� ������ � 
				-- ��������� ������ ����� ������ ��� ��� ������ ������������� ������
				-- �� ����� ��������� ������������� ������
				if	( char == braceOpen )
					and
					( nextIsEOL( editor.CurrentPos ) or nextIs( editor.CurrentPos, braceClose ) )
				then
					-- �� ���������� ������������ ������ { � cpp
					if	( char == '{' ) and
						( editor.LexerLanguage == 'cpp' or editor.LexerLanguage == 'css' )
					then
						editor:BeginUndoAction()
						local ln = GetCurrLineNumber()
						if	( ln > 0 and GetLineIndentation( ln ) > GetLineIndentation( ln - 1 ) )
							and
							( IsLineStartPos( editor.CurrentPos ) )
							and 
							( not IsInLineEnd( ln-1, '{' ) )
						then
							editor:BackTab()
						end
						editor:AddText( '{' )
						editor:NewLine()
						if ( GetLineIndentation( ln ) == GetLineIndentation( ln + 1 ) ) then
							editor:Tab()
						end
						local pos = editor.CurrentPos
						editor:NewLine()
						if ( GetLineIndentation( ln + 2 ) == GetLineIndentation( ln + 1 ) ) then
							editor:BackTab()
						end
						editor:AddText( '}' )
						editor:GotoPos( pos )
						editor:EndUndoAction()
						return true
					end
					-- ���� ��������� ������ � ����������� ������ � �����, �� ������� ���� �� ��� �������� � ������
					if	( braceOpen == braceClose )
						and
						( math.fmod( FindCount( editor:GetCurLine(), braceOpen ), 2 ) == 1 )
					then
						return false
					end
					-- ��������� ������������� ������
					editor:BeginUndoAction()
					editor:InsertText( editor.CurrentPos, braceClose )
					editor:EndUndoAction()
					g_isPastedBraceClose = true
				end
				-- ���� �� ������ ������������� ������
				if ( char == braceClose ) then
					-- "�� ����������" ������������ ������ } � cpp � css
					if ( char == '}' ) and
						( editor.LexerLanguage == 'cpp' or editor.LexerLanguage == 'css' )
					then
						editor:BeginUndoAction()
						if (IsLineStartPos( editor.CurrentPos ) )
						then
							editor:BackTab()
						end
						editor:AddText( '}' )
						editor:EndUndoAction()
						return true
					end
				end
			end
		end
	end
	return false
end

-- ������������� ������� ��������� OnKey
local old_OnKey = OnKey
function OnKey( key, shift, ctrl, alt, char )
	-- ���� ���-�� ��� ��������� ������ �� �� �� ������������
	if ( old_OnKey and old_OnKey( key, shift, ctrl, alt, char ) ) then
		return true
	end

	if ( editor.Focus ) then
		if ( key == 8 and g_isPastedBraceClose == true ) then -- VK_BACK (08)
			g_isPastedBraceClose = false
			editor:BeginUndoAction()
			editor:CharRight()
			editor:DeleteBack()
			editor:EndUndoAction()
			return true
		end
		
		g_isPastedBraceClose = false
		
		if ( char ~= '' ) then
			return SmartBraces( char )
		end
	end

	return false
end
