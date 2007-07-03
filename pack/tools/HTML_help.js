// HTML Help Context
// Version: 1.5
// Autor: mozers�
//  -----------------------------------------------------------------------
//  �������� ������� (����� HTML ����) � ���� ��� ���������
//  ������������ ��� ��������� ����������� � ��������� ������
//  ��������� ������� ������� �� ���� ���������� � ������� ������� Enter

//  �����������:
//  �������� � ���� ���� .properties ��������� ������:
//    SciTE.files=*.properties;*.lua;*.iface
//    command.help.$(SciTE.files)=wscript "$(SciteDefaultHome)\tools\HTML_help.js" "$(SciteDefaultHome)\doc\SciTEDoc.html" "$(CurrentSelection)"
//    command.help.subsystem.$(SciTE.files)=2
//
//    command.help.*.lua="$(SciteDefaultHome)\tools\HTML_help.js" "$(SciteDefaultHome)\help\lua5.htm" "$(CurrentSelection)"
//    command.help.subsystem.*.lua=2
//  -----------------------------------------------------------------------

var Args = WScript.Arguments;
var help_path = Args(0);
var text_find = Args(1);

// ��������� ���� Internet Explorer � ��������� � ���� html ���� �������
var objIE = new ActiveXObject('InternetExplorer.Application');
with (objIE) {
	MenuBar = 0;
	ToolBar = 0;
	StatusBar = 0;
	Navigate (help_path);
	Visible = 1;
}
while (objIE.Busy) {};


if (text_find) {
	// ���� ����� � ���� ��������� � �������� ���
	var TextRange=objIE.document.body.createTextRange();
	for(var i=0;TextRange.findText(text_find);i++){
		TextRange.execCommand('BackColor','','yellow');
		TextRange.execCommand('CreateBookmark','','bmk'+i);
		TextRange.collapse(false);
	}
	var WSHShell = WScript.CreateObject('WScript.Shell');
	if (i==0){
		WSHShell.Popup('�����  "' + Args(1) + '"  �� ������!', 2, '������������ SciTE', 64);
	} else {
		WSHShell.Popup('������� '+ i +' ��������� ������ "' + Args(1) + '"\n����������� ENTER ��� �������� �����������!', 2, '������������ SciTE', 64);
		// ������������� ������� �� ������ ��������� ���������
		objIE.document.location.href=objIE.document.location.href+'#bmk0';

		// �������� � ���� ��������� ������ ��� �������� �������� �� ��������� ����������
		var oScript = objIE.document.createElement("SCRIPT");
		oScript.type = "text/javascript";
		oScript.text = 'TextRange=document.body.createTextRange(); document.onkeypress=function (){if (event.keyCode==13) {if (TextRange.findText(\"'+text_find+'\")){TextRange.select(); TextRange.collapse(false);}}}';
		objIE.document.getElementsByTagName("BODY")[0].appendChild(oScript);
	}
}
