// SciTE - Scintilla based Text Editor
/** @file SciTEProps.cxx
 ** Properties management.
 **/
// Copyright 1998-2001 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <fcntl.h>
#include <time.h>   	// For time_t

#include "Platform.h"

#if PLAT_GTK

#include <unistd.h>

#endif

#if PLAT_WIN
// For getcwd
#ifdef _MSC_VER
#include <direct.h>
#endif
#ifdef __BORLANDC__
#include <dir.h>
#endif

#endif

#include "SciTE.h"
#include "PropSet.h"
#include "Accessor.h"
#include "Scintilla.h"
#include "SciLexer.h"
#include "Extender.h"
#include "SciTEBase.h"

PropSetFile::PropSetFile() {}

PropSetFile::~PropSetFile() {}

/**
 * Get a line of input. If end of line escaped with '\\' then continue reading.
 */
static bool GetFullLine(const char *&fpc, int &lenData, char *s, int len) {
	bool continuation = true;
	s[0] = '\0';
	while ((len > 1) && lenData > 0) {
		char ch = *fpc;
		fpc++;
		lenData--;
		if ((ch == '\r') || (ch == '\n')) {
			if (!continuation) {
				if ((lenData > 0) && (ch == '\r') && ((*fpc) == '\n')) {
					// munch the second half of a crlf
					fpc++;
					lenData--;
				}
				*s = '\0';
				return true;
			}
		} else if ((ch == '\\') && (lenData > 0) && ((*fpc == '\r') || (*fpc == '\n'))) {
			continuation = true;
		} else {
			continuation = false;
			*s++ = ch;
			*s = '\0';
			len--;
		}
	}
	return false;
}

bool PropSetFile::ReadLine(char *linebuf, bool ifIsTrue, const char *directoryForImports) {
	if (isalpha(linebuf[0]))    // If clause ends with first non-indented line
		ifIsTrue = true;
	if (isprefix(linebuf, "if ")) {
		const char *expr = linebuf + strlen("if") + 1;
		ifIsTrue = GetInt(expr);
	} else if (isprefix(linebuf, "import ") && directoryForImports) {
		char importPath[1024];
		strcpy(importPath, directoryForImports);
		strcat(importPath, linebuf + strlen("import") + 1);
		strcat(importPath, ".properties");
		Read(importPath, directoryForImports);
	} else if (isalpha(linebuf[0])) {
		Set(linebuf);
	} else if (isspace(linebuf[0]) && ifIsTrue) {
		Set(linebuf);
	}
	return ifIsTrue;
}

void PropSetFile::ReadFromMemory(const char *data, int len, const char *directoryForImports) {
	const char *pd = data;
	char linebuf[60000];
	bool ifIsTrue = true;
	while (len > 0) {
		GetFullLine(pd, len, linebuf, sizeof(linebuf));
		ifIsTrue = ReadLine(linebuf, ifIsTrue, directoryForImports);
	}
}

void PropSetFile::Read(const char *filename, const char *directoryForImports) {
	char propsData[60000];
#ifdef __vms
	FILE *rcfile = fopen(filename, "r");
#else
	FILE *rcfile = fopen(filename, "rb");
#endif
	if (rcfile) {
		int lenFile = fread(propsData, 1, sizeof(propsData), rcfile);
		fclose(rcfile);
		ReadFromMemory(propsData, lenFile, directoryForImports);
	} else {
		//printf("Could not open <%s>\n", filename);
	}

}

const char propFileName[] = "SciTE.properties";

void SciTEBase::ReadGlobalPropFile() {
	char propfile[MAX_PATH + 20];
	char propdir[MAX_PATH + 20];
	propsBase.Clear();
#if PLAT_GTK
	propsBase.Set("PLAT_GTK", "1");
#endif
#if PLAT_WIN
	propsBase.Set("PLAT_WIN", "1");
#endif
	if (GetDefaultPropertiesFileName(propfile, propdir, sizeof(propfile))) {
		strcat(propdir, pathSepString);
		propsBase.Read(propfile, propdir);
	}
	propsUser.Clear();
	if (GetUserPropertiesFileName(propfile, propdir, sizeof(propfile))) {
		strcat(propdir, pathSepString);
		propsUser.Read(propfile, propdir);
	}
}

