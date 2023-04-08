#!/usr/bin/env python3
# CheckAtFile.py
# Check that file headers mention the file name in a standard way
# Check that include guards are present when needed and follow a common naming convention
# Implemented 2019 by Neil Hodgson neilh@scintilla.org
# Requires Python 3.6 or later

import pathlib

srcRoot = pathlib.Path(__file__).resolve().parent.parent.parent

neutralEncoding = "cp437"	# Each byte value is valid in cp437

# Find all the files in the second level directories
# moc_* generated by Qt moc
# scintilla-marshal.* generated by glib-genmarshal
srcPaths = []
for base in ["scintilla", "lexilla", "scite"]:
	baseDir = srcRoot / base
	for src in baseDir.glob("**/*"):
		if src.suffix in [".cxx", ".h", ".mm", ".m", ".cpp", ".c"]:
			if not src.name.startswith("moc_") and \
				not src.name.startswith("scintilla-marshal") and \
				"cov-int" not in src.parts:
				srcPaths.append(src)

#~ for p in srcPaths:
	#~ print(p.parts)

headerPaths = [f for f in srcPaths if f.suffix == ".h"]

# Check whether a file name comment is present
for p in srcPaths:
	if "lexilla/test/examples/" in str(p).replace("\\", "/"):
		# Weed out test example files
		continue
	baseName = p.name
	with p.open(encoding=neutralEncoding) as f:
		lines = f.readlines()
		if "pyside_global.h" in lines[0]:
			# Weed out generated file
			continue
		for i in range(min(20, len(lines))):
			atLine = lines[i]
			if "@file" in atLine:
				break
		if "@file" in atLine:
			#~ print(atLine, p)
			_a, _b, fileName = atLine.partition("@file")
			fileName = fileName.strip().split()[0]
			if baseName != fileName:
				if baseName.lower() == fileName.lower():
					print(f"{p}:2: wrong case @file:{fileName}")
				else:
					print(f"{p}:2: wrong @file:{fileName}")
		else:
			atLine = lines[1]
			if "$Id:" in atLine:
				# Lua uses source code control "$Id" variable so
				# strip it and the ",v" that follows the file name.
				atLine = atLine.replace(",v", "")
				atLine = atLine.replace("$Id:", "")
			fields = atLine.strip().split()
			fileName = ""
			if len(fields) > 1:
				fileName = fields[1]
			if baseName != fileName:
				if baseName.lower() == fileName.lower():
					print(f"{p}:2: wrong case @file:{fileName}")
				else:
					print(f"{p}:2: wrong file comment:{atLine.rstrip()}")
			else:
				#~ print(f"{p}:2: no @file [" + fileName + "] [" + baseName + "]")
				pass

# Check whether a header guard is present
for header in headerPaths:
	# For Cocoa, using #import avoids need for guards
	if "cocoa" in header.parent.parts:
		continue
	# global.h generated for ScintillaEditPy
	if header.parent.name == "ScintillaEditPy" and header.name == "global.h":
		continue
	# XPM pixmap files may need to be edited with a graphics program
	if header.name == "pixmapsGNOME.h":
		continue
	if header.name == "SciIcon.h":
		continue

	with header.open(encoding=neutralEncoding) as f:
		# ScintillaWidget.h -> SCINTILLAWIDGET_H
		guard = header.name.upper().replace(".", "_")
		if "lua" in str(header.parent):
			guard = guard.lower()
		lines = f.readlines()
		matches = [line.strip() for line in lines if guard in line.split() and "#endif" not in line]
		#ifndef XPM_H:#define XPM_H
		standardGuardSet = "#ifndef " + guard + ":#define " + guard
		if ":".join(matches) != standardGuardSet:
			print(f"{header}:0: ", guard, ":".join(matches))
			print("\n".join(standardGuardSet.split(":")))