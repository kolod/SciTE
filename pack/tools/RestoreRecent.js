/*
RestoreRecent.js
Authors: mozers�
Version: 1.0
------------------------------------------------------
Description:
  It is started from script RestoreRecent.lua
  Save position, bookmarks, folds to SciTE.recent file
  ����������� �� ������� RestoreRecent.lua
  ������ ������� �������, �������� � ������� �� ����� SciTE.session � ��������� ��� ���� SciTE.recent
*/

var WshShell = new ActiveXObject("WScript.Shell");
var FSO = new ActiveXObject("Scripting.FileSystemObject");

try {
	var scite_user_home = WScript.Arguments(0); // ���� �������� ���������� � ���.������ ������������� ������� (RestoreRecent.lua)
} catch(e) {
	WScript.Echo('This script started only from RestoreRecent.lua!');
	WScript.Quit(1);
}

var session_filename = scite_user_home + '\\SciTE.session';
var recent_filename = scite_user_home + '\\SciTE.recent';

var cur_date = fDate();
var recent_arr = ReadRecentFile(recent_filename);
ReadSessionFile(session_filename);
RemoveWaste();
SaveRecentFile(recent_filename);

// ���������� ������� ���� � ���� "dd.mm.yyyy"
function fDate() {
	var d = new Date();
	var year = d.getYear();
	var day = d.getDate();
	if (day < 10){day = '0' + day};
	var month = d.getMonth() + 1;
	if (month < 10){month = '0' + month};
	return day + '.' + month + '.' + year;
}

// �������������� ��������� ������� � ��������� ��� ���������
function Param2Index(param){
	var index = -1;
	switch(param){
		case 'date':
			index = 0; break;
		case 'path':
			index = 1; break;
		case 'position':
			index = 2; break;
		case 'bookmarks':
			index = 3; break;
		case 'folds':
			index = 4;
	}
	return index;
}

// �������������� ���������� ����� ��������� � �������� ������
function Index2Param(index){
	var param = '';
	switch(index){
		case 0:
			param = 'date'; break;
		case 1:
			param = 'path'; break;
		case 2:
			param = 'position'; break;
		case 3:
			param = 'bookmarks'; break;
		case 4:
			param = 'folds';
	}
	return param;
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
	arr_tmp[0] = cur_date;
	recent_arr[i] = arr_tmp;
	return i;
}

// ������ SciTE.session � ������, �������� ������� � ������� ����������� �������
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
	for (var i=recent_arr.length-1; i>0; i--){
		if ((recent_arr[i].length == 3) && (recent_arr[i][2] == 1)) {
		// ���� � ������ � ����� ������ {����,�������,����} � �������=1 ��:
			recent_arr.splice(i, 1);
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
					file.WriteLine('buffer.' + i + '.' + Index2Param(j) + '=' + value);
				}
			}
			file.WriteLine(''); // ����� ��� ������� :)
		}
	}
	file.Close();
}