void ChopTerminalSlash(char *path) {
	int endOfPath = strlen(path) - 1;
	if (path[endOfPath] == pathSepChar) {
		path[endOfPath] = '\0';
	}
}

void SciTEBase::GetDocumentDirectory(char *docDir, int len) {
	if (dirName[0]) {
		strncpy(docDir, dirName, len);
		docDir[len - 1] = '\0';
	} else {
		getcwd(docDir, len);
		docDir[len - 1] = '\0';
		// In Windows, getcwd returns a trailing backslash
		// when the CWD is at the root of a disk, so remove it
		ChopTerminalSlash(docDir);
	}
}

void SciTEBase::ReadLocalPropFile() {
	char propdir[MAX_PATH + 20];
	GetDocumentDirectory(propdir, sizeof(propdir));
	char propfile[MAX_PATH + 20];
	strcpy(propfile, propdir);
#ifndef __vms
	strcat(propdir, pathSepString);
	strcat(propfile, pathSepString);
#endif
	strcat(propfile, propFileName);
	propsLocal.Clear();
	propsLocal.Read(propfile, propdir);
	//Platform::DebugPrintf("Reading local properties from %s\n", propfile);

	// TODO: Grab these from Platform and update when environment says to
	props.Set("Chrome", "#C0C0C0");
	props.Set("ChromeHighlight", "#FFFFFF");
}

static int IntFromHexDigit(const char ch) {
	if (isdigit(ch))
		return ch - '0';
	else if (ch >= 'A' && ch <= 'F')
		return ch - 'A' + 10;
	else if (ch >= 'a' && ch <= 'f')
		return ch - 'a' + 10;
	else
		return 0;
}

static Colour ColourFromString(const char *val) {
	int r = IntFromHexDigit(val[1]) * 16 + IntFromHexDigit(val[2]);
	int g = IntFromHexDigit(val[3]) * 16 + IntFromHexDigit(val[4]);
	int b = IntFromHexDigit(val[5]) * 16 + IntFromHexDigit(val[6]);
	return Colour(r, g, b);
}

/**
 * Put the next property item from the given property string
 * into the buffer pointed by @a pPropItem.
 * @return NULL if the end of the list is met, else, it points to the next item.
 */
char *SciTEBase::GetNextPropItem(
	const char *pStart,  	/**< the property string to parse for the first call,
							 * pointer returned by the previous call for the following. */
	char *pPropItem,  	///< pointer on a buffer receiving the requested prop item
	int maxLen)			///< size of the above buffer
{
	char *pNext;
	int size = maxLen - 1;

	*pPropItem = '\0';
	if (pStart == NULL) {
		return NULL;
	}
	pNext = const_cast<char *>(strchr(pStart, ','));
	if (pNext) {	// Separator is found
		if (size > pNext - pStart) {
			// Found string fits in buffer
			size = pNext - pStart;
		}
		pNext++;
	}
	strncpy(pPropItem, pStart, size);
	pPropItem[size] = '\0';
	return pNext;
}

