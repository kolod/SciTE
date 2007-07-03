-- Style Changer
-- ����� �������: mozers�
-- ����� ����� cpp_style_classic: mimir
-- ������� ����� ����� ���������� ������ �� �

-- ��� ����������� �������� � ���� ���� .properties ��������� ������:
--   command.name.9.$(file.patterns.cpp)=Change Style
--   command.9.$(file.patterns.cpp)=dofile $(SciteDefaultHome)\tools\style_changer.lua
--   command.mode.9.$(file.patterns.cpp)=subsystem:lua,savebefore:no
-----------------------------------------------
local file = props["SciteDefaultHome"].."\\languages\\cpp.properties"
local classic = 'import languages\\cpp_style_classic'
io.input(file)
local text = io.read('*a')
local find = string.find(text, '#'..classic)
if find == nil then
	text = string.gsub(text, classic, '#'..classic)
else
	text = string.gsub(text, '#'..classic, classic)
end
io.output(file)
io.write (text)
io.close()
scite.Perform("reloadproperties:")
