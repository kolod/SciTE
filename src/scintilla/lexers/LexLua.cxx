// Scintilla source code edit control
/** @file LexLua.cxx
 ** Lexer for Lua language.
 **
 ** Written by Paul Winwood.
 ** Folder by Alexey Yutkin.
 ** Modified by Marcos E. Wurzius & Philippe Lhoste
 **/

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

// Test for [=[ ... ]=] delimiters, returns 0 if it's only a [ or ],
// return 1 for [[ or ]], returns >=2 for [=[ or ]=] and so on.
// The maximum number of '=' characters allowed is 254.
static int LongDelimCheck(StyleContext &sc) {
	int sep = 1;
	while (sc.GetRelative(sep) == '=' && sep < 0xFF)
		sep++;
	if (sc.GetRelative(sep) == sc.ch)
		return sep;
	return 0;
}

static void ColouriseLuaDoc(
	unsigned int startPos,
	int length,
	int initStyle,
	WordList *keywordlists[],
	Accessor &styler) {

	WordList &keywords = *keywordlists[0];
	WordList &keywords2 = *keywordlists[1];
	WordList &keywords3 = *keywordlists[2];
	WordList &keywords4 = *keywordlists[3];
	WordList &keywords5 = *keywordlists[4];
	WordList &keywords6 = *keywordlists[5];
	WordList &keywords7 = *keywordlists[6];
	WordList &keywords8 = *keywordlists[7];

	// Accepts accented characters
	CharacterSet setWordStart(CharacterSet::setAlpha, "_", 0x80, true);
//!	CharacterSet setWord(CharacterSet::setAlphaNum, "._", 0x80, true);
	CharacterSet setWord(CharacterSet::setAlphaNum, "_", 0x80, true); //!-change-[LuaLexerImprovement]
	// Not exactly following number definition (several dots are seen as OK, etc.)
	// but probably enough in most cases. [pP] is for hex floats.
	CharacterSet setNumber(CharacterSet::setDigits, ".-+abcdefpABCDEFP");
	CharacterSet setExponent(CharacterSet::setNone, "eEpP");
	CharacterSet setLuaOperator(CharacterSet::setNone, "*/-+()={}~[];<>,.^%:#");
	CharacterSet setEscapeSkip(CharacterSet::setNone, "\"'\\");

//!-start-[LuaLexerImprovement]
	// if stay on identifier or operator then go back to start of object
	while (startPos > 1 && (
		initStyle == SCE_LUA_WORD ||
		initStyle == SCE_LUA_OPERATOR ||
		initStyle == SCE_LUA_IDENTIFIER ||
		(initStyle >= SCE_LUA_WORD2 && initStyle <= SCE_LUA_WORD8)))
	{
		startPos--;
		initStyle = styler.StyleAt(startPos-1);
	}
//!-end-[LuaLexerImprovement]

	int currentLine = styler.GetLine(startPos);
	// Initialize long string [[ ... ]] or block comment --[[ ... ]] nesting level,
	// if we are inside such a string. Block comment was introduced in Lua 5.0,
	// blocks with separators [=[ ... ]=] in Lua 5.1.
	// Continuation of a string (\* whitespace escaping) is controlled by stringWs.
	int nestLevel = 0;
	int sepCount = 0;
	int stringWs = 0;
	if (initStyle == SCE_LUA_LITERALSTRING || initStyle == SCE_LUA_COMMENT ||
		initStyle == SCE_LUA_STRING || initStyle == SCE_LUA_CHARACTER) {
		int lineState = styler.GetLineState(currentLine - 1);
		nestLevel = lineState >> 9;
		sepCount = lineState & 0xFF;
		stringWs = lineState & 0x100;
	}

	// Do not leak onto next line
	if (initStyle == SCE_LUA_STRINGEOL || initStyle == SCE_LUA_COMMENTLINE || initStyle == SCE_LUA_PREPROCESSOR) {
		initStyle = SCE_LUA_DEFAULT;
	}

//!	StyleContext sc(startPos, length, initStyle, styler);
//!-start-[LuaLexerImprovement]
	unsigned int objectPartEndPos = 0;
	bool isObject = false;
	bool isObjectStart = false;
	bool isSubObject = false;
	char sChar = 0;
	class StyleContextEx : public StyleContext
	{
	public:
		StyleContextEx( unsigned int startPos,
						unsigned int length,
						int initStyle,
						LexAccessor &styler_ )
		: StyleContext( startPos, length, initStyle, styler_)
		, endPosEx( startPos + length )
		, stylerEx( styler_ )
		{
		}
		void MoveTo(unsigned int pos) {
			if (pos < endPosEx) {
				pos--;
				currentPos = pos;
				chPrev = 0;
				ch = static_cast<unsigned char>(stylerEx.SafeGetCharAt(pos));
				if (stylerEx.IsLeadByte(static_cast<char>(ch))) {
					pos++;
					ch = ch << 8;
					ch |= static_cast<unsigned char>(stylerEx.SafeGetCharAt(pos));
				}
				chNext = static_cast<unsigned char>(stylerEx.SafeGetCharAt(pos+1));
				if (stylerEx.IsLeadByte(static_cast<char>(chNext))) {
					chNext = chNext << 8;
					chNext |= static_cast<unsigned char>(stylerEx.SafeGetCharAt(pos+2));
				}
				// End of line?
				// Trigger on CR only (Mac style) or either on LF from CR+LF (Dos/Win)
				// or on LF alone (Unix). Avoid triggering two times on Dos/Win.
				atLineEnd = (ch == '\r' && chNext != '\n') ||
							(ch == '\n') ||
							(currentPos >= endPosEx);
				Forward();
			} else {
				currentPos = endPosEx;
				atLineStart = false;
				chPrev = ' ';
				ch = ' ';
				chNext = ' ';
				atLineEnd = true;
			}
		}
	private:
		unsigned int endPosEx;
		LexAccessor &stylerEx;
	};
	StyleContextEx sc(startPos, length, initStyle, styler);
//!-end-[LuaLexerImprovement]
	if (startPos == 0 && sc.ch == '#') {
		// shbang line: # is a comment only if first char of the script
		sc.SetState(SCE_LUA_COMMENTLINE);
	}
//!	for (; sc.More(); sc.Forward()) {
	for (bool doing = sc.More(); doing; doing = sc.More(), sc.Forward()) { //!-change-[LexersLastWordFix]
		if (sc.atLineEnd) {
			// Update the line state, so it can be seen by next line
			currentLine = styler.GetLine(sc.currentPos);
			switch (sc.state) {
			case SCE_LUA_LITERALSTRING:
			case SCE_LUA_COMMENT:
			case SCE_LUA_STRING:
			case SCE_LUA_CHARACTER:
				// Inside a literal string, block comment or string, we set the line state
				styler.SetLineState(currentLine, (nestLevel << 9) | stringWs | sepCount);
				break;
			default:
				// Reset the line state
				styler.SetLineState(currentLine, 0);
				break;
			}
		}
		if (sc.atLineStart && (sc.state == SCE_LUA_STRING)) {
			// Prevent SCE_LUA_STRINGEOL from leaking back to previous line
			sc.SetState(SCE_LUA_STRING);
		}

		// Handle string line continuation
		if ((sc.state == SCE_LUA_STRING || sc.state == SCE_LUA_CHARACTER) &&
				sc.ch == '\\') {
			if (sc.chNext == '\n' || sc.chNext == '\r') {
				sc.Forward();
				if (sc.ch == '\r' && sc.chNext == '\n') {
					sc.Forward();
				}
				continue;
			}
		}

		// Determine if the current state should terminate.
		if (sc.state == SCE_LUA_OPERATOR) {
			sc.SetState(SCE_LUA_DEFAULT);
		} else if (sc.state == SCE_LUA_NUMBER) {
			// We stop the number definition on non-numerical non-dot non-eEpP non-sign non-hexdigit char
			if (!setNumber.Contains(sc.ch)) {
				sc.SetState(SCE_LUA_DEFAULT);
			} else if (sc.ch == '-' || sc.ch == '+') {
				if (!setExponent.Contains(sc.chPrev))
					sc.SetState(SCE_LUA_DEFAULT);
			}
//!		} else if (sc.state == SCE_LUA_IDENTIFIER) {
//!			if (!setWord.Contains(sc.ch) || sc.Match('.', '.')) {
//!-start-[LuaLexerImprovement]
		} else if (sc.state == SCE_LUA_IDENTIFIER
				|| sc.state == SCE_LUA_WORD
				|| sc.state == SCE_LUA_WORD2
				|| sc.state == SCE_LUA_WORD3
				|| sc.state == SCE_LUA_WORD4
				|| sc.state == SCE_LUA_WORD5
				|| sc.state == SCE_LUA_WORD6
				|| sc.state == SCE_LUA_WORD7
				|| sc.state == SCE_LUA_WORD8) {
			if (!setWord.Contains(sc.ch)) {
				bool isFin;
				if ((sc.ch == ':' || sc.ch == '.') && setWordStart.Contains(sc.chNext)) {
					// continue with object fields
					if (!isObject) {
						isObject = true;
						isObjectStart = true;
						objectPartEndPos = sc.currentPos;
						continue;
					}
					isFin = false;
				} else {
					isFin = true;
				}
//!-end-[LuaLexerImprovement]
				char s[100];
				sc.GetCurrent(s, sizeof(s));
				if (keywords.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD);
				} else if (keywords2.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD2);
				} else if (keywords3.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD3);
				} else if (keywords4.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD4);
				} else if (keywords5.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD5);
				} else if (keywords6.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD6);
				} else if (keywords7.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD7);
				} else if (keywords8.InList(s)) {
					sc.ChangeState(SCE_LUA_WORD8);
//!-start-[LuaLexerImprovement]
				} else if (isObject || isSubObject) {
					// colourise objects part separately
					if (isObject) {
						int currPos = sc.currentPos;
						sc.MoveTo(objectPartEndPos);
						if (isObjectStart) {
							sc.GetCurrent(s, sizeof(s));
							if (keywords.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD);
							} else if (keywords2.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD2);
							} else if (keywords3.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD3);
							} else if (keywords4.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD4);
							} else if (keywords5.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD5);
							} else if (keywords6.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD6);
							} else if (keywords7.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD7);
							} else if (keywords8.InList(s)) {
								sc.ChangeState(SCE_LUA_WORD8);
							}
							isObjectStart = false;
						}
						sc.SetState(SCE_LUA_OPERATOR);
						s[0] = static_cast<char>(sc.ch);
						sc.Forward();
						sc.SetState(SCE_LUA_IDENTIFIER);
						sc.MoveTo(currPos);
					} else {
						s[0] = sChar;
					}
					sc.GetCurrent(s + 1, sizeof(s) - 1);
					if (keywords.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD);
					} else if (keywords2.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD2);
					} else if (keywords3.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD3);
					} else if (keywords4.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD4);
					} else if (keywords5.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD5);
					} else if (keywords6.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD6);
					} else if (keywords7.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD7);
					} else if (keywords8.InList(s)) {
						sc.ChangeState(SCE_LUA_WORD8);
					}
					objectPartEndPos = sc.currentPos;
