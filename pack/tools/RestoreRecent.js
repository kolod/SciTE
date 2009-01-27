/*
RestoreRecent.js
Authors: mozers�
Version: 1.1.1
------------------------------------------------------
Description:
  It is started from script RestoreRecent.lua
  Save position, bookmarks, folds to SciTE.recent file
  ����������� �� ������� RestoreRecent.lua
  ������ ������� �������, �������� � ������� �� ����� SciTE.session � ��������� ��� ���� SciTE.recent
*/

var WshShell = new ActiveXObject("WScript.Shell");
var FSO = new ActiveXObject("Scripting.FileSystemObject");
var params = new Array('date', 'path', 'position', 'bookmarks', 'folds');

try {
	var scite_user_home = WScript.Arguments(0); // ���� �������� ���������� � ���.������ ������������� ������� (RestoreRecent.lua)
} catch(e) {
	WScript.Echo('This script started only from RestoreRecent.lua!');
	WScript.Quit(1);
}

var session_filename = scite_user_home + '\\SciTE.session';
var recent_filename = scite_user_home + '\\SciTE.recent';

var cur_date = GetDate();
var cur_date_string = DateFormatString(cur_date);
var recent_arr = ReadRecentFile(recent_filename);
ReadSessionFile(session_filename);
RemoveWaste();
SaveRecentFile(recent_filename);

// ���������� ������, ���������� ���� {d, m, y}
function GetDate(obj) {
	if (obj==undefined){
		var d = new Date();
	}else{
		var d = new Date(obj);
	}
	var arr = new Array (d.getDate(), d.getMonth(), d.getYear());
	return arr;
}

// ����������� ���� � ���� "dd.mm.yyyy"
function DateFormatString(date_arr){
	var d = date_arr[0];
	d = (d < 10) ? ('0' + d) : d;
	var m = date_arr[1] + 1;
	m = (m < 10) ? ('0' + m) : m;
	var y = date_arr[2];
	return d + '.' + m + '.' + y;
}

// ����������� ���� � ����� (�������� +-1���� �� ������� �����, �� ������ � ���)
function DateFormatNumber(date_arr){
	var d = date_arr[0];
	var m = date_arr[1] * 30;
	var y = date_arr[2] * 365;
	return d + m + y;
}

// �������������� ������ ���� "dd.mm.yyyy" � �����
function DateString2Number(date_str){
	var m = date_str.match(/(\d+)\.(\d+)\.(\d+)/);
	var arr = new Array (Number(m[1]), Number(m[2])-1, Number(m[3]));
	return DateFormatNumber(arr);
}

// �������������� ���������� ����� ��������� � �������� ������
function Param2Index(param){
	for (var i=0; i<params.length; i++) {
		if (param == params[i]) return i;
	}
	return -1;
}

// ������ SciTE.recent � ���������� ������ recent_arr[�����_�����][���_���������] = ��������
function ReadRecentFile(filename) {
	var arr = new Array;
	if (FSO.FileExists(filename)) {
		if (FSO.GetFile(filename).Size > 0) {
			file = FSO.OpenTextFile(filename, 1);
			while (!file.AtEndOfStream){
				var line = file.ReadLine();
				var r = line.match(/buffer\.(\d)\.([a-z]+)=(.+)$/);
				if (r) { // r = ������: {1-�����_�����, 2-���_���������, 3-��������}
					var y = Param2Index(r[2]);
					if (y != -1) {
						var x = r[1];
						if (!arr[x]) {
							var arr_tmp = new Array;
							arr_tmp[y] = r[3];
							arr[x] = arr_tmp;
						}else{
							arr[x][y] = r[3];
						}
					}
				}
			}
			file.Close();
		}
	}
	return(arr);
}

// �������� ������� � ������� ������ � ������ �� ������� (recent_arr[i][1] == ���_����� ?)
function IsRecent(filespec){
	for (var i=1; i<recent_arr.length; i++) {
		if (recent_arr[i][1] == filespec) break;
	}
	// ���� ������ � ����� ���������� - ���������� ��� ������� ������ � ���
	// ���� ������ ���������� - ������� �� � ���������� ����� ������ �������
	var arr_tmp = new Array;
	arr_tmp[0] = cur_date_string;
	recent_arr[i] = arr_tmp;
	return i;
}

// ������ SciTE.session � ������, �������� ������� � ��� ����������� �������
function ReadSessionFile(filename){
	if (FSO.FileExists(filename)) {
		if (FSO.GetFile(filename).Size > 0) {
			file = FSO.OpenTextFile(filename, 1);
			var x;
			while (!file.AtEndOfStream) {
				var line = file.ReadLine().toLowerCase();
				var r = line.match(/buffer\.(\d)\.([a-z]+)=(.+)$/);
				if (r) { // r = ������: {1-�����_�����, 2-���_���������, 3-��������}
					if (r[2] == 'path') x = IsRecent(r[3]);
					var y = Param2Index(r[2]);
					recent_arr[x][y] = r[3];
				}
			}
			file.Close();
		}
	}
}

// ������� �� ������� ������ � ������ � ������� ������������ ���� ������ �� �������.
function RemoveWaste(){
	// ������� ����������������� ������
	for (var i=recent_arr.length-1; i>0; i--){
		if ((recent_arr[i].length == 3) && (recent_arr[i][2] == 1)) {
		// ���� � ������ � ����� ������ 3 ��������� {����,�������,����} � �������=1 ��:
			recent_arr.splice(i, 1);
		}
	}

	// ������� ������ ������
	var link_age = 30; // max ���� ����� ������ � SciTE.recent (����)
	var cur_date_number = DateFormatNumber(cur_date);
	var recent_date_number = 0;
	if (FSO.FileExists(recent_filename)) {
		var recent_date = FSO.GetFile(recent_filename).DateLastModified;
		recent_date_number = DateFormatNumber(GetDate(recent_date));
	}
	// ��������� ������� ����������� ������ 1 ��� � ����
	if (cur_date_number > recent_date_number) {
		for (var i=recent_arr.length-1; i>0; i--){
			var link_date_number = DateString2Number(recent_arr[i][0]);
			if (cur_date_number - link_date_number > link_age) {
			// ���� ������� ����� ������ ���������� ���������� ����, ��:
				recent_arr.splice(i, 1);
			}
		}
	}
}

// C�������� ������ � SciTE.recent
function SaveRecentFile(filename){
	var file = FSO.OpenTextFile(filename, 2, true);
	for (var i=0; i<recent_arr.length; i++){
		if (recent_arr[i]) {
			for (var j=0; j<recent_arr[i].length; j++) {
				var value = recent_arr[i][j];
				if (value) {
					file.WriteLine('buffer.' + i + '.' + params[j] + '=' + value);
				}
			}
			file.WriteLine(''); // ����� ��� ������� :)
		}
	}
	file.Close();
}