StyleDefinition::StyleDefinition(const char *definition) :
size(0), fore(0), back(Colour(0xff,0xff,0xff)), bold(false), italics(false), eolfilled(false), underlined(false) {
	specified = sdNone;
	char *val = StringDup(definition);
	//Platform::DebugPrintf("Style %d is [%s]\n", style, val);
	char *opt = val;
	while (opt) {
		char *cpComma = strchr(opt, ',');
		if (cpComma)
			*cpComma = '\0';
		char *colon = strchr(opt, ':');
		if (colon)
			*colon++ = '\0';
		if (0 == strcmp(opt, "italics")) {
			specified = static_cast<flags>(specified | sdItalics);
			italics = true;
		}
		if (0 == strcmp(opt, "notitalics")) {
			specified = static_cast<flags>(specified | sdItalics);
			italics = false;
		}
		if (0 == strcmp(opt, "bold")) {
			specified = static_cast<flags>(specified | sdBold);
			bold = true;
		}
		if (0 == strcmp(opt, "notbold")) {
			specified = static_cast<flags>(specified | sdBold);
			bold = false;
		}
		if (0 == strcmp(opt, "font")) {
			specified = static_cast<flags>(specified | sdFont);
			font.assign(colon);
		}
		if (0 == strcmp(opt, "fore")) {
			specified = static_cast<flags>(specified | sdFore);
			fore = ColourFromString(colon);
		}
		if (0 == strcmp(opt, "back")) {
			specified = static_cast<flags>(specified | sdBack);
			back = ColourFromString(colon);
		}
		if (0 == strcmp(opt, "size")) {
			specified = static_cast<flags>(specified | sdSize);
			size = atoi(colon);
		}
		if (0 == strcmp(opt, "eolfilled")) {
			specified = static_cast<flags>(specified | sdEOLFilled);
			eolfilled = true;
		}
		if (0 == strcmp(opt, "noteolfilled")) {
			specified = static_cast<flags>(specified | sdEOLFilled);
			eolfilled = false;
		}
		if (0 == strcmp(opt, "underlined")) {
			specified = static_cast<flags>(specified | sdUnderlined);
			underlined = true;
		}
		if (0 == strcmp(opt, "notunderlined")) {
			specified = static_cast<flags>(specified | sdUnderlined);
			underlined = false;
		}
		if (cpComma)
			opt = cpComma + 1;
		else
			opt = 0;
	}
	delete []val;
}

void SciTEBase::SetOneStyle(Window &win, int style, const char *s) {
	StyleDefinition sd(s);
	if (sd.specified & StyleDefinition::sdItalics)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETITALIC, style, sd.italics ? 1 : 0);
	if (sd.specified & StyleDefinition::sdBold)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETBOLD, style, sd.bold ? 1 : 0);
	if (sd.specified & StyleDefinition::sdFont)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETFONT, style, reinterpret_cast<long>(sd.font.c_str()));
	if (sd.specified & StyleDefinition::sdFore)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETFORE, style, sd.fore.AsLong());
	if (sd.specified & StyleDefinition::sdBack)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETBACK, style, sd.back.AsLong());
	if (sd.specified & StyleDefinition::sdSize)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETSIZE, style, sd.size);
	if (sd.specified & StyleDefinition::sdEOLFilled)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETEOLFILLED, style, sd.eolfilled ? 1 : 0);
	if (sd.specified & StyleDefinition::sdUnderlined)
		Platform::SendScintilla(win.GetID(), SCI_STYLESETUNDERLINE, style, sd.underlined ? 1 : 0);
	Platform::SendScintilla(win.GetID(), SCI_STYLESETCHARACTERSET, style, characterSet);
}

void SciTEBase::SetStyleFor(Window &win, const char *lang) {
	for (int style = 0; style <= STYLE_MAX; style++) {
		if (style != STYLE_DEFAULT) {
			char key[200];
			sprintf(key, "style.%s.%0d", lang, style);
			SString sval = props.GetExpanded(key);
			SetOneStyle(win, style, sval.c_str());
		}
	}
}

void lowerCaseString(char *s) {
	while (*s) {
		*s = static_cast<char>(tolower(*s));
		s++;
	}
}

SString SciTEBase::ExtensionFileName() {
	if (overrideExtension.length())
		return overrideExtension;
	else if (fileName[0]) {
		// Force extension to lower case
		char fileNameWithLowerCaseExtension[MAX_PATH];
		strcpy(fileNameWithLowerCaseExtension, fileName);
		char *extension = strrchr(fileNameWithLowerCaseExtension, '.');
		if (extension) {
			lowerCaseString(extension);
		}
		return SString(fileNameWithLowerCaseExtension);
	} else
		return props.Get("default.file.ext");
}

void SciTEBase::ForwardPropertyToEditor(const char *key) {
	SString value = props.Get(key);
	SendEditorString(SCI_SETPROPERTY,
		reinterpret_cast<uptr_t>(key), value.c_str());
}