//!-end-[LuaLexerImprovement]
				}
//!-start-[LuaLexerImprovement]
				if (isFin) {
					isObject = false;
//!-end-[LuaLexerImprovement]
					sc.SetState(SCE_LUA_DEFAULT);
				}//!-add-[LuaLexerImprovement]
			}
		} else if (sc.state == SCE_LUA_COMMENTLINE || sc.state == SCE_LUA_PREPROCESSOR) {
			if (sc.atLineEnd) {
				sc.ForwardSetState(SCE_LUA_DEFAULT);
			}
		} else if (sc.state == SCE_LUA_STRING) {
			if (stringWs) {
				if (!IsASpace(sc.ch))
					stringWs = 0;
			}
			if (sc.ch == '\\') {
				if (setEscapeSkip.Contains(sc.chNext)) {
					sc.Forward();
				} else if (sc.chNext == '*') {
					sc.Forward();
					stringWs = 0x100;
				}
			} else if (sc.ch == '\"') {
				sc.ForwardSetState(SCE_LUA_DEFAULT);
			} else if (stringWs == 0 && sc.atLineEnd) {
				sc.ChangeState(SCE_LUA_STRINGEOL);
				sc.ForwardSetState(SCE_LUA_DEFAULT);
			}
		} else if (sc.state == SCE_LUA_CHARACTER) {
			if (stringWs) {
				if (!IsASpace(sc.ch))
					stringWs = 0;
			}
			if (sc.ch == '\\') {
				if (setEscapeSkip.Contains(sc.chNext)) {
					sc.Forward();
				} else if (sc.chNext == '*') {
					sc.Forward();
					stringWs = 0x100;
				}
			} else if (sc.ch == '\'') {
				sc.ForwardSetState(SCE_LUA_DEFAULT);
			} else if (stringWs == 0 && sc.atLineEnd) {
				sc.ChangeState(SCE_LUA_STRINGEOL);
				sc.ForwardSetState(SCE_LUA_DEFAULT);
			}
		} else if (sc.state == SCE_LUA_LITERALSTRING || sc.state == SCE_LUA_COMMENT) {
			if (sc.ch == '[') {
				int sep = LongDelimCheck(sc);
				if (sep == 1 && sepCount == 1) {    // [[-only allowed to nest
					nestLevel++;
					sc.Forward();
				}
			} else if (sc.ch == ']') {
				int sep = LongDelimCheck(sc);
				if (sep == 1 && sepCount == 1) {    // un-nest with ]]-only
					nestLevel--;
					sc.Forward();
					if (nestLevel == 0) {
						sc.ForwardSetState(SCE_LUA_DEFAULT);
					}
				} else if (sep > 1 && sep == sepCount) {   // ]=]-style delim
					sc.Forward(sep);
					sc.ForwardSetState(SCE_LUA_DEFAULT);
				}
			}
		}

		// Determine if a new state should be entered.
		if (sc.state == SCE_LUA_DEFAULT) {
			if (IsADigit(sc.ch) || (sc.ch == '.' && IsADigit(sc.chNext))) {
				sc.SetState(SCE_LUA_NUMBER);
				if (sc.ch == '0' && toupper(sc.chNext) == 'X') {
					sc.Forward();
				}
			} else if (setWordStart.Contains(sc.ch)) {
				sc.SetState(SCE_LUA_IDENTIFIER);
			} else if (sc.ch == '\"') {
				sc.SetState(SCE_LUA_STRING);
				stringWs = 0;
			} else if (sc.ch == '\'') {
				sc.SetState(SCE_LUA_CHARACTER);
				stringWs = 0;
			} else if (sc.ch == '[') {
				sepCount = LongDelimCheck(sc);
				if (sepCount == 0) {
					sc.SetState(SCE_LUA_OPERATOR);
				} else {
					nestLevel = 1;
					sc.SetState(SCE_LUA_LITERALSTRING);
					sc.Forward(sepCount);
				}
			} else if (sc.Match('-', '-')) {
				sc.SetState(SCE_LUA_COMMENTLINE);
				if (sc.Match("--[")) {
					sc.Forward(2);
					sepCount = LongDelimCheck(sc);
					if (sepCount > 0) {
						nestLevel = 1;
						sc.ChangeState(SCE_LUA_COMMENT);
						sc.Forward(sepCount);
					}
				} else {
					sc.Forward();
				}
			} else if (sc.atLineStart && sc.Match('$')) {
				sc.SetState(SCE_LUA_PREPROCESSOR);	// Obsolete since Lua 4.0, but still in old code
			} else if (setLuaOperator.Contains(sc.ch)) {
				sc.SetState(SCE_LUA_OPERATOR);
			}
//!-start-[LuaLexerImprovement]
			if (sc.ch == ')' || sc.ch == ']') {
				isSubObject = true;
			}
			else {
				if (isSubObject && sc.state != SCE_LUA_IDENTIFIER) {
					if (setWordStart.Contains(sc.chNext) && (sc.ch == '.' || sc.ch == ':'))
						sChar = static_cast<char>(sc.ch);
					else
						isSubObject = false;
				}
			}
//!-end-[LuaLexerImprovement]
		}
	}

