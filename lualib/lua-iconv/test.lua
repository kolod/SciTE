require "iconv"

function Convert(text_in, code_in, code_out)
	local cd = iconv.open(code_in, code_out)
	assert(cd, "Failed to create a converter object.")
	local text_out, err = cd:iconv(text_in)

	if err == iconv.ERROR_INCOMPLETE then
		print("ERROR: Incomplete input.")
	elseif err == iconv.ERROR_INVALID then
		print("ERROR: Invalid input.")
	elseif err == iconv.ERROR_NO_MEMORY then
		print("ERROR: Failed to allocate memory.")
	elseif err == iconv.ERROR_UNKNOWN then
		print("ERROR: There was an unknown error.")
	end
	return text_out
end

local text0 = editor:GetSelText()
local text1 = Convert(text0, "cp866", "windows-1251")
-- editor:ReplaceSel(text1)
print(text1)

--[[-------------------------------------------------
strCaptionText - ⥪�� ��������� ����. ���祭�� ��-㬮�砭�� ࠢ�� "InputBox"
  strPrompt - ⥪�� �ਣ��襭�� ��� ����� �����. ���祭�� ��-㬮�砭�� ࠢ�� "Enter"
  strDefaultValue - ��室��� ���祭�� ���� �����. ���祭�� ��-㬮�砭�� ࠢ�� ���⮩ ��ப� ""
  funcCheckInput - �㭪�� ��� �஢�ન ��������� ⥪��. ����砥� ⥪�� � ⮬ ����, � ����� �� �㤥� ����� � ⮫쪮 �� ����㯨�訬 ᨬ����� � �����頥� ���� true - �ਭ��� ��� ᨬ���, ���� false - �⪫����� ����. ���祭�� ��-㬮�砭�� ࠢ�� nil - ���� ��� �����-���� ��࠭�祭��
  intMinWidth - �������쭠� �ਭ� ���� ����� � ��।���� ᨬ����� (�᫨ strPrompt ��� strDefaultValue ���� ��, � �������쭠� �ਭ� ��⮬���᪨ ���������� ��� ����襥 �� ���). ���祭�� ��-㬮�砭�� ࠢ�� 20
--]]-------------------------------------------------