void SciTEBase::ReadProperties() {
	//DWORD dwStart = timeGetTime();
	SString fileNameForExtension = ExtensionFileName();

	language = props.GetNewExpand("lexer.", fileNameForExtension.c_str());

	if (language == "python") {
		lexLanguage = SCLEX_PYTHON;
	} else if (language == "cpp") {
		lexLanguage = SCLEX_CPP;
	} else if (language == "hypertext") {
		lexLanguage = SCLEX_HTML;
	} else if (language == "xml") {
		lexLanguage = SCLEX_XML;
	} else if (language == "perl") {
		lexLanguage = SCLEX_PERL;
	} else if (language == "sql") {
		lexLanguage = SCLEX_SQL;
	} else if (language == "vb") {
		lexLanguage = SCLEX_VB;
	} else if (language == "props") {
		lexLanguage = SCLEX_PROPERTIES;
	} else if (language == "errorlist") {
		lexLanguage = SCLEX_ERRORLIST;
	} else if (language == "makefile") {
		lexLanguage = SCLEX_MAKEFILE;
	} else if (language == "batch") {
		lexLanguage = SCLEX_BATCH;
	} else if (language == "latex") {
		lexLanguage = SCLEX_LATEX;
	} else if (language == "lua") {
		lexLanguage = SCLEX_LUA;
	} else if (language == "diff") {
		lexLanguage = SCLEX_DIFF;
	} else if (language == "container") {
		lexLanguage = SCLEX_CONTAINER;
	} else if (language == "conf") {
		lexLanguage = SCLEX_CONF;
	} else if (language == "pascal") {
		lexLanguage = SCLEX_PASCAL;
	} else if (language == "ave") {
		lexLanguage = SCLEX_AVE;
	} else {
		lexLanguage = SCLEX_NULL;
	}

	if ((lexLanguage == SCLEX_HTML) || (lexLanguage == SCLEX_XML))
		SendEditor(SCI_SETSTYLEBITS, 7);
	else
		SendEditor(SCI_SETSTYLEBITS, 5);

	SendEditor(SCI_SETLEXER, lexLanguage);
	SendOutput(SCI_SETLEXER, SCLEX_ERRORLIST);

	apis.Clear();

	SString kw0 = props.GetNewExpand("keywords.", fileNameForExtension.c_str());
	SendEditorString(SCI_SETKEYWORDS, 0, kw0.c_str());
	SString kw1 = props.GetNewExpand("keywords2.", fileNameForExtension.c_str());
	SendEditorString(SCI_SETKEYWORDS, 1, kw1.c_str());
	SString kw2 = props.GetNewExpand("keywords3.", fileNameForExtension.c_str());
	SendEditorString(SCI_SETKEYWORDS, 2, kw2.c_str());
	SString kw3 = props.GetNewExpand("keywords4.", fileNameForExtension.c_str());
	SendEditorString(SCI_SETKEYWORDS, 3, kw3.c_str());
	SString kw4 = props.GetNewExpand("keywords5.", fileNameForExtension.c_str());
	SendEditorString(SCI_SETKEYWORDS, 4, kw4.c_str());

	char homepath[MAX_PATH + 20];
	if (GetSciteDefaultHome(homepath, sizeof(homepath))) {
		props.Set("SciteDefaultHome", homepath);
	}
	if (GetSciteUserHome(homepath, sizeof(homepath))) {
		props.Set("SciteUserHome", homepath);
	}

	ForwardPropertyToEditor("fold");
	ForwardPropertyToEditor("fold.compact");
	ForwardPropertyToEditor("fold.comment");
	ForwardPropertyToEditor("fold.html");
	ForwardPropertyToEditor("styling.within.preprocessor");
	ForwardPropertyToEditor("tab.timmy.whinge.level");

	SString apifilename = props.GetNewExpand("api.", fileNameForExtension.c_str());
	if (apifilename.length()) {
		FILE *fp = fopen(apifilename.c_str(), fileRead);
		if (fp) {
			fseek(fp, 0, SEEK_END);
			int len = ftell(fp);
			char *buffer = apis.Allocate(len);
			if (buffer) {
				fseek(fp, 0, SEEK_SET);
				fread(buffer, 1, len, fp);
				apis.SetFromAllocated();
			}
			fclose(fp);
			//Platform::DebugPrintf("Finished api file %d\n", len);
		}

	}

	if (!props.GetInt("eol.auto")) {
		SString eol_mode = props.Get("eol.mode");
		if (eol_mode == "LF") {
			SendEditor(SCI_SETEOLMODE, SC_EOL_LF);
		} else if (eol_mode == "CR") {
			SendEditor(SCI_SETEOLMODE, SC_EOL_CR);
		} else if (eol_mode == "CRLF") {
			SendEditor(SCI_SETEOLMODE, SC_EOL_CRLF);
		}
	}

	codePage = props.GetInt("code.page");
	SendEditor(SCI_SETCODEPAGE, codePage);

	characterSet = props.GetInt("character.set");

	SString colour;
	colour = props.Get("caret.fore");
	if (colour.length()) {
		SendEditor(SCI_SETCARETFORE, ColourFromString(colour.c_str()).AsLong());
	}

	SendEditor(SCI_SETCARETWIDTH, props.GetInt("caret.width", 1));
	SendOutput(SCI_SETCARETWIDTH, props.GetInt("caret.width", 1));

	colour = props.Get("calltip.back");
	if (colour.length()) {
		SendEditor(SCI_CALLTIPSETBACK, ColourFromString(colour.c_str()).AsLong());
	}

	SString caretPeriod = props.Get("caret.period");
	if (caretPeriod.length()) {
		SendEditor(SCI_SETCARETPERIOD, caretPeriod.value());
		SendOutput(SCI_SETCARETPERIOD, caretPeriod.value());
	}

	int caretStrict = props.GetInt("caret.policy.strict") ? CARET_STRICT : 0;
	int caretSlop = props.GetInt("caret.policy.slop", 1) ? CARET_SLOP : 0;
	int caretLines = props.GetInt("caret.policy.lines");
	SendEditor(SCI_SETCARETPOLICY, caretStrict | caretSlop, caretLines);

	int visibleStrict = props.GetInt("visible.policy.strict") ? VISIBLE_STRICT : 0;
	int visibleSlop = props.GetInt("visible.policy.slop", 1) ? VISIBLE_SLOP : 0;
	int visibleLines = props.GetInt("visible.policy.lines");
	SendEditor(SCI_SETVISIBLEPOLICY, visibleStrict | visibleSlop, visibleLines);

	SendEditor(SCI_SETEDGECOLUMN, props.GetInt("edge.column", 0));
	SendEditor(SCI_SETEDGEMODE, props.GetInt("edge.mode", EDGE_NONE));
	colour = props.Get("edge.colour");
	if (colour.length()) {
		SendEditor(SCI_SETEDGECOLOUR, ColourFromString(colour.c_str()).AsLong());
	}

	SString selfore = props.Get("selection.fore");
	if (selfore.length()) {
		SendChildren(SCI_SETSELFORE, 1, ColourFromString(selfore.c_str()).AsLong());
	} else {
		SendChildren(SCI_SETSELFORE, 0, 0);
	}
	colour = props.Get("selection.back");
	if (colour.length()) {
		SendChildren(SCI_SETSELBACK, 1, ColourFromString(colour.c_str()).AsLong());
	} else {
		if (selfore.length())
			SendChildren(SCI_SETSELBACK, 0, 0);
		else	// Have to show selection somehow
			SendChildren(SCI_SETSELBACK, 1, Colour(0xC0, 0xC0, 0xC0).AsLong());
	}

	char bracesStyleKey[200];
	sprintf(bracesStyleKey, "braces.%s.style", language.c_str());
	bracesStyle = props.GetInt(bracesStyleKey, 0);

	char key[200];
	SString sval;

	sprintf(key, "calltip.%s.ignorecase", "*");
	sval = props.GetNewExpand(key, "");
	callTipIgnoreCase = sval == "1";
	sprintf(key, "calltip.%s.ignorecase", language.c_str());
	sval = props.GetNewExpand(key, "");
	if (sval != "")
		callTipIgnoreCase = sval == "1";

	sprintf(key, "autocomplete.%s.ignorecase", "*");
	sval = props.GetNewExpand(key, "");
	autoCompleteIgnoreCase = sval == "1";
	sprintf(key, "autocomplete.%s.ignorecase", language.c_str());
	sval = props.GetNewExpand(key, "");
	if (sval != "")
		autoCompleteIgnoreCase = sval == "1";
	SendEditor(SCI_AUTOCSETIGNORECASE, autoCompleteIgnoreCase ? 1 : 0);

	int autoCChooseSingle = props.GetInt("autocomplete.choose.single");
	SendEditor(SCI_AUTOCSETCHOOSESINGLE, autoCChooseSingle),

	// Set styles
	// For each window set the global default style, then the language default style, then the other global styles, then the other language styles

	SendEditor(SCI_STYLERESETDEFAULT, 0, 0);
	SendOutput(SCI_STYLERESETDEFAULT, 0, 0);

	sprintf(key, "style.%s.%0d", "*", STYLE_DEFAULT);
	sval = props.GetNewExpand(key, "");
	SetOneStyle(wEditor, STYLE_DEFAULT, sval.c_str());
	SetOneStyle(wOutput, STYLE_DEFAULT, sval.c_str());

	sprintf(key, "style.%s.%0d", language.c_str(), STYLE_DEFAULT);
	sval = props.GetNewExpand(key, "");
	SetOneStyle(wEditor, STYLE_DEFAULT, sval.c_str());

	SendEditor(SCI_STYLECLEARALL, 0, 0);

	SetStyleFor(wEditor, "*");
	SetStyleFor(wEditor, language.c_str());

	SendOutput(SCI_STYLECLEARALL, 0, 0);

	sprintf(key, "style.%s.%0d", "errorlist", STYLE_DEFAULT);
	sval = props.GetNewExpand(key, "");
	SetOneStyle(wOutput, STYLE_DEFAULT, sval.c_str());

	SendOutput(SCI_STYLECLEARALL, 0, 0);

	SetStyleFor(wOutput, "*");
	SetStyleFor(wOutput, "errorlist");

	if (firstPropertiesRead) {
		ReadPropertiesInitial();
	}

	SendEditor(SCI_SETUSEPALETTE, props.GetInt("use.palette"));
	SendEditor(SCI_SETPRINTMAGNIFICATION, props.GetInt("print.magnification"));
	SendEditor(SCI_SETPRINTCOLOURMODE, props.GetInt("print.colour.mode"));

	clearBeforeExecute = props.GetInt("clear.before.execute");

	int blankMarginLeft = props.GetInt("blank.margin.left", 1);
	int blankMarginRight = props.GetInt("blank.margin.right", 1);
	//long marginCombined = Platform::LongFromTwoShorts(blankMarginLeft, blankMarginRight);
	SendEditor(SCI_SETMARGINLEFT, 0, blankMarginLeft);
	SendEditor(SCI_SETMARGINRIGHT, 0, blankMarginRight);
	SendOutput(SCI_SETMARGINLEFT, 0, blankMarginLeft);
	SendOutput(SCI_SETMARGINRIGHT, 0, blankMarginRight);

	SendEditor(SCI_SETMARGINWIDTHN, 1, margin ? marginWidth : 0);
	SendEditor(SCI_SETMARGINWIDTHN, 0, lineNumbers ? lineNumbersWidth : 0);

	bufferedDraw = props.GetInt("buffered.draw", 1);
	SendEditor(SCI_SETBUFFEREDDRAW, bufferedDraw);

	bracesCheck = props.GetInt("braces.check");
	bracesSloppy = props.GetInt("braces.sloppy");

	SString wordCharacters = props.GetNewExpand("word.characters.", fileNameForExtension.c_str());
	if (wordCharacters.length()) {
		SendEditorString(SCI_SETWORDCHARS, 0, wordCharacters.c_str());
	} else {
		SendEditor(SCI_SETWORDCHARS, 0, 0);
	}

	SendEditor(SCI_SETUSETABS, props.GetInt("use.tabs", 1));
	int tabSize = props.GetInt("tabsize");
	if (tabSize) {
		SendEditor(SCI_SETTABWIDTH, tabSize);
	}
	indentSize = props.GetInt("indent.size");
	SendEditor(SCI_SETINDENT, indentSize);
	indentOpening = props.GetInt("indent.opening");
	indentClosing = props.GetInt("indent.closing");
	SString lookback = props.GetNewExpand("statement.lookback.", fileNameForExtension.c_str());
	statementLookback = lookback.value();
	statementIndent = GetStyleAndWords("statement.indent.");
	statementEnd = GetStyleAndWords("statement.end.");
	blockStart = GetStyleAndWords("block.start.");
	blockEnd = GetStyleAndWords("block.end.");

	if (props.GetInt("vc.home.key", 1)) {
		AssignKey(SCK_HOME, 0, SCI_VCHOME);
		AssignKey(SCK_HOME, SCMOD_SHIFT, SCI_VCHOMEEXTEND);
	} else {
		AssignKey(SCK_HOME, 0, SCI_HOME);
		AssignKey(SCK_HOME, SCMOD_SHIFT, SCI_HOMEEXTEND);
	}
	AssignKey('L', SCMOD_SHIFT | SCMOD_CTRL, SCI_LINEDELETE);
	SendEditor(SCI_SETHSCROLLBAR, props.GetInt("horizontal.scrollbar", 1));
	SendOutput(SCI_SETHSCROLLBAR, props.GetInt("output.horizontal.scrollbar", 1));

	SetToolsMenu();

	SendEditor(SCI_SETFOLDFLAGS, props.GetInt("fold.flags"));

	// To put the folder markers in the line number region
	//SendEditor(SCI_SETMARGINMASKN, 0, SC_MASK_FOLDERS);

	SendEditor(SCI_SETMODEVENTMASK, SC_MOD_CHANGEFOLD);

	// Create a margin column for the folding symbols
	SendEditor(SCI_SETMARGINTYPEN, 2, SC_MARGIN_SYMBOL);

	SendEditor(SCI_SETMARGINWIDTHN, 2, foldMargin ? foldMarginWidth : 0);

	SendEditor(SCI_SETMARGINMASKN, 2, SC_MASK_FOLDERS);
	SendEditor(SCI_SETMARGINSENSITIVEN, 2, 1);

	if (props.GetInt("fold.use.plus")) {
		SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPEN, SC_MARK_MINUS);
		SendEditor(SCI_MARKERSETFORE, SC_MARKNUM_FOLDEROPEN, Colour(0xff, 0xff, 0xff).AsLong());
		SendEditor(SCI_MARKERSETBACK, SC_MARKNUM_FOLDEROPEN, Colour(0, 0, 0).AsLong());
		SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDER, SC_MARK_PLUS);
		SendEditor(SCI_MARKERSETFORE, SC_MARKNUM_FOLDER, Colour(0xff, 0xff, 0xff).AsLong());
		SendEditor(SCI_MARKERSETBACK, SC_MARKNUM_FOLDER, Colour(0, 0, 0).AsLong());
	} else {
		SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPEN, SC_MARK_ARROWDOWN);
		SendEditor(SCI_MARKERSETFORE, SC_MARKNUM_FOLDEROPEN, Colour(0, 0, 0).AsLong());
		SendEditor(SCI_MARKERSETBACK, SC_MARKNUM_FOLDEROPEN, Colour(0, 0, 0).AsLong());
		SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDER, SC_MARK_ARROW);
		SendEditor(SCI_MARKERSETFORE, SC_MARKNUM_FOLDER, Colour(0, 0, 0).AsLong());
		SendEditor(SCI_MARKERSETBACK, SC_MARKNUM_FOLDER, Colour(0, 0, 0).AsLong());
	}
	if (extender) {
		extender->Clear();

		char defaultDir[MAX_PATH];
		GetDefaultDirectory(defaultDir, sizeof(defaultDir));
		char scriptPath[MAX_PATH];
		if (Exists(defaultDir, "SciTEGlobal.lua", scriptPath)) {
			// Found fglobal file in global directory
			extender->Load(scriptPath);
		}

		// Check for an extension script
		SString extensionFile = props.GetNewExpand("extension.", fileNameForExtension.c_str());
		if (extensionFile.length()) {
			// find file in local directory
			char docDir[MAX_PATH];
			GetDocumentDirectory(docDir, sizeof(docDir));
			if (Exists(docDir, extensionFile.c_str(), scriptPath)) {
				// Found file in document directory
				extender->Load(scriptPath);
			} else if (Exists(defaultDir, extensionFile.c_str(), scriptPath)) {
				// Found file in global directory
				extender->Load(scriptPath);
			} else if (Exists("", extensionFile.c_str(), scriptPath)) {
				// Found as completely specified file name
				extender->Load(scriptPath);
			}
		}
	}

	firstPropertiesRead = false;
	//DWORD dwEnd = timeGetTime();
	//Platform::DebugPrintf("Properties read took %d\n", dwEnd - dwStart);
}