/*!-remove-[LexersLastWordFix]
	if (setWord.Contains(sc.chPrev)) {
		char s[100];
		sc.GetCurrent(s, sizeof(s));
		if (keywords.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD);
		} else if (keywords2.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD2);
		} else if (keywords3.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD3);
		} else if (keywords4.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD4);
		} else if (keywords5.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD5);
		} else if (keywords6.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD6);
		} else if (keywords7.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD7);
		} else if (keywords8.InList(s)) {
			sc.ChangeState(SCE_LUA_WORD8);
		}
	}
*/

	sc.Complete();
}

static void FoldLuaDoc(unsigned int startPos, int length, int /* initStyle */, WordList *[],
                       Accessor &styler) {
	unsigned int lengthDoc = startPos + length;
	int visibleChars = 0;
	int lineCurrent = styler.GetLine(startPos);
	int levelPrev = styler.LevelAt(lineCurrent) & SC_FOLDLEVELNUMBERMASK;
	int levelCurrent = levelPrev;
	char chNext = styler[startPos];
	bool foldCompact = styler.GetPropertyInt("fold.compact", 1) != 0;
	int styleNext = styler.StyleAt(startPos);
	char s[10];

	for (unsigned int i = startPos; i < lengthDoc; i++) {
		char ch = chNext;
		chNext = styler.SafeGetCharAt(i + 1);
		int style = styleNext;
		styleNext = styler.StyleAt(i + 1);
		bool atEOL = (ch == '\r' && chNext != '\n') || (ch == '\n');
		if (style == SCE_LUA_WORD) {
			if (ch == 'i' || ch == 'd' || ch == 'f' || ch == 'e' || ch == 'r' || ch == 'u') {
				for (unsigned int j = 0; j < 8; j++) {
					if (!iswordchar(styler[i + j])) {
						break;
					}
					s[j] = styler[i + j];
					s[j + 1] = '\0';
				}

				if ((strcmp(s, "if") == 0) || (strcmp(s, "do") == 0) || (strcmp(s, "function") == 0) || (strcmp(s, "repeat") == 0)) {
					levelCurrent++;
				}
				if ((strcmp(s, "end") == 0) || (strcmp(s, "elseif") == 0) || (strcmp(s, "until") == 0)) {
					levelCurrent--;
				}
			}
		} else if (style == SCE_LUA_OPERATOR) {
			if (ch == '{' || ch == '(') {
				levelCurrent++;
			} else if (ch == '}' || ch == ')') {
				levelCurrent--;
			}
		} else if (style == SCE_LUA_LITERALSTRING || style == SCE_LUA_COMMENT) {
			if (ch == '[') {
				levelCurrent++;
			} else if (ch == ']') {
				levelCurrent--;
			}
		}

		if (atEOL) {
			int lev = levelPrev;
			if (visibleChars == 0 && foldCompact) {
				lev |= SC_FOLDLEVELWHITEFLAG;
			}
			if ((levelCurrent > levelPrev) && (visibleChars > 0)) {
				lev |= SC_FOLDLEVELHEADERFLAG;
			}
			if (lev != styler.LevelAt(lineCurrent)) {
				styler.SetLevel(lineCurrent, lev);
			}
			lineCurrent++;
//!-start-[LexersFoldFix]
			if ((levelCurrent & SC_FOLDLEVELNUMBERMASK) < SC_FOLDLEVELBASE)
				levelCurrent = SC_FOLDLEVELBASE;
//!-end-[LexersFoldFix]
			levelPrev = levelCurrent;
			visibleChars = 0;
		}
		if (!isspacechar(ch)) {
			visibleChars++;
		}
	}
	// Fill in the real level of the next line, keeping the current flags as they will be filled in later

	int flagsNext = styler.LevelAt(lineCurrent) & ~SC_FOLDLEVELNUMBERMASK;
	styler.SetLevel(lineCurrent, levelPrev | flagsNext);
}

static const char * const luaWordListDesc[] = {
	"Keywords",
	"Basic functions",
	"String, (table) & math functions",
	"(coroutines), I/O & system facilities",
	"user1",
	"user2",
	"user3",
	"user4",
	0
};

LexerModule lmLua(SCLEX_LUA, ColouriseLuaDoc, "lua", FoldLuaDoc, luaWordListDesc);
