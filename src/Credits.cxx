// SciTE - Scintilla based Text Editor
/** @file Credits.cxx
 ** Display a list of contributors in the about box.
 **/
// Copyright 1998-2011 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#include <cstddef>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <ctime>

#include <tuple>
#include <string>
#include <string_view>
#include <vector>
#include <map>
#include <set>
#include <memory>
#include <chrono>
#include <atomic>
#include <mutex>

#if defined(GTK)
#include <gtk/gtk.h>
#endif

#include "ILexer.h"

#include "ScintillaTypes.h"
#include "ScintillaCall.h"

#include "GUI.h"
#include "ScintillaWindow.h"
#include "StringList.h"
#include "StringHelpers.h"
#include "FilePath.h"
#include "StyleDefinition.h"
#include "PropSetFile.h"
#include "StyleWriter.h"
#include "Extender.h"
#include "SciTE.h"
#include "JobQueue.h"

#include "Cookie.h"
#include "Worker.h"
#include "MatchMarker.h"
#include "SciTEBase.h"

// Contributor names are in UTF-8
static const char *contributors[] = {
#if defined(GTK)
            "Icons Copyright(C) 1998 by Dean S. Jones",
            "    http://jfa.javalobby.org/projects/icons/",
#endif
//++Autogenerated -- run ../scripts/RegenerateSource.py to regenerate
//**\(            "\*",\n\)
            "Atsuo Ishimoto",
            "Mark Hammond",
            "Francois Le Coguiec",
            "Dale Nagata",
            "Ralf Reinhardt",
            "Philippe Lhoste",
            "Andrew McKinlay",
            "Stephan R. A. Deibel",
            "Hans Eckardt",
            "Vassili Bourdo",
            "Maksim Lin",
            "Robin Dunn",
            "John Ehresman",
            "Steffen Goeldner",
            "Deepak S.",
            "DevelopMentor http://www.develop.com",
            "Yann Gaillard",
            "Aubin Paul",
            "Jason Diamond",
            "Ahmad Baitalmal",
            "Paul Winwood",
            "Maxim Baranov",
            "Ragnar H\303\270jland",
            "Christian Obrecht",
            "Andreas Neukoetter",
            "Adam Gates",
            "Steve Lhomme",
            "Ferdinand Prantl",
            "Jan Dries",
            "Markus Gritsch",
            "Tahir Karaca",
            "Ahmad Zawawi",
            "Laurent le Tynevez",
            "Walter Braeu",
            "Ashley Cambrell",
            "Garrett Serack",
            "Holger Schmidt",
            "ActiveState http://www.activestate.com",
            "James Larcombe",
            "Alexey Yutkin",
            "Jan Hercek",
            "Richard Pecl",
            "Edward K. Ream",
            "Valery Kondakoff",
            "Sm\303\241ri McCarthy",
            "Clemens Wyss",
            "Simon Steele",
            "Serge A. Baranov",
            "Xavier Nodet",
            "Willy Devaux",
            "David Clain",
            "Brendon Yenson",
            "Vamsi Potluru http://www.baanboard.com",
            "Praveen Ambekar",
            "Alan Knowles",
            "Kengo Jinno",
            "Valentin Valchev",
            "Marcos E. Wurzius",
            "Martin Alderson",
            "Robert Gustavsson",
            "Jos\303\251 Fonseca",
            "Holger Kiemes",
            "Francis Irving",
            "Scott Kirkwood",
            "Brian Quinlan",
            "Ubi",
            "Michael R. Duerig",
            "Deepak T",
            "Don Paul Beletsky",
            "Gerhard Kalab",
            "Olivier Dagenais",
            "Josh Wingstrom",
            "Bruce Dodson",
            "Sergey Koshcheyev",
            "Chuan-jian Shen",
            "Shane Caraveo",
            "Alexander Scripnik",
            "Ryan Christianson",
            "Martin Steffensen",
            "Jakub Vr\303\241na",
            "The Black Horus",
            "Bernd Kreuss",
            "Thomas Lauer",
            "Mike Lansdaal",
            "Yukihiro Nakai",
            "Jochen Tucht",
            "Greg Smith",
            "Steve Schoettler",
            "Mauritius Thinnes",
            "Darren Schroeder",
            "Pedro Guerreiro",
            "Steven te Brinke",
            "Dan Petitt",
            "Biswapesh Chattopadhyay",
            "Kein-Hong Man",
            "Patrizio Bekerle",
            "Nigel Hathaway",
            "Hrishikesh Desai",
            "Sergey Puljajev",
            "Mathias Rauen",
            "Angelo Mandato http://www.spaceblue.com",
            "Denis Sureau",
            "Kaspar Schiess",
            "Christoph H\303\266sler",
            "Jo\303\243o Paulo F Farias",
            "Ron Schofield",
            "Stefan Wosnik",
            "Marius Gheorghe",
            "Naba Kumar",
            "Sean O'Dell",
            "Stefanos Togoulidis",
            "Hans Hagen",
            "Jim Cape",
            "Roland Walter",
            "Brian Mosher",
            "Nicholas Nemtsev",
            "Roy Wood",
            "Peter-Henry Mander",
            "Robert Boucher",
            "Christoph Dalitz",
            "April White",
            "S. Umar",
            "Trent Mick",
            "Filip Yaghob",
            "Avi Yegudin",
            "Vivi Orunitia",
            "Manfred Becker",
            "Dimitris Keletsekis",
            "Yuiga",
            "Davide Scola",
            "Jason Boggs",
            "Reinhold Niesner",
            "Jos van der Zande",
            "Pescuma",
            "Pavol Bosik",
            "Johannes Schmid",
            "Blair McGlashan",
            "Mikael Hultgren",
            "Florian Balmer",
            "Hadar Raz",
            "Herr Pfarrer",
            "Ben Key",
            "Gene Barry",
            "Niki Spahiev",
            "Carsten Sperber",
            "Phil Reid",
            "Iago Rubio",
            "R\303\251gis Vaquette",
            "Massimo Cor\303\240",
            "Elias Pschernig",
            "Chris Jones",
            "Josiah Reynolds",
            "Robert Roessler rftp.com http://www.rftp.com",
            "Steve Donovan",
            "Jan Martin Pettersen",
            "Sergey Philippov",
            "Borujoa",
            "Michael Owens",
            "Franck Marcia",
            "Massimo Maria Ghisalberti",
            "Frank Wunderlich",
            "Josepmaria Roca",
            "Tobias Engvall",
            "Suzumizaki Kimitaka",
            "Michael Cartmell",
            "Pascal Hurni",
            "Andre",
            "Randy Butler",
            "Georg Ritter",
            "Michael Goffioul",
            "Ben Harper",
            "Adam Strzelecki",
            "Kamen Stanev",
            "Steve Menard",
            "Oliver Yeoh",
            "Eric Promislow",
            "Joseph Galbraith",
            "Jeffrey Ren",
            "Armel Asselin",
            "Jim Pattee",
            "Friedrich Vedder",
            "Sebastian Pipping",
            "Andre Arpin",
            "Stanislav Maslovski",
            "Martin Stone",
            "Fabien Proriol",
            "mimir",
            "Nicola Civran",
            "Snow",
            "Mitchell Foral",
            "Pieter Holtzhausen",
            "Waldemar Augustyn",
            "Jason Haslam",
            "Sebastian Steinlechner",
            "Chris Rickard",
            "Rob McMullen",
            "Stefan Schwendeler",
            "Cristian Adam",
            "Nicolas Chachereau",
            "Istvan Szollosi",
            "Xie Renhui",
            "Enrico Tr\303\266ger",
            "Todd Whiteman",
            "Yuval Papish",
            "instanton",
            "Sergio Lucato",
            "VladVRO",
            "Dmitry Maslov",
            "chupakabra",
            "Juan Carlos Arevalo Baeza",
            "Nick Treleaven",
            "Stephen Stagg",
            "Jean-Paul Iribarren",
            "Tim Gerundt",
            "Sam Harwell",
            "Boris",
            "Jason Oster",
            "Gertjan Kloosterman",
            "alexbodn",
            "Sergiu Dotenco",
            "Anders Karlsson",
            "ozlooper",
            "Marko Njezic",
            "Eugen Bitter",
            "Christoph Baumann",
            "Christopher Bean",
            "Sergey Kishchenko",
            "Kai Liu",
            "Andreas Rumpf",
            "James Moffatt",
            "Yuzhou Xin",
            "Nic Jansma",
            "Evan Jones",
            "Mike Lischke",
            "Eric Kidd",
            "maXmo",
            "David Severwright",
            "Jon Strait",
            "Oliver Kiddle",
            "Etienne Girondel",
            "Haimag Ren",
            "Andrey Moskalyov",
            "Xavi",
            "Toby Inkster",
            "Eric Forgeot",
            "Colomban Wendling",
            "Neo",
            "Jordan Russell",
            "Farshid Lashkari",
            "Sam Rawlins",
            "Michael Mullin",
            "Carlos SS",
            "vim",
            "Martial Demolins",
            "Tino Weinkauf",
            "J\303\251r\303\264me Laforge",
            "Udo Lechner",
            "Marco Falda",
            "Dariusz Knoci\305\204ski",
            "Ben Fisher",
            "Don Gobin",
            "John Yeung",
            "Adobe",
            "Elizabeth A. Irizarry",
            "Mike Schroeder",
            "Morten MacFly",
            "Jaime Gimeno",
            "Thomas Linder Puls",
            "Artyom Zuikov",
            "Gerrit",
            "Occam's Razor",
            "Ben Bluemel",
            "David Wolfendale",
            "Chris Angelico",
            "Marat Dukhan",
            "Stefan Weil",
            "Rex Conn",
            "Ross McKay",
            "Bruno Barbieri",
            "Gordon Smith",
            "dimitar",
            "S\303\251bastien Granjoux",
            "zeniko",
            "James Ribe",
            "Markus Ni\303\237l",
            "Martin Panter",
            "Mark Yen",
            "Philippe Elsass",
            "Dimitar Zhekov",
            "Fan Yang",
            "Denis Shelomovskij",
            "darmar",
            "John Vella",
            "Chinh Nguyen",
            "Sakshi Verma",
            "Joel B. Mohler",
            "Isiledhel",
            "Vidya Wasi",
            "G. Hu",
            "Byron Hawkins",
            "Alpha",
            "John Donoghue",
            "kudah",
            "Igor Shaula",
            "Pavel Bulochkin",
            "Yosef Or Boczko",
            "Brian Griffin",
            "\303\226zg\303\274r Emir",
            "Neomi",
            "OmegaPhil",
            "SiegeLord",
            "Erik",
            "TJF",
            "Mark Robinson",
            "Thomas Martitz",
            "felix",
            "Christian Walther",
            "Ebben",
            "Robert Gieseke",
            "Mike M",
            "nkmathew",
            "Andreas Tscharner",
            "Lee Wilmott",
            "johnsonj",
            "Vicente",
            "Nick Gravgaard",
            "Ian Goldby",
            "Holger Stenger",
            "danselmi",
            "Mat Berchtold",
            "Michael Staszewski",
            "Baurzhan Muftakhidinov",
            "Erik Angelin",
            "Yusuf Ramazan Karag\303\266z",
            "Markus Heidelberg",
            "Joe Mueller",
            "Mika Attila",
            "JoMazM",
            "Markus Moser",
            "Stefan K\303\274ng",
            "Ji\305\231\303\255 Techet",
            "Jonathan Hunt",
            "Serg Stetsuk",
            "Jordan Jueckstock",
            "Yury Dubinsky",
            "Sam Hocevar",
            "Luyomi",
            "Matt Gilarde",
            "Mark C",
            "Johannes Sasongko",
            "fstirlitz",
            "Robin Haberkorn",
            "Pavel Sountsov",
            "Dirk Lorenzen",
            "Kasper B. Graversen",
            "Chris Mayo",
            "Van de Bugger",
            "Tse Kit Yam",
            "SmartShare Systems https://www.smartsharesystems.com/",
            "Morten Br\303\270rup",
            "Alexey Denisov",
            "Justin Dailey",
            "oirfeodent",
            "A-R-C-A",
            "Roberto Rossi",
            "Kenny Liu",
            "Iain Clarke",
            "desto",
            "John Flatness",
            "Thorsten Kani",
            "Bernhard M. Wiedemann",
            "Baldur Karlsson",
            "Martin Kleusberg",
            "Jannick",
            "Zufu Liu",
            "Simon Sobisch",
            "Georger Ara\303\272jo",
            "Tobias K\303\274hne",
            "Dimitar Radev",
            "Liang Bai",
            "Gunter K\303\266nigsmann",
            "Nicholai Benalal",
            "Uniface",
            "Raghda Morsy",
            "Giuseppe Corbelli",
            "Andreas R\303\266nnquist",
            "Henrik Hank",
            "Luke Rasmussen",
            "Philipp",
            "maboroshin",
            "Gokul Krishnan",
            "John Horigan",
            "jj5",
            "Jad Altahan",
            "Andrea Ricchi",
            "Juarez Rudsatz",
            "Wil van Antwerpen",
            "Hodong Kim",
            "Michael Conrad",
            "Dejan Budimir",
            "Andreas Falkenhahn",
            "Mark Reay",
            "David Shuman",
            "McLoo",
            "Shmuel Zeigerman",
            "Chris Graham",
            "Hugues Larrive",
            "Prakash Sahni",
            "Michel Sauvard",
            "uhf7",
            "gnombat",
            "Derek Brown",
            "cshnik",
            "Robert Di Pardo",
            "YX Hao",
            "Petko Georgiev",
            "Damiano Lombardi",
            "riQQ",

//--Autogenerated -- end of automatically generated section
        };