// Properties that are interactively modifiable are only read from the properties file once.

void SciTEBase::ReadPropertiesInitial() {
	splitVertical = props.GetInt("split.vertical");
	int sizeHorizontal = props.GetInt("output.horizontal.size", 0);
	int sizeVertical = props.GetInt("output.vertical.size", 0);
	if (splitVertical && sizeVertical > 0 && heightOutput < sizeVertical || sizeHorizontal && heightOutput < sizeHorizontal) {
		heightOutput = NormaliseSplit(splitVertical ? sizeHorizontal : sizeVertical);
		SizeSubWindows();
		Redraw();
	}
	indentationWSVisible = props.GetInt("view.indentation.whitespace", 1);
	ViewWhitespace(props.GetInt("view.whitespace"));
	SendEditor(SCI_SETINDENTATIONGUIDES, props.GetInt("view.indentation.guides"));
	SendEditor(SCI_SETVIEWEOL, props.GetInt("view.eol"));

	sbVisible = props.GetInt("statusbar.visible");
	tbVisible = props.GetInt("toolbar.visible");
	tabVisible = props.GetInt("tabbar.visible");
	tabMultiLine = props.GetInt("tabbar.multiline");
#if PLAT_WIN
	if (tabMultiLine) {	// Windows specific!
		long wl = ::GetWindowLong(wTabBar.GetID(), GWL_STYLE);
		::SetWindowLong(wTabBar.GetID(), GWL_STYLE, wl | TCS_MULTILINE);
	}
#endif

	lineNumbersWidth = 0;
	SString linenums = props.Get("line.numbers");
	if (linenums.length())
		lineNumbersWidth = linenums.value();
	lineNumbers = lineNumbersWidth;
	if (lineNumbersWidth == 0)
		lineNumbersWidth = lineNumbersWidthDefault;

	marginWidth = 0;
	SString margwidth = props.Get("margin.width");
	if (margwidth.length())
		marginWidth = margwidth.value();
	margin = marginWidth;
	if (marginWidth == 0)
		marginWidth = marginWidthDefault;

	foldMarginWidth = props.GetInt("fold.margin.width", foldMarginWidthDefault);
	foldMargin = foldMarginWidth;
	if (foldMarginWidth == 0)
		foldMarginWidth = foldMarginWidthDefault;

	char homepath[MAX_PATH + 20];
	if (GetSciteDefaultHome(homepath, sizeof(homepath))) {
		props.Set("SciteDefaultHome", homepath);
	}
	if (GetSciteUserHome(homepath, sizeof(homepath))) {
		props.Set("SciteUserHome", homepath);
	}
}

void SciTEBase::OpenProperties(int propsFile) {
	char propfile[MAX_PATH + 20];
	char propdir[MAX_PATH + 20];
	if (propsFile == IDM_OPENLOCALPROPERTIES) {
		GetDocumentDirectory(propfile, sizeof(propfile));
#ifdef __vms
		strcpy(propfile, VMSToUnixStyle(propfile));
#endif
		strcat(propfile, pathSepString);
		strcat(propfile, propFileName);
		Open(propfile);
	} else if (propsFile == IDM_OPENUSERPROPERTIES) {
		if (GetUserPropertiesFileName(propfile, propdir, sizeof(propfile))) {
			Open(propfile);
		}
	} else {	// IDM_OPENGLOBALPROPERTIES
		if (GetDefaultPropertiesFileName(propfile, propdir, sizeof(propfile))) {
			Open(propfile);
		}
	}
}
