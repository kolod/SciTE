# IFaceTableGen.py - regenerate the IFaceTable.cxx from the Scintilla.iface
# interface definition file.  Based on Scintilla's HFacer.py.
# The header files are copied to a temporary file apart from the section between a //++Autogenerated
# comment and a //--Autogenerated comment which is generated by the printHFile and printLexHFile
# functions. After the temporary file is created, it is copied back to the original file name.

import string
import sys
import os

srcRoot = "../.."

sys.path.append(srcRoot + "/scintilla/include")

import Face

def Contains(s,sub):
	return string.find(s, sub) != -1

def printIFaceTableCXXFile(f,out):
	constants = []
	functions = {}
	properties = {}
	
	for name in f.order:
		features = f.features[name]
		if features["Category"] != "Deprecated":
			if features["FeatureType"] == "val":
				if not (Contains(name, "SCE_") or Contains(name, "SCLEX_")):
					constants.append( (name, features["Value"]) )
			elif features["FeatureType"] in ["fun","get","set"]:
				functions[name] = features

				if features["FeatureType"] == "get":
					propname = string.replace(name, "Get", "", 1)
					properties[propname] = (name, properties.get(propname,(None,None))[1])

				elif features["FeatureType"] == "set":
					propname = string.replace(name, "Set", "", 1)
					properties[propname] = (properties.get(propname,(None,None))[0], name)



	for propname, (getterName, setterName) in properties.items():
		getter = getterName and functions[getterName]
		setter = setterName and functions[setterName]
		
		getterValue, getterIndex, getterType = 0, None, None
		setterValue, setterIndex, setterType = 0, None, None
		propType, propIndex = None, None

		isok = (getterName or setterName) and not (getter is setter)
		
		if isok and getter:
			getterValue = getter['Value']
			getterType = getter['ReturnType']
			getterIndex = getter['Param1Type'] or 'void'

			isok = ((getter['Param2Type'] or 'void') == 'void')

		if isok and setter:
			setterValue = setter['Value']
			setterType = setter['Param1Type'] or 'void'
			setterIndex = 'void'
			if (setter['Param2Type'] or 'void') <> 'void':
				setterIndex = setterType
				setterType = setter['Param2Type']

			isok = (setter['ReturnType'] == 'void')

		if isok and getter and setter:
			isok = (getterType == setterType) and (getterIndex == setterIndex)

		propType = getterType or setterType
		propIndex = getterIndex or setterIndex

		if isok:
			# do the types appear to be useable?  THIS IS OVERRIDDEN BELOW
			isok = (propType in ('int', 'position', 'colour', 'bool')
				and propIndex in ('void','int','position','string','bool'))

			# indexers not supported yet
			isok = (isok and propIndex in ('bool', 'void'))

			# If there were string properties (which there are not), they would 
			# have to follow a different protocol, and would not have matched
			# the signature established above.  I suggest this is the signature
			# for a string getter and setter:
			#   get int funcname(void,stringresult)
			#   set void funcname(void,string)
			#
			# for an indexed string getter and setter, the indexer goes in
			# wparam and must not be called 'int length', since 'int length'
			# has special meaning.

			# A bool indexer has a special meaning.  It means "if the script
			# assigns the language's nil value to the property, call the 
			# setter with args (0,0); otherwise call it with (1, value)."
			#
			# Although there are no getters indexed by bool, I suggest the
			# following protocol:  If getter(1,0) returns 0, return nil to
			# the script.  Otherwise return getter(0,0).
			

		if isok:
			properties[propname] = (getterValue, setterValue, propType, propIndex)

			# If it is exposed as a property, it should not be exposed as a function.
			if getter:
				constants.append( ("SCI_" + string.upper(getterName), getterValue) )
				del(functions[getterName])
			if setter:
				constants.append( ("SCI_" + string.upper(setterName), setterValue) )
				del(functions[setterName])
		else:
			del(properties[propname])

	out.write("\nstatic IFaceConstant ifaceConstants[] = {")
	
	if constants:
		constants.sort()
		
		first = 1
		for name, value in constants:
			if first: first = 0
			else: out.write(",")
			
			out.write('\n\t{"%s",%s}' % (name, value))
		
		out.write("\n};\n")
	else:
		out.write('{"",0}};\n')

	# Write an array of function descriptions.  This can be
	# used as a sort of compiled typelib.

	out.write("\nstatic IFaceFunction ifaceFunctions[] = {")
	if functions:
		funclist = functions.items()
		funclist.sort()
	
		first = 1
		for name, features in funclist:
			if first: first = 0
			else: out.write(",")
			
			paramTypes = [
				features["Param1Type"] or "void",
				features["Param2Type"] or "void"
			]
			
			returnType = features["ReturnType"]
			
			# Fix-up: if a param is an int named length, change to iface_type_length.
			if features["Param1Type"] == "int" and features["Param1Name"] == "length":
				paramTypes[0] = "length"

			if features["Param2Type"] == "int" and features["Param2Name"] == "length":
				paramTypes[1] = "length"


			out.write('\n\t{"%s", %s, iface_%s, {iface_%s, iface_%s}}' % (
				name, features["Value"], returnType, paramTypes[0], paramTypes[1]
			))
	
		out.write("\n};\n")
	else:
		out.write('{""}};\n')

	out.write("\nstatic IFaceProperty ifaceProperties[] = {")
	if properties:
		proplist = properties.items()
		proplist.sort()

		first = 1
		for propname, (getter, setter, valueType, paramType) in proplist:
			if first: first = 0
			else: out.write(",")
	
			out.write('\n\t{"%s", %s, %s, iface_%s, iface_%s}' % (
				propname, getter, setter, valueType, paramType
			))

		out.write("\n};\n")
	else:
		out.write('{""}};\n')
	
	out.write("\nenum {\n")
	out.write("\tifaceFunctionCount = %d,\n" % len(functions))
	out.write("\tifaceConstantCount = %d,\n" % len(constants))
	out.write("\tifacePropertyCount = %d\n" % len(properties))
	out.write("};\n\n")


def CopyWithInsertion(input, output, genfn, definition):
	copying = 1
	for line in input.readlines():
		if copying:
			output.write(line)
		if Contains(line, "//++Autogenerated"):
			copying = 0
			genfn(definition, output)
		if Contains(line, "//--Autogenerated"):
			copying = 1
			output.write(line)

def contents(filename):
	f = file(filename)
	t = f.read()
	f.close()
	return t

def Regenerate(filename, genfn, definition):
	inText = contents(filename)
	tempname = "IFaceTableGen.tmp"
	out = open(tempname,"w")
	hfile = open(filename)
	CopyWithInsertion(hfile, out, genfn, definition)
	out.close()
	hfile.close()
	outText = contents(tempname)
	if inText == outText:
		os.unlink(tempname)
	else:
		os.unlink(filename)
		os.rename(tempname, filename)

f = Face.Face()
f.ReadFromFile(srcRoot + "/scintilla/include/Scintilla.iface")
Regenerate(srcRoot + "/scite/src/IFaceTable.cxx", printIFaceTableCXXFile, f)