// AddStyledText only called from About so static size buffer is OK
static void AddStyledText(GUI::ScintillaWindow &wsci, const char *s, int attr) {
	const size_t len = strlen(s);
	std::vector<char> buf(len*2);
	for (size_t i = 0; i < len; i++) {
		buf[i*2] = s[i];
		buf[i*2 + 1] = static_cast<char>(attr);
	}
	wsci.AddStyledText(len*2, &buf[0]);
}

static void SetAboutStyle(GUI::ScintillaWindow &wsci, int style, Scintilla::API::Colour fore) {
	wsci.StyleSetFore(style, fore);
}

namespace {

// Implement low quality pseudo-random colours for the pretties.
// Pseudo-random algorithm based on R. G. Dromey "How to Solve it by Computer" page 122.

class RandomColour {
	int mult;
	int incr;
	int modulus;
	int randomValue;
	int NextRandom() noexcept {
		randomValue = (mult * randomValue + incr) % modulus;
		return randomValue;
	}
	void HackColour(int &n) noexcept {
		n += (NextRandom() % 100) - 50;
		if (n > 0xE7)
			n = 0x60;
		if (n < 0)
			n = 0x80;
	}
public:
	int r;
	int g;
	int b;
	RandomColour() noexcept :
		mult(109),
		incr(853),
		modulus(4096),
		randomValue(time(nullptr) % modulus),
		r(NextRandom() % 256),
		g(NextRandom() % 256),
		b(NextRandom() % 256) {
	}
	void Next() noexcept {
		HackColour(r);
		HackColour(g);
		HackColour(b);
	}
};

}

