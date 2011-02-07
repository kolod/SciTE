// Scintilla source code edit control
/** @file LexInno.cxx
 ** Lexer for Inno Setup scripts.
 **/
// Written by Friedrich Vedder <fvedd@t-online.de>, using code from LexOthers.cxx.
// The License.txt file describes the conditions under which this software may be distributed.

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>

#include "ILexer.h"
#include "Scintilla.h"
#include "SciLexer.h"

#include "WordList.h"
#include "LexAccessor.h"
#include "Accessor.h"
#include "StyleContext.h"
#include "CharacterSet.h"
#include "LexerModule.h"

#ifdef SCI_NAMESPACE
using namespace Scintilla;
#endif

//!-start-[update.inno]
static int findCodeSection(Accessor &styler, int length) {
	int state = SCE_INNO_DEFAULT;
	char chPrev = 0;
	char ch = 0;
	char chNext = styler[0];
	bool isBOL, isEOL, isWS, isBOLWS = 0;
	int bufferCount = 0;
	char buffer[10] = {0,0,0,0,0,0,0,0,0,0};

	for (int i = 0; i < length; i++) {
		chPrev = ch;
		ch = chNext;
		chNext = styler.SafeGetCharAt(i + 1);

		if (styler.IsLeadByte(ch)) {
			chNext = styler.SafeGetCharAt(i + 2);
			i++;
			continue;
		}

		isBOL = (chPrev == 0) || (chPrev == '\n') || (chPrev == '\r' && ch != '\n');
		isBOLWS = (isBOL) ? 1 : (isBOLWS && (chPrev == ' ' || chPrev == '\t'));
		isEOL = (ch == '\n' || ch == '\r');
		isWS = (ch == ' ' || ch == '\t');

		switch(state) {
			case SCE_INNO_DEFAULT:
				if (ch == ';' && isBOLWS) {
					// Start of a comment
					state = SCE_INNO_COMMENT;
				} else if (ch == '[' && isBOLWS) {
					// Start of a section name
					bufferCount = 0;
					state = SCE_INNO_SECTION;
				} else if (ch == '#' && isBOLWS) {
					// Start of a preprocessor directive
					state = SCE_INNO_PREPROC;
				} else if (ch == '{' && chNext != '{' && chPrev != '{') {
					// Start of an inline expansion
					state = SCE_INNO_INLINE_EXPANSION;
				} else if (ch == '"') {
					// Start of a double-quote string
					state = SCE_INNO_STRING_DOUBLE;
				} else if (ch == '\'') {
					// Start of a single-quote string
					state = SCE_INNO_STRING_SINGLE;
				} else if (isascii(ch) && (isalpha(ch) || (ch == '_'))) {
					// Start of an identifier
					state = SCE_INNO_IDENTIFIER;
				}
				break;

			case SCE_INNO_COMMENT:
				if (isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_IDENTIFIER:
				if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
				} else {
					state = SCE_INNO_DEFAULT;
					// Push back the faulty character
					chNext = styler[i--];
					ch = chPrev;
				}
				break;

			case SCE_INNO_SECTION:
				if (ch == ']') {
					state = SCE_INNO_DEFAULT;
					buffer[bufferCount] = '\0';
					bufferCount = 0;
					bool isCode = !CompareCaseInsensitive(buffer, "code");
					if ( isCode ) return i;
				} else if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
					if (bufferCount<10){
						buffer[bufferCount++] = static_cast<char>(tolower(ch));
					}
				} else {
					state = SCE_INNO_DEFAULT;
					bufferCount = 0;
				}
				break;

			case SCE_INNO_PREPROC:
				if (isWS || isEOL) {
					if (isascii(chPrev) && isalpha(chPrev)) {
						state = SCE_INNO_DEFAULT;
						// Push back the faulty character
						chNext = styler[i--];
						ch = chPrev;
					}
				}
				break;

			case SCE_INNO_STRING_DOUBLE:
				if (ch == '"' || isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_STRING_SINGLE:
				if (ch == '\'' || isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_INLINE_EXPANSION:
				if (ch == '}') {
					state = SCE_INNO_DEFAULT;
				} else if (isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;
		}
	}
	return -1;
}

static int findSectionAfterCode(Accessor &styler, int codesectionposstart, int posend) {
	int state = SCE_INNO_DEFAULT;
	char chPrev = 0;
	char ch = 0;
	char chNext = styler[codesectionposstart];
	bool isBOL, isEOL, isWS, isBOLWS = 0;
	bool isCStyleComment = false;

	for (int i = codesectionposstart; i < posend; i++) {
		chPrev = ch;
		ch = chNext;
		chNext = styler.SafeGetCharAt(i + 1);

		if (styler.IsLeadByte(ch)) {
			chNext = styler.SafeGetCharAt(i + 2);
			i++;
			continue;
		}

		isBOL = (chPrev == 0) || (chPrev == '\n') || (chPrev == '\r' && ch != '\n');
		isBOLWS = (isBOL) ? 1 : (isBOLWS && (chPrev == ' ' || chPrev == '\t'));
		isEOL = (ch == '\n' || ch == '\r');
		isWS = (ch == ' ' || ch == '\t');

		switch(state) {
			case SCE_INNO_DEFAULT:
				if (ch == '[' && isBOLWS) {
					state = SCE_INNO_SECTION;
				} else if (ch == '{' || (ch == '(' && chNext == '*')) {
					// Start of a Pascal comment
					state = SCE_INNO_COMMENT_PASCAL;
					isCStyleComment = false;
				} else if (ch == '/' && chNext == '/') {
					// Apparently, C-style comments are legal, too
					state = SCE_INNO_COMMENT_PASCAL;
					isCStyleComment = true;
				} else if (ch == '"') {
					// Start of a double-quote string
					state = SCE_INNO_STRING_DOUBLE;
				} else if (ch == '\'') {
					// Start of a single-quote string
					state = SCE_INNO_STRING_SINGLE;
				} else if (isascii(ch) && (isalpha(ch) || (ch == '_'))) {
					// Start of an identifier
					state = SCE_INNO_IDENTIFIER;
				}
				break;

			case SCE_INNO_IDENTIFIER:
				if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
				} else {
					state = SCE_INNO_DEFAULT;
					// Push back the faulty character
					chNext = styler[i--];
					ch = chPrev;
				}
				break;

			case SCE_INNO_SECTION:
				if (ch == ']') {
					state = SCE_INNO_DEFAULT;
					// section found
					return i;
				} else if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
				} else {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_STRING_DOUBLE:
				if (ch == '"' || isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_STRING_SINGLE:
				if (ch == '\'' || isEOL) {
					state = SCE_INNO_DEFAULT;
				}
				break;

			case SCE_INNO_COMMENT_PASCAL:
				if (isCStyleComment) {
					if (isEOL) {
						state = SCE_INNO_DEFAULT;
					}
				} else {
					if (ch == '}' || (ch == ')' && chPrev == '*')) {
						state = SCE_INNO_DEFAULT;
					}
				}
				break;
		}
	}
	return -1;
}
//!-end-[update.inno]

static void ColouriseInnoDoc(unsigned int startPos, int length, int, WordList *keywordLists[], Accessor &styler) {
	int state = SCE_INNO_DEFAULT;
	char chPrev;
	char ch = 0;
	char chNext = styler[startPos];
	int lengthDoc = startPos + length;
	char *buffer = new char[length];
	int bufferCount = 0;
	bool isBOL, isEOL, isWS, isBOLWS = 0;
	bool isCode = false;
	bool isCStyleComment = false;

	WordList &sectionKeywords = *keywordLists[0];
	WordList &standardKeywords = *keywordLists[1];
	WordList &parameterKeywords = *keywordLists[2];
	WordList &preprocessorKeywords = *keywordLists[3];
	WordList &pascalKeywords = *keywordLists[4];
	WordList &userKeywords = *keywordLists[5];

	//!-start-[update.inno]
	int codePos = findCodeSection(styler, lengthDoc);
	int sectionPosAfterCode = findSectionAfterCode(styler, codePos, lengthDoc);
	//!-end-[update.inno]

	// Go through all provided text segment
	// using the hand-written state machine shown below
	styler.StartAt(startPos);
	styler.StartSegment(startPos);
	for (int i = startPos; i < lengthDoc; i++) {
		chPrev = ch;
		ch = chNext;
		chNext = styler.SafeGetCharAt(i + 1);

		if (styler.IsLeadByte(ch)) {
			chNext = styler.SafeGetCharAt(i + 2);
			i++;
			continue;
		}

		isBOL = (chPrev == 0) || (chPrev == '\n') || (chPrev == '\r' && ch != '\n');
		isBOLWS = (isBOL) ? 1 : (isBOLWS && (chPrev == ' ' || chPrev == '\t'));
		isEOL = (ch == '\n' || ch == '\r');
		isWS = (ch == ' ' || ch == '\t');
		isCode = (codePos >= 0) && (codePos < i) && (sectionPosAfterCode == -1 || sectionPosAfterCode > i); //!-add-[update.inno]

		switch(state) {
			case SCE_INNO_DEFAULT:
				if (!isCode && ch == ';' && isBOLWS) {
					// Start of a comment
					state = SCE_INNO_COMMENT;
				} else if (ch == '[' && isBOLWS) {
					// Start of a section name
					bufferCount = 0;
					state = SCE_INNO_SECTION;
				} else if (ch == '#' && isBOLWS) {
					// Start of a preprocessor directive
					state = SCE_INNO_PREPROC;
				} else if (!isCode && ch == '{' && chNext != '{' && chPrev != '{') {
					// Start of an inline expansion
					state = SCE_INNO_INLINE_EXPANSION;
				} else if (isCode && (ch == '{' || (ch == '(' && chNext == '*'))) {
					// Start of a Pascal comment
					state = SCE_INNO_COMMENT_PASCAL;
					isCStyleComment = false;
				} else if (isCode && ch == '/' && chNext == '/') {
					// Apparently, C-style comments are legal, too
					state = SCE_INNO_COMMENT_PASCAL;
					isCStyleComment = true;
				} else if (ch == '"') {
					// Start of a double-quote string
					state = SCE_INNO_STRING_DOUBLE;
				} else if (ch == '\'') {
					// Start of a single-quote string
					state = SCE_INNO_STRING_SINGLE;
				} else if (isascii(ch) && (isalpha(ch) || (ch == '_'))) {
					// Start of an identifier
					bufferCount = 0;
					buffer[bufferCount++] = static_cast<char>(tolower(ch));
					state = SCE_INNO_IDENTIFIER;
				} else {
					// Style it the default style
					styler.ColourTo(i,SCE_INNO_DEFAULT);
				}
				break;

			case SCE_INNO_COMMENT:
				if (isEOL) {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_COMMENT);
				}
				break;

			case SCE_INNO_IDENTIFIER:
				if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
					buffer[bufferCount++] = static_cast<char>(tolower(ch));
				} else {
					state = SCE_INNO_DEFAULT;
					buffer[bufferCount] = '\0';

					// Check if the buffer contains a keyword
					if (!isCode && standardKeywords.InList(buffer)) {
						styler.ColourTo(i-1,SCE_INNO_KEYWORD);
					} else if (!isCode && parameterKeywords.InList(buffer)) {
						styler.ColourTo(i-1,SCE_INNO_PARAMETER);
					} else if (isCode && pascalKeywords.InList(buffer)) {
						styler.ColourTo(i-1,SCE_INNO_KEYWORD_PASCAL);
					} else if (!isCode && userKeywords.InList(buffer)) {
						styler.ColourTo(i-1,SCE_INNO_KEYWORD_USER);
					} else {
						styler.ColourTo(i-1,SCE_INNO_DEFAULT);
					}

					// Push back the faulty character
					chNext = styler[i--];
					ch = chPrev;
				}
				break;

			case SCE_INNO_SECTION:
				if (ch == ']') {
					state = SCE_INNO_DEFAULT;
					buffer[bufferCount] = '\0';

					// Check if the buffer contains a section name
					if (sectionKeywords.InList(buffer)) {
						styler.ColourTo(i,SCE_INNO_SECTION);
//!						isCode = !CompareCaseInsensitive(buffer, "code");//!-remove-[update.inno]
					} else {
						styler.ColourTo(i,SCE_INNO_DEFAULT);
					}
				} else if (isascii(ch) && (isalnum(ch) || (ch == '_'))) {
					buffer[bufferCount++] = static_cast<char>(tolower(ch));
				} else {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_DEFAULT);
				}
				break;

			case SCE_INNO_PREPROC:
				if (isWS || isEOL) {
					if (isascii(chPrev) && isalpha(chPrev)) {
						state = SCE_INNO_DEFAULT;
						buffer[bufferCount] = '\0';

						// Check if the buffer contains a preprocessor directive
						if (preprocessorKeywords.InList(buffer)) {
							styler.ColourTo(i-1,SCE_INNO_PREPROC);
						} else {
							styler.ColourTo(i-1,SCE_INNO_DEFAULT);
						}

						// Push back the faulty character
						chNext = styler[i--];
						ch = chPrev;
					}
				} else if (isascii(ch) && isalpha(ch)) {
					if (chPrev == '#' || chPrev == ' ' || chPrev == '\t')
						bufferCount = 0;
					buffer[bufferCount++] = static_cast<char>(tolower(ch));
				}
				break;

			case SCE_INNO_STRING_DOUBLE:
				if (ch == '"' || isEOL) {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_STRING_DOUBLE);
				}
				break;

			case SCE_INNO_STRING_SINGLE:
				if (ch == '\'' || isEOL) {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_STRING_SINGLE);
				}
				break;

			case SCE_INNO_INLINE_EXPANSION:
				if (ch == '}') {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_INLINE_EXPANSION);
				} else if (isEOL) {
					state = SCE_INNO_DEFAULT;
					styler.ColourTo(i,SCE_INNO_DEFAULT);
				}
				break;

			case SCE_INNO_COMMENT_PASCAL:
				if (isCStyleComment) {
					if (isEOL) {
						state = SCE_INNO_DEFAULT;
						styler.ColourTo(i,SCE_INNO_COMMENT_PASCAL);
					}
				} else {
					if (ch == '}' || (ch == ')' && chPrev == '*')) {
						state = SCE_INNO_DEFAULT;
						styler.ColourTo(i,SCE_INNO_COMMENT_PASCAL);
					}/* else if (isEOL) {
						state = SCE_INNO_DEFAULT;
						styler.ColourTo(i,SCE_INNO_DEFAULT);
					}*/ //!-remove-[update.inno]
				}
				break;

		}
	}
	delete []buffer;
}

