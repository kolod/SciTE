//  ColorSet v.3.2
//  mozers� (��� �������� ������� dB6)
//  -----------------------------------------------------------------------
//  �������� ��������� ������ ������ �����
//  ��������� ������ �������� ���������� � ��������� �������� �����
//  ��� ����������� �������� � ���� ���� .properties ��������� ������:
//    command.name.6.*=����� �����
//    command.6.*=wscript "$(SciteDefaultHome)\tools\ColorSet.js"
//    command.input.6.*=$(CurrentSelection)
//    command.mode.6.*=subsystem:windows,replaceselection:auto,savebefore:no,quiet:yes
//  ����������:
//    ��� ������ ���������� ������� � ������� COMDLG32.OCX (�� ����������� ����� ��� ������������)
//  -----------------------------------------------------------------------

var defColor = "FFFFFF";

// ������ ��������� ���.������
var cmd = WScript.StdIn.ReadAll();
var strInput;
if (cmd == "") {
	strInput = defColor;
} else {
	strInput = cmd;
}

// ����, ���� �� ��������� ����� � ��������� ������
var regEx = /[0-9|A-F]{6}/i;
var FindColors = regEx.exec(strInput);

// ���� � ��� ����������� �������� �� COMDLG32.OCX, �� ���������������� ��� ��� �������.
//~ var WshShell = new ActiveXObject("WScript.Shell");
//~ WshShell.RegWrite('HKCR\\Licenses\\4D553650-6ABE-11cf-8ADB-00AA00C00905\\', 'gfjmrfkfifkmkfffrlmmgmhmnlulkmfmqkqj');

// �������� ��������� ������ ������ �����
try {
	var objDialog = new ActiveXObject("MSComDlg.CommonDialog");
} catch(e) {
	WScript.Echo("Please register COMDLG32.OCX before!");
	WScript.Quit(1);
}

objDialog.CancelError = 1;
objDialog.Flags = 1 + 2;
if (FindColors) {
	objDialog.Color = "&H" + BGR2RGB(FindColors[0]);
} else {
	strInput = defColor;
	objDialog.Color = "&H" + BGR2RGB(defColor);
}

// �������� ����������� ���� ������ �����
try {objDialog.ShowColor();
	// ���� ������ "OK"
	var B = Dec2Hex((objDialog.Color & 0xFF0000) >>> 16);
	var G = Dec2Hex((objDialog.Color & 0xFF00) >>> 8 );
	var R = Dec2Hex(objDialog.Color & 0xFF);
	var resultColor = R + G + B;
	strOut = strInput.replace(regEx, resultColor);
	WScript.StdOut.Write (strOut);
	err_code = 0;
} catch(e) {
	err_code = 1;
}

WScript.Quit (err_code);

// ---------------------------------------------------
// ������� �������������� �������� �����
function BGR2RGB(colorBGR){
	var colorRGB = colorBGR.replace(/(.{2})(.{2})(.{2})/,'$3$2$1');
	return colorRGB;
}

// ---------------------------------------------------
function Dec2Hex (Dec) {
	var hexChars = '0123456789ABCDEF';
	var a = Dec % 16;
	var b = (Dec - a) / 16;
	var hex = '' + hexChars.charAt(b) + hexChars.charAt(a);
	return hex;
}