void SciTEBase::SetAboutMessage(GUI::ScintillaWindow &wsci, const char *appTitle) {
	if (wsci.Created()) {
		wsci.StyleResetDefault();
		std::string sVersion = " ";
		sVersion += VERSION_SCITE;
		sVersion += "   Scintilla:";
		sVersion += VERSION_SCINTILLA;
		sVersion += "   Lexilla:";
		sVersion += VERSION_LEXILLA;
#if defined(GTK)
		wsci.StyleSetFont(StyleDefault, "Serif");
		constexpr int fontSize = 14;
		sVersion += "\n    compiled for GTK:";
		sVersion += StdStringFromInteger(GTK_MAJOR_VERSION);
		sVersion += ".";
		sVersion += StdStringFromInteger(GTK_MINOR_VERSION);
		sVersion += ".";
		sVersion += StdStringFromInteger(GTK_MICRO_VERSION);
#else
		constexpr int fontSize = 15;
#endif
		sVersion += "\n";

		wsci.SetCodePage(SA::CpUtf8);

		wsci.StyleSetSize(StyleDefault, fontSize);
		wsci.StyleSetBack(StyleDefault, ColourRGB(0xff, 0xff, 0xff));
		wsci.StyleClearAll();

		SetAboutStyle(wsci, 0, ColourRGB(0xff, 0xff, 0xff));
		wsci.StyleSetSize(0, fontSize);
		wsci.StyleSetBack(0, ColourRGB(0, 0, 0x80));
		wsci.StyleSetEOLFilled(0, true);
		wsci.StyleSetBold(0, true);
		AddStyledText(wsci, "\t\t\t\t", 0);
		AddStyledText(wsci, appTitle, 0);
		AddStyledText(wsci, "\n", 0);
		SetAboutStyle(wsci, 1, ColourRGB(0, 0, 0));
		constexpr int trsSty = 5; // define the stylenumber to assign font for translators.
		std::string translator = GetTranslationToAbout("TranslationCredit", false);
		SetAboutStyle(wsci, trsSty, ColourRGB(0, 0, 0));
		if constexpr (sizeof(void *) == 4) {
			AddStyledText(wsci, "32-bit\n", 1);
		}
		AddStyledText(wsci, GetTranslationToAbout("Version").c_str(), trsSty);
		AddStyledText(wsci, sVersion.c_str(), 1);
		AddStyledText(wsci, "    " __DATE__ " " __TIME__ "\n", 1);
		SetAboutStyle(wsci, 2, ColourRGB(0, 0, 0));
		wsci.StyleSetItalic(2, true);
		AddStyledText(wsci, GetTranslationToAbout("by").c_str(), trsSty);
		AddStyledText(wsci, " Neil Hodgson.\n", 2);
		SetAboutStyle(wsci, 3, ColourRGB(0, 0, 0));
		AddStyledText(wsci, COPYRIGHT_DATES ".\n", 3);
		SetAboutStyle(wsci, 4, ColourRGB(0, 0x7f, 0x7f));
		AddStyledText(wsci, "http://www.scintilla.org\n", 4);
		AddStyledText(wsci, "Lua scripting language by TeCGraf, PUC-Rio\n", 3);
		AddStyledText(wsci, "    http://www.lua.org\n", 4);
		if (translator.length()) {
			AddStyledText(wsci, translator.c_str(), trsSty);
			AddStyledText(wsci, "\n", 5);
		}
		AddStyledText(wsci, GetTranslationToAbout("Contributors:").c_str(), trsSty);
		for (unsigned int co = 0; co < std::size(contributors); co++) {
			const int colourIndex = 50 + (co % 78);
			AddStyledText(wsci, "\n    ", colourIndex);
			AddStyledText(wsci, contributors[co], colourIndex);
		}
		RandomColour colour;
		for (unsigned int sty = 0; sty < 78; sty++) {
			colour.Next();
			SetAboutStyle(wsci, sty + 50, ColourRGB(colour.r, colour.g, colour.b));
		}
		wsci.SetReadOnly(true);
	}
}