static const char * const innoWordListDesc[] = {
	"Sections",
	"Keywords",
	"Parameters",
	"Preprocessor directives",
	"Pascal keywords",
	"User defined keywords",
	0
};

static void FoldInnoDoc(unsigned int startPos, int length, int, WordList *[], Accessor &styler) {
	unsigned int endPos = startPos + length;
	char chNext = styler[startPos];

	int lineCurrent = styler.GetLine(startPos);

	bool sectionFlag = false;
	int levelPrev = lineCurrent > 0 ? styler.LevelAt(lineCurrent - 1) : SC_FOLDLEVELBASE;
	int level;

	for (unsigned int i = startPos; i < endPos; i++) {
		char ch = chNext;
		chNext = styler[i+1];
		bool atEOL = (ch == '\r' && chNext != '\n') || (ch == '\n');
		int style = styler.StyleAt(i);

		if (style == SCE_INNO_SECTION)
			sectionFlag = true;

		if (atEOL || i == endPos - 1) {
			if (sectionFlag) {
				level = SC_FOLDLEVELBASE | SC_FOLDLEVELHEADERFLAG;
				if (level == levelPrev)
					styler.SetLevel(lineCurrent - 1, levelPrev & ~SC_FOLDLEVELHEADERFLAG);
			} else {
				level = levelPrev & SC_FOLDLEVELNUMBERMASK;
				if (levelPrev & SC_FOLDLEVELHEADERFLAG)
					level++;
			}

			styler.SetLevel(lineCurrent, level);

			levelPrev = level;
			lineCurrent++;
			sectionFlag = false;
		}
	}
}

LexerModule lmInno(SCLEX_INNOSETUP, ColouriseInnoDoc, "inno", FoldInnoDoc, innoWordListDesc);
