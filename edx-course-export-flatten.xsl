<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    
    <xsl:output method="xml" indent="yes"></xsl:output>

    <!-- A micro-pipeline in XSLT using <xsl:variable> and modes
         to build a flat xml-structure from a edx course export consisting of xml-documents 
         scattered over many files and folders 
         in this case from an extracted edx-course export archive

         - load a xml-file, store in a variable
         - then process the files this xml document references (in another mode) 
         - then add them as children of this node and store in a variable
         - repeat until all levels of files have been processed and merged into one flat xml tree -->

    <!-- This micro-pipeline has been written to work with a known xml-structure.
         It works as intended with the edx course export. 
         It could possibly be re-written more generic using recursive templates/functions -->
    
    <!-- This stylesheet is intended of being called with an initial template, and the folder as a string parameter.
         The empty string will be supplied as a default a default folder parameter, 
         indicating to look for the starting course.xml in the current folder -->

    <!-- Example calling this stylesheet with saxon xslt/xquery processor:

         saxon -it:main f=/relative/path/to/edx-export-folder -xsl:'/full/path/to/edx-course-export-visualizer.xsl'

         saxon -it:main -xsl:'/full/path/to/edx-course-export-visualizer.xsl 

         -it:main specifies the initial template

         f=office365 would specify that the edx-course-export is in the relative path office365. 

         If the f-parameter is dropped, the stylesheet will simply look for the initial course.xml file in the current folder you are issuing the command from.

         -xsl:path speficies where this xsl-stylesheet is located in the filesystem
    -->

   <!-- Written by Eirik Hanssen, OsloMet – Oslo Metropolitan University -->

   <!-- License: Gnu GPLv3 -->

    <xsl:param name="f" as="xs:string" select="''"/>
    
    <!-- folders in the extracted edx course export -->

    <xsl:variable name="f_root" select="$f"/>
    <xsl:variable name="input" select="doc(concat($f_root,'/course.xml'))"/>
    <xsl:variable name="f_chapter" select="concat($f_root, '/chapter/')"/>
    <xsl:variable name="f_sequential" select="concat($f_root, '/sequential/')"/>
    <xsl:variable name="f_vertical" select="concat($f_root, '/vertical/')"/>
    <xsl:variable name="f_html" select="concat($f_root, '/html/')"/>
    <xsl:variable name="f_video" select="concat($f_root, '/video/')"/>

<xsl:variable name="html_doctype_entities_local">
<!--  Define some entities that are used in html files. This might need to be expanded later -->
    <xsl:text><![CDATA[<!DOCTYPE html [ 
<!ENTITY nbsp "&#160;">
<!ENTITY aring "å">
<!ENTITY Aring "Å">
<!ENTITY oslash "ø">
<!ENTITY Oslash "Ø">
<!ENTITY aelig "æ">
<!ENTITY AElig "Æ">
<!ENTITY lsquo "‘">
<!ENTITY rsquo "’">
<!ENTITY mdash "—">
<!ENTITY ndash "–">
<!ENTITY ldquo "“">
<!ENTITY rdquo "”">
<!ENTITY laquo "«">
<!ENTITY raquo "»">
<!ENTITY eacute "é">
<!ENTITY Eacute "É">
]>]]></xsl:text>
</xsl:variable>
    
<xsl:variable name="html_doctype_entities_w3c">
<!--  it would be wise to use a local entity resolver instead of fetching these entities over the internet: how do we do this? -->
<xsl:text><![CDATA[<!DOCTYPE html [
  <!ENTITY % w3centities-f PUBLIC "-//W3C//ENTITIES Combined Set//EN//XML"
      "http://www.w3.org/2003/entities/2007/w3centities-f.ent">
  %w3centities-f;
]>]]></xsl:text>
</xsl:variable>

    <!-- 
     Copyright 1998 - 2011 W3C.

     Use and distribution of this code are permitted under the terms of
     either of the following two licences:

     1) W3C Software Notice and License.
        http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231.html


     2) The license used for the WHATWG HTML specification,
        which states, in full:
            You are granted a license to use, reproduce and create derivative
            works of this document.


     Please report any errors to David Carlisle
     via the public W3C list www-math@w3.org.

 
       Public identifier: -//W3C//ENTITIES Combined Set//EN//XML
       System identifier: http://www.w3.org/2003/entities/2007/w3centities-f.ent

     The public identifier should always be used verbatim.
     The system identifier may be changed to suit local requirements.

     Typical invocation:

       <!ENTITY % w3centities-f PUBLIC
         "-//W3C//ENTITIES Combined Set//EN//XML"
         "http://www.w3.org/2003/entities/2007/w3centities-f.ent"
       >
       %w3centities-f;
-->
    <xsl:variable name="w3c_entities_local"><![CDATA[<!DOCTYPE html [

<!ENTITY AElig            "&#x000C6;" ><!--LATIN CAPITAL LETTER AE -->
<!ENTITY AMP              "&#38;#38;" ><!--AMPERSAND -->
<!ENTITY Aacgr            "&#x00386;" ><!--GREEK CAPITAL LETTER ALPHA WITH TONOS -->
<!ENTITY Aacute           "&#x000C1;" ><!--LATIN CAPITAL LETTER A WITH ACUTE -->
<!ENTITY Abreve           "&#x00102;" ><!--LATIN CAPITAL LETTER A WITH BREVE -->
<!ENTITY Acirc            "&#x000C2;" ><!--LATIN CAPITAL LETTER A WITH CIRCUMFLEX -->
<!ENTITY Acy              "&#x00410;" ><!--CYRILLIC CAPITAL LETTER A -->
<!ENTITY Afr              "&#x1D504;" ><!--MATHEMATICAL FRAKTUR CAPITAL A -->
<!ENTITY Agr              "&#x00391;" ><!--GREEK CAPITAL LETTER ALPHA -->
<!ENTITY Agrave           "&#x000C0;" ><!--LATIN CAPITAL LETTER A WITH GRAVE -->
<!ENTITY Alpha            "&#x00391;" ><!--GREEK CAPITAL LETTER ALPHA -->
<!ENTITY Amacr            "&#x00100;" ><!--LATIN CAPITAL LETTER A WITH MACRON -->
<!ENTITY And              "&#x02A53;" ><!--DOUBLE LOGICAL AND -->
<!ENTITY Aogon            "&#x00104;" ><!--LATIN CAPITAL LETTER A WITH OGONEK -->
<!ENTITY Aopf             "&#x1D538;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL A -->
<!ENTITY ApplyFunction    "&#x02061;" ><!--FUNCTION APPLICATION -->
<!ENTITY Aring            "&#x000C5;" ><!--LATIN CAPITAL LETTER A WITH RING ABOVE -->
<!ENTITY Ascr             "&#x1D49C;" ><!--MATHEMATICAL SCRIPT CAPITAL A -->
<!ENTITY Assign           "&#x02254;" ><!--COLON EQUALS -->
<!ENTITY Atilde           "&#x000C3;" ><!--LATIN CAPITAL LETTER A WITH TILDE -->
<!ENTITY Auml             "&#x000C4;" ><!--LATIN CAPITAL LETTER A WITH DIAERESIS -->
<!ENTITY Backslash        "&#x02216;" ><!--SET MINUS -->
<!ENTITY Barv             "&#x02AE7;" ><!--SHORT DOWN TACK WITH OVERBAR -->
<!ENTITY Barwed           "&#x02306;" ><!--PERSPECTIVE -->
<!ENTITY Bcy              "&#x00411;" ><!--CYRILLIC CAPITAL LETTER BE -->
<!ENTITY Because          "&#x02235;" ><!--BECAUSE -->
<!ENTITY Bernoullis       "&#x0212C;" ><!--SCRIPT CAPITAL B -->
<!ENTITY Beta             "&#x00392;" ><!--GREEK CAPITAL LETTER BETA -->
<!ENTITY Bfr              "&#x1D505;" ><!--MATHEMATICAL FRAKTUR CAPITAL B -->
<!ENTITY Bgr              "&#x00392;" ><!--GREEK CAPITAL LETTER BETA -->
<!ENTITY Bopf             "&#x1D539;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL B -->
<!ENTITY Breve            "&#x002D8;" ><!--BREVE -->
<!ENTITY Bscr             "&#x0212C;" ><!--SCRIPT CAPITAL B -->
<!ENTITY Bumpeq           "&#x0224E;" ><!--GEOMETRICALLY EQUIVALENT TO -->
<!ENTITY CHcy             "&#x00427;" ><!--CYRILLIC CAPITAL LETTER CHE -->
<!ENTITY COPY             "&#x000A9;" ><!--COPYRIGHT SIGN -->
<!ENTITY Cacute           "&#x00106;" ><!--LATIN CAPITAL LETTER C WITH ACUTE -->
<!ENTITY Cap              "&#x022D2;" ><!--DOUBLE INTERSECTION -->
<!ENTITY CapitalDifferentialD "&#x02145;" ><!--DOUBLE-STRUCK ITALIC CAPITAL D -->
<!ENTITY Cayleys          "&#x0212D;" ><!--BLACK-LETTER CAPITAL C -->
<!ENTITY Ccaron           "&#x0010C;" ><!--LATIN CAPITAL LETTER C WITH CARON -->
<!ENTITY Ccedil           "&#x000C7;" ><!--LATIN CAPITAL LETTER C WITH CEDILLA -->
<!ENTITY Ccirc            "&#x00108;" ><!--LATIN CAPITAL LETTER C WITH CIRCUMFLEX -->
<!ENTITY Cconint          "&#x02230;" ><!--VOLUME INTEGRAL -->
<!ENTITY Cdot             "&#x0010A;" ><!--LATIN CAPITAL LETTER C WITH DOT ABOVE -->
<!ENTITY Cedilla          "&#x000B8;" ><!--CEDILLA -->
<!ENTITY CenterDot        "&#x000B7;" ><!--MIDDLE DOT -->
<!ENTITY Cfr              "&#x0212D;" ><!--BLACK-LETTER CAPITAL C -->
<!ENTITY Chi              "&#x003A7;" ><!--GREEK CAPITAL LETTER CHI -->
<!ENTITY CircleDot        "&#x02299;" ><!--CIRCLED DOT OPERATOR -->
<!ENTITY CircleMinus      "&#x02296;" ><!--CIRCLED MINUS -->
<!ENTITY CirclePlus       "&#x02295;" ><!--CIRCLED PLUS -->
<!ENTITY CircleTimes      "&#x02297;" ><!--CIRCLED TIMES -->
<!ENTITY ClockwiseContourIntegral "&#x02232;" ><!--CLOCKWISE CONTOUR INTEGRAL -->
<!ENTITY CloseCurlyDoubleQuote "&#x0201D;" ><!--RIGHT DOUBLE QUOTATION MARK -->
<!ENTITY CloseCurlyQuote  "&#x02019;" ><!--RIGHT SINGLE QUOTATION MARK -->
<!ENTITY Colon            "&#x02237;" ><!--PROPORTION -->
<!ENTITY Colone           "&#x02A74;" ><!--DOUBLE COLON EQUAL -->
<!ENTITY Congruent        "&#x02261;" ><!--IDENTICAL TO -->
<!ENTITY Conint           "&#x0222F;" ><!--SURFACE INTEGRAL -->
<!ENTITY ContourIntegral  "&#x0222E;" ><!--CONTOUR INTEGRAL -->
<!ENTITY Copf             "&#x02102;" ><!--DOUBLE-STRUCK CAPITAL C -->
<!ENTITY Coproduct        "&#x02210;" ><!--N-ARY COPRODUCT -->
<!ENTITY CounterClockwiseContourIntegral "&#x02233;" ><!--ANTICLOCKWISE CONTOUR INTEGRAL -->
<!ENTITY Cross            "&#x02A2F;" ><!--VECTOR OR CROSS PRODUCT -->
<!ENTITY Cscr             "&#x1D49E;" ><!--MATHEMATICAL SCRIPT CAPITAL C -->
<!ENTITY Cup              "&#x022D3;" ><!--DOUBLE UNION -->
<!ENTITY CupCap           "&#x0224D;" ><!--EQUIVALENT TO -->
<!ENTITY DD               "&#x02145;" ><!--DOUBLE-STRUCK ITALIC CAPITAL D -->
<!ENTITY DDotrahd         "&#x02911;" ><!--RIGHTWARDS ARROW WITH DOTTED STEM -->
<!ENTITY DJcy             "&#x00402;" ><!--CYRILLIC CAPITAL LETTER DJE -->
<!ENTITY DScy             "&#x00405;" ><!--CYRILLIC CAPITAL LETTER DZE -->
<!ENTITY DZcy             "&#x0040F;" ><!--CYRILLIC CAPITAL LETTER DZHE -->
<!ENTITY Dagger           "&#x02021;" ><!--DOUBLE DAGGER -->
<!ENTITY Darr             "&#x021A1;" ><!--DOWNWARDS TWO HEADED ARROW -->
<!ENTITY Dashv            "&#x02AE4;" ><!--VERTICAL BAR DOUBLE LEFT TURNSTILE -->
<!ENTITY Dcaron           "&#x0010E;" ><!--LATIN CAPITAL LETTER D WITH CARON -->
<!ENTITY Dcy              "&#x00414;" ><!--CYRILLIC CAPITAL LETTER DE -->
<!ENTITY Del              "&#x02207;" ><!--NABLA -->
<!ENTITY Delta            "&#x00394;" ><!--GREEK CAPITAL LETTER DELTA -->
<!ENTITY Dfr              "&#x1D507;" ><!--MATHEMATICAL FRAKTUR CAPITAL D -->
<!ENTITY Dgr              "&#x00394;" ><!--GREEK CAPITAL LETTER DELTA -->
<!ENTITY DiacriticalAcute "&#x000B4;" ><!--ACUTE ACCENT -->
<!ENTITY DiacriticalDot   "&#x002D9;" ><!--DOT ABOVE -->
<!ENTITY DiacriticalDoubleAcute "&#x002DD;" ><!--DOUBLE ACUTE ACCENT -->
<!ENTITY DiacriticalGrave "&#x00060;" ><!--GRAVE ACCENT -->
<!ENTITY DiacriticalTilde "&#x002DC;" ><!--SMALL TILDE -->
<!ENTITY Diamond          "&#x022C4;" ><!--DIAMOND OPERATOR -->
<!ENTITY DifferentialD    "&#x02146;" ><!--DOUBLE-STRUCK ITALIC SMALL D -->
<!ENTITY Dopf             "&#x1D53B;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL D -->
<!ENTITY Dot              "&#x000A8;" ><!--DIAERESIS -->
<!ENTITY DotDot           " &#x020DC;" ><!--COMBINING FOUR DOTS ABOVE -->
<!ENTITY DotEqual         "&#x02250;" ><!--APPROACHES THE LIMIT -->
<!ENTITY DoubleContourIntegral "&#x0222F;" ><!--SURFACE INTEGRAL -->
<!ENTITY DoubleDot        "&#x000A8;" ><!--DIAERESIS -->
<!ENTITY DoubleDownArrow  "&#x021D3;" ><!--DOWNWARDS DOUBLE ARROW -->
<!ENTITY DoubleLeftArrow  "&#x021D0;" ><!--LEFTWARDS DOUBLE ARROW -->
<!ENTITY DoubleLeftRightArrow "&#x021D4;" ><!--LEFT RIGHT DOUBLE ARROW -->
<!ENTITY DoubleLeftTee    "&#x02AE4;" ><!--VERTICAL BAR DOUBLE LEFT TURNSTILE -->
<!ENTITY DoubleLongLeftArrow "&#x027F8;" ><!--LONG LEFTWARDS DOUBLE ARROW -->
<!ENTITY DoubleLongLeftRightArrow "&#x027FA;" ><!--LONG LEFT RIGHT DOUBLE ARROW -->
<!ENTITY DoubleLongRightArrow "&#x027F9;" ><!--LONG RIGHTWARDS DOUBLE ARROW -->
<!ENTITY DoubleRightArrow "&#x021D2;" ><!--RIGHTWARDS DOUBLE ARROW -->
<!ENTITY DoubleRightTee   "&#x022A8;" ><!--TRUE -->
<!ENTITY DoubleUpArrow    "&#x021D1;" ><!--UPWARDS DOUBLE ARROW -->
<!ENTITY DoubleUpDownArrow "&#x021D5;" ><!--UP DOWN DOUBLE ARROW -->
<!ENTITY DoubleVerticalBar "&#x02225;" ><!--PARALLEL TO -->
<!ENTITY DownArrow        "&#x02193;" ><!--DOWNWARDS ARROW -->
<!ENTITY DownArrowBar     "&#x02913;" ><!--DOWNWARDS ARROW TO BAR -->
<!ENTITY DownArrowUpArrow "&#x021F5;" ><!--DOWNWARDS ARROW LEFTWARDS OF UPWARDS ARROW -->
<!ENTITY DownBreve        " &#x00311;" ><!--COMBINING INVERTED BREVE -->
<!ENTITY DownLeftRightVector "&#x02950;" ><!--LEFT BARB DOWN RIGHT BARB DOWN HARPOON -->
<!ENTITY DownLeftTeeVector "&#x0295E;" ><!--LEFTWARDS HARPOON WITH BARB DOWN FROM BAR -->
<!ENTITY DownLeftVector   "&#x021BD;" ><!--LEFTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY DownLeftVectorBar "&#x02956;" ><!--LEFTWARDS HARPOON WITH BARB DOWN TO BAR -->
<!ENTITY DownRightTeeVector "&#x0295F;" ><!--RIGHTWARDS HARPOON WITH BARB DOWN FROM BAR -->
<!ENTITY DownRightVector  "&#x021C1;" ><!--RIGHTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY DownRightVectorBar "&#x02957;" ><!--RIGHTWARDS HARPOON WITH BARB DOWN TO BAR -->
<!ENTITY DownTee          "&#x022A4;" ><!--DOWN TACK -->
<!ENTITY DownTeeArrow     "&#x021A7;" ><!--DOWNWARDS ARROW FROM BAR -->
<!ENTITY Downarrow        "&#x021D3;" ><!--DOWNWARDS DOUBLE ARROW -->
<!ENTITY Dscr             "&#x1D49F;" ><!--MATHEMATICAL SCRIPT CAPITAL D -->
<!ENTITY Dstrok           "&#x00110;" ><!--LATIN CAPITAL LETTER D WITH STROKE -->
<!ENTITY EEacgr           "&#x00389;" ><!--GREEK CAPITAL LETTER ETA WITH TONOS -->
<!ENTITY EEgr             "&#x00397;" ><!--GREEK CAPITAL LETTER ETA -->
<!ENTITY ENG              "&#x0014A;" ><!--LATIN CAPITAL LETTER ENG -->
<!ENTITY ETH              "&#x000D0;" ><!--LATIN CAPITAL LETTER ETH -->
<!ENTITY Eacgr            "&#x00388;" ><!--GREEK CAPITAL LETTER EPSILON WITH TONOS -->
<!ENTITY Eacute           "&#x000C9;" ><!--LATIN CAPITAL LETTER E WITH ACUTE -->
<!ENTITY Ecaron           "&#x0011A;" ><!--LATIN CAPITAL LETTER E WITH CARON -->
<!ENTITY Ecirc            "&#x000CA;" ><!--LATIN CAPITAL LETTER E WITH CIRCUMFLEX -->
<!ENTITY Ecy              "&#x0042D;" ><!--CYRILLIC CAPITAL LETTER E -->
<!ENTITY Edot             "&#x00116;" ><!--LATIN CAPITAL LETTER E WITH DOT ABOVE -->
<!ENTITY Efr              "&#x1D508;" ><!--MATHEMATICAL FRAKTUR CAPITAL E -->
<!ENTITY Egr              "&#x00395;" ><!--GREEK CAPITAL LETTER EPSILON -->
<!ENTITY Egrave           "&#x000C8;" ><!--LATIN CAPITAL LETTER E WITH GRAVE -->
<!ENTITY Element          "&#x02208;" ><!--ELEMENT OF -->
<!ENTITY Emacr            "&#x00112;" ><!--LATIN CAPITAL LETTER E WITH MACRON -->
<!ENTITY EmptySmallSquare "&#x025FB;" ><!--WHITE MEDIUM SQUARE -->
<!ENTITY EmptyVerySmallSquare "&#x025AB;" ><!--WHITE SMALL SQUARE -->
<!ENTITY Eogon            "&#x00118;" ><!--LATIN CAPITAL LETTER E WITH OGONEK -->
<!ENTITY Eopf             "&#x1D53C;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL E -->
<!ENTITY Epsilon          "&#x00395;" ><!--GREEK CAPITAL LETTER EPSILON -->
<!ENTITY Equal            "&#x02A75;" ><!--TWO CONSECUTIVE EQUALS SIGNS -->
<!ENTITY EqualTilde       "&#x02242;" ><!--MINUS TILDE -->
<!ENTITY Equilibrium      "&#x021CC;" ><!--RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON -->
<!ENTITY Escr             "&#x02130;" ><!--SCRIPT CAPITAL E -->
<!ENTITY Esim             "&#x02A73;" ><!--EQUALS SIGN ABOVE TILDE OPERATOR -->
<!ENTITY Eta              "&#x00397;" ><!--GREEK CAPITAL LETTER ETA -->
<!ENTITY Euml             "&#x000CB;" ><!--LATIN CAPITAL LETTER E WITH DIAERESIS -->
<!ENTITY Exists           "&#x02203;" ><!--THERE EXISTS -->
<!ENTITY ExponentialE     "&#x02147;" ><!--DOUBLE-STRUCK ITALIC SMALL E -->
<!ENTITY Fcy              "&#x00424;" ><!--CYRILLIC CAPITAL LETTER EF -->
<!ENTITY Ffr              "&#x1D509;" ><!--MATHEMATICAL FRAKTUR CAPITAL F -->
<!ENTITY FilledSmallSquare "&#x025FC;" ><!--BLACK MEDIUM SQUARE -->
<!ENTITY FilledVerySmallSquare "&#x025AA;" ><!--BLACK SMALL SQUARE -->
<!ENTITY Fopf             "&#x1D53D;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL F -->
<!ENTITY ForAll           "&#x02200;" ><!--FOR ALL -->
<!ENTITY Fouriertrf       "&#x02131;" ><!--SCRIPT CAPITAL F -->
<!ENTITY Fscr             "&#x02131;" ><!--SCRIPT CAPITAL F -->
<!ENTITY GJcy             "&#x00403;" ><!--CYRILLIC CAPITAL LETTER GJE -->
<!ENTITY GT               "&#x0003E;" ><!--GREATER-THAN SIGN -->
<!ENTITY Gamma            "&#x00393;" ><!--GREEK CAPITAL LETTER GAMMA -->
<!ENTITY Gammad           "&#x003DC;" ><!--GREEK LETTER DIGAMMA -->
<!ENTITY Gbreve           "&#x0011E;" ><!--LATIN CAPITAL LETTER G WITH BREVE -->
<!ENTITY Gcedil           "&#x00122;" ><!--LATIN CAPITAL LETTER G WITH CEDILLA -->
<!ENTITY Gcirc            "&#x0011C;" ><!--LATIN CAPITAL LETTER G WITH CIRCUMFLEX -->
<!ENTITY Gcy              "&#x00413;" ><!--CYRILLIC CAPITAL LETTER GHE -->
<!ENTITY Gdot             "&#x00120;" ><!--LATIN CAPITAL LETTER G WITH DOT ABOVE -->
<!ENTITY Gfr              "&#x1D50A;" ><!--MATHEMATICAL FRAKTUR CAPITAL G -->
<!ENTITY Gg               "&#x022D9;" ><!--VERY MUCH GREATER-THAN -->
<!ENTITY Ggr              "&#x00393;" ><!--GREEK CAPITAL LETTER GAMMA -->
<!ENTITY Gopf             "&#x1D53E;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL G -->
<!ENTITY GreaterEqual     "&#x02265;" ><!--GREATER-THAN OR EQUAL TO -->
<!ENTITY GreaterEqualLess "&#x022DB;" ><!--GREATER-THAN EQUAL TO OR LESS-THAN -->
<!ENTITY GreaterFullEqual "&#x02267;" ><!--GREATER-THAN OVER EQUAL TO -->
<!ENTITY GreaterGreater   "&#x02AA2;" ><!--DOUBLE NESTED GREATER-THAN -->
<!ENTITY GreaterLess      "&#x02277;" ><!--GREATER-THAN OR LESS-THAN -->
<!ENTITY GreaterSlantEqual "&#x02A7E;" ><!--GREATER-THAN OR SLANTED EQUAL TO -->
<!ENTITY GreaterTilde     "&#x02273;" ><!--GREATER-THAN OR EQUIVALENT TO -->
<!ENTITY Gscr             "&#x1D4A2;" ><!--MATHEMATICAL SCRIPT CAPITAL G -->
<!ENTITY Gt               "&#x0226B;" ><!--MUCH GREATER-THAN -->
<!ENTITY HARDcy           "&#x0042A;" ><!--CYRILLIC CAPITAL LETTER HARD SIGN -->
<!ENTITY Hacek            "&#x002C7;" ><!--CARON -->
<!ENTITY Hat              "&#x0005E;" ><!--CIRCUMFLEX ACCENT -->
<!ENTITY Hcirc            "&#x00124;" ><!--LATIN CAPITAL LETTER H WITH CIRCUMFLEX -->
<!ENTITY Hfr              "&#x0210C;" ><!--BLACK-LETTER CAPITAL H -->
<!ENTITY HilbertSpace     "&#x0210B;" ><!--SCRIPT CAPITAL H -->
<!ENTITY Hopf             "&#x0210D;" ><!--DOUBLE-STRUCK CAPITAL H -->
<!ENTITY HorizontalLine   "&#x02500;" ><!--BOX DRAWINGS LIGHT HORIZONTAL -->
<!ENTITY Hscr             "&#x0210B;" ><!--SCRIPT CAPITAL H -->
<!ENTITY Hstrok           "&#x00126;" ><!--LATIN CAPITAL LETTER H WITH STROKE -->
<!ENTITY HumpDownHump     "&#x0224E;" ><!--GEOMETRICALLY EQUIVALENT TO -->
<!ENTITY HumpEqual        "&#x0224F;" ><!--DIFFERENCE BETWEEN -->
<!ENTITY IEcy             "&#x00415;" ><!--CYRILLIC CAPITAL LETTER IE -->
<!ENTITY IJlig            "&#x00132;" ><!--LATIN CAPITAL LIGATURE IJ -->
<!ENTITY IOcy             "&#x00401;" ><!--CYRILLIC CAPITAL LETTER IO -->
<!ENTITY Iacgr            "&#x0038A;" ><!--GREEK CAPITAL LETTER IOTA WITH TONOS -->
<!ENTITY Iacute           "&#x000CD;" ><!--LATIN CAPITAL LETTER I WITH ACUTE -->
<!ENTITY Icirc            "&#x000CE;" ><!--LATIN CAPITAL LETTER I WITH CIRCUMFLEX -->
<!ENTITY Icy              "&#x00418;" ><!--CYRILLIC CAPITAL LETTER I -->
<!ENTITY Idigr            "&#x003AA;" ><!--GREEK CAPITAL LETTER IOTA WITH DIALYTIKA -->
<!ENTITY Idot             "&#x00130;" ><!--LATIN CAPITAL LETTER I WITH DOT ABOVE -->
<!ENTITY Ifr              "&#x02111;" ><!--BLACK-LETTER CAPITAL I -->
<!ENTITY Igr              "&#x00399;" ><!--GREEK CAPITAL LETTER IOTA -->
<!ENTITY Igrave           "&#x000CC;" ><!--LATIN CAPITAL LETTER I WITH GRAVE -->
<!ENTITY Im               "&#x02111;" ><!--BLACK-LETTER CAPITAL I -->
<!ENTITY Imacr            "&#x0012A;" ><!--LATIN CAPITAL LETTER I WITH MACRON -->
<!ENTITY ImaginaryI       "&#x02148;" ><!--DOUBLE-STRUCK ITALIC SMALL I -->
<!ENTITY Implies          "&#x021D2;" ><!--RIGHTWARDS DOUBLE ARROW -->
<!ENTITY Int              "&#x0222C;" ><!--DOUBLE INTEGRAL -->
<!ENTITY Integral         "&#x0222B;" ><!--INTEGRAL -->
<!ENTITY Intersection     "&#x022C2;" ><!--N-ARY INTERSECTION -->
<!ENTITY InvisibleComma   "&#x02063;" ><!--INVISIBLE SEPARATOR -->
<!ENTITY InvisibleTimes   "&#x02062;" ><!--INVISIBLE TIMES -->
<!ENTITY Iogon            "&#x0012E;" ><!--LATIN CAPITAL LETTER I WITH OGONEK -->
<!ENTITY Iopf             "&#x1D540;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL I -->
<!ENTITY Iota             "&#x00399;" ><!--GREEK CAPITAL LETTER IOTA -->
<!ENTITY Iscr             "&#x02110;" ><!--SCRIPT CAPITAL I -->
<!ENTITY Itilde           "&#x00128;" ><!--LATIN CAPITAL LETTER I WITH TILDE -->
<!ENTITY Iukcy            "&#x00406;" ><!--CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I -->
<!ENTITY Iuml             "&#x000CF;" ><!--LATIN CAPITAL LETTER I WITH DIAERESIS -->
<!ENTITY Jcirc            "&#x00134;" ><!--LATIN CAPITAL LETTER J WITH CIRCUMFLEX -->
<!ENTITY Jcy              "&#x00419;" ><!--CYRILLIC CAPITAL LETTER SHORT I -->
<!ENTITY Jfr              "&#x1D50D;" ><!--MATHEMATICAL FRAKTUR CAPITAL J -->
<!ENTITY Jopf             "&#x1D541;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL J -->
<!ENTITY Jscr             "&#x1D4A5;" ><!--MATHEMATICAL SCRIPT CAPITAL J -->
<!ENTITY Jsercy           "&#x00408;" ><!--CYRILLIC CAPITAL LETTER JE -->
<!ENTITY Jukcy            "&#x00404;" ><!--CYRILLIC CAPITAL LETTER UKRAINIAN IE -->
<!ENTITY KHcy             "&#x00425;" ><!--CYRILLIC CAPITAL LETTER HA -->
<!ENTITY KHgr             "&#x003A7;" ><!--GREEK CAPITAL LETTER CHI -->
<!ENTITY KJcy             "&#x0040C;" ><!--CYRILLIC CAPITAL LETTER KJE -->
<!ENTITY Kappa            "&#x0039A;" ><!--GREEK CAPITAL LETTER KAPPA -->
<!ENTITY Kcedil           "&#x00136;" ><!--LATIN CAPITAL LETTER K WITH CEDILLA -->
<!ENTITY Kcy              "&#x0041A;" ><!--CYRILLIC CAPITAL LETTER KA -->
<!ENTITY Kfr              "&#x1D50E;" ><!--MATHEMATICAL FRAKTUR CAPITAL K -->
<!ENTITY Kgr              "&#x0039A;" ><!--GREEK CAPITAL LETTER KAPPA -->
<!ENTITY Kopf             "&#x1D542;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL K -->
<!ENTITY Kscr             "&#x1D4A6;" ><!--MATHEMATICAL SCRIPT CAPITAL K -->
<!ENTITY LJcy             "&#x00409;" ><!--CYRILLIC CAPITAL LETTER LJE -->
<!ENTITY LT               "&#38;#60;" ><!--LESS-THAN SIGN -->
<!ENTITY Lacute           "&#x00139;" ><!--LATIN CAPITAL LETTER L WITH ACUTE -->
<!ENTITY Lambda           "&#x0039B;" ><!--GREEK CAPITAL LETTER LAMDA -->
<!ENTITY Lang             "&#x027EA;" ><!--MATHEMATICAL LEFT DOUBLE ANGLE BRACKET -->
<!ENTITY Laplacetrf       "&#x02112;" ><!--SCRIPT CAPITAL L -->
<!ENTITY Larr             "&#x0219E;" ><!--LEFTWARDS TWO HEADED ARROW -->
<!ENTITY Lcaron           "&#x0013D;" ><!--LATIN CAPITAL LETTER L WITH CARON -->
<!ENTITY Lcedil           "&#x0013B;" ><!--LATIN CAPITAL LETTER L WITH CEDILLA -->
<!ENTITY Lcy              "&#x0041B;" ><!--CYRILLIC CAPITAL LETTER EL -->
<!ENTITY LeftAngleBracket "&#x027E8;" ><!--MATHEMATICAL LEFT ANGLE BRACKET -->
<!ENTITY LeftArrow        "&#x02190;" ><!--LEFTWARDS ARROW -->
<!ENTITY LeftArrowBar     "&#x021E4;" ><!--LEFTWARDS ARROW TO BAR -->
<!ENTITY LeftArrowRightArrow "&#x021C6;" ><!--LEFTWARDS ARROW OVER RIGHTWARDS ARROW -->
<!ENTITY LeftCeiling      "&#x02308;" ><!--LEFT CEILING -->
<!ENTITY LeftDoubleBracket "&#x027E6;" ><!--MATHEMATICAL LEFT WHITE SQUARE BRACKET -->
<!ENTITY LeftDownTeeVector "&#x02961;" ><!--DOWNWARDS HARPOON WITH BARB LEFT FROM BAR -->
<!ENTITY LeftDownVector   "&#x021C3;" ><!--DOWNWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY LeftDownVectorBar "&#x02959;" ><!--DOWNWARDS HARPOON WITH BARB LEFT TO BAR -->
<!ENTITY LeftFloor        "&#x0230A;" ><!--LEFT FLOOR -->
<!ENTITY LeftRightArrow   "&#x02194;" ><!--LEFT RIGHT ARROW -->
<!ENTITY LeftRightVector  "&#x0294E;" ><!--LEFT BARB UP RIGHT BARB UP HARPOON -->
<!ENTITY LeftTee          "&#x022A3;" ><!--LEFT TACK -->
<!ENTITY LeftTeeArrow     "&#x021A4;" ><!--LEFTWARDS ARROW FROM BAR -->
<!ENTITY LeftTeeVector    "&#x0295A;" ><!--LEFTWARDS HARPOON WITH BARB UP FROM BAR -->
<!ENTITY LeftTriangle     "&#x022B2;" ><!--NORMAL SUBGROUP OF -->
<!ENTITY LeftTriangleBar  "&#x029CF;" ><!--LEFT TRIANGLE BESIDE VERTICAL BAR -->
<!ENTITY LeftTriangleEqual "&#x022B4;" ><!--NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY LeftUpDownVector "&#x02951;" ><!--UP BARB LEFT DOWN BARB LEFT HARPOON -->
<!ENTITY LeftUpTeeVector  "&#x02960;" ><!--UPWARDS HARPOON WITH BARB LEFT FROM BAR -->
<!ENTITY LeftUpVector     "&#x021BF;" ><!--UPWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY LeftUpVectorBar  "&#x02958;" ><!--UPWARDS HARPOON WITH BARB LEFT TO BAR -->
<!ENTITY LeftVector       "&#x021BC;" ><!--LEFTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY LeftVectorBar    "&#x02952;" ><!--LEFTWARDS HARPOON WITH BARB UP TO BAR -->
<!ENTITY Leftarrow        "&#x021D0;" ><!--LEFTWARDS DOUBLE ARROW -->
<!ENTITY Leftrightarrow   "&#x021D4;" ><!--LEFT RIGHT DOUBLE ARROW -->
<!ENTITY LessEqualGreater "&#x022DA;" ><!--LESS-THAN EQUAL TO OR GREATER-THAN -->
<!ENTITY LessFullEqual    "&#x02266;" ><!--LESS-THAN OVER EQUAL TO -->
<!ENTITY LessGreater      "&#x02276;" ><!--LESS-THAN OR GREATER-THAN -->
<!ENTITY LessLess         "&#x02AA1;" ><!--DOUBLE NESTED LESS-THAN -->
<!ENTITY LessSlantEqual   "&#x02A7D;" ><!--LESS-THAN OR SLANTED EQUAL TO -->
<!ENTITY LessTilde        "&#x02272;" ><!--LESS-THAN OR EQUIVALENT TO -->
<!ENTITY Lfr              "&#x1D50F;" ><!--MATHEMATICAL FRAKTUR CAPITAL L -->
<!ENTITY Lgr              "&#x0039B;" ><!--GREEK CAPITAL LETTER LAMDA -->
<!ENTITY Ll               "&#x022D8;" ><!--VERY MUCH LESS-THAN -->
<!ENTITY Lleftarrow       "&#x021DA;" ><!--LEFTWARDS TRIPLE ARROW -->
<!ENTITY Lmidot           "&#x0013F;" ><!--LATIN CAPITAL LETTER L WITH MIDDLE DOT -->
<!ENTITY LongLeftArrow    "&#x027F5;" ><!--LONG LEFTWARDS ARROW -->
<!ENTITY LongLeftRightArrow "&#x027F7;" ><!--LONG LEFT RIGHT ARROW -->
<!ENTITY LongRightArrow   "&#x027F6;" ><!--LONG RIGHTWARDS ARROW -->
<!ENTITY Longleftarrow    "&#x027F8;" ><!--LONG LEFTWARDS DOUBLE ARROW -->
<!ENTITY Longleftrightarrow "&#x027FA;" ><!--LONG LEFT RIGHT DOUBLE ARROW -->
<!ENTITY Longrightarrow   "&#x027F9;" ><!--LONG RIGHTWARDS DOUBLE ARROW -->
<!ENTITY Lopf             "&#x1D543;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL L -->
<!ENTITY LowerLeftArrow   "&#x02199;" ><!--SOUTH WEST ARROW -->
<!ENTITY LowerRightArrow  "&#x02198;" ><!--SOUTH EAST ARROW -->
<!ENTITY Lscr             "&#x02112;" ><!--SCRIPT CAPITAL L -->
<!ENTITY Lsh              "&#x021B0;" ><!--UPWARDS ARROW WITH TIP LEFTWARDS -->
<!ENTITY Lstrok           "&#x00141;" ><!--LATIN CAPITAL LETTER L WITH STROKE -->
<!ENTITY Lt               "&#x0226A;" ><!--MUCH LESS-THAN -->
<!ENTITY Map              "&#x02905;" ><!--RIGHTWARDS TWO-HEADED ARROW FROM BAR -->
<!ENTITY Mcy              "&#x0041C;" ><!--CYRILLIC CAPITAL LETTER EM -->
<!ENTITY MediumSpace      "&#x0205F;" ><!--MEDIUM MATHEMATICAL SPACE -->
<!ENTITY Mellintrf        "&#x02133;" ><!--SCRIPT CAPITAL M -->
<!ENTITY Mfr              "&#x1D510;" ><!--MATHEMATICAL FRAKTUR CAPITAL M -->
<!ENTITY Mgr              "&#x0039C;" ><!--GREEK CAPITAL LETTER MU -->
<!ENTITY MinusPlus        "&#x02213;" ><!--MINUS-OR-PLUS SIGN -->
<!ENTITY Mopf             "&#x1D544;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL M -->
<!ENTITY Mscr             "&#x02133;" ><!--SCRIPT CAPITAL M -->
<!ENTITY Mu               "&#x0039C;" ><!--GREEK CAPITAL LETTER MU -->
<!ENTITY NJcy             "&#x0040A;" ><!--CYRILLIC CAPITAL LETTER NJE -->
<!ENTITY Nacute           "&#x00143;" ><!--LATIN CAPITAL LETTER N WITH ACUTE -->
<!ENTITY Ncaron           "&#x00147;" ><!--LATIN CAPITAL LETTER N WITH CARON -->
<!ENTITY Ncedil           "&#x00145;" ><!--LATIN CAPITAL LETTER N WITH CEDILLA -->
<!ENTITY Ncy              "&#x0041D;" ><!--CYRILLIC CAPITAL LETTER EN -->
<!ENTITY NegativeMediumSpace "&#x0200B;" ><!--ZERO WIDTH SPACE -->
<!ENTITY NegativeThickSpace "&#x0200B;" ><!--ZERO WIDTH SPACE -->
<!ENTITY NegativeThinSpace "&#x0200B;" ><!--ZERO WIDTH SPACE -->
<!ENTITY NegativeVeryThinSpace "&#x0200B;" ><!--ZERO WIDTH SPACE -->
<!ENTITY NestedGreaterGreater "&#x0226B;" ><!--MUCH GREATER-THAN -->
<!ENTITY NestedLessLess   "&#x0226A;" ><!--MUCH LESS-THAN -->
<!ENTITY NewLine          "&#x0000A;" ><!--LINE FEED (LF) -->
<!ENTITY Nfr              "&#x1D511;" ><!--MATHEMATICAL FRAKTUR CAPITAL N -->
<!ENTITY Ngr              "&#x0039D;" ><!--GREEK CAPITAL LETTER NU -->
<!ENTITY NoBreak          "&#x02060;" ><!--WORD JOINER -->
<!ENTITY NonBreakingSpace "&#x000A0;" ><!--NO-BREAK SPACE -->
<!ENTITY Nopf             "&#x02115;" ><!--DOUBLE-STRUCK CAPITAL N -->
<!ENTITY Not              "&#x02AEC;" ><!--DOUBLE STROKE NOT SIGN -->
<!ENTITY NotCongruent     "&#x02262;" ><!--NOT IDENTICAL TO -->
<!ENTITY NotCupCap        "&#x0226D;" ><!--NOT EQUIVALENT TO -->
<!ENTITY NotDoubleVerticalBar "&#x02226;" ><!--NOT PARALLEL TO -->
<!ENTITY NotElement       "&#x02209;" ><!--NOT AN ELEMENT OF -->
<!ENTITY NotEqual         "&#x02260;" ><!--NOT EQUAL TO -->
<!ENTITY NotEqualTilde    "&#x02242;&#x00338;" ><!--MINUS TILDE with slash -->
<!ENTITY NotExists        "&#x02204;" ><!--THERE DOES NOT EXIST -->
<!ENTITY NotGreater       "&#x0226F;" ><!--NOT GREATER-THAN -->
<!ENTITY NotGreaterEqual  "&#x02271;" ><!--NEITHER GREATER-THAN NOR EQUAL TO -->
<!ENTITY NotGreaterFullEqual "&#x02267;&#x00338;" ><!--GREATER-THAN OVER EQUAL TO with slash -->
<!ENTITY NotGreaterGreater "&#x0226B;&#x00338;" ><!--MUCH GREATER THAN with slash -->
<!ENTITY NotGreaterLess   "&#x02279;" ><!--NEITHER GREATER-THAN NOR LESS-THAN -->
<!ENTITY NotGreaterSlantEqual "&#x02A7E;&#x00338;" ><!--GREATER-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY NotGreaterTilde  "&#x02275;" ><!--NEITHER GREATER-THAN NOR EQUIVALENT TO -->
<!ENTITY NotHumpDownHump  "&#x0224E;&#x00338;" ><!--GEOMETRICALLY EQUIVALENT TO with slash -->
<!ENTITY NotHumpEqual     "&#x0224F;&#x00338;" ><!--DIFFERENCE BETWEEN with slash -->
<!ENTITY NotLeftTriangle  "&#x022EA;" ><!--NOT NORMAL SUBGROUP OF -->
<!ENTITY NotLeftTriangleBar "&#x029CF;&#x00338;" ><!--LEFT TRIANGLE BESIDE VERTICAL BAR with slash -->
<!ENTITY NotLeftTriangleEqual "&#x022EC;" ><!--NOT NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY NotLess          "&#x0226E;" ><!--NOT LESS-THAN -->
<!ENTITY NotLessEqual     "&#x02270;" ><!--NEITHER LESS-THAN NOR EQUAL TO -->
<!ENTITY NotLessGreater   "&#x02278;" ><!--NEITHER LESS-THAN NOR GREATER-THAN -->
<!ENTITY NotLessLess      "&#x0226A;&#x00338;" ><!--MUCH LESS THAN with slash -->
<!ENTITY NotLessSlantEqual "&#x02A7D;&#x00338;" ><!--LESS-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY NotLessTilde     "&#x02274;" ><!--NEITHER LESS-THAN NOR EQUIVALENT TO -->
<!ENTITY NotNestedGreaterGreater "&#x02AA2;&#x00338;" ><!--DOUBLE NESTED GREATER-THAN with slash -->
<!ENTITY NotNestedLessLess "&#x02AA1;&#x00338;" ><!--DOUBLE NESTED LESS-THAN with slash -->
<!ENTITY NotPrecedes      "&#x02280;" ><!--DOES NOT PRECEDE -->
<!ENTITY NotPrecedesEqual "&#x02AAF;&#x00338;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY NotPrecedesSlantEqual "&#x022E0;" ><!--DOES NOT PRECEDE OR EQUAL -->
<!ENTITY NotReverseElement "&#x0220C;" ><!--DOES NOT CONTAIN AS MEMBER -->
<!ENTITY NotRightTriangle "&#x022EB;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP -->
<!ENTITY NotRightTriangleBar "&#x029D0;&#x00338;" ><!--VERTICAL BAR BESIDE RIGHT TRIANGLE with slash -->
<!ENTITY NotRightTriangleEqual "&#x022ED;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL -->
<!ENTITY NotSquareSubset  "&#x0228F;&#x00338;" ><!--SQUARE IMAGE OF with slash -->
<!ENTITY NotSquareSubsetEqual "&#x022E2;" ><!--NOT SQUARE IMAGE OF OR EQUAL TO -->
<!ENTITY NotSquareSuperset "&#x02290;&#x00338;" ><!--SQUARE ORIGINAL OF with slash -->
<!ENTITY NotSquareSupersetEqual "&#x022E3;" ><!--NOT SQUARE ORIGINAL OF OR EQUAL TO -->
<!ENTITY NotSubset        "&#x02282;&#x020D2;" ><!--SUBSET OF with vertical line -->
<!ENTITY NotSubsetEqual   "&#x02288;" ><!--NEITHER A SUBSET OF NOR EQUAL TO -->
<!ENTITY NotSucceeds      "&#x02281;" ><!--DOES NOT SUCCEED -->
<!ENTITY NotSucceedsEqual "&#x02AB0;&#x00338;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY NotSucceedsSlantEqual "&#x022E1;" ><!--DOES NOT SUCCEED OR EQUAL -->
<!ENTITY NotSucceedsTilde "&#x0227F;&#x00338;" ><!--SUCCEEDS OR EQUIVALENT TO with slash -->
<!ENTITY NotSuperset      "&#x02283;&#x020D2;" ><!--SUPERSET OF with vertical line -->
<!ENTITY NotSupersetEqual "&#x02289;" ><!--NEITHER A SUPERSET OF NOR EQUAL TO -->
<!ENTITY NotTilde         "&#x02241;" ><!--NOT TILDE -->
<!ENTITY NotTildeEqual    "&#x02244;" ><!--NOT ASYMPTOTICALLY EQUAL TO -->
<!ENTITY NotTildeFullEqual "&#x02247;" ><!--NEITHER APPROXIMATELY NOR ACTUALLY EQUAL TO -->
<!ENTITY NotTildeTilde    "&#x02249;" ><!--NOT ALMOST EQUAL TO -->
<!ENTITY NotVerticalBar   "&#x02224;" ><!--DOES NOT DIVIDE -->
<!ENTITY Nscr             "&#x1D4A9;" ><!--MATHEMATICAL SCRIPT CAPITAL N -->
<!ENTITY Ntilde           "&#x000D1;" ><!--LATIN CAPITAL LETTER N WITH TILDE -->
<!ENTITY Nu               "&#x0039D;" ><!--GREEK CAPITAL LETTER NU -->
<!ENTITY OElig            "&#x00152;" ><!--LATIN CAPITAL LIGATURE OE -->
<!ENTITY OHacgr           "&#x0038F;" ><!--GREEK CAPITAL LETTER OMEGA WITH TONOS -->
<!ENTITY OHgr             "&#x003A9;" ><!--GREEK CAPITAL LETTER OMEGA -->
<!ENTITY Oacgr            "&#x0038C;" ><!--GREEK CAPITAL LETTER OMICRON WITH TONOS -->
<!ENTITY Oacute           "&#x000D3;" ><!--LATIN CAPITAL LETTER O WITH ACUTE -->
<!ENTITY Ocirc            "&#x000D4;" ><!--LATIN CAPITAL LETTER O WITH CIRCUMFLEX -->
<!ENTITY Ocy              "&#x0041E;" ><!--CYRILLIC CAPITAL LETTER O -->
<!ENTITY Odblac           "&#x00150;" ><!--LATIN CAPITAL LETTER O WITH DOUBLE ACUTE -->
<!ENTITY Ofr              "&#x1D512;" ><!--MATHEMATICAL FRAKTUR CAPITAL O -->
<!ENTITY Ogr              "&#x0039F;" ><!--GREEK CAPITAL LETTER OMICRON -->
<!ENTITY Ograve           "&#x000D2;" ><!--LATIN CAPITAL LETTER O WITH GRAVE -->
<!ENTITY Omacr            "&#x0014C;" ><!--LATIN CAPITAL LETTER O WITH MACRON -->
<!ENTITY Omega            "&#x003A9;" ><!--GREEK CAPITAL LETTER OMEGA -->
<!ENTITY Omicron          "&#x0039F;" ><!--GREEK CAPITAL LETTER OMICRON -->
<!ENTITY Oopf             "&#x1D546;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL O -->
<!ENTITY OpenCurlyDoubleQuote "&#x0201C;" ><!--LEFT DOUBLE QUOTATION MARK -->
<!ENTITY OpenCurlyQuote   "&#x02018;" ><!--LEFT SINGLE QUOTATION MARK -->
<!ENTITY Or               "&#x02A54;" ><!--DOUBLE LOGICAL OR -->
<!ENTITY Oscr             "&#x1D4AA;" ><!--MATHEMATICAL SCRIPT CAPITAL O -->
<!ENTITY Oslash           "&#x000D8;" ><!--LATIN CAPITAL LETTER O WITH STROKE -->
<!ENTITY Otilde           "&#x000D5;" ><!--LATIN CAPITAL LETTER O WITH TILDE -->
<!ENTITY Otimes           "&#x02A37;" ><!--MULTIPLICATION SIGN IN DOUBLE CIRCLE -->
<!ENTITY Ouml             "&#x000D6;" ><!--LATIN CAPITAL LETTER O WITH DIAERESIS -->
<!ENTITY OverBar          "&#x0203E;" ><!--OVERLINE -->
<!ENTITY OverBrace        "&#x023DE;" ><!--TOP CURLY BRACKET -->
<!ENTITY OverBracket      "&#x023B4;" ><!--TOP SQUARE BRACKET -->
<!ENTITY OverParenthesis  "&#x023DC;" ><!--TOP PARENTHESIS -->
<!ENTITY PHgr             "&#x003A6;" ><!--GREEK CAPITAL LETTER PHI -->
<!ENTITY PSgr             "&#x003A8;" ><!--GREEK CAPITAL LETTER PSI -->
<!ENTITY PartialD         "&#x02202;" ><!--PARTIAL DIFFERENTIAL -->
<!ENTITY Pcy              "&#x0041F;" ><!--CYRILLIC CAPITAL LETTER PE -->
<!ENTITY Pfr              "&#x1D513;" ><!--MATHEMATICAL FRAKTUR CAPITAL P -->
<!ENTITY Pgr              "&#x003A0;" ><!--GREEK CAPITAL LETTER PI -->
<!ENTITY Phi              "&#x003A6;" ><!--GREEK CAPITAL LETTER PHI -->
<!ENTITY Pi               "&#x003A0;" ><!--GREEK CAPITAL LETTER PI -->
<!ENTITY PlusMinus        "&#x000B1;" ><!--PLUS-MINUS SIGN -->
<!ENTITY Poincareplane    "&#x0210C;" ><!--BLACK-LETTER CAPITAL H -->
<!ENTITY Popf             "&#x02119;" ><!--DOUBLE-STRUCK CAPITAL P -->
<!ENTITY Pr               "&#x02ABB;" ><!--DOUBLE PRECEDES -->
<!ENTITY Precedes         "&#x0227A;" ><!--PRECEDES -->
<!ENTITY PrecedesEqual    "&#x02AAF;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY PrecedesSlantEqual "&#x0227C;" ><!--PRECEDES OR EQUAL TO -->
<!ENTITY PrecedesTilde    "&#x0227E;" ><!--PRECEDES OR EQUIVALENT TO -->
<!ENTITY Prime            "&#x02033;" ><!--DOUBLE PRIME -->
<!ENTITY Product          "&#x0220F;" ><!--N-ARY PRODUCT -->
<!ENTITY Proportion       "&#x02237;" ><!--PROPORTION -->
<!ENTITY Proportional     "&#x0221D;" ><!--PROPORTIONAL TO -->
<!ENTITY Pscr             "&#x1D4AB;" ><!--MATHEMATICAL SCRIPT CAPITAL P -->
<!ENTITY Psi              "&#x003A8;" ><!--GREEK CAPITAL LETTER PSI -->
<!ENTITY QUOT             "&#x00022;" ><!--QUOTATION MARK -->
<!ENTITY Qfr              "&#x1D514;" ><!--MATHEMATICAL FRAKTUR CAPITAL Q -->
<!ENTITY Qopf             "&#x0211A;" ><!--DOUBLE-STRUCK CAPITAL Q -->
<!ENTITY Qscr             "&#x1D4AC;" ><!--MATHEMATICAL SCRIPT CAPITAL Q -->
<!ENTITY RBarr            "&#x02910;" ><!--RIGHTWARDS TWO-HEADED TRIPLE DASH ARROW -->
<!ENTITY REG              "&#x000AE;" ><!--REGISTERED SIGN -->
<!ENTITY Racute           "&#x00154;" ><!--LATIN CAPITAL LETTER R WITH ACUTE -->
<!ENTITY Rang             "&#x027EB;" ><!--MATHEMATICAL RIGHT DOUBLE ANGLE BRACKET -->
<!ENTITY Rarr             "&#x021A0;" ><!--RIGHTWARDS TWO HEADED ARROW -->
<!ENTITY Rarrtl           "&#x02916;" ><!--RIGHTWARDS TWO-HEADED ARROW WITH TAIL -->
<!ENTITY Rcaron           "&#x00158;" ><!--LATIN CAPITAL LETTER R WITH CARON -->
<!ENTITY Rcedil           "&#x00156;" ><!--LATIN CAPITAL LETTER R WITH CEDILLA -->
<!ENTITY Rcy              "&#x00420;" ><!--CYRILLIC CAPITAL LETTER ER -->
<!ENTITY Re               "&#x0211C;" ><!--BLACK-LETTER CAPITAL R -->
<!ENTITY ReverseElement   "&#x0220B;" ><!--CONTAINS AS MEMBER -->
<!ENTITY ReverseEquilibrium "&#x021CB;" ><!--LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON -->
<!ENTITY ReverseUpEquilibrium "&#x0296F;" ><!--DOWNWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY Rfr              "&#x0211C;" ><!--BLACK-LETTER CAPITAL R -->
<!ENTITY Rgr              "&#x003A1;" ><!--GREEK CAPITAL LETTER RHO -->
<!ENTITY Rho              "&#x003A1;" ><!--GREEK CAPITAL LETTER RHO -->
<!ENTITY RightAngleBracket "&#x027E9;" ><!--MATHEMATICAL RIGHT ANGLE BRACKET -->
<!ENTITY RightArrow       "&#x02192;" ><!--RIGHTWARDS ARROW -->
<!ENTITY RightArrowBar    "&#x021E5;" ><!--RIGHTWARDS ARROW TO BAR -->
<!ENTITY RightArrowLeftArrow "&#x021C4;" ><!--RIGHTWARDS ARROW OVER LEFTWARDS ARROW -->
<!ENTITY RightCeiling     "&#x02309;" ><!--RIGHT CEILING -->
<!ENTITY RightDoubleBracket "&#x027E7;" ><!--MATHEMATICAL RIGHT WHITE SQUARE BRACKET -->
<!ENTITY RightDownTeeVector "&#x0295D;" ><!--DOWNWARDS HARPOON WITH BARB RIGHT FROM BAR -->
<!ENTITY RightDownVector  "&#x021C2;" ><!--DOWNWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY RightDownVectorBar "&#x02955;" ><!--DOWNWARDS HARPOON WITH BARB RIGHT TO BAR -->
<!ENTITY RightFloor       "&#x0230B;" ><!--RIGHT FLOOR -->
<!ENTITY RightTee         "&#x022A2;" ><!--RIGHT TACK -->
<!ENTITY RightTeeArrow    "&#x021A6;" ><!--RIGHTWARDS ARROW FROM BAR -->
<!ENTITY RightTeeVector   "&#x0295B;" ><!--RIGHTWARDS HARPOON WITH BARB UP FROM BAR -->
<!ENTITY RightTriangle    "&#x022B3;" ><!--CONTAINS AS NORMAL SUBGROUP -->
<!ENTITY RightTriangleBar "&#x029D0;" ><!--VERTICAL BAR BESIDE RIGHT TRIANGLE -->
<!ENTITY RightTriangleEqual "&#x022B5;" ><!--CONTAINS AS NORMAL SUBGROUP OR EQUAL TO -->
<!ENTITY RightUpDownVector "&#x0294F;" ><!--UP BARB RIGHT DOWN BARB RIGHT HARPOON -->
<!ENTITY RightUpTeeVector "&#x0295C;" ><!--UPWARDS HARPOON WITH BARB RIGHT FROM BAR -->
<!ENTITY RightUpVector    "&#x021BE;" ><!--UPWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY RightUpVectorBar "&#x02954;" ><!--UPWARDS HARPOON WITH BARB RIGHT TO BAR -->
<!ENTITY RightVector      "&#x021C0;" ><!--RIGHTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY RightVectorBar   "&#x02953;" ><!--RIGHTWARDS HARPOON WITH BARB UP TO BAR -->
<!ENTITY Rightarrow       "&#x021D2;" ><!--RIGHTWARDS DOUBLE ARROW -->
<!ENTITY Ropf             "&#x0211D;" ><!--DOUBLE-STRUCK CAPITAL R -->
<!ENTITY RoundImplies     "&#x02970;" ><!--RIGHT DOUBLE ARROW WITH ROUNDED HEAD -->
<!ENTITY Rrightarrow      "&#x021DB;" ><!--RIGHTWARDS TRIPLE ARROW -->
<!ENTITY Rscr             "&#x0211B;" ><!--SCRIPT CAPITAL R -->
<!ENTITY Rsh              "&#x021B1;" ><!--UPWARDS ARROW WITH TIP RIGHTWARDS -->
<!ENTITY RuleDelayed      "&#x029F4;" ><!--RULE-DELAYED -->
<!ENTITY SHCHcy           "&#x00429;" ><!--CYRILLIC CAPITAL LETTER SHCHA -->
<!ENTITY SHcy             "&#x00428;" ><!--CYRILLIC CAPITAL LETTER SHA -->
<!ENTITY SOFTcy           "&#x0042C;" ><!--CYRILLIC CAPITAL LETTER SOFT SIGN -->
<!ENTITY Sacute           "&#x0015A;" ><!--LATIN CAPITAL LETTER S WITH ACUTE -->
<!ENTITY Sc               "&#x02ABC;" ><!--DOUBLE SUCCEEDS -->
<!ENTITY Scaron           "&#x00160;" ><!--LATIN CAPITAL LETTER S WITH CARON -->
<!ENTITY Scedil           "&#x0015E;" ><!--LATIN CAPITAL LETTER S WITH CEDILLA -->
<!ENTITY Scirc            "&#x0015C;" ><!--LATIN CAPITAL LETTER S WITH CIRCUMFLEX -->
<!ENTITY Scy              "&#x00421;" ><!--CYRILLIC CAPITAL LETTER ES -->
<!ENTITY Sfr              "&#x1D516;" ><!--MATHEMATICAL FRAKTUR CAPITAL S -->
<!ENTITY Sgr              "&#x003A3;" ><!--GREEK CAPITAL LETTER SIGMA -->
<!ENTITY ShortDownArrow   "&#x02193;" ><!--DOWNWARDS ARROW -->
<!ENTITY ShortLeftArrow   "&#x02190;" ><!--LEFTWARDS ARROW -->
<!ENTITY ShortRightArrow  "&#x02192;" ><!--RIGHTWARDS ARROW -->
<!ENTITY ShortUpArrow     "&#x02191;" ><!--UPWARDS ARROW -->
<!ENTITY Sigma            "&#x003A3;" ><!--GREEK CAPITAL LETTER SIGMA -->
<!ENTITY SmallCircle      "&#x02218;" ><!--RING OPERATOR -->
<!ENTITY Sopf             "&#x1D54A;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL S -->
<!ENTITY Sqrt             "&#x0221A;" ><!--SQUARE ROOT -->
<!ENTITY Square           "&#x025A1;" ><!--WHITE SQUARE -->
<!ENTITY SquareIntersection "&#x02293;" ><!--SQUARE CAP -->
<!ENTITY SquareSubset     "&#x0228F;" ><!--SQUARE IMAGE OF -->
<!ENTITY SquareSubsetEqual "&#x02291;" ><!--SQUARE IMAGE OF OR EQUAL TO -->
<!ENTITY SquareSuperset   "&#x02290;" ><!--SQUARE ORIGINAL OF -->
<!ENTITY SquareSupersetEqual "&#x02292;" ><!--SQUARE ORIGINAL OF OR EQUAL TO -->
<!ENTITY SquareUnion      "&#x02294;" ><!--SQUARE CUP -->
<!ENTITY Sscr             "&#x1D4AE;" ><!--MATHEMATICAL SCRIPT CAPITAL S -->
<!ENTITY Star             "&#x022C6;" ><!--STAR OPERATOR -->
<!ENTITY Sub              "&#x022D0;" ><!--DOUBLE SUBSET -->
<!ENTITY Subset           "&#x022D0;" ><!--DOUBLE SUBSET -->
<!ENTITY SubsetEqual      "&#x02286;" ><!--SUBSET OF OR EQUAL TO -->
<!ENTITY Succeeds         "&#x0227B;" ><!--SUCCEEDS -->
<!ENTITY SucceedsEqual    "&#x02AB0;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY SucceedsSlantEqual "&#x0227D;" ><!--SUCCEEDS OR EQUAL TO -->
<!ENTITY SucceedsTilde    "&#x0227F;" ><!--SUCCEEDS OR EQUIVALENT TO -->
<!ENTITY SuchThat         "&#x0220B;" ><!--CONTAINS AS MEMBER -->
<!ENTITY Sum              "&#x02211;" ><!--N-ARY SUMMATION -->
<!ENTITY Sup              "&#x022D1;" ><!--DOUBLE SUPERSET -->
<!ENTITY Superset         "&#x02283;" ><!--SUPERSET OF -->
<!ENTITY SupersetEqual    "&#x02287;" ><!--SUPERSET OF OR EQUAL TO -->
<!ENTITY Supset           "&#x022D1;" ><!--DOUBLE SUPERSET -->
<!ENTITY THORN            "&#x000DE;" ><!--LATIN CAPITAL LETTER THORN -->
<!ENTITY THgr             "&#x00398;" ><!--GREEK CAPITAL LETTER THETA -->
<!ENTITY TRADE            "&#x02122;" ><!--TRADE MARK SIGN -->
<!ENTITY TSHcy            "&#x0040B;" ><!--CYRILLIC CAPITAL LETTER TSHE -->
<!ENTITY TScy             "&#x00426;" ><!--CYRILLIC CAPITAL LETTER TSE -->
<!ENTITY Tab              "&#x00009;" ><!--CHARACTER TABULATION -->
<!ENTITY Tau              "&#x003A4;" ><!--GREEK CAPITAL LETTER TAU -->
<!ENTITY Tcaron           "&#x00164;" ><!--LATIN CAPITAL LETTER T WITH CARON -->
<!ENTITY Tcedil           "&#x00162;" ><!--LATIN CAPITAL LETTER T WITH CEDILLA -->
<!ENTITY Tcy              "&#x00422;" ><!--CYRILLIC CAPITAL LETTER TE -->
<!ENTITY Tfr              "&#x1D517;" ><!--MATHEMATICAL FRAKTUR CAPITAL T -->
<!ENTITY Tgr              "&#x003A4;" ><!--GREEK CAPITAL LETTER TAU -->
<!ENTITY Therefore        "&#x02234;" ><!--THEREFORE -->
<!ENTITY Theta            "&#x00398;" ><!--GREEK CAPITAL LETTER THETA -->
<!ENTITY ThickSpace       "&#x0205F;&#x0200A;" ><!--space of width 5/18 em -->
<!ENTITY ThinSpace        "&#x02009;" ><!--THIN SPACE -->
<!ENTITY Tilde            "&#x0223C;" ><!--TILDE OPERATOR -->
<!ENTITY TildeEqual       "&#x02243;" ><!--ASYMPTOTICALLY EQUAL TO -->
<!ENTITY TildeFullEqual   "&#x02245;" ><!--APPROXIMATELY EQUAL TO -->
<!ENTITY TildeTilde       "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY Topf             "&#x1D54B;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL T -->
<!ENTITY TripleDot        " &#x020DB;" ><!--COMBINING THREE DOTS ABOVE -->
<!ENTITY Tscr             "&#x1D4AF;" ><!--MATHEMATICAL SCRIPT CAPITAL T -->
<!ENTITY Tstrok           "&#x00166;" ><!--LATIN CAPITAL LETTER T WITH STROKE -->
<!ENTITY Uacgr            "&#x0038E;" ><!--GREEK CAPITAL LETTER UPSILON WITH TONOS -->
<!ENTITY Uacute           "&#x000DA;" ><!--LATIN CAPITAL LETTER U WITH ACUTE -->
<!ENTITY Uarr             "&#x0219F;" ><!--UPWARDS TWO HEADED ARROW -->
<!ENTITY Uarrocir         "&#x02949;" ><!--UPWARDS TWO-HEADED ARROW FROM SMALL CIRCLE -->
<!ENTITY Ubrcy            "&#x0040E;" ><!--CYRILLIC CAPITAL LETTER SHORT U -->
<!ENTITY Ubreve           "&#x0016C;" ><!--LATIN CAPITAL LETTER U WITH BREVE -->
<!ENTITY Ucirc            "&#x000DB;" ><!--LATIN CAPITAL LETTER U WITH CIRCUMFLEX -->
<!ENTITY Ucy              "&#x00423;" ><!--CYRILLIC CAPITAL LETTER U -->
<!ENTITY Udblac           "&#x00170;" ><!--LATIN CAPITAL LETTER U WITH DOUBLE ACUTE -->
<!ENTITY Udigr            "&#x003AB;" ><!--GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA -->
<!ENTITY Ufr              "&#x1D518;" ><!--MATHEMATICAL FRAKTUR CAPITAL U -->
<!ENTITY Ugr              "&#x003A5;" ><!--GREEK CAPITAL LETTER UPSILON -->
<!ENTITY Ugrave           "&#x000D9;" ><!--LATIN CAPITAL LETTER U WITH GRAVE -->
<!ENTITY Umacr            "&#x0016A;" ><!--LATIN CAPITAL LETTER U WITH MACRON -->
<!ENTITY UnderBar         "&#x0005F;" ><!--LOW LINE -->
<!ENTITY UnderBrace       "&#x023DF;" ><!--BOTTOM CURLY BRACKET -->
<!ENTITY UnderBracket     "&#x023B5;" ><!--BOTTOM SQUARE BRACKET -->
<!ENTITY UnderParenthesis "&#x023DD;" ><!--BOTTOM PARENTHESIS -->
<!ENTITY Union            "&#x022C3;" ><!--N-ARY UNION -->
<!ENTITY UnionPlus        "&#x0228E;" ><!--MULTISET UNION -->
<!ENTITY Uogon            "&#x00172;" ><!--LATIN CAPITAL LETTER U WITH OGONEK -->
<!ENTITY Uopf             "&#x1D54C;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL U -->
<!ENTITY UpArrow          "&#x02191;" ><!--UPWARDS ARROW -->
<!ENTITY UpArrowBar       "&#x02912;" ><!--UPWARDS ARROW TO BAR -->
<!ENTITY UpArrowDownArrow "&#x021C5;" ><!--UPWARDS ARROW LEFTWARDS OF DOWNWARDS ARROW -->
<!ENTITY UpDownArrow      "&#x02195;" ><!--UP DOWN ARROW -->
<!ENTITY UpEquilibrium    "&#x0296E;" ><!--UPWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY UpTee            "&#x022A5;" ><!--UP TACK -->
<!ENTITY UpTeeArrow       "&#x021A5;" ><!--UPWARDS ARROW FROM BAR -->
<!ENTITY Uparrow          "&#x021D1;" ><!--UPWARDS DOUBLE ARROW -->
<!ENTITY Updownarrow      "&#x021D5;" ><!--UP DOWN DOUBLE ARROW -->
<!ENTITY UpperLeftArrow   "&#x02196;" ><!--NORTH WEST ARROW -->
<!ENTITY UpperRightArrow  "&#x02197;" ><!--NORTH EAST ARROW -->
<!ENTITY Upsi             "&#x003D2;" ><!--GREEK UPSILON WITH HOOK SYMBOL -->
<!ENTITY Upsilon          "&#x003A5;" ><!--GREEK CAPITAL LETTER UPSILON -->
<!ENTITY Uring            "&#x0016E;" ><!--LATIN CAPITAL LETTER U WITH RING ABOVE -->
<!ENTITY Uscr             "&#x1D4B0;" ><!--MATHEMATICAL SCRIPT CAPITAL U -->
<!ENTITY Utilde           "&#x00168;" ><!--LATIN CAPITAL LETTER U WITH TILDE -->
<!ENTITY Uuml             "&#x000DC;" ><!--LATIN CAPITAL LETTER U WITH DIAERESIS -->
<!ENTITY VDash            "&#x022AB;" ><!--DOUBLE VERTICAL BAR DOUBLE RIGHT TURNSTILE -->
<!ENTITY Vbar             "&#x02AEB;" ><!--DOUBLE UP TACK -->
<!ENTITY Vcy              "&#x00412;" ><!--CYRILLIC CAPITAL LETTER VE -->
<!ENTITY Vdash            "&#x022A9;" ><!--FORCES -->
<!ENTITY Vdashl           "&#x02AE6;" ><!--LONG DASH FROM LEFT MEMBER OF DOUBLE VERTICAL -->
<!ENTITY Vee              "&#x022C1;" ><!--N-ARY LOGICAL OR -->
<!ENTITY Verbar           "&#x02016;" ><!--DOUBLE VERTICAL LINE -->
<!ENTITY Vert             "&#x02016;" ><!--DOUBLE VERTICAL LINE -->
<!ENTITY VerticalBar      "&#x02223;" ><!--DIVIDES -->
<!ENTITY VerticalLine     "&#x0007C;" ><!--VERTICAL LINE -->
<!ENTITY VerticalSeparator "&#x02758;" ><!--LIGHT VERTICAL BAR -->
<!ENTITY VerticalTilde    "&#x02240;" ><!--WREATH PRODUCT -->
<!ENTITY VeryThinSpace    "&#x0200A;" ><!--HAIR SPACE -->
<!ENTITY Vfr              "&#x1D519;" ><!--MATHEMATICAL FRAKTUR CAPITAL V -->
<!ENTITY Vopf             "&#x1D54D;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL V -->
<!ENTITY Vscr             "&#x1D4B1;" ><!--MATHEMATICAL SCRIPT CAPITAL V -->
<!ENTITY Vvdash           "&#x022AA;" ><!--TRIPLE VERTICAL BAR RIGHT TURNSTILE -->
<!ENTITY Wcirc            "&#x00174;" ><!--LATIN CAPITAL LETTER W WITH CIRCUMFLEX -->
<!ENTITY Wedge            "&#x022C0;" ><!--N-ARY LOGICAL AND -->
<!ENTITY Wfr              "&#x1D51A;" ><!--MATHEMATICAL FRAKTUR CAPITAL W -->
<!ENTITY Wopf             "&#x1D54E;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL W -->
<!ENTITY Wscr             "&#x1D4B2;" ><!--MATHEMATICAL SCRIPT CAPITAL W -->
<!ENTITY Xfr              "&#x1D51B;" ><!--MATHEMATICAL FRAKTUR CAPITAL X -->
<!ENTITY Xgr              "&#x0039E;" ><!--GREEK CAPITAL LETTER XI -->
<!ENTITY Xi               "&#x0039E;" ><!--GREEK CAPITAL LETTER XI -->
<!ENTITY Xopf             "&#x1D54F;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL X -->
<!ENTITY Xscr             "&#x1D4B3;" ><!--MATHEMATICAL SCRIPT CAPITAL X -->
<!ENTITY YAcy             "&#x0042F;" ><!--CYRILLIC CAPITAL LETTER YA -->
<!ENTITY YIcy             "&#x00407;" ><!--CYRILLIC CAPITAL LETTER YI -->
<!ENTITY YUcy             "&#x0042E;" ><!--CYRILLIC CAPITAL LETTER YU -->
<!ENTITY Yacute           "&#x000DD;" ><!--LATIN CAPITAL LETTER Y WITH ACUTE -->
<!ENTITY Ycirc            "&#x00176;" ><!--LATIN CAPITAL LETTER Y WITH CIRCUMFLEX -->
<!ENTITY Ycy              "&#x0042B;" ><!--CYRILLIC CAPITAL LETTER YERU -->
<!ENTITY Yfr              "&#x1D51C;" ><!--MATHEMATICAL FRAKTUR CAPITAL Y -->
<!ENTITY Yopf             "&#x1D550;" ><!--MATHEMATICAL DOUBLE-STRUCK CAPITAL Y -->
<!ENTITY Yscr             "&#x1D4B4;" ><!--MATHEMATICAL SCRIPT CAPITAL Y -->
<!ENTITY Yuml             "&#x00178;" ><!--LATIN CAPITAL LETTER Y WITH DIAERESIS -->
<!ENTITY ZHcy             "&#x00416;" ><!--CYRILLIC CAPITAL LETTER ZHE -->
<!ENTITY Zacute           "&#x00179;" ><!--LATIN CAPITAL LETTER Z WITH ACUTE -->
<!ENTITY Zcaron           "&#x0017D;" ><!--LATIN CAPITAL LETTER Z WITH CARON -->
<!ENTITY Zcy              "&#x00417;" ><!--CYRILLIC CAPITAL LETTER ZE -->
<!ENTITY Zdot             "&#x0017B;" ><!--LATIN CAPITAL LETTER Z WITH DOT ABOVE -->
<!ENTITY ZeroWidthSpace   "&#x0200B;" ><!--ZERO WIDTH SPACE -->
<!ENTITY Zeta             "&#x00396;" ><!--GREEK CAPITAL LETTER ZETA -->
<!ENTITY Zfr              "&#x02128;" ><!--BLACK-LETTER CAPITAL Z -->
<!ENTITY Zgr              "&#x00396;" ><!--GREEK CAPITAL LETTER ZETA -->
<!ENTITY Zopf             "&#x02124;" ><!--DOUBLE-STRUCK CAPITAL Z -->
<!ENTITY Zscr             "&#x1D4B5;" ><!--MATHEMATICAL SCRIPT CAPITAL Z -->
<!ENTITY aacgr            "&#x003AC;" ><!--GREEK SMALL LETTER ALPHA WITH TONOS -->
<!ENTITY aacute           "&#x000E1;" ><!--LATIN SMALL LETTER A WITH ACUTE -->
<!ENTITY abreve           "&#x00103;" ><!--LATIN SMALL LETTER A WITH BREVE -->
<!ENTITY ac               "&#x0223E;" ><!--INVERTED LAZY S -->
<!ENTITY acE              "&#x0223E;&#x00333;" ><!--INVERTED LAZY S with double underline -->
<!ENTITY acd              "&#x0223F;" ><!--SINE WAVE -->
<!ENTITY acirc            "&#x000E2;" ><!--LATIN SMALL LETTER A WITH CIRCUMFLEX -->
<!ENTITY acute            "&#x000B4;" ><!--ACUTE ACCENT -->
<!ENTITY acy              "&#x00430;" ><!--CYRILLIC SMALL LETTER A -->
<!ENTITY aelig            "&#x000E6;" ><!--LATIN SMALL LETTER AE -->
<!ENTITY af               "&#x02061;" ><!--FUNCTION APPLICATION -->
<!ENTITY afr              "&#x1D51E;" ><!--MATHEMATICAL FRAKTUR SMALL A -->
<!ENTITY agr              "&#x003B1;" ><!--GREEK SMALL LETTER ALPHA -->
<!ENTITY agrave           "&#x000E0;" ><!--LATIN SMALL LETTER A WITH GRAVE -->
<!ENTITY alefsym          "&#x02135;" ><!--ALEF SYMBOL -->
<!ENTITY aleph            "&#x02135;" ><!--ALEF SYMBOL -->
<!ENTITY alpha            "&#x003B1;" ><!--GREEK SMALL LETTER ALPHA -->
<!ENTITY amacr            "&#x00101;" ><!--LATIN SMALL LETTER A WITH MACRON -->
<!ENTITY amalg            "&#x02A3F;" ><!--AMALGAMATION OR COPRODUCT -->
<!ENTITY amp              "&#38;#38;" ><!--AMPERSAND -->
<!ENTITY and              "&#x02227;" ><!--LOGICAL AND -->
<!ENTITY andand           "&#x02A55;" ><!--TWO INTERSECTING LOGICAL AND -->
<!ENTITY andd             "&#x02A5C;" ><!--LOGICAL AND WITH HORIZONTAL DASH -->
<!ENTITY andslope         "&#x02A58;" ><!--SLOPING LARGE AND -->
<!ENTITY andv             "&#x02A5A;" ><!--LOGICAL AND WITH MIDDLE STEM -->
<!ENTITY ang              "&#x02220;" ><!--ANGLE -->
<!ENTITY ange             "&#x029A4;" ><!--ANGLE WITH UNDERBAR -->
<!ENTITY angle            "&#x02220;" ><!--ANGLE -->
<!ENTITY angmsd           "&#x02221;" ><!--MEASURED ANGLE -->
<!ENTITY angmsdaa         "&#x029A8;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING UP AND RIGHT -->
<!ENTITY angmsdab         "&#x029A9;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING UP AND LEFT -->
<!ENTITY angmsdac         "&#x029AA;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING DOWN AND RIGHT -->
<!ENTITY angmsdad         "&#x029AB;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING DOWN AND LEFT -->
<!ENTITY angmsdae         "&#x029AC;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING RIGHT AND UP -->
<!ENTITY angmsdaf         "&#x029AD;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING LEFT AND UP -->
<!ENTITY angmsdag         "&#x029AE;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING RIGHT AND DOWN -->
<!ENTITY angmsdah         "&#x029AF;" ><!--MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING LEFT AND DOWN -->
<!ENTITY angrt            "&#x0221F;" ><!--RIGHT ANGLE -->
<!ENTITY angrtvb          "&#x022BE;" ><!--RIGHT ANGLE WITH ARC -->
<!ENTITY angrtvbd         "&#x0299D;" ><!--MEASURED RIGHT ANGLE WITH DOT -->
<!ENTITY angsph           "&#x02222;" ><!--SPHERICAL ANGLE -->
<!ENTITY angst            "&#x000C5;" ><!--LATIN CAPITAL LETTER A WITH RING ABOVE -->
<!ENTITY angzarr          "&#x0237C;" ><!--RIGHT ANGLE WITH DOWNWARDS ZIGZAG ARROW -->
<!ENTITY aogon            "&#x00105;" ><!--LATIN SMALL LETTER A WITH OGONEK -->
<!ENTITY aopf             "&#x1D552;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL A -->
<!ENTITY ap               "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY apE              "&#x02A70;" ><!--APPROXIMATELY EQUAL OR EQUAL TO -->
<!ENTITY apacir           "&#x02A6F;" ><!--ALMOST EQUAL TO WITH CIRCUMFLEX ACCENT -->
<!ENTITY ape              "&#x0224A;" ><!--ALMOST EQUAL OR EQUAL TO -->
<!ENTITY apid             "&#x0224B;" ><!--TRIPLE TILDE -->
<!ENTITY apos             "&#x00027;" ><!--APOSTROPHE -->
<!ENTITY approx           "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY approxeq         "&#x0224A;" ><!--ALMOST EQUAL OR EQUAL TO -->
<!ENTITY aring            "&#x000E5;" ><!--LATIN SMALL LETTER A WITH RING ABOVE -->
<!ENTITY ascr             "&#x1D4B6;" ><!--MATHEMATICAL SCRIPT SMALL A -->
<!ENTITY ast              "&#x0002A;" ><!--ASTERISK -->
<!ENTITY asymp            "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY asympeq          "&#x0224D;" ><!--EQUIVALENT TO -->
<!ENTITY atilde           "&#x000E3;" ><!--LATIN SMALL LETTER A WITH TILDE -->
<!ENTITY auml             "&#x000E4;" ><!--LATIN SMALL LETTER A WITH DIAERESIS -->
<!ENTITY awconint         "&#x02233;" ><!--ANTICLOCKWISE CONTOUR INTEGRAL -->
<!ENTITY awint            "&#x02A11;" ><!--ANTICLOCKWISE INTEGRATION -->
<!ENTITY b.Delta          "&#x1D6AB;" ><!--MATHEMATICAL BOLD CAPITAL DELTA -->
<!ENTITY b.Gamma          "&#x1D6AA;" ><!--MATHEMATICAL BOLD CAPITAL GAMMA -->
<!ENTITY b.Gammad         "&#x1D7CA;" ><!--MATHEMATICAL BOLD CAPITAL DIGAMMA -->
<!ENTITY b.Lambda         "&#x1D6B2;" ><!--MATHEMATICAL BOLD CAPITAL LAMDA -->
<!ENTITY b.Omega          "&#x1D6C0;" ><!--MATHEMATICAL BOLD CAPITAL OMEGA -->
<!ENTITY b.Phi            "&#x1D6BD;" ><!--MATHEMATICAL BOLD CAPITAL PHI -->
<!ENTITY b.Pi             "&#x1D6B7;" ><!--MATHEMATICAL BOLD CAPITAL PI -->
<!ENTITY b.Psi            "&#x1D6BF;" ><!--MATHEMATICAL BOLD CAPITAL PSI -->
<!ENTITY b.Sigma          "&#x1D6BA;" ><!--MATHEMATICAL BOLD CAPITAL SIGMA -->
<!ENTITY b.Theta          "&#x1D6AF;" ><!--MATHEMATICAL BOLD CAPITAL THETA -->
<!ENTITY b.Upsi           "&#x1D6BC;" ><!--MATHEMATICAL BOLD CAPITAL UPSILON -->
<!ENTITY b.Xi             "&#x1D6B5;" ><!--MATHEMATICAL BOLD CAPITAL XI -->
<!ENTITY b.alpha          "&#x1D6C2;" ><!--MATHEMATICAL BOLD SMALL ALPHA -->
<!ENTITY b.beta           "&#x1D6C3;" ><!--MATHEMATICAL BOLD SMALL BETA -->
<!ENTITY b.chi            "&#x1D6D8;" ><!--MATHEMATICAL BOLD SMALL CHI -->
<!ENTITY b.delta          "&#x1D6C5;" ><!--MATHEMATICAL BOLD SMALL DELTA -->
<!ENTITY b.epsi           "&#x1D6C6;" ><!--MATHEMATICAL BOLD SMALL EPSILON -->
<!ENTITY b.epsiv          "&#x1D6DC;" ><!--MATHEMATICAL BOLD EPSILON SYMBOL -->
<!ENTITY b.eta            "&#x1D6C8;" ><!--MATHEMATICAL BOLD SMALL ETA -->
<!ENTITY b.gamma          "&#x1D6C4;" ><!--MATHEMATICAL BOLD SMALL GAMMA -->
<!ENTITY b.gammad         "&#x1D7CB;" ><!--MATHEMATICAL BOLD SMALL DIGAMMA -->
<!ENTITY b.iota           "&#x1D6CA;" ><!--MATHEMATICAL BOLD SMALL IOTA -->
<!ENTITY b.kappa          "&#x1D6CB;" ><!--MATHEMATICAL BOLD SMALL KAPPA -->
<!ENTITY b.kappav         "&#x1D6DE;" ><!--MATHEMATICAL BOLD KAPPA SYMBOL -->
<!ENTITY b.lambda         "&#x1D6CC;" ><!--MATHEMATICAL BOLD SMALL LAMDA -->
<!ENTITY b.mu             "&#x1D6CD;" ><!--MATHEMATICAL BOLD SMALL MU -->
<!ENTITY b.nu             "&#x1D6CE;" ><!--MATHEMATICAL BOLD SMALL NU -->
<!ENTITY b.omega          "&#x1D6DA;" ><!--MATHEMATICAL BOLD SMALL OMEGA -->
<!ENTITY b.phi            "&#x1D6D7;" ><!--MATHEMATICAL BOLD SMALL PHI -->
<!ENTITY b.phiv           "&#x1D6DF;" ><!--MATHEMATICAL BOLD PHI SYMBOL -->
<!ENTITY b.pi             "&#x1D6D1;" ><!--MATHEMATICAL BOLD SMALL PI -->
<!ENTITY b.piv            "&#x1D6E1;" ><!--MATHEMATICAL BOLD PI SYMBOL -->
<!ENTITY b.psi            "&#x1D6D9;" ><!--MATHEMATICAL BOLD SMALL PSI -->
<!ENTITY b.rho            "&#x1D6D2;" ><!--MATHEMATICAL BOLD SMALL RHO -->
<!ENTITY b.rhov           "&#x1D6E0;" ><!--MATHEMATICAL BOLD RHO SYMBOL -->
<!ENTITY b.sigma          "&#x1D6D4;" ><!--MATHEMATICAL BOLD SMALL SIGMA -->
<!ENTITY b.sigmav         "&#x1D6D3;" ><!--MATHEMATICAL BOLD SMALL FINAL SIGMA -->
<!ENTITY b.tau            "&#x1D6D5;" ><!--MATHEMATICAL BOLD SMALL TAU -->
<!ENTITY b.thetas         "&#x1D6C9;" ><!--MATHEMATICAL BOLD SMALL THETA -->
<!ENTITY b.thetav         "&#x1D6DD;" ><!--MATHEMATICAL BOLD THETA SYMBOL -->
<!ENTITY b.upsi           "&#x1D6D6;" ><!--MATHEMATICAL BOLD SMALL UPSILON -->
<!ENTITY b.xi             "&#x1D6CF;" ><!--MATHEMATICAL BOLD SMALL XI -->
<!ENTITY b.zeta           "&#x1D6C7;" ><!--MATHEMATICAL BOLD SMALL ZETA -->
<!ENTITY bNot             "&#x02AED;" ><!--REVERSED DOUBLE STROKE NOT SIGN -->
<!ENTITY backcong         "&#x0224C;" ><!--ALL EQUAL TO -->
<!ENTITY backepsilon      "&#x003F6;" ><!--GREEK REVERSED LUNATE EPSILON SYMBOL -->
<!ENTITY backprime        "&#x02035;" ><!--REVERSED PRIME -->
<!ENTITY backsim          "&#x0223D;" ><!--REVERSED TILDE -->
<!ENTITY backsimeq        "&#x022CD;" ><!--REVERSED TILDE EQUALS -->
<!ENTITY barvee           "&#x022BD;" ><!--NOR -->
<!ENTITY barwed           "&#x02305;" ><!--PROJECTIVE -->
<!ENTITY barwedge         "&#x02305;" ><!--PROJECTIVE -->
<!ENTITY bbrk             "&#x023B5;" ><!--BOTTOM SQUARE BRACKET -->
<!ENTITY bbrktbrk         "&#x023B6;" ><!--BOTTOM SQUARE BRACKET OVER TOP SQUARE BRACKET -->
<!ENTITY bcong            "&#x0224C;" ><!--ALL EQUAL TO -->
<!ENTITY bcy              "&#x00431;" ><!--CYRILLIC SMALL LETTER BE -->
<!ENTITY bdquo            "&#x0201E;" ><!--DOUBLE LOW-9 QUOTATION MARK -->
<!ENTITY becaus           "&#x02235;" ><!--BECAUSE -->
<!ENTITY because          "&#x02235;" ><!--BECAUSE -->
<!ENTITY bemptyv          "&#x029B0;" ><!--REVERSED EMPTY SET -->
<!ENTITY bepsi            "&#x003F6;" ><!--GREEK REVERSED LUNATE EPSILON SYMBOL -->
<!ENTITY bernou           "&#x0212C;" ><!--SCRIPT CAPITAL B -->
<!ENTITY beta             "&#x003B2;" ><!--GREEK SMALL LETTER BETA -->
<!ENTITY beth             "&#x02136;" ><!--BET SYMBOL -->
<!ENTITY between          "&#x0226C;" ><!--BETWEEN -->
<!ENTITY bfr              "&#x1D51F;" ><!--MATHEMATICAL FRAKTUR SMALL B -->
<!ENTITY bgr              "&#x003B2;" ><!--GREEK SMALL LETTER BETA -->
<!ENTITY bigcap           "&#x022C2;" ><!--N-ARY INTERSECTION -->
<!ENTITY bigcirc          "&#x025EF;" ><!--LARGE CIRCLE -->
<!ENTITY bigcup           "&#x022C3;" ><!--N-ARY UNION -->
<!ENTITY bigodot          "&#x02A00;" ><!--N-ARY CIRCLED DOT OPERATOR -->
<!ENTITY bigoplus         "&#x02A01;" ><!--N-ARY CIRCLED PLUS OPERATOR -->
<!ENTITY bigotimes        "&#x02A02;" ><!--N-ARY CIRCLED TIMES OPERATOR -->
<!ENTITY bigsqcup         "&#x02A06;" ><!--N-ARY SQUARE UNION OPERATOR -->
<!ENTITY bigstar          "&#x02605;" ><!--BLACK STAR -->
<!ENTITY bigtriangledown  "&#x025BD;" ><!--WHITE DOWN-POINTING TRIANGLE -->
<!ENTITY bigtriangleup    "&#x025B3;" ><!--WHITE UP-POINTING TRIANGLE -->
<!ENTITY biguplus         "&#x02A04;" ><!--N-ARY UNION OPERATOR WITH PLUS -->
<!ENTITY bigvee           "&#x022C1;" ><!--N-ARY LOGICAL OR -->
<!ENTITY bigwedge         "&#x022C0;" ><!--N-ARY LOGICAL AND -->
<!ENTITY bkarow           "&#x0290D;" ><!--RIGHTWARDS DOUBLE DASH ARROW -->
<!ENTITY blacklozenge     "&#x029EB;" ><!--BLACK LOZENGE -->
<!ENTITY blacksquare      "&#x025AA;" ><!--BLACK SMALL SQUARE -->
<!ENTITY blacktriangle    "&#x025B4;" ><!--BLACK UP-POINTING SMALL TRIANGLE -->
<!ENTITY blacktriangledown "&#x025BE;" ><!--BLACK DOWN-POINTING SMALL TRIANGLE -->
<!ENTITY blacktriangleleft "&#x025C2;" ><!--BLACK LEFT-POINTING SMALL TRIANGLE -->
<!ENTITY blacktriangleright "&#x025B8;" ><!--BLACK RIGHT-POINTING SMALL TRIANGLE -->
<!ENTITY blank            "&#x02423;" ><!--OPEN BOX -->
<!ENTITY blk12            "&#x02592;" ><!--MEDIUM SHADE -->
<!ENTITY blk14            "&#x02591;" ><!--LIGHT SHADE -->
<!ENTITY blk34            "&#x02593;" ><!--DARK SHADE -->
<!ENTITY block            "&#x02588;" ><!--FULL BLOCK -->
<!ENTITY bne              "&#x0003D;&#x020E5;" ><!--EQUALS SIGN with reverse slash -->
<!ENTITY bnequiv          "&#x02261;&#x020E5;" ><!--IDENTICAL TO with reverse slash -->
<!ENTITY bnot             "&#x02310;" ><!--REVERSED NOT SIGN -->
<!ENTITY bopf             "&#x1D553;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL B -->
<!ENTITY bot              "&#x022A5;" ><!--UP TACK -->
<!ENTITY bottom           "&#x022A5;" ><!--UP TACK -->
<!ENTITY bowtie           "&#x022C8;" ><!--BOWTIE -->
<!ENTITY boxDL            "&#x02557;" ><!--BOX DRAWINGS DOUBLE DOWN AND LEFT -->
<!ENTITY boxDR            "&#x02554;" ><!--BOX DRAWINGS DOUBLE DOWN AND RIGHT -->
<!ENTITY boxDl            "&#x02556;" ><!--BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE -->
<!ENTITY boxDr            "&#x02553;" ><!--BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE -->
<!ENTITY boxH             "&#x02550;" ><!--BOX DRAWINGS DOUBLE HORIZONTAL -->
<!ENTITY boxHD            "&#x02566;" ><!--BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL -->
<!ENTITY boxHU            "&#x02569;" ><!--BOX DRAWINGS DOUBLE UP AND HORIZONTAL -->
<!ENTITY boxHd            "&#x02564;" ><!--BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE -->
<!ENTITY boxHu            "&#x02567;" ><!--BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE -->
<!ENTITY boxUL            "&#x0255D;" ><!--BOX DRAWINGS DOUBLE UP AND LEFT -->
<!ENTITY boxUR            "&#x0255A;" ><!--BOX DRAWINGS DOUBLE UP AND RIGHT -->
<!ENTITY boxUl            "&#x0255C;" ><!--BOX DRAWINGS UP DOUBLE AND LEFT SINGLE -->
<!ENTITY boxUr            "&#x02559;" ><!--BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE -->
<!ENTITY boxV             "&#x02551;" ><!--BOX DRAWINGS DOUBLE VERTICAL -->
<!ENTITY boxVH            "&#x0256C;" ><!--BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL -->
<!ENTITY boxVL            "&#x02563;" ><!--BOX DRAWINGS DOUBLE VERTICAL AND LEFT -->
<!ENTITY boxVR            "&#x02560;" ><!--BOX DRAWINGS DOUBLE VERTICAL AND RIGHT -->
<!ENTITY boxVh            "&#x0256B;" ><!--BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE -->
<!ENTITY boxVl            "&#x02562;" ><!--BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE -->
<!ENTITY boxVr            "&#x0255F;" ><!--BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE -->
<!ENTITY boxbox           "&#x029C9;" ><!--TWO JOINED SQUARES -->
<!ENTITY boxdL            "&#x02555;" ><!--BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE -->
<!ENTITY boxdR            "&#x02552;" ><!--BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE -->
<!ENTITY boxdl            "&#x02510;" ><!--BOX DRAWINGS LIGHT DOWN AND LEFT -->
<!ENTITY boxdr            "&#x0250C;" ><!--BOX DRAWINGS LIGHT DOWN AND RIGHT -->
<!ENTITY boxh             "&#x02500;" ><!--BOX DRAWINGS LIGHT HORIZONTAL -->
<!ENTITY boxhD            "&#x02565;" ><!--BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE -->
<!ENTITY boxhU            "&#x02568;" ><!--BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE -->
<!ENTITY boxhd            "&#x0252C;" ><!--BOX DRAWINGS LIGHT DOWN AND HORIZONTAL -->
<!ENTITY boxhu            "&#x02534;" ><!--BOX DRAWINGS LIGHT UP AND HORIZONTAL -->
<!ENTITY boxminus         "&#x0229F;" ><!--SQUARED MINUS -->
<!ENTITY boxplus          "&#x0229E;" ><!--SQUARED PLUS -->
<!ENTITY boxtimes         "&#x022A0;" ><!--SQUARED TIMES -->
<!ENTITY boxuL            "&#x0255B;" ><!--BOX DRAWINGS UP SINGLE AND LEFT DOUBLE -->
<!ENTITY boxuR            "&#x02558;" ><!--BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE -->
<!ENTITY boxul            "&#x02518;" ><!--BOX DRAWINGS LIGHT UP AND LEFT -->
<!ENTITY boxur            "&#x02514;" ><!--BOX DRAWINGS LIGHT UP AND RIGHT -->
<!ENTITY boxv             "&#x02502;" ><!--BOX DRAWINGS LIGHT VERTICAL -->
<!ENTITY boxvH            "&#x0256A;" ><!--BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE -->
<!ENTITY boxvL            "&#x02561;" ><!--BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE -->
<!ENTITY boxvR            "&#x0255E;" ><!--BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE -->
<!ENTITY boxvh            "&#x0253C;" ><!--BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL -->
<!ENTITY boxvl            "&#x02524;" ><!--BOX DRAWINGS LIGHT VERTICAL AND LEFT -->
<!ENTITY boxvr            "&#x0251C;" ><!--BOX DRAWINGS LIGHT VERTICAL AND RIGHT -->
<!ENTITY bprime           "&#x02035;" ><!--REVERSED PRIME -->
<!ENTITY breve            "&#x002D8;" ><!--BREVE -->
<!ENTITY brvbar           "&#x000A6;" ><!--BROKEN BAR -->
<!ENTITY bscr             "&#x1D4B7;" ><!--MATHEMATICAL SCRIPT SMALL B -->
<!ENTITY bsemi            "&#x0204F;" ><!--REVERSED SEMICOLON -->
<!ENTITY bsim             "&#x0223D;" ><!--REVERSED TILDE -->
<!ENTITY bsime            "&#x022CD;" ><!--REVERSED TILDE EQUALS -->
<!ENTITY bsol             "&#x0005C;" ><!--REVERSE SOLIDUS -->
<!ENTITY bsolb            "&#x029C5;" ><!--SQUARED FALLING DIAGONAL SLASH -->
<!ENTITY bsolhsub         "&#x027C8;" ><!--REVERSE SOLIDUS PRECEDING SUBSET -->
<!ENTITY bull             "&#x02022;" ><!--BULLET -->
<!ENTITY bullet           "&#x02022;" ><!--BULLET -->
<!ENTITY bump             "&#x0224E;" ><!--GEOMETRICALLY EQUIVALENT TO -->
<!ENTITY bumpE            "&#x02AAE;" ><!--EQUALS SIGN WITH BUMPY ABOVE -->
<!ENTITY bumpe            "&#x0224F;" ><!--DIFFERENCE BETWEEN -->
<!ENTITY bumpeq           "&#x0224F;" ><!--DIFFERENCE BETWEEN -->
<!ENTITY cacute           "&#x00107;" ><!--LATIN SMALL LETTER C WITH ACUTE -->
<!ENTITY cap              "&#x02229;" ><!--INTERSECTION -->
<!ENTITY capand           "&#x02A44;" ><!--INTERSECTION WITH LOGICAL AND -->
<!ENTITY capbrcup         "&#x02A49;" ><!--INTERSECTION ABOVE BAR ABOVE UNION -->
<!ENTITY capcap           "&#x02A4B;" ><!--INTERSECTION BESIDE AND JOINED WITH INTERSECTION -->
<!ENTITY capcup           "&#x02A47;" ><!--INTERSECTION ABOVE UNION -->
<!ENTITY capdot           "&#x02A40;" ><!--INTERSECTION WITH DOT -->
<!ENTITY caps             "&#x02229;&#x0FE00;" ><!--INTERSECTION with serifs -->
<!ENTITY caret            "&#x02041;" ><!--CARET INSERTION POINT -->
<!ENTITY caron            "&#x002C7;" ><!--CARON -->
<!ENTITY ccaps            "&#x02A4D;" ><!--CLOSED INTERSECTION WITH SERIFS -->
<!ENTITY ccaron           "&#x0010D;" ><!--LATIN SMALL LETTER C WITH CARON -->
<!ENTITY ccedil           "&#x000E7;" ><!--LATIN SMALL LETTER C WITH CEDILLA -->
<!ENTITY ccirc            "&#x00109;" ><!--LATIN SMALL LETTER C WITH CIRCUMFLEX -->
<!ENTITY ccups            "&#x02A4C;" ><!--CLOSED UNION WITH SERIFS -->
<!ENTITY ccupssm          "&#x02A50;" ><!--CLOSED UNION WITH SERIFS AND SMASH PRODUCT -->
<!ENTITY cdot             "&#x0010B;" ><!--LATIN SMALL LETTER C WITH DOT ABOVE -->
<!ENTITY cedil            "&#x000B8;" ><!--CEDILLA -->
<!ENTITY cemptyv          "&#x029B2;" ><!--EMPTY SET WITH SMALL CIRCLE ABOVE -->
<!ENTITY cent             "&#x000A2;" ><!--CENT SIGN -->
<!ENTITY centerdot        "&#x000B7;" ><!--MIDDLE DOT -->
<!ENTITY cfr              "&#x1D520;" ><!--MATHEMATICAL FRAKTUR SMALL C -->
<!ENTITY chcy             "&#x00447;" ><!--CYRILLIC SMALL LETTER CHE -->
<!ENTITY check            "&#x02713;" ><!--CHECK MARK -->
<!ENTITY checkmark        "&#x02713;" ><!--CHECK MARK -->
<!ENTITY chi              "&#x003C7;" ><!--GREEK SMALL LETTER CHI -->
<!ENTITY cir              "&#x025CB;" ><!--WHITE CIRCLE -->
<!ENTITY cirE             "&#x029C3;" ><!--CIRCLE WITH TWO HORIZONTAL STROKES TO THE RIGHT -->
<!ENTITY circ             "&#x002C6;" ><!--MODIFIER LETTER CIRCUMFLEX ACCENT -->
<!ENTITY circeq           "&#x02257;" ><!--RING EQUAL TO -->
<!ENTITY circlearrowleft  "&#x021BA;" ><!--ANTICLOCKWISE OPEN CIRCLE ARROW -->
<!ENTITY circlearrowright "&#x021BB;" ><!--CLOCKWISE OPEN CIRCLE ARROW -->
<!ENTITY circledR         "&#x000AE;" ><!--REGISTERED SIGN -->
<!ENTITY circledS         "&#x024C8;" ><!--CIRCLED LATIN CAPITAL LETTER S -->
<!ENTITY circledast       "&#x0229B;" ><!--CIRCLED ASTERISK OPERATOR -->
<!ENTITY circledcirc      "&#x0229A;" ><!--CIRCLED RING OPERATOR -->
<!ENTITY circleddash      "&#x0229D;" ><!--CIRCLED DASH -->
<!ENTITY cire             "&#x02257;" ><!--RING EQUAL TO -->
<!ENTITY cirfnint         "&#x02A10;" ><!--CIRCULATION FUNCTION -->
<!ENTITY cirmid           "&#x02AEF;" ><!--VERTICAL LINE WITH CIRCLE ABOVE -->
<!ENTITY cirscir          "&#x029C2;" ><!--CIRCLE WITH SMALL CIRCLE TO THE RIGHT -->
<!ENTITY clubs            "&#x02663;" ><!--BLACK CLUB SUIT -->
<!ENTITY clubsuit         "&#x02663;" ><!--BLACK CLUB SUIT -->
<!ENTITY colon            "&#x0003A;" ><!--COLON -->
<!ENTITY colone           "&#x02254;" ><!--COLON EQUALS -->
<!ENTITY coloneq          "&#x02254;" ><!--COLON EQUALS -->
<!ENTITY comma            "&#x0002C;" ><!--COMMA -->
<!ENTITY commat           "&#x00040;" ><!--COMMERCIAL AT -->
<!ENTITY comp             "&#x02201;" ><!--COMPLEMENT -->
<!ENTITY compfn           "&#x02218;" ><!--RING OPERATOR -->
<!ENTITY complement       "&#x02201;" ><!--COMPLEMENT -->
<!ENTITY complexes        "&#x02102;" ><!--DOUBLE-STRUCK CAPITAL C -->
<!ENTITY cong             "&#x02245;" ><!--APPROXIMATELY EQUAL TO -->
<!ENTITY congdot          "&#x02A6D;" ><!--CONGRUENT WITH DOT ABOVE -->
<!ENTITY conint           "&#x0222E;" ><!--CONTOUR INTEGRAL -->
<!ENTITY copf             "&#x1D554;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL C -->
<!ENTITY coprod           "&#x02210;" ><!--N-ARY COPRODUCT -->
<!ENTITY copy             "&#x000A9;" ><!--COPYRIGHT SIGN -->
<!ENTITY copysr           "&#x02117;" ><!--SOUND RECORDING COPYRIGHT -->
<!ENTITY crarr            "&#x021B5;" ><!--DOWNWARDS ARROW WITH CORNER LEFTWARDS -->
<!ENTITY cross            "&#x02717;" ><!--BALLOT X -->
<!ENTITY cscr             "&#x1D4B8;" ><!--MATHEMATICAL SCRIPT SMALL C -->
<!ENTITY csub             "&#x02ACF;" ><!--CLOSED SUBSET -->
<!ENTITY csube            "&#x02AD1;" ><!--CLOSED SUBSET OR EQUAL TO -->
<!ENTITY csup             "&#x02AD0;" ><!--CLOSED SUPERSET -->
<!ENTITY csupe            "&#x02AD2;" ><!--CLOSED SUPERSET OR EQUAL TO -->
<!ENTITY ctdot            "&#x022EF;" ><!--MIDLINE HORIZONTAL ELLIPSIS -->
<!ENTITY cudarrl          "&#x02938;" ><!--RIGHT-SIDE ARC CLOCKWISE ARROW -->
<!ENTITY cudarrr          "&#x02935;" ><!--ARROW POINTING RIGHTWARDS THEN CURVING DOWNWARDS -->
<!ENTITY cuepr            "&#x022DE;" ><!--EQUAL TO OR PRECEDES -->
<!ENTITY cuesc            "&#x022DF;" ><!--EQUAL TO OR SUCCEEDS -->
<!ENTITY cularr           "&#x021B6;" ><!--ANTICLOCKWISE TOP SEMICIRCLE ARROW -->
<!ENTITY cularrp          "&#x0293D;" ><!--TOP ARC ANTICLOCKWISE ARROW WITH PLUS -->
<!ENTITY cup              "&#x0222A;" ><!--UNION -->
<!ENTITY cupbrcap         "&#x02A48;" ><!--UNION ABOVE BAR ABOVE INTERSECTION -->
<!ENTITY cupcap           "&#x02A46;" ><!--UNION ABOVE INTERSECTION -->
<!ENTITY cupcup           "&#x02A4A;" ><!--UNION BESIDE AND JOINED WITH UNION -->
<!ENTITY cupdot           "&#x0228D;" ><!--MULTISET MULTIPLICATION -->
<!ENTITY cupor            "&#x02A45;" ><!--UNION WITH LOGICAL OR -->
<!ENTITY cups             "&#x0222A;&#x0FE00;" ><!--UNION with serifs -->
<!ENTITY curarr           "&#x021B7;" ><!--CLOCKWISE TOP SEMICIRCLE ARROW -->
<!ENTITY curarrm          "&#x0293C;" ><!--TOP ARC CLOCKWISE ARROW WITH MINUS -->
<!ENTITY curlyeqprec      "&#x022DE;" ><!--EQUAL TO OR PRECEDES -->
<!ENTITY curlyeqsucc      "&#x022DF;" ><!--EQUAL TO OR SUCCEEDS -->
<!ENTITY curlyvee         "&#x022CE;" ><!--CURLY LOGICAL OR -->
<!ENTITY curlywedge       "&#x022CF;" ><!--CURLY LOGICAL AND -->
<!ENTITY curren           "&#x000A4;" ><!--CURRENCY SIGN -->
<!ENTITY curvearrowleft   "&#x021B6;" ><!--ANTICLOCKWISE TOP SEMICIRCLE ARROW -->
<!ENTITY curvearrowright  "&#x021B7;" ><!--CLOCKWISE TOP SEMICIRCLE ARROW -->
<!ENTITY cuvee            "&#x022CE;" ><!--CURLY LOGICAL OR -->
<!ENTITY cuwed            "&#x022CF;" ><!--CURLY LOGICAL AND -->
<!ENTITY cwconint         "&#x02232;" ><!--CLOCKWISE CONTOUR INTEGRAL -->
<!ENTITY cwint            "&#x02231;" ><!--CLOCKWISE INTEGRAL -->
<!ENTITY cylcty           "&#x0232D;" ><!--CYLINDRICITY -->
<!ENTITY dArr             "&#x021D3;" ><!--DOWNWARDS DOUBLE ARROW -->
<!ENTITY dHar             "&#x02965;" ><!--DOWNWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY dagger           "&#x02020;" ><!--DAGGER -->
<!ENTITY daleth           "&#x02138;" ><!--DALET SYMBOL -->
<!ENTITY darr             "&#x02193;" ><!--DOWNWARDS ARROW -->
<!ENTITY dash             "&#x02010;" ><!--HYPHEN -->
<!ENTITY dashv            "&#x022A3;" ><!--LEFT TACK -->
<!ENTITY dbkarow          "&#x0290F;" ><!--RIGHTWARDS TRIPLE DASH ARROW -->
<!ENTITY dblac            "&#x002DD;" ><!--DOUBLE ACUTE ACCENT -->
<!ENTITY dcaron           "&#x0010F;" ><!--LATIN SMALL LETTER D WITH CARON -->
<!ENTITY dcy              "&#x00434;" ><!--CYRILLIC SMALL LETTER DE -->
<!ENTITY dd               "&#x02146;" ><!--DOUBLE-STRUCK ITALIC SMALL D -->
<!ENTITY ddagger          "&#x02021;" ><!--DOUBLE DAGGER -->
<!ENTITY ddarr            "&#x021CA;" ><!--DOWNWARDS PAIRED ARROWS -->
<!ENTITY ddotseq          "&#x02A77;" ><!--EQUALS SIGN WITH TWO DOTS ABOVE AND TWO DOTS BELOW -->
<!ENTITY deg              "&#x000B0;" ><!--DEGREE SIGN -->
<!ENTITY delta            "&#x003B4;" ><!--GREEK SMALL LETTER DELTA -->
<!ENTITY demptyv          "&#x029B1;" ><!--EMPTY SET WITH OVERBAR -->
<!ENTITY dfisht           "&#x0297F;" ><!--DOWN FISH TAIL -->
<!ENTITY dfr              "&#x1D521;" ><!--MATHEMATICAL FRAKTUR SMALL D -->
<!ENTITY dgr              "&#x003B4;" ><!--GREEK SMALL LETTER DELTA -->
<!ENTITY dharl            "&#x021C3;" ><!--DOWNWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY dharr            "&#x021C2;" ><!--DOWNWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY diam             "&#x022C4;" ><!--DIAMOND OPERATOR -->
<!ENTITY diamond          "&#x022C4;" ><!--DIAMOND OPERATOR -->
<!ENTITY diamondsuit      "&#x02666;" ><!--BLACK DIAMOND SUIT -->
<!ENTITY diams            "&#x02666;" ><!--BLACK DIAMOND SUIT -->
<!ENTITY die              "&#x000A8;" ><!--DIAERESIS -->
<!ENTITY digamma          "&#x003DD;" ><!--GREEK SMALL LETTER DIGAMMA -->
<!ENTITY disin            "&#x022F2;" ><!--ELEMENT OF WITH LONG HORIZONTAL STROKE -->
<!ENTITY div              "&#x000F7;" ><!--DIVISION SIGN -->
<!ENTITY divide           "&#x000F7;" ><!--DIVISION SIGN -->
<!ENTITY divideontimes    "&#x022C7;" ><!--DIVISION TIMES -->
<!ENTITY divonx           "&#x022C7;" ><!--DIVISION TIMES -->
<!ENTITY djcy             "&#x00452;" ><!--CYRILLIC SMALL LETTER DJE -->
<!ENTITY dlcorn           "&#x0231E;" ><!--BOTTOM LEFT CORNER -->
<!ENTITY dlcrop           "&#x0230D;" ><!--BOTTOM LEFT CROP -->
<!ENTITY dollar           "&#x00024;" ><!--DOLLAR SIGN -->
<!ENTITY dopf             "&#x1D555;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL D -->
<!ENTITY dot              "&#x002D9;" ><!--DOT ABOVE -->
<!ENTITY doteq            "&#x02250;" ><!--APPROACHES THE LIMIT -->
<!ENTITY doteqdot         "&#x02251;" ><!--GEOMETRICALLY EQUAL TO -->
<!ENTITY dotminus         "&#x02238;" ><!--DOT MINUS -->
<!ENTITY dotplus          "&#x02214;" ><!--DOT PLUS -->
<!ENTITY dotsquare        "&#x022A1;" ><!--SQUARED DOT OPERATOR -->
<!ENTITY doublebarwedge   "&#x02306;" ><!--PERSPECTIVE -->
<!ENTITY downarrow        "&#x02193;" ><!--DOWNWARDS ARROW -->
<!ENTITY downdownarrows   "&#x021CA;" ><!--DOWNWARDS PAIRED ARROWS -->
<!ENTITY downharpoonleft  "&#x021C3;" ><!--DOWNWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY downharpoonright "&#x021C2;" ><!--DOWNWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY drbkarow         "&#x02910;" ><!--RIGHTWARDS TWO-HEADED TRIPLE DASH ARROW -->
<!ENTITY drcorn           "&#x0231F;" ><!--BOTTOM RIGHT CORNER -->
<!ENTITY drcrop           "&#x0230C;" ><!--BOTTOM RIGHT CROP -->
<!ENTITY dscr             "&#x1D4B9;" ><!--MATHEMATICAL SCRIPT SMALL D -->
<!ENTITY dscy             "&#x00455;" ><!--CYRILLIC SMALL LETTER DZE -->
<!ENTITY dsol             "&#x029F6;" ><!--SOLIDUS WITH OVERBAR -->
<!ENTITY dstrok           "&#x00111;" ><!--LATIN SMALL LETTER D WITH STROKE -->
<!ENTITY dtdot            "&#x022F1;" ><!--DOWN RIGHT DIAGONAL ELLIPSIS -->
<!ENTITY dtri             "&#x025BF;" ><!--WHITE DOWN-POINTING SMALL TRIANGLE -->
<!ENTITY dtrif            "&#x025BE;" ><!--BLACK DOWN-POINTING SMALL TRIANGLE -->
<!ENTITY duarr            "&#x021F5;" ><!--DOWNWARDS ARROW LEFTWARDS OF UPWARDS ARROW -->
<!ENTITY duhar            "&#x0296F;" ><!--DOWNWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY dwangle          "&#x029A6;" ><!--OBLIQUE ANGLE OPENING UP -->
<!ENTITY dzcy             "&#x0045F;" ><!--CYRILLIC SMALL LETTER DZHE -->
<!ENTITY dzigrarr         "&#x027FF;" ><!--LONG RIGHTWARDS SQUIGGLE ARROW -->
<!ENTITY eDDot            "&#x02A77;" ><!--EQUALS SIGN WITH TWO DOTS ABOVE AND TWO DOTS BELOW -->
<!ENTITY eDot             "&#x02251;" ><!--GEOMETRICALLY EQUAL TO -->
<!ENTITY eacgr            "&#x003AD;" ><!--GREEK SMALL LETTER EPSILON WITH TONOS -->
<!ENTITY eacute           "&#x000E9;" ><!--LATIN SMALL LETTER E WITH ACUTE -->
<!ENTITY easter           "&#x02A6E;" ><!--EQUALS WITH ASTERISK -->
<!ENTITY ecaron           "&#x0011B;" ><!--LATIN SMALL LETTER E WITH CARON -->
<!ENTITY ecir             "&#x02256;" ><!--RING IN EQUAL TO -->
<!ENTITY ecirc            "&#x000EA;" ><!--LATIN SMALL LETTER E WITH CIRCUMFLEX -->
<!ENTITY ecolon           "&#x02255;" ><!--EQUALS COLON -->
<!ENTITY ecy              "&#x0044D;" ><!--CYRILLIC SMALL LETTER E -->
<!ENTITY edot             "&#x00117;" ><!--LATIN SMALL LETTER E WITH DOT ABOVE -->
<!ENTITY ee               "&#x02147;" ><!--DOUBLE-STRUCK ITALIC SMALL E -->
<!ENTITY eeacgr           "&#x003AE;" ><!--GREEK SMALL LETTER ETA WITH TONOS -->
<!ENTITY eegr             "&#x003B7;" ><!--GREEK SMALL LETTER ETA -->
<!ENTITY efDot            "&#x02252;" ><!--APPROXIMATELY EQUAL TO OR THE IMAGE OF -->
<!ENTITY efr              "&#x1D522;" ><!--MATHEMATICAL FRAKTUR SMALL E -->
<!ENTITY eg               "&#x02A9A;" ><!--DOUBLE-LINE EQUAL TO OR GREATER-THAN -->
<!ENTITY egr              "&#x003B5;" ><!--GREEK SMALL LETTER EPSILON -->
<!ENTITY egrave           "&#x000E8;" ><!--LATIN SMALL LETTER E WITH GRAVE -->
<!ENTITY egs              "&#x02A96;" ><!--SLANTED EQUAL TO OR GREATER-THAN -->
<!ENTITY egsdot           "&#x02A98;" ><!--SLANTED EQUAL TO OR GREATER-THAN WITH DOT INSIDE -->
<!ENTITY el               "&#x02A99;" ><!--DOUBLE-LINE EQUAL TO OR LESS-THAN -->
<!ENTITY elinters         "&#x023E7;" ><!--ELECTRICAL INTERSECTION -->
<!ENTITY ell              "&#x02113;" ><!--SCRIPT SMALL L -->
<!ENTITY els              "&#x02A95;" ><!--SLANTED EQUAL TO OR LESS-THAN -->
<!ENTITY elsdot           "&#x02A97;" ><!--SLANTED EQUAL TO OR LESS-THAN WITH DOT INSIDE -->
<!ENTITY emacr            "&#x00113;" ><!--LATIN SMALL LETTER E WITH MACRON -->
<!ENTITY empty            "&#x02205;" ><!--EMPTY SET -->
<!ENTITY emptyset         "&#x02205;" ><!--EMPTY SET -->
<!ENTITY emptyv           "&#x02205;" ><!--EMPTY SET -->
<!ENTITY emsp             "&#x02003;" ><!--EM SPACE -->
<!ENTITY emsp13           "&#x02004;" ><!--THREE-PER-EM SPACE -->
<!ENTITY emsp14           "&#x02005;" ><!--FOUR-PER-EM SPACE -->
<!ENTITY eng              "&#x0014B;" ><!--LATIN SMALL LETTER ENG -->
<!ENTITY ensp             "&#x02002;" ><!--EN SPACE -->
<!ENTITY eogon            "&#x00119;" ><!--LATIN SMALL LETTER E WITH OGONEK -->
<!ENTITY eopf             "&#x1D556;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL E -->
<!ENTITY epar             "&#x022D5;" ><!--EQUAL AND PARALLEL TO -->
<!ENTITY eparsl           "&#x029E3;" ><!--EQUALS SIGN AND SLANTED PARALLEL -->
<!ENTITY eplus            "&#x02A71;" ><!--EQUALS SIGN ABOVE PLUS SIGN -->
<!ENTITY epsi             "&#x003B5;" ><!--GREEK SMALL LETTER EPSILON -->
<!ENTITY epsilon          "&#x003B5;" ><!--GREEK SMALL LETTER EPSILON -->
<!ENTITY epsiv            "&#x003F5;" ><!--GREEK LUNATE EPSILON SYMBOL -->
<!ENTITY eqcirc           "&#x02256;" ><!--RING IN EQUAL TO -->
<!ENTITY eqcolon          "&#x02255;" ><!--EQUALS COLON -->
<!ENTITY eqsim            "&#x02242;" ><!--MINUS TILDE -->
<!ENTITY eqslantgtr       "&#x02A96;" ><!--SLANTED EQUAL TO OR GREATER-THAN -->
<!ENTITY eqslantless      "&#x02A95;" ><!--SLANTED EQUAL TO OR LESS-THAN -->
<!ENTITY equals           "&#x0003D;" ><!--EQUALS SIGN -->
<!ENTITY equest           "&#x0225F;" ><!--QUESTIONED EQUAL TO -->
<!ENTITY equiv            "&#x02261;" ><!--IDENTICAL TO -->
<!ENTITY equivDD          "&#x02A78;" ><!--EQUIVALENT WITH FOUR DOTS ABOVE -->
<!ENTITY eqvparsl         "&#x029E5;" ><!--IDENTICAL TO AND SLANTED PARALLEL -->
<!ENTITY erDot            "&#x02253;" ><!--IMAGE OF OR APPROXIMATELY EQUAL TO -->
<!ENTITY erarr            "&#x02971;" ><!--EQUALS SIGN ABOVE RIGHTWARDS ARROW -->
<!ENTITY escr             "&#x0212F;" ><!--SCRIPT SMALL E -->
<!ENTITY esdot            "&#x02250;" ><!--APPROACHES THE LIMIT -->
<!ENTITY esim             "&#x02242;" ><!--MINUS TILDE -->
<!ENTITY eta              "&#x003B7;" ><!--GREEK SMALL LETTER ETA -->
<!ENTITY eth              "&#x000F0;" ><!--LATIN SMALL LETTER ETH -->
<!ENTITY euml             "&#x000EB;" ><!--LATIN SMALL LETTER E WITH DIAERESIS -->
<!ENTITY euro             "&#x020AC;" ><!--EURO SIGN -->
<!ENTITY excl             "&#x00021;" ><!--EXCLAMATION MARK -->
<!ENTITY exist            "&#x02203;" ><!--THERE EXISTS -->
<!ENTITY expectation      "&#x02130;" ><!--SCRIPT CAPITAL E -->
<!ENTITY exponentiale     "&#x02147;" ><!--DOUBLE-STRUCK ITALIC SMALL E -->
<!ENTITY fallingdotseq    "&#x02252;" ><!--APPROXIMATELY EQUAL TO OR THE IMAGE OF -->
<!ENTITY fcy              "&#x00444;" ><!--CYRILLIC SMALL LETTER EF -->
<!ENTITY female           "&#x02640;" ><!--FEMALE SIGN -->
<!ENTITY ffilig           "&#x0FB03;" ><!--LATIN SMALL LIGATURE FFI -->
<!ENTITY fflig            "&#x0FB00;" ><!--LATIN SMALL LIGATURE FF -->
<!ENTITY ffllig           "&#x0FB04;" ><!--LATIN SMALL LIGATURE FFL -->
<!ENTITY ffr              "&#x1D523;" ><!--MATHEMATICAL FRAKTUR SMALL F -->
<!ENTITY filig            "&#x0FB01;" ><!--LATIN SMALL LIGATURE FI -->
<!ENTITY fjlig            "&#x00066;&#x0006A;" ><!--fj ligature -->
<!ENTITY flat             "&#x0266D;" ><!--MUSIC FLAT SIGN -->
<!ENTITY fllig            "&#x0FB02;" ><!--LATIN SMALL LIGATURE FL -->
<!ENTITY fltns            "&#x025B1;" ><!--WHITE PARALLELOGRAM -->
<!ENTITY fnof             "&#x00192;" ><!--LATIN SMALL LETTER F WITH HOOK -->
<!ENTITY fopf             "&#x1D557;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL F -->
<!ENTITY forall           "&#x02200;" ><!--FOR ALL -->
<!ENTITY fork             "&#x022D4;" ><!--PITCHFORK -->
<!ENTITY forkv            "&#x02AD9;" ><!--ELEMENT OF OPENING DOWNWARDS -->
<!ENTITY fpartint         "&#x02A0D;" ><!--FINITE PART INTEGRAL -->
<!ENTITY frac12           "&#x000BD;" ><!--VULGAR FRACTION ONE HALF -->
<!ENTITY frac13           "&#x02153;" ><!--VULGAR FRACTION ONE THIRD -->
<!ENTITY frac14           "&#x000BC;" ><!--VULGAR FRACTION ONE QUARTER -->
<!ENTITY frac15           "&#x02155;" ><!--VULGAR FRACTION ONE FIFTH -->
<!ENTITY frac16           "&#x02159;" ><!--VULGAR FRACTION ONE SIXTH -->
<!ENTITY frac18           "&#x0215B;" ><!--VULGAR FRACTION ONE EIGHTH -->
<!ENTITY frac23           "&#x02154;" ><!--VULGAR FRACTION TWO THIRDS -->
<!ENTITY frac25           "&#x02156;" ><!--VULGAR FRACTION TWO FIFTHS -->
<!ENTITY frac34           "&#x000BE;" ><!--VULGAR FRACTION THREE QUARTERS -->
<!ENTITY frac35           "&#x02157;" ><!--VULGAR FRACTION THREE FIFTHS -->
<!ENTITY frac38           "&#x0215C;" ><!--VULGAR FRACTION THREE EIGHTHS -->
<!ENTITY frac45           "&#x02158;" ><!--VULGAR FRACTION FOUR FIFTHS -->
<!ENTITY frac56           "&#x0215A;" ><!--VULGAR FRACTION FIVE SIXTHS -->
<!ENTITY frac58           "&#x0215D;" ><!--VULGAR FRACTION FIVE EIGHTHS -->
<!ENTITY frac78           "&#x0215E;" ><!--VULGAR FRACTION SEVEN EIGHTHS -->
<!ENTITY frasl            "&#x02044;" ><!--FRACTION SLASH -->
<!ENTITY frown            "&#x02322;" ><!--FROWN -->
<!ENTITY fscr             "&#x1D4BB;" ><!--MATHEMATICAL SCRIPT SMALL F -->
<!ENTITY gE               "&#x02267;" ><!--GREATER-THAN OVER EQUAL TO -->
<!ENTITY gEl              "&#x02A8C;" ><!--GREATER-THAN ABOVE DOUBLE-LINE EQUAL ABOVE LESS-THAN -->
<!ENTITY gacute           "&#x001F5;" ><!--LATIN SMALL LETTER G WITH ACUTE -->
<!ENTITY gamma            "&#x003B3;" ><!--GREEK SMALL LETTER GAMMA -->
<!ENTITY gammad           "&#x003DD;" ><!--GREEK SMALL LETTER DIGAMMA -->
<!ENTITY gap              "&#x02A86;" ><!--GREATER-THAN OR APPROXIMATE -->
<!ENTITY gbreve           "&#x0011F;" ><!--LATIN SMALL LETTER G WITH BREVE -->
<!ENTITY gcirc            "&#x0011D;" ><!--LATIN SMALL LETTER G WITH CIRCUMFLEX -->
<!ENTITY gcy              "&#x00433;" ><!--CYRILLIC SMALL LETTER GHE -->
<!ENTITY gdot             "&#x00121;" ><!--LATIN SMALL LETTER G WITH DOT ABOVE -->
<!ENTITY ge               "&#x02265;" ><!--GREATER-THAN OR EQUAL TO -->
<!ENTITY gel              "&#x022DB;" ><!--GREATER-THAN EQUAL TO OR LESS-THAN -->
<!ENTITY geq              "&#x02265;" ><!--GREATER-THAN OR EQUAL TO -->
<!ENTITY geqq             "&#x02267;" ><!--GREATER-THAN OVER EQUAL TO -->
<!ENTITY geqslant         "&#x02A7E;" ><!--GREATER-THAN OR SLANTED EQUAL TO -->
<!ENTITY ges              "&#x02A7E;" ><!--GREATER-THAN OR SLANTED EQUAL TO -->
<!ENTITY gescc            "&#x02AA9;" ><!--GREATER-THAN CLOSED BY CURVE ABOVE SLANTED EQUAL -->
<!ENTITY gesdot           "&#x02A80;" ><!--GREATER-THAN OR SLANTED EQUAL TO WITH DOT INSIDE -->
<!ENTITY gesdoto          "&#x02A82;" ><!--GREATER-THAN OR SLANTED EQUAL TO WITH DOT ABOVE -->
<!ENTITY gesdotol         "&#x02A84;" ><!--GREATER-THAN OR SLANTED EQUAL TO WITH DOT ABOVE LEFT -->
<!ENTITY gesl             "&#x022DB;&#x0FE00;" ><!--GREATER-THAN slanted EQUAL TO OR LESS-THAN -->
<!ENTITY gesles           "&#x02A94;" ><!--GREATER-THAN ABOVE SLANTED EQUAL ABOVE LESS-THAN ABOVE SLANTED EQUAL -->
<!ENTITY gfr              "&#x1D524;" ><!--MATHEMATICAL FRAKTUR SMALL G -->
<!ENTITY gg               "&#x0226B;" ><!--MUCH GREATER-THAN -->
<!ENTITY ggg              "&#x022D9;" ><!--VERY MUCH GREATER-THAN -->
<!ENTITY ggr              "&#x003B3;" ><!--GREEK SMALL LETTER GAMMA -->
<!ENTITY gimel            "&#x02137;" ><!--GIMEL SYMBOL -->
<!ENTITY gjcy             "&#x00453;" ><!--CYRILLIC SMALL LETTER GJE -->
<!ENTITY gl               "&#x02277;" ><!--GREATER-THAN OR LESS-THAN -->
<!ENTITY glE              "&#x02A92;" ><!--GREATER-THAN ABOVE LESS-THAN ABOVE DOUBLE-LINE EQUAL -->
<!ENTITY gla              "&#x02AA5;" ><!--GREATER-THAN BESIDE LESS-THAN -->
<!ENTITY glj              "&#x02AA4;" ><!--GREATER-THAN OVERLAPPING LESS-THAN -->
<!ENTITY gnE              "&#x02269;" ><!--GREATER-THAN BUT NOT EQUAL TO -->
<!ENTITY gnap             "&#x02A8A;" ><!--GREATER-THAN AND NOT APPROXIMATE -->
<!ENTITY gnapprox         "&#x02A8A;" ><!--GREATER-THAN AND NOT APPROXIMATE -->
<!ENTITY gne              "&#x02A88;" ><!--GREATER-THAN AND SINGLE-LINE NOT EQUAL TO -->
<!ENTITY gneq             "&#x02A88;" ><!--GREATER-THAN AND SINGLE-LINE NOT EQUAL TO -->
<!ENTITY gneqq            "&#x02269;" ><!--GREATER-THAN BUT NOT EQUAL TO -->
<!ENTITY gnsim            "&#x022E7;" ><!--GREATER-THAN BUT NOT EQUIVALENT TO -->
<!ENTITY gopf             "&#x1D558;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL G -->
<!ENTITY grave            "&#x00060;" ><!--GRAVE ACCENT -->
<!ENTITY gscr             "&#x0210A;" ><!--SCRIPT SMALL G -->
<!ENTITY gsim             "&#x02273;" ><!--GREATER-THAN OR EQUIVALENT TO -->
<!ENTITY gsime            "&#x02A8E;" ><!--GREATER-THAN ABOVE SIMILAR OR EQUAL -->
<!ENTITY gsiml            "&#x02A90;" ><!--GREATER-THAN ABOVE SIMILAR ABOVE LESS-THAN -->
<!ENTITY gt               "&#x0003E;" ><!--GREATER-THAN SIGN -->
<!ENTITY gtcc             "&#x02AA7;" ><!--GREATER-THAN CLOSED BY CURVE -->
<!ENTITY gtcir            "&#x02A7A;" ><!--GREATER-THAN WITH CIRCLE INSIDE -->
<!ENTITY gtdot            "&#x022D7;" ><!--GREATER-THAN WITH DOT -->
<!ENTITY gtlPar           "&#x02995;" ><!--DOUBLE LEFT ARC GREATER-THAN BRACKET -->
<!ENTITY gtquest          "&#x02A7C;" ><!--GREATER-THAN WITH QUESTION MARK ABOVE -->
<!ENTITY gtrapprox        "&#x02A86;" ><!--GREATER-THAN OR APPROXIMATE -->
<!ENTITY gtrarr           "&#x02978;" ><!--GREATER-THAN ABOVE RIGHTWARDS ARROW -->
<!ENTITY gtrdot           "&#x022D7;" ><!--GREATER-THAN WITH DOT -->
<!ENTITY gtreqless        "&#x022DB;" ><!--GREATER-THAN EQUAL TO OR LESS-THAN -->
<!ENTITY gtreqqless       "&#x02A8C;" ><!--GREATER-THAN ABOVE DOUBLE-LINE EQUAL ABOVE LESS-THAN -->
<!ENTITY gtrless          "&#x02277;" ><!--GREATER-THAN OR LESS-THAN -->
<!ENTITY gtrsim           "&#x02273;" ><!--GREATER-THAN OR EQUIVALENT TO -->
<!ENTITY gvertneqq        "&#x02269;&#x0FE00;" ><!--GREATER-THAN BUT NOT EQUAL TO - with vertical stroke -->
<!ENTITY gvnE             "&#x02269;&#x0FE00;" ><!--GREATER-THAN BUT NOT EQUAL TO - with vertical stroke -->
<!ENTITY hArr             "&#x021D4;" ><!--LEFT RIGHT DOUBLE ARROW -->
<!ENTITY hairsp           "&#x0200A;" ><!--HAIR SPACE -->
<!ENTITY half             "&#x000BD;" ><!--VULGAR FRACTION ONE HALF -->
<!ENTITY hamilt           "&#x0210B;" ><!--SCRIPT CAPITAL H -->
<!ENTITY hardcy           "&#x0044A;" ><!--CYRILLIC SMALL LETTER HARD SIGN -->
<!ENTITY harr             "&#x02194;" ><!--LEFT RIGHT ARROW -->
<!ENTITY harrcir          "&#x02948;" ><!--LEFT RIGHT ARROW THROUGH SMALL CIRCLE -->
<!ENTITY harrw            "&#x021AD;" ><!--LEFT RIGHT WAVE ARROW -->
<!ENTITY hbar             "&#x0210F;" ><!--PLANCK CONSTANT OVER TWO PI -->
<!ENTITY hcirc            "&#x00125;" ><!--LATIN SMALL LETTER H WITH CIRCUMFLEX -->
<!ENTITY hearts           "&#x02665;" ><!--BLACK HEART SUIT -->
<!ENTITY heartsuit        "&#x02665;" ><!--BLACK HEART SUIT -->
<!ENTITY hellip           "&#x02026;" ><!--HORIZONTAL ELLIPSIS -->
<!ENTITY hercon           "&#x022B9;" ><!--HERMITIAN CONJUGATE MATRIX -->
<!ENTITY hfr              "&#x1D525;" ><!--MATHEMATICAL FRAKTUR SMALL H -->
<!ENTITY hksearow         "&#x02925;" ><!--SOUTH EAST ARROW WITH HOOK -->
<!ENTITY hkswarow         "&#x02926;" ><!--SOUTH WEST ARROW WITH HOOK -->
<!ENTITY hoarr            "&#x021FF;" ><!--LEFT RIGHT OPEN-HEADED ARROW -->
<!ENTITY homtht           "&#x0223B;" ><!--HOMOTHETIC -->
<!ENTITY hookleftarrow    "&#x021A9;" ><!--LEFTWARDS ARROW WITH HOOK -->
<!ENTITY hookrightarrow   "&#x021AA;" ><!--RIGHTWARDS ARROW WITH HOOK -->
<!ENTITY hopf             "&#x1D559;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL H -->
<!ENTITY horbar           "&#x02015;" ><!--HORIZONTAL BAR -->
<!ENTITY hscr             "&#x1D4BD;" ><!--MATHEMATICAL SCRIPT SMALL H -->
<!ENTITY hslash           "&#x0210F;" ><!--PLANCK CONSTANT OVER TWO PI -->
<!ENTITY hstrok           "&#x00127;" ><!--LATIN SMALL LETTER H WITH STROKE -->
<!ENTITY hybull           "&#x02043;" ><!--HYPHEN BULLET -->
<!ENTITY hyphen           "&#x02010;" ><!--HYPHEN -->
<!ENTITY iacgr            "&#x003AF;" ><!--GREEK SMALL LETTER IOTA WITH TONOS -->
<!ENTITY iacute           "&#x000ED;" ><!--LATIN SMALL LETTER I WITH ACUTE -->
<!ENTITY ic               "&#x02063;" ><!--INVISIBLE SEPARATOR -->
<!ENTITY icirc            "&#x000EE;" ><!--LATIN SMALL LETTER I WITH CIRCUMFLEX -->
<!ENTITY icy              "&#x00438;" ><!--CYRILLIC SMALL LETTER I -->
<!ENTITY idiagr           "&#x00390;" ><!--GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS -->
<!ENTITY idigr            "&#x003CA;" ><!--GREEK SMALL LETTER IOTA WITH DIALYTIKA -->
<!ENTITY iecy             "&#x00435;" ><!--CYRILLIC SMALL LETTER IE -->
<!ENTITY iexcl            "&#x000A1;" ><!--INVERTED EXCLAMATION MARK -->
<!ENTITY iff              "&#x021D4;" ><!--LEFT RIGHT DOUBLE ARROW -->
<!ENTITY ifr              "&#x1D526;" ><!--MATHEMATICAL FRAKTUR SMALL I -->
<!ENTITY igr              "&#x003B9;" ><!--GREEK SMALL LETTER IOTA -->
<!ENTITY igrave           "&#x000EC;" ><!--LATIN SMALL LETTER I WITH GRAVE -->
<!ENTITY ii               "&#x02148;" ><!--DOUBLE-STRUCK ITALIC SMALL I -->
<!ENTITY iiiint           "&#x02A0C;" ><!--QUADRUPLE INTEGRAL OPERATOR -->
<!ENTITY iiint            "&#x0222D;" ><!--TRIPLE INTEGRAL -->
<!ENTITY iinfin           "&#x029DC;" ><!--INCOMPLETE INFINITY -->
<!ENTITY iiota            "&#x02129;" ><!--TURNED GREEK SMALL LETTER IOTA -->
<!ENTITY ijlig            "&#x00133;" ><!--LATIN SMALL LIGATURE IJ -->
<!ENTITY imacr            "&#x0012B;" ><!--LATIN SMALL LETTER I WITH MACRON -->
<!ENTITY image            "&#x02111;" ><!--BLACK-LETTER CAPITAL I -->
<!ENTITY imagline         "&#x02110;" ><!--SCRIPT CAPITAL I -->
<!ENTITY imagpart         "&#x02111;" ><!--BLACK-LETTER CAPITAL I -->
<!ENTITY imath            "&#x00131;" ><!--LATIN SMALL LETTER DOTLESS I -->
<!ENTITY imof             "&#x022B7;" ><!--IMAGE OF -->
<!ENTITY imped            "&#x001B5;" ><!--LATIN CAPITAL LETTER Z WITH STROKE -->
<!ENTITY in               "&#x02208;" ><!--ELEMENT OF -->
<!ENTITY incare           "&#x02105;" ><!--CARE OF -->
<!ENTITY infin            "&#x0221E;" ><!--INFINITY -->
<!ENTITY infintie         "&#x029DD;" ><!--TIE OVER INFINITY -->
<!ENTITY inodot           "&#x00131;" ><!--LATIN SMALL LETTER DOTLESS I -->
<!ENTITY int              "&#x0222B;" ><!--INTEGRAL -->
<!ENTITY intcal           "&#x022BA;" ><!--INTERCALATE -->
<!ENTITY integers         "&#x02124;" ><!--DOUBLE-STRUCK CAPITAL Z -->
<!ENTITY intercal         "&#x022BA;" ><!--INTERCALATE -->
<!ENTITY intlarhk         "&#x02A17;" ><!--INTEGRAL WITH LEFTWARDS ARROW WITH HOOK -->
<!ENTITY intprod          "&#x02A3C;" ><!--INTERIOR PRODUCT -->
<!ENTITY iocy             "&#x00451;" ><!--CYRILLIC SMALL LETTER IO -->
<!ENTITY iogon            "&#x0012F;" ><!--LATIN SMALL LETTER I WITH OGONEK -->
<!ENTITY iopf             "&#x1D55A;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL I -->
<!ENTITY iota             "&#x003B9;" ><!--GREEK SMALL LETTER IOTA -->
<!ENTITY iprod            "&#x02A3C;" ><!--INTERIOR PRODUCT -->
<!ENTITY iquest           "&#x000BF;" ><!--INVERTED QUESTION MARK -->
<!ENTITY iscr             "&#x1D4BE;" ><!--MATHEMATICAL SCRIPT SMALL I -->
<!ENTITY isin             "&#x02208;" ><!--ELEMENT OF -->
<!ENTITY isinE            "&#x022F9;" ><!--ELEMENT OF WITH TWO HORIZONTAL STROKES -->
<!ENTITY isindot          "&#x022F5;" ><!--ELEMENT OF WITH DOT ABOVE -->
<!ENTITY isins            "&#x022F4;" ><!--SMALL ELEMENT OF WITH VERTICAL BAR AT END OF HORIZONTAL STROKE -->
<!ENTITY isinsv           "&#x022F3;" ><!--ELEMENT OF WITH VERTICAL BAR AT END OF HORIZONTAL STROKE -->
<!ENTITY isinv            "&#x02208;" ><!--ELEMENT OF -->
<!ENTITY it               "&#x02062;" ><!--INVISIBLE TIMES -->
<!ENTITY itilde           "&#x00129;" ><!--LATIN SMALL LETTER I WITH TILDE -->
<!ENTITY iukcy            "&#x00456;" ><!--CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I -->
<!ENTITY iuml             "&#x000EF;" ><!--LATIN SMALL LETTER I WITH DIAERESIS -->
<!ENTITY jcirc            "&#x00135;" ><!--LATIN SMALL LETTER J WITH CIRCUMFLEX -->
<!ENTITY jcy              "&#x00439;" ><!--CYRILLIC SMALL LETTER SHORT I -->
<!ENTITY jfr              "&#x1D527;" ><!--MATHEMATICAL FRAKTUR SMALL J -->
<!ENTITY jmath            "&#x00237;" ><!--LATIN SMALL LETTER DOTLESS J -->
<!ENTITY jopf             "&#x1D55B;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL J -->
<!ENTITY jscr             "&#x1D4BF;" ><!--MATHEMATICAL SCRIPT SMALL J -->
<!ENTITY jsercy           "&#x00458;" ><!--CYRILLIC SMALL LETTER JE -->
<!ENTITY jukcy            "&#x00454;" ><!--CYRILLIC SMALL LETTER UKRAINIAN IE -->
<!ENTITY kappa            "&#x003BA;" ><!--GREEK SMALL LETTER KAPPA -->
<!ENTITY kappav           "&#x003F0;" ><!--GREEK KAPPA SYMBOL -->
<!ENTITY kcedil           "&#x00137;" ><!--LATIN SMALL LETTER K WITH CEDILLA -->
<!ENTITY kcy              "&#x0043A;" ><!--CYRILLIC SMALL LETTER KA -->
<!ENTITY kfr              "&#x1D528;" ><!--MATHEMATICAL FRAKTUR SMALL K -->
<!ENTITY kgr              "&#x003BA;" ><!--GREEK SMALL LETTER KAPPA -->
<!ENTITY kgreen           "&#x00138;" ><!--LATIN SMALL LETTER KRA -->
<!ENTITY khcy             "&#x00445;" ><!--CYRILLIC SMALL LETTER HA -->
<!ENTITY khgr             "&#x003C7;" ><!--GREEK SMALL LETTER CHI -->
<!ENTITY kjcy             "&#x0045C;" ><!--CYRILLIC SMALL LETTER KJE -->
<!ENTITY kopf             "&#x1D55C;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL K -->
<!ENTITY kscr             "&#x1D4C0;" ><!--MATHEMATICAL SCRIPT SMALL K -->
<!ENTITY lAarr            "&#x021DA;" ><!--LEFTWARDS TRIPLE ARROW -->
<!ENTITY lArr             "&#x021D0;" ><!--LEFTWARDS DOUBLE ARROW -->
<!ENTITY lAtail           "&#x0291B;" ><!--LEFTWARDS DOUBLE ARROW-TAIL -->
<!ENTITY lBarr            "&#x0290E;" ><!--LEFTWARDS TRIPLE DASH ARROW -->
<!ENTITY lE               "&#x02266;" ><!--LESS-THAN OVER EQUAL TO -->
<!ENTITY lEg              "&#x02A8B;" ><!--LESS-THAN ABOVE DOUBLE-LINE EQUAL ABOVE GREATER-THAN -->
<!ENTITY lHar             "&#x02962;" ><!--LEFTWARDS HARPOON WITH BARB UP ABOVE LEFTWARDS HARPOON WITH BARB DOWN -->
<!ENTITY lacute           "&#x0013A;" ><!--LATIN SMALL LETTER L WITH ACUTE -->
<!ENTITY laemptyv         "&#x029B4;" ><!--EMPTY SET WITH LEFT ARROW ABOVE -->
<!ENTITY lagran           "&#x02112;" ><!--SCRIPT CAPITAL L -->
<!ENTITY lambda           "&#x003BB;" ><!--GREEK SMALL LETTER LAMDA -->
<!ENTITY lang             "&#x027E8;" ><!--MATHEMATICAL LEFT ANGLE BRACKET -->
<!ENTITY langd            "&#x02991;" ><!--LEFT ANGLE BRACKET WITH DOT -->
<!ENTITY langle           "&#x027E8;" ><!--MATHEMATICAL LEFT ANGLE BRACKET -->
<!ENTITY lap              "&#x02A85;" ><!--LESS-THAN OR APPROXIMATE -->
<!ENTITY laquo            "&#x000AB;" ><!--LEFT-POINTING DOUBLE ANGLE QUOTATION MARK -->
<!ENTITY larr             "&#x02190;" ><!--LEFTWARDS ARROW -->
<!ENTITY larrb            "&#x021E4;" ><!--LEFTWARDS ARROW TO BAR -->
<!ENTITY larrbfs          "&#x0291F;" ><!--LEFTWARDS ARROW FROM BAR TO BLACK DIAMOND -->
<!ENTITY larrfs           "&#x0291D;" ><!--LEFTWARDS ARROW TO BLACK DIAMOND -->
<!ENTITY larrhk           "&#x021A9;" ><!--LEFTWARDS ARROW WITH HOOK -->
<!ENTITY larrlp           "&#x021AB;" ><!--LEFTWARDS ARROW WITH LOOP -->
<!ENTITY larrpl           "&#x02939;" ><!--LEFT-SIDE ARC ANTICLOCKWISE ARROW -->
<!ENTITY larrsim          "&#x02973;" ><!--LEFTWARDS ARROW ABOVE TILDE OPERATOR -->
<!ENTITY larrtl           "&#x021A2;" ><!--LEFTWARDS ARROW WITH TAIL -->
<!ENTITY lat              "&#x02AAB;" ><!--LARGER THAN -->
<!ENTITY latail           "&#x02919;" ><!--LEFTWARDS ARROW-TAIL -->
<!ENTITY late             "&#x02AAD;" ><!--LARGER THAN OR EQUAL TO -->
<!ENTITY lates            "&#x02AAD;&#x0FE00;" ><!--LARGER THAN OR slanted EQUAL -->
<!ENTITY lbarr            "&#x0290C;" ><!--LEFTWARDS DOUBLE DASH ARROW -->
<!ENTITY lbbrk            "&#x02772;" ><!--LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT -->
<!ENTITY lbrace           "&#x0007B;" ><!--LEFT CURLY BRACKET -->
<!ENTITY lbrack           "&#x0005B;" ><!--LEFT SQUARE BRACKET -->
<!ENTITY lbrke            "&#x0298B;" ><!--LEFT SQUARE BRACKET WITH UNDERBAR -->
<!ENTITY lbrksld          "&#x0298F;" ><!--LEFT SQUARE BRACKET WITH TICK IN BOTTOM CORNER -->
<!ENTITY lbrkslu          "&#x0298D;" ><!--LEFT SQUARE BRACKET WITH TICK IN TOP CORNER -->
<!ENTITY lcaron           "&#x0013E;" ><!--LATIN SMALL LETTER L WITH CARON -->
<!ENTITY lcedil           "&#x0013C;" ><!--LATIN SMALL LETTER L WITH CEDILLA -->
<!ENTITY lceil            "&#x02308;" ><!--LEFT CEILING -->
<!ENTITY lcub             "&#x0007B;" ><!--LEFT CURLY BRACKET -->
<!ENTITY lcy              "&#x0043B;" ><!--CYRILLIC SMALL LETTER EL -->
<!ENTITY ldca             "&#x02936;" ><!--ARROW POINTING DOWNWARDS THEN CURVING LEFTWARDS -->
<!ENTITY ldquo            "&#x0201C;" ><!--LEFT DOUBLE QUOTATION MARK -->
<!ENTITY ldquor           "&#x0201E;" ><!--DOUBLE LOW-9 QUOTATION MARK -->
<!ENTITY ldrdhar          "&#x02967;" ><!--LEFTWARDS HARPOON WITH BARB DOWN ABOVE RIGHTWARDS HARPOON WITH BARB DOWN -->
<!ENTITY ldrushar         "&#x0294B;" ><!--LEFT BARB DOWN RIGHT BARB UP HARPOON -->
<!ENTITY ldsh             "&#x021B2;" ><!--DOWNWARDS ARROW WITH TIP LEFTWARDS -->
<!ENTITY le               "&#x02264;" ><!--LESS-THAN OR EQUAL TO -->
<!ENTITY leftarrow        "&#x02190;" ><!--LEFTWARDS ARROW -->
<!ENTITY leftarrowtail    "&#x021A2;" ><!--LEFTWARDS ARROW WITH TAIL -->
<!ENTITY leftharpoondown  "&#x021BD;" ><!--LEFTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY leftharpoonup    "&#x021BC;" ><!--LEFTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY leftleftarrows   "&#x021C7;" ><!--LEFTWARDS PAIRED ARROWS -->
<!ENTITY leftrightarrow   "&#x02194;" ><!--LEFT RIGHT ARROW -->
<!ENTITY leftrightarrows  "&#x021C6;" ><!--LEFTWARDS ARROW OVER RIGHTWARDS ARROW -->
<!ENTITY leftrightharpoons "&#x021CB;" ><!--LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON -->
<!ENTITY leftrightsquigarrow "&#x021AD;" ><!--LEFT RIGHT WAVE ARROW -->
<!ENTITY leftthreetimes   "&#x022CB;" ><!--LEFT SEMIDIRECT PRODUCT -->
<!ENTITY leg              "&#x022DA;" ><!--LESS-THAN EQUAL TO OR GREATER-THAN -->
<!ENTITY leq              "&#x02264;" ><!--LESS-THAN OR EQUAL TO -->
<!ENTITY leqq             "&#x02266;" ><!--LESS-THAN OVER EQUAL TO -->
<!ENTITY leqslant         "&#x02A7D;" ><!--LESS-THAN OR SLANTED EQUAL TO -->
<!ENTITY les              "&#x02A7D;" ><!--LESS-THAN OR SLANTED EQUAL TO -->
<!ENTITY lescc            "&#x02AA8;" ><!--LESS-THAN CLOSED BY CURVE ABOVE SLANTED EQUAL -->
<!ENTITY lesdot           "&#x02A7F;" ><!--LESS-THAN OR SLANTED EQUAL TO WITH DOT INSIDE -->
<!ENTITY lesdoto          "&#x02A81;" ><!--LESS-THAN OR SLANTED EQUAL TO WITH DOT ABOVE -->
<!ENTITY lesdotor         "&#x02A83;" ><!--LESS-THAN OR SLANTED EQUAL TO WITH DOT ABOVE RIGHT -->
<!ENTITY lesg             "&#x022DA;&#x0FE00;" ><!--LESS-THAN slanted EQUAL TO OR GREATER-THAN -->
<!ENTITY lesges           "&#x02A93;" ><!--LESS-THAN ABOVE SLANTED EQUAL ABOVE GREATER-THAN ABOVE SLANTED EQUAL -->
<!ENTITY lessapprox       "&#x02A85;" ><!--LESS-THAN OR APPROXIMATE -->
<!ENTITY lessdot          "&#x022D6;" ><!--LESS-THAN WITH DOT -->
<!ENTITY lesseqgtr        "&#x022DA;" ><!--LESS-THAN EQUAL TO OR GREATER-THAN -->
<!ENTITY lesseqqgtr       "&#x02A8B;" ><!--LESS-THAN ABOVE DOUBLE-LINE EQUAL ABOVE GREATER-THAN -->
<!ENTITY lessgtr          "&#x02276;" ><!--LESS-THAN OR GREATER-THAN -->
<!ENTITY lesssim          "&#x02272;" ><!--LESS-THAN OR EQUIVALENT TO -->
<!ENTITY lfisht           "&#x0297C;" ><!--LEFT FISH TAIL -->
<!ENTITY lfloor           "&#x0230A;" ><!--LEFT FLOOR -->
<!ENTITY lfr              "&#x1D529;" ><!--MATHEMATICAL FRAKTUR SMALL L -->
<!ENTITY lg               "&#x02276;" ><!--LESS-THAN OR GREATER-THAN -->
<!ENTITY lgE              "&#x02A91;" ><!--LESS-THAN ABOVE GREATER-THAN ABOVE DOUBLE-LINE EQUAL -->
<!ENTITY lgr              "&#x003BB;" ><!--GREEK SMALL LETTER LAMDA -->
<!ENTITY lhard            "&#x021BD;" ><!--LEFTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY lharu            "&#x021BC;" ><!--LEFTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY lharul           "&#x0296A;" ><!--LEFTWARDS HARPOON WITH BARB UP ABOVE LONG DASH -->
<!ENTITY lhblk            "&#x02584;" ><!--LOWER HALF BLOCK -->
<!ENTITY ljcy             "&#x00459;" ><!--CYRILLIC SMALL LETTER LJE -->
<!ENTITY ll               "&#x0226A;" ><!--MUCH LESS-THAN -->
<!ENTITY llarr            "&#x021C7;" ><!--LEFTWARDS PAIRED ARROWS -->
<!ENTITY llcorner         "&#x0231E;" ><!--BOTTOM LEFT CORNER -->
<!ENTITY llhard           "&#x0296B;" ><!--LEFTWARDS HARPOON WITH BARB DOWN BELOW LONG DASH -->
<!ENTITY lltri            "&#x025FA;" ><!--LOWER LEFT TRIANGLE -->
<!ENTITY lmidot           "&#x00140;" ><!--LATIN SMALL LETTER L WITH MIDDLE DOT -->
<!ENTITY lmoust           "&#x023B0;" ><!--UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION -->
<!ENTITY lmoustache       "&#x023B0;" ><!--UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION -->
<!ENTITY lnE              "&#x02268;" ><!--LESS-THAN BUT NOT EQUAL TO -->
<!ENTITY lnap             "&#x02A89;" ><!--LESS-THAN AND NOT APPROXIMATE -->
<!ENTITY lnapprox         "&#x02A89;" ><!--LESS-THAN AND NOT APPROXIMATE -->
<!ENTITY lne              "&#x02A87;" ><!--LESS-THAN AND SINGLE-LINE NOT EQUAL TO -->
<!ENTITY lneq             "&#x02A87;" ><!--LESS-THAN AND SINGLE-LINE NOT EQUAL TO -->
<!ENTITY lneqq            "&#x02268;" ><!--LESS-THAN BUT NOT EQUAL TO -->
<!ENTITY lnsim            "&#x022E6;" ><!--LESS-THAN BUT NOT EQUIVALENT TO -->
<!ENTITY loang            "&#x027EC;" ><!--MATHEMATICAL LEFT WHITE TORTOISE SHELL BRACKET -->
<!ENTITY loarr            "&#x021FD;" ><!--LEFTWARDS OPEN-HEADED ARROW -->
<!ENTITY lobrk            "&#x027E6;" ><!--MATHEMATICAL LEFT WHITE SQUARE BRACKET -->
<!ENTITY longleftarrow    "&#x027F5;" ><!--LONG LEFTWARDS ARROW -->
<!ENTITY longleftrightarrow "&#x027F7;" ><!--LONG LEFT RIGHT ARROW -->
<!ENTITY longmapsto       "&#x027FC;" ><!--LONG RIGHTWARDS ARROW FROM BAR -->
<!ENTITY longrightarrow   "&#x027F6;" ><!--LONG RIGHTWARDS ARROW -->
<!ENTITY looparrowleft    "&#x021AB;" ><!--LEFTWARDS ARROW WITH LOOP -->
<!ENTITY looparrowright   "&#x021AC;" ><!--RIGHTWARDS ARROW WITH LOOP -->
<!ENTITY lopar            "&#x02985;" ><!--LEFT WHITE PARENTHESIS -->
<!ENTITY lopf             "&#x1D55D;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL L -->
<!ENTITY loplus           "&#x02A2D;" ><!--PLUS SIGN IN LEFT HALF CIRCLE -->
<!ENTITY lotimes          "&#x02A34;" ><!--MULTIPLICATION SIGN IN LEFT HALF CIRCLE -->
<!ENTITY lowast           "&#x02217;" ><!--ASTERISK OPERATOR -->
<!ENTITY lowbar           "&#x0005F;" ><!--LOW LINE -->
<!ENTITY loz              "&#x025CA;" ><!--LOZENGE -->
<!ENTITY lozenge          "&#x025CA;" ><!--LOZENGE -->
<!ENTITY lozf             "&#x029EB;" ><!--BLACK LOZENGE -->
<!ENTITY lpar             "&#x00028;" ><!--LEFT PARENTHESIS -->
<!ENTITY lparlt           "&#x02993;" ><!--LEFT ARC LESS-THAN BRACKET -->
<!ENTITY lrarr            "&#x021C6;" ><!--LEFTWARDS ARROW OVER RIGHTWARDS ARROW -->
<!ENTITY lrcorner         "&#x0231F;" ><!--BOTTOM RIGHT CORNER -->
<!ENTITY lrhar            "&#x021CB;" ><!--LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON -->
<!ENTITY lrhard           "&#x0296D;" ><!--RIGHTWARDS HARPOON WITH BARB DOWN BELOW LONG DASH -->
<!ENTITY lrm              "&#x0200E;" ><!--LEFT-TO-RIGHT MARK -->
<!ENTITY lrtri            "&#x022BF;" ><!--RIGHT TRIANGLE -->
<!ENTITY lsaquo           "&#x02039;" ><!--SINGLE LEFT-POINTING ANGLE QUOTATION MARK -->
<!ENTITY lscr             "&#x1D4C1;" ><!--MATHEMATICAL SCRIPT SMALL L -->
<!ENTITY lsh              "&#x021B0;" ><!--UPWARDS ARROW WITH TIP LEFTWARDS -->
<!ENTITY lsim             "&#x02272;" ><!--LESS-THAN OR EQUIVALENT TO -->
<!ENTITY lsime            "&#x02A8D;" ><!--LESS-THAN ABOVE SIMILAR OR EQUAL -->
<!ENTITY lsimg            "&#x02A8F;" ><!--LESS-THAN ABOVE SIMILAR ABOVE GREATER-THAN -->
<!ENTITY lsqb             "&#x0005B;" ><!--LEFT SQUARE BRACKET -->
<!ENTITY lsquo            "&#x02018;" ><!--LEFT SINGLE QUOTATION MARK -->
<!ENTITY lsquor           "&#x0201A;" ><!--SINGLE LOW-9 QUOTATION MARK -->
<!ENTITY lstrok           "&#x00142;" ><!--LATIN SMALL LETTER L WITH STROKE -->
<!ENTITY lt               "&#38;#60;" ><!--LESS-THAN SIGN -->
<!ENTITY ltcc             "&#x02AA6;" ><!--LESS-THAN CLOSED BY CURVE -->
<!ENTITY ltcir            "&#x02A79;" ><!--LESS-THAN WITH CIRCLE INSIDE -->
<!ENTITY ltdot            "&#x022D6;" ><!--LESS-THAN WITH DOT -->
<!ENTITY lthree           "&#x022CB;" ><!--LEFT SEMIDIRECT PRODUCT -->
<!ENTITY ltimes           "&#x022C9;" ><!--LEFT NORMAL FACTOR SEMIDIRECT PRODUCT -->
<!ENTITY ltlarr           "&#x02976;" ><!--LESS-THAN ABOVE LEFTWARDS ARROW -->
<!ENTITY ltquest          "&#x02A7B;" ><!--LESS-THAN WITH QUESTION MARK ABOVE -->
<!ENTITY ltrPar           "&#x02996;" ><!--DOUBLE RIGHT ARC LESS-THAN BRACKET -->
<!ENTITY ltri             "&#x025C3;" ><!--WHITE LEFT-POINTING SMALL TRIANGLE -->
<!ENTITY ltrie            "&#x022B4;" ><!--NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY ltrif            "&#x025C2;" ><!--BLACK LEFT-POINTING SMALL TRIANGLE -->
<!ENTITY lurdshar         "&#x0294A;" ><!--LEFT BARB UP RIGHT BARB DOWN HARPOON -->
<!ENTITY luruhar          "&#x02966;" ><!--LEFTWARDS HARPOON WITH BARB UP ABOVE RIGHTWARDS HARPOON WITH BARB UP -->
<!ENTITY lvertneqq        "&#x02268;&#x0FE00;" ><!--LESS-THAN BUT NOT EQUAL TO - with vertical stroke -->
<!ENTITY lvnE             "&#x02268;&#x0FE00;" ><!--LESS-THAN BUT NOT EQUAL TO - with vertical stroke -->
<!ENTITY mDDot            "&#x0223A;" ><!--GEOMETRIC PROPORTION -->
<!ENTITY macr             "&#x000AF;" ><!--MACRON -->
<!ENTITY male             "&#x02642;" ><!--MALE SIGN -->
<!ENTITY malt             "&#x02720;" ><!--MALTESE CROSS -->
<!ENTITY maltese          "&#x02720;" ><!--MALTESE CROSS -->
<!ENTITY map              "&#x021A6;" ><!--RIGHTWARDS ARROW FROM BAR -->
<!ENTITY mapsto           "&#x021A6;" ><!--RIGHTWARDS ARROW FROM BAR -->
<!ENTITY mapstodown       "&#x021A7;" ><!--DOWNWARDS ARROW FROM BAR -->
<!ENTITY mapstoleft       "&#x021A4;" ><!--LEFTWARDS ARROW FROM BAR -->
<!ENTITY mapstoup         "&#x021A5;" ><!--UPWARDS ARROW FROM BAR -->
<!ENTITY marker           "&#x025AE;" ><!--BLACK VERTICAL RECTANGLE -->
<!ENTITY mcomma           "&#x02A29;" ><!--MINUS SIGN WITH COMMA ABOVE -->
<!ENTITY mcy              "&#x0043C;" ><!--CYRILLIC SMALL LETTER EM -->
<!ENTITY mdash            "&#x02014;" ><!--EM DASH -->
<!ENTITY measuredangle    "&#x02221;" ><!--MEASURED ANGLE -->
<!ENTITY mfr              "&#x1D52A;" ><!--MATHEMATICAL FRAKTUR SMALL M -->
<!ENTITY mgr              "&#x003BC;" ><!--GREEK SMALL LETTER MU -->
<!ENTITY mho              "&#x02127;" ><!--INVERTED OHM SIGN -->
<!ENTITY micro            "&#x000B5;" ><!--MICRO SIGN -->
<!ENTITY mid              "&#x02223;" ><!--DIVIDES -->
<!ENTITY midast           "&#x0002A;" ><!--ASTERISK -->
<!ENTITY midcir           "&#x02AF0;" ><!--VERTICAL LINE WITH CIRCLE BELOW -->
<!ENTITY middot           "&#x000B7;" ><!--MIDDLE DOT -->
<!ENTITY minus            "&#x02212;" ><!--MINUS SIGN -->
<!ENTITY minusb           "&#x0229F;" ><!--SQUARED MINUS -->
<!ENTITY minusd           "&#x02238;" ><!--DOT MINUS -->
<!ENTITY minusdu          "&#x02A2A;" ><!--MINUS SIGN WITH DOT BELOW -->
<!ENTITY mlcp             "&#x02ADB;" ><!--TRANSVERSAL INTERSECTION -->
<!ENTITY mldr             "&#x02026;" ><!--HORIZONTAL ELLIPSIS -->
<!ENTITY mnplus           "&#x02213;" ><!--MINUS-OR-PLUS SIGN -->
<!ENTITY models           "&#x022A7;" ><!--MODELS -->
<!ENTITY mopf             "&#x1D55E;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL M -->
<!ENTITY mp               "&#x02213;" ><!--MINUS-OR-PLUS SIGN -->
<!ENTITY mscr             "&#x1D4C2;" ><!--MATHEMATICAL SCRIPT SMALL M -->
<!ENTITY mstpos           "&#x0223E;" ><!--INVERTED LAZY S -->
<!ENTITY mu               "&#x003BC;" ><!--GREEK SMALL LETTER MU -->
<!ENTITY multimap         "&#x022B8;" ><!--MULTIMAP -->
<!ENTITY mumap            "&#x022B8;" ><!--MULTIMAP -->
<!ENTITY nGg              "&#x022D9;&#x00338;" ><!--VERY MUCH GREATER-THAN with slash -->
<!ENTITY nGt              "&#x0226B;&#x020D2;" ><!--MUCH GREATER THAN with vertical line -->
<!ENTITY nGtv             "&#x0226B;&#x00338;" ><!--MUCH GREATER THAN with slash -->
<!ENTITY nLeftarrow       "&#x021CD;" ><!--LEFTWARDS DOUBLE ARROW WITH STROKE -->
<!ENTITY nLeftrightarrow  "&#x021CE;" ><!--LEFT RIGHT DOUBLE ARROW WITH STROKE -->
<!ENTITY nLl              "&#x022D8;&#x00338;" ><!--VERY MUCH LESS-THAN with slash -->
<!ENTITY nLt              "&#x0226A;&#x020D2;" ><!--MUCH LESS THAN with vertical line -->
<!ENTITY nLtv             "&#x0226A;&#x00338;" ><!--MUCH LESS THAN with slash -->
<!ENTITY nRightarrow      "&#x021CF;" ><!--RIGHTWARDS DOUBLE ARROW WITH STROKE -->
<!ENTITY nVDash           "&#x022AF;" ><!--NEGATED DOUBLE VERTICAL BAR DOUBLE RIGHT TURNSTILE -->
<!ENTITY nVdash           "&#x022AE;" ><!--DOES NOT FORCE -->
<!ENTITY nabla            "&#x02207;" ><!--NABLA -->
<!ENTITY nacute           "&#x00144;" ><!--LATIN SMALL LETTER N WITH ACUTE -->
<!ENTITY nang             "&#x02220;&#x020D2;" ><!--ANGLE with vertical line -->
<!ENTITY nap              "&#x02249;" ><!--NOT ALMOST EQUAL TO -->
<!ENTITY napE             "&#x02A70;&#x00338;" ><!--APPROXIMATELY EQUAL OR EQUAL TO with slash -->
<!ENTITY napid            "&#x0224B;&#x00338;" ><!--TRIPLE TILDE with slash -->
<!ENTITY napos            "&#x00149;" ><!--LATIN SMALL LETTER N PRECEDED BY APOSTROPHE -->
<!ENTITY napprox          "&#x02249;" ><!--NOT ALMOST EQUAL TO -->
<!ENTITY natur            "&#x0266E;" ><!--MUSIC NATURAL SIGN -->
<!ENTITY natural          "&#x0266E;" ><!--MUSIC NATURAL SIGN -->
<!ENTITY naturals         "&#x02115;" ><!--DOUBLE-STRUCK CAPITAL N -->
<!ENTITY nbsp             "&#x000A0;" ><!--NO-BREAK SPACE -->
<!ENTITY nbump            "&#x0224E;&#x00338;" ><!--GEOMETRICALLY EQUIVALENT TO with slash -->
<!ENTITY nbumpe           "&#x0224F;&#x00338;" ><!--DIFFERENCE BETWEEN with slash -->
<!ENTITY ncap             "&#x02A43;" ><!--INTERSECTION WITH OVERBAR -->
<!ENTITY ncaron           "&#x00148;" ><!--LATIN SMALL LETTER N WITH CARON -->
<!ENTITY ncedil           "&#x00146;" ><!--LATIN SMALL LETTER N WITH CEDILLA -->
<!ENTITY ncong            "&#x02247;" ><!--NEITHER APPROXIMATELY NOR ACTUALLY EQUAL TO -->
<!ENTITY ncongdot         "&#x02A6D;&#x00338;" ><!--CONGRUENT WITH DOT ABOVE with slash -->
<!ENTITY ncup             "&#x02A42;" ><!--UNION WITH OVERBAR -->
<!ENTITY ncy              "&#x0043D;" ><!--CYRILLIC SMALL LETTER EN -->
<!ENTITY ndash            "&#x02013;" ><!--EN DASH -->
<!ENTITY ne               "&#x02260;" ><!--NOT EQUAL TO -->
<!ENTITY neArr            "&#x021D7;" ><!--NORTH EAST DOUBLE ARROW -->
<!ENTITY nearhk           "&#x02924;" ><!--NORTH EAST ARROW WITH HOOK -->
<!ENTITY nearr            "&#x02197;" ><!--NORTH EAST ARROW -->
<!ENTITY nearrow          "&#x02197;" ><!--NORTH EAST ARROW -->
<!ENTITY nedot            "&#x02250;&#x00338;" ><!--APPROACHES THE LIMIT with slash -->
<!ENTITY nequiv           "&#x02262;" ><!--NOT IDENTICAL TO -->
<!ENTITY nesear           "&#x02928;" ><!--NORTH EAST ARROW AND SOUTH EAST ARROW -->
<!ENTITY nesim            "&#x02242;&#x00338;" ><!--MINUS TILDE with slash -->
<!ENTITY nexist           "&#x02204;" ><!--THERE DOES NOT EXIST -->
<!ENTITY nexists          "&#x02204;" ><!--THERE DOES NOT EXIST -->
<!ENTITY nfr              "&#x1D52B;" ><!--MATHEMATICAL FRAKTUR SMALL N -->
<!ENTITY ngE              "&#x02267;&#x00338;" ><!--GREATER-THAN OVER EQUAL TO with slash -->
<!ENTITY nge              "&#x02271;" ><!--NEITHER GREATER-THAN NOR EQUAL TO -->
<!ENTITY ngeq             "&#x02271;" ><!--NEITHER GREATER-THAN NOR EQUAL TO -->
<!ENTITY ngeqq            "&#x02267;&#x00338;" ><!--GREATER-THAN OVER EQUAL TO with slash -->
<!ENTITY ngeqslant        "&#x02A7E;&#x00338;" ><!--GREATER-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY nges             "&#x02A7E;&#x00338;" ><!--GREATER-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY ngr              "&#x003BD;" ><!--GREEK SMALL LETTER NU -->
<!ENTITY ngsim            "&#x02275;" ><!--NEITHER GREATER-THAN NOR EQUIVALENT TO -->
<!ENTITY ngt              "&#x0226F;" ><!--NOT GREATER-THAN -->
<!ENTITY ngtr             "&#x0226F;" ><!--NOT GREATER-THAN -->
<!ENTITY nhArr            "&#x021CE;" ><!--LEFT RIGHT DOUBLE ARROW WITH STROKE -->
<!ENTITY nharr            "&#x021AE;" ><!--LEFT RIGHT ARROW WITH STROKE -->
<!ENTITY nhpar            "&#x02AF2;" ><!--PARALLEL WITH HORIZONTAL STROKE -->
<!ENTITY ni               "&#x0220B;" ><!--CONTAINS AS MEMBER -->
<!ENTITY nis              "&#x022FC;" ><!--SMALL CONTAINS WITH VERTICAL BAR AT END OF HORIZONTAL STROKE -->
<!ENTITY nisd             "&#x022FA;" ><!--CONTAINS WITH LONG HORIZONTAL STROKE -->
<!ENTITY niv              "&#x0220B;" ><!--CONTAINS AS MEMBER -->
<!ENTITY njcy             "&#x0045A;" ><!--CYRILLIC SMALL LETTER NJE -->
<!ENTITY nlArr            "&#x021CD;" ><!--LEFTWARDS DOUBLE ARROW WITH STROKE -->
<!ENTITY nlE              "&#x02266;&#x00338;" ><!--LESS-THAN OVER EQUAL TO with slash -->
<!ENTITY nlarr            "&#x0219A;" ><!--LEFTWARDS ARROW WITH STROKE -->
<!ENTITY nldr             "&#x02025;" ><!--TWO DOT LEADER -->
<!ENTITY nle              "&#x02270;" ><!--NEITHER LESS-THAN NOR EQUAL TO -->
<!ENTITY nleftarrow       "&#x0219A;" ><!--LEFTWARDS ARROW WITH STROKE -->
<!ENTITY nleftrightarrow  "&#x021AE;" ><!--LEFT RIGHT ARROW WITH STROKE -->
<!ENTITY nleq             "&#x02270;" ><!--NEITHER LESS-THAN NOR EQUAL TO -->
<!ENTITY nleqq            "&#x02266;&#x00338;" ><!--LESS-THAN OVER EQUAL TO with slash -->
<!ENTITY nleqslant        "&#x02A7D;&#x00338;" ><!--LESS-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY nles             "&#x02A7D;&#x00338;" ><!--LESS-THAN OR SLANTED EQUAL TO with slash -->
<!ENTITY nless            "&#x0226E;" ><!--NOT LESS-THAN -->
<!ENTITY nlsim            "&#x02274;" ><!--NEITHER LESS-THAN NOR EQUIVALENT TO -->
<!ENTITY nlt              "&#x0226E;" ><!--NOT LESS-THAN -->
<!ENTITY nltri            "&#x022EA;" ><!--NOT NORMAL SUBGROUP OF -->
<!ENTITY nltrie           "&#x022EC;" ><!--NOT NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY nmid             "&#x02224;" ><!--DOES NOT DIVIDE -->
<!ENTITY nopf             "&#x1D55F;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL N -->
<!ENTITY not              "&#x000AC;" ><!--NOT SIGN -->
<!ENTITY notin            "&#x02209;" ><!--NOT AN ELEMENT OF -->
<!ENTITY notinE           "&#x022F9;&#x00338;" ><!--ELEMENT OF WITH TWO HORIZONTAL STROKES with slash -->
<!ENTITY notindot         "&#x022F5;&#x00338;" ><!--ELEMENT OF WITH DOT ABOVE with slash -->
<!ENTITY notinva          "&#x02209;" ><!--NOT AN ELEMENT OF -->
<!ENTITY notinvb          "&#x022F7;" ><!--SMALL ELEMENT OF WITH OVERBAR -->
<!ENTITY notinvc          "&#x022F6;" ><!--ELEMENT OF WITH OVERBAR -->
<!ENTITY notni            "&#x0220C;" ><!--DOES NOT CONTAIN AS MEMBER -->
<!ENTITY notniva          "&#x0220C;" ><!--DOES NOT CONTAIN AS MEMBER -->
<!ENTITY notnivb          "&#x022FE;" ><!--SMALL CONTAINS WITH OVERBAR -->
<!ENTITY notnivc          "&#x022FD;" ><!--CONTAINS WITH OVERBAR -->
<!ENTITY npar             "&#x02226;" ><!--NOT PARALLEL TO -->
<!ENTITY nparallel        "&#x02226;" ><!--NOT PARALLEL TO -->
<!ENTITY nparsl           "&#x02AFD;&#x020E5;" ><!--DOUBLE SOLIDUS OPERATOR with reverse slash -->
<!ENTITY npart            "&#x02202;&#x00338;" ><!--PARTIAL DIFFERENTIAL with slash -->
<!ENTITY npolint          "&#x02A14;" ><!--LINE INTEGRATION NOT INCLUDING THE POLE -->
<!ENTITY npr              "&#x02280;" ><!--DOES NOT PRECEDE -->
<!ENTITY nprcue           "&#x022E0;" ><!--DOES NOT PRECEDE OR EQUAL -->
<!ENTITY npre             "&#x02AAF;&#x00338;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY nprec            "&#x02280;" ><!--DOES NOT PRECEDE -->
<!ENTITY npreceq          "&#x02AAF;&#x00338;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY nrArr            "&#x021CF;" ><!--RIGHTWARDS DOUBLE ARROW WITH STROKE -->
<!ENTITY nrarr            "&#x0219B;" ><!--RIGHTWARDS ARROW WITH STROKE -->
<!ENTITY nrarrc           "&#x02933;&#x00338;" ><!--WAVE ARROW POINTING DIRECTLY RIGHT with slash -->
<!ENTITY nrarrw           "&#x0219D;&#x00338;" ><!--RIGHTWARDS WAVE ARROW with slash -->
<!ENTITY nrightarrow      "&#x0219B;" ><!--RIGHTWARDS ARROW WITH STROKE -->
<!ENTITY nrtri            "&#x022EB;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP -->
<!ENTITY nrtrie           "&#x022ED;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL -->
<!ENTITY nsc              "&#x02281;" ><!--DOES NOT SUCCEED -->
<!ENTITY nsccue           "&#x022E1;" ><!--DOES NOT SUCCEED OR EQUAL -->
<!ENTITY nsce             "&#x02AB0;&#x00338;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY nscr             "&#x1D4C3;" ><!--MATHEMATICAL SCRIPT SMALL N -->
<!ENTITY nshortmid        "&#x02224;" ><!--DOES NOT DIVIDE -->
<!ENTITY nshortparallel   "&#x02226;" ><!--NOT PARALLEL TO -->
<!ENTITY nsim             "&#x02241;" ><!--NOT TILDE -->
<!ENTITY nsime            "&#x02244;" ><!--NOT ASYMPTOTICALLY EQUAL TO -->
<!ENTITY nsimeq           "&#x02244;" ><!--NOT ASYMPTOTICALLY EQUAL TO -->
<!ENTITY nsmid            "&#x02224;" ><!--DOES NOT DIVIDE -->
<!ENTITY nspar            "&#x02226;" ><!--NOT PARALLEL TO -->
<!ENTITY nsqsube          "&#x022E2;" ><!--NOT SQUARE IMAGE OF OR EQUAL TO -->
<!ENTITY nsqsupe          "&#x022E3;" ><!--NOT SQUARE ORIGINAL OF OR EQUAL TO -->
<!ENTITY nsub             "&#x02284;" ><!--NOT A SUBSET OF -->
<!ENTITY nsubE            "&#x02AC5;&#x00338;" ><!--SUBSET OF ABOVE EQUALS SIGN with slash -->
<!ENTITY nsube            "&#x02288;" ><!--NEITHER A SUBSET OF NOR EQUAL TO -->
<!ENTITY nsubset          "&#x02282;&#x020D2;" ><!--SUBSET OF with vertical line -->
<!ENTITY nsubseteq        "&#x02288;" ><!--NEITHER A SUBSET OF NOR EQUAL TO -->
<!ENTITY nsubseteqq       "&#x02AC5;&#x00338;" ><!--SUBSET OF ABOVE EQUALS SIGN with slash -->
<!ENTITY nsucc            "&#x02281;" ><!--DOES NOT SUCCEED -->
<!ENTITY nsucceq          "&#x02AB0;&#x00338;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash -->
<!ENTITY nsup             "&#x02285;" ><!--NOT A SUPERSET OF -->
<!ENTITY nsupE            "&#x02AC6;&#x00338;" ><!--SUPERSET OF ABOVE EQUALS SIGN with slash -->
<!ENTITY nsupe            "&#x02289;" ><!--NEITHER A SUPERSET OF NOR EQUAL TO -->
<!ENTITY nsupset          "&#x02283;&#x020D2;" ><!--SUPERSET OF with vertical line -->
<!ENTITY nsupseteq        "&#x02289;" ><!--NEITHER A SUPERSET OF NOR EQUAL TO -->
<!ENTITY nsupseteqq       "&#x02AC6;&#x00338;" ><!--SUPERSET OF ABOVE EQUALS SIGN with slash -->
<!ENTITY ntgl             "&#x02279;" ><!--NEITHER GREATER-THAN NOR LESS-THAN -->
<!ENTITY ntilde           "&#x000F1;" ><!--LATIN SMALL LETTER N WITH TILDE -->
<!ENTITY ntlg             "&#x02278;" ><!--NEITHER LESS-THAN NOR GREATER-THAN -->
<!ENTITY ntriangleleft    "&#x022EA;" ><!--NOT NORMAL SUBGROUP OF -->
<!ENTITY ntrianglelefteq  "&#x022EC;" ><!--NOT NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY ntriangleright   "&#x022EB;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP -->
<!ENTITY ntrianglerighteq "&#x022ED;" ><!--DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL -->
<!ENTITY nu               "&#x003BD;" ><!--GREEK SMALL LETTER NU -->
<!ENTITY num              "&#x00023;" ><!--NUMBER SIGN -->
<!ENTITY numero           "&#x02116;" ><!--NUMERO SIGN -->
<!ENTITY numsp            "&#x02007;" ><!--FIGURE SPACE -->
<!ENTITY nvDash           "&#x022AD;" ><!--NOT TRUE -->
<!ENTITY nvHarr           "&#x02904;" ><!--LEFT RIGHT DOUBLE ARROW WITH VERTICAL STROKE -->
<!ENTITY nvap             "&#x0224D;&#x020D2;" ><!--EQUIVALENT TO with vertical line -->
<!ENTITY nvdash           "&#x022AC;" ><!--DOES NOT PROVE -->
<!ENTITY nvge             "&#x02265;&#x020D2;" ><!--GREATER-THAN OR EQUAL TO with vertical line -->
<!ENTITY nvgt             "&#x0003E;&#x020D2;" ><!--GREATER-THAN SIGN with vertical line -->
<!ENTITY nvinfin          "&#x029DE;" ><!--INFINITY NEGATED WITH VERTICAL BAR -->
<!ENTITY nvlArr           "&#x02902;" ><!--LEFTWARDS DOUBLE ARROW WITH VERTICAL STROKE -->
<!ENTITY nvle             "&#x02264;&#x020D2;" ><!--LESS-THAN OR EQUAL TO with vertical line -->
<!ENTITY nvlt             "&#38;#x0003C;&#x020D2;" ><!--LESS-THAN SIGN with vertical line -->
<!ENTITY nvltrie          "&#x022B4;&#x020D2;" ><!--NORMAL SUBGROUP OF OR EQUAL TO with vertical line -->
<!ENTITY nvrArr           "&#x02903;" ><!--RIGHTWARDS DOUBLE ARROW WITH VERTICAL STROKE -->
<!ENTITY nvrtrie          "&#x022B5;&#x020D2;" ><!--CONTAINS AS NORMAL SUBGROUP OR EQUAL TO with vertical line -->
<!ENTITY nvsim            "&#x0223C;&#x020D2;" ><!--TILDE OPERATOR with vertical line -->
<!ENTITY nwArr            "&#x021D6;" ><!--NORTH WEST DOUBLE ARROW -->
<!ENTITY nwarhk           "&#x02923;" ><!--NORTH WEST ARROW WITH HOOK -->
<!ENTITY nwarr            "&#x02196;" ><!--NORTH WEST ARROW -->
<!ENTITY nwarrow          "&#x02196;" ><!--NORTH WEST ARROW -->
<!ENTITY nwnear           "&#x02927;" ><!--NORTH WEST ARROW AND NORTH EAST ARROW -->
<!ENTITY oS               "&#x024C8;" ><!--CIRCLED LATIN CAPITAL LETTER S -->
<!ENTITY oacgr            "&#x003CC;" ><!--GREEK SMALL LETTER OMICRON WITH TONOS -->
<!ENTITY oacute           "&#x000F3;" ><!--LATIN SMALL LETTER O WITH ACUTE -->
<!ENTITY oast             "&#x0229B;" ><!--CIRCLED ASTERISK OPERATOR -->
<!ENTITY ocir             "&#x0229A;" ><!--CIRCLED RING OPERATOR -->
<!ENTITY ocirc            "&#x000F4;" ><!--LATIN SMALL LETTER O WITH CIRCUMFLEX -->
<!ENTITY ocy              "&#x0043E;" ><!--CYRILLIC SMALL LETTER O -->
<!ENTITY odash            "&#x0229D;" ><!--CIRCLED DASH -->
<!ENTITY odblac           "&#x00151;" ><!--LATIN SMALL LETTER O WITH DOUBLE ACUTE -->
<!ENTITY odiv             "&#x02A38;" ><!--CIRCLED DIVISION SIGN -->
<!ENTITY odot             "&#x02299;" ><!--CIRCLED DOT OPERATOR -->
<!ENTITY odsold           "&#x029BC;" ><!--CIRCLED ANTICLOCKWISE-ROTATED DIVISION SIGN -->
<!ENTITY oelig            "&#x00153;" ><!--LATIN SMALL LIGATURE OE -->
<!ENTITY ofcir            "&#x029BF;" ><!--CIRCLED BULLET -->
<!ENTITY ofr              "&#x1D52C;" ><!--MATHEMATICAL FRAKTUR SMALL O -->
<!ENTITY ogon             "&#x002DB;" ><!--OGONEK -->
<!ENTITY ogr              "&#x003BF;" ><!--GREEK SMALL LETTER OMICRON -->
<!ENTITY ograve           "&#x000F2;" ><!--LATIN SMALL LETTER O WITH GRAVE -->
<!ENTITY ogt              "&#x029C1;" ><!--CIRCLED GREATER-THAN -->
<!ENTITY ohacgr           "&#x003CE;" ><!--GREEK SMALL LETTER OMEGA WITH TONOS -->
<!ENTITY ohbar            "&#x029B5;" ><!--CIRCLE WITH HORIZONTAL BAR -->
<!ENTITY ohgr             "&#x003C9;" ><!--GREEK SMALL LETTER OMEGA -->
<!ENTITY ohm              "&#x003A9;" ><!--GREEK CAPITAL LETTER OMEGA -->
<!ENTITY oint             "&#x0222E;" ><!--CONTOUR INTEGRAL -->
<!ENTITY olarr            "&#x021BA;" ><!--ANTICLOCKWISE OPEN CIRCLE ARROW -->
<!ENTITY olcir            "&#x029BE;" ><!--CIRCLED WHITE BULLET -->
<!ENTITY olcross          "&#x029BB;" ><!--CIRCLE WITH SUPERIMPOSED X -->
<!ENTITY oline            "&#x0203E;" ><!--OVERLINE -->
<!ENTITY olt              "&#x029C0;" ><!--CIRCLED LESS-THAN -->
<!ENTITY omacr            "&#x0014D;" ><!--LATIN SMALL LETTER O WITH MACRON -->
<!ENTITY omega            "&#x003C9;" ><!--GREEK SMALL LETTER OMEGA -->
<!ENTITY omicron          "&#x003BF;" ><!--GREEK SMALL LETTER OMICRON -->
<!ENTITY omid             "&#x029B6;" ><!--CIRCLED VERTICAL BAR -->
<!ENTITY ominus           "&#x02296;" ><!--CIRCLED MINUS -->
<!ENTITY oopf             "&#x1D560;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL O -->
<!ENTITY opar             "&#x029B7;" ><!--CIRCLED PARALLEL -->
<!ENTITY operp            "&#x029B9;" ><!--CIRCLED PERPENDICULAR -->
<!ENTITY oplus            "&#x02295;" ><!--CIRCLED PLUS -->
<!ENTITY or               "&#x02228;" ><!--LOGICAL OR -->
<!ENTITY orarr            "&#x021BB;" ><!--CLOCKWISE OPEN CIRCLE ARROW -->
<!ENTITY ord              "&#x02A5D;" ><!--LOGICAL OR WITH HORIZONTAL DASH -->
<!ENTITY order            "&#x02134;" ><!--SCRIPT SMALL O -->
<!ENTITY orderof          "&#x02134;" ><!--SCRIPT SMALL O -->
<!ENTITY ordf             "&#x000AA;" ><!--FEMININE ORDINAL INDICATOR -->
<!ENTITY ordm             "&#x000BA;" ><!--MASCULINE ORDINAL INDICATOR -->
<!ENTITY origof           "&#x022B6;" ><!--ORIGINAL OF -->
<!ENTITY oror             "&#x02A56;" ><!--TWO INTERSECTING LOGICAL OR -->
<!ENTITY orslope          "&#x02A57;" ><!--SLOPING LARGE OR -->
<!ENTITY orv              "&#x02A5B;" ><!--LOGICAL OR WITH MIDDLE STEM -->
<!ENTITY oscr             "&#x02134;" ><!--SCRIPT SMALL O -->
<!ENTITY oslash           "&#x000F8;" ><!--LATIN SMALL LETTER O WITH STROKE -->
<!ENTITY osol             "&#x02298;" ><!--CIRCLED DIVISION SLASH -->
<!ENTITY otilde           "&#x000F5;" ><!--LATIN SMALL LETTER O WITH TILDE -->
<!ENTITY otimes           "&#x02297;" ><!--CIRCLED TIMES -->
<!ENTITY otimesas         "&#x02A36;" ><!--CIRCLED MULTIPLICATION SIGN WITH CIRCUMFLEX ACCENT -->
<!ENTITY ouml             "&#x000F6;" ><!--LATIN SMALL LETTER O WITH DIAERESIS -->
<!ENTITY ovbar            "&#x0233D;" ><!--APL FUNCTIONAL SYMBOL CIRCLE STILE -->
<!ENTITY par              "&#x02225;" ><!--PARALLEL TO -->
<!ENTITY para             "&#x000B6;" ><!--PILCROW SIGN -->
<!ENTITY parallel         "&#x02225;" ><!--PARALLEL TO -->
<!ENTITY parsim           "&#x02AF3;" ><!--PARALLEL WITH TILDE OPERATOR -->
<!ENTITY parsl            "&#x02AFD;" ><!--DOUBLE SOLIDUS OPERATOR -->
<!ENTITY part             "&#x02202;" ><!--PARTIAL DIFFERENTIAL -->
<!ENTITY pcy              "&#x0043F;" ><!--CYRILLIC SMALL LETTER PE -->
<!ENTITY percnt           "&#x00025;" ><!--PERCENT SIGN -->
<!ENTITY period           "&#x0002E;" ><!--FULL STOP -->
<!ENTITY permil           "&#x02030;" ><!--PER MILLE SIGN -->
<!ENTITY perp             "&#x022A5;" ><!--UP TACK -->
<!ENTITY pertenk          "&#x02031;" ><!--PER TEN THOUSAND SIGN -->
<!ENTITY pfr              "&#x1D52D;" ><!--MATHEMATICAL FRAKTUR SMALL P -->
<!ENTITY pgr              "&#x003C0;" ><!--GREEK SMALL LETTER PI -->
<!ENTITY phgr             "&#x003C6;" ><!--GREEK SMALL LETTER PHI -->
<!ENTITY phi              "&#x003C6;" ><!--GREEK SMALL LETTER PHI -->
<!ENTITY phiv             "&#x003D5;" ><!--GREEK PHI SYMBOL -->
<!ENTITY phmmat           "&#x02133;" ><!--SCRIPT CAPITAL M -->
<!ENTITY phone            "&#x0260E;" ><!--BLACK TELEPHONE -->
<!ENTITY pi               "&#x003C0;" ><!--GREEK SMALL LETTER PI -->
<!ENTITY pitchfork        "&#x022D4;" ><!--PITCHFORK -->
<!ENTITY piv              "&#x003D6;" ><!--GREEK PI SYMBOL -->
<!ENTITY planck           "&#x0210F;" ><!--PLANCK CONSTANT OVER TWO PI -->
<!ENTITY planckh          "&#x0210E;" ><!--PLANCK CONSTANT -->
<!ENTITY plankv           "&#x0210F;" ><!--PLANCK CONSTANT OVER TWO PI -->
<!ENTITY plus             "&#x0002B;" ><!--PLUS SIGN -->
<!ENTITY plusacir         "&#x02A23;" ><!--PLUS SIGN WITH CIRCUMFLEX ACCENT ABOVE -->
<!ENTITY plusb            "&#x0229E;" ><!--SQUARED PLUS -->
<!ENTITY pluscir          "&#x02A22;" ><!--PLUS SIGN WITH SMALL CIRCLE ABOVE -->
<!ENTITY plusdo           "&#x02214;" ><!--DOT PLUS -->
<!ENTITY plusdu           "&#x02A25;" ><!--PLUS SIGN WITH DOT BELOW -->
<!ENTITY pluse            "&#x02A72;" ><!--PLUS SIGN ABOVE EQUALS SIGN -->
<!ENTITY plusmn           "&#x000B1;" ><!--PLUS-MINUS SIGN -->
<!ENTITY plussim          "&#x02A26;" ><!--PLUS SIGN WITH TILDE BELOW -->
<!ENTITY plustwo          "&#x02A27;" ><!--PLUS SIGN WITH SUBSCRIPT TWO -->
<!ENTITY pm               "&#x000B1;" ><!--PLUS-MINUS SIGN -->
<!ENTITY pointint         "&#x02A15;" ><!--INTEGRAL AROUND A POINT OPERATOR -->
<!ENTITY popf             "&#x1D561;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL P -->
<!ENTITY pound            "&#x000A3;" ><!--POUND SIGN -->
<!ENTITY pr               "&#x0227A;" ><!--PRECEDES -->
<!ENTITY prE              "&#x02AB3;" ><!--PRECEDES ABOVE EQUALS SIGN -->
<!ENTITY prap             "&#x02AB7;" ><!--PRECEDES ABOVE ALMOST EQUAL TO -->
<!ENTITY prcue            "&#x0227C;" ><!--PRECEDES OR EQUAL TO -->
<!ENTITY pre              "&#x02AAF;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY prec             "&#x0227A;" ><!--PRECEDES -->
<!ENTITY precapprox       "&#x02AB7;" ><!--PRECEDES ABOVE ALMOST EQUAL TO -->
<!ENTITY preccurlyeq      "&#x0227C;" ><!--PRECEDES OR EQUAL TO -->
<!ENTITY preceq           "&#x02AAF;" ><!--PRECEDES ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY precnapprox      "&#x02AB9;" ><!--PRECEDES ABOVE NOT ALMOST EQUAL TO -->
<!ENTITY precneqq         "&#x02AB5;" ><!--PRECEDES ABOVE NOT EQUAL TO -->
<!ENTITY precnsim         "&#x022E8;" ><!--PRECEDES BUT NOT EQUIVALENT TO -->
<!ENTITY precsim          "&#x0227E;" ><!--PRECEDES OR EQUIVALENT TO -->
<!ENTITY prime            "&#x02032;" ><!--PRIME -->
<!ENTITY primes           "&#x02119;" ><!--DOUBLE-STRUCK CAPITAL P -->
<!ENTITY prnE             "&#x02AB5;" ><!--PRECEDES ABOVE NOT EQUAL TO -->
<!ENTITY prnap            "&#x02AB9;" ><!--PRECEDES ABOVE NOT ALMOST EQUAL TO -->
<!ENTITY prnsim           "&#x022E8;" ><!--PRECEDES BUT NOT EQUIVALENT TO -->
<!ENTITY prod             "&#x0220F;" ><!--N-ARY PRODUCT -->
<!ENTITY profalar         "&#x0232E;" ><!--ALL AROUND-PROFILE -->
<!ENTITY profline         "&#x02312;" ><!--ARC -->
<!ENTITY profsurf         "&#x02313;" ><!--SEGMENT -->
<!ENTITY prop             "&#x0221D;" ><!--PROPORTIONAL TO -->
<!ENTITY propto           "&#x0221D;" ><!--PROPORTIONAL TO -->
<!ENTITY prsim            "&#x0227E;" ><!--PRECEDES OR EQUIVALENT TO -->
<!ENTITY prurel           "&#x022B0;" ><!--PRECEDES UNDER RELATION -->
<!ENTITY pscr             "&#x1D4C5;" ><!--MATHEMATICAL SCRIPT SMALL P -->
<!ENTITY psgr             "&#x003C8;" ><!--GREEK SMALL LETTER PSI -->
<!ENTITY psi              "&#x003C8;" ><!--GREEK SMALL LETTER PSI -->
<!ENTITY puncsp           "&#x02008;" ><!--PUNCTUATION SPACE -->
<!ENTITY qfr              "&#x1D52E;" ><!--MATHEMATICAL FRAKTUR SMALL Q -->
<!ENTITY qint             "&#x02A0C;" ><!--QUADRUPLE INTEGRAL OPERATOR -->
<!ENTITY qopf             "&#x1D562;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL Q -->
<!ENTITY qprime           "&#x02057;" ><!--QUADRUPLE PRIME -->
<!ENTITY qscr             "&#x1D4C6;" ><!--MATHEMATICAL SCRIPT SMALL Q -->
<!ENTITY quaternions      "&#x0210D;" ><!--DOUBLE-STRUCK CAPITAL H -->
<!ENTITY quatint          "&#x02A16;" ><!--QUATERNION INTEGRAL OPERATOR -->
<!ENTITY quest            "&#x0003F;" ><!--QUESTION MARK -->
<!ENTITY questeq          "&#x0225F;" ><!--QUESTIONED EQUAL TO -->
<!ENTITY quot             "&#x00022;" ><!--QUOTATION MARK -->
<!ENTITY rAarr            "&#x021DB;" ><!--RIGHTWARDS TRIPLE ARROW -->
<!ENTITY rArr             "&#x021D2;" ><!--RIGHTWARDS DOUBLE ARROW -->
<!ENTITY rAtail           "&#x0291C;" ><!--RIGHTWARDS DOUBLE ARROW-TAIL -->
<!ENTITY rBarr            "&#x0290F;" ><!--RIGHTWARDS TRIPLE DASH ARROW -->
<!ENTITY rHar             "&#x02964;" ><!--RIGHTWARDS HARPOON WITH BARB UP ABOVE RIGHTWARDS HARPOON WITH BARB DOWN -->
<!ENTITY race             "&#x0223D;&#x00331;" ><!--REVERSED TILDE with underline -->
<!ENTITY racute           "&#x00155;" ><!--LATIN SMALL LETTER R WITH ACUTE -->
<!ENTITY radic            "&#x0221A;" ><!--SQUARE ROOT -->
<!ENTITY raemptyv         "&#x029B3;" ><!--EMPTY SET WITH RIGHT ARROW ABOVE -->
<!ENTITY rang             "&#x027E9;" ><!--MATHEMATICAL RIGHT ANGLE BRACKET -->
<!ENTITY rangd            "&#x02992;" ><!--RIGHT ANGLE BRACKET WITH DOT -->
<!ENTITY range            "&#x029A5;" ><!--REVERSED ANGLE WITH UNDERBAR -->
<!ENTITY rangle           "&#x027E9;" ><!--MATHEMATICAL RIGHT ANGLE BRACKET -->
<!ENTITY raquo            "&#x000BB;" ><!--RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK -->
<!ENTITY rarr             "&#x02192;" ><!--RIGHTWARDS ARROW -->
<!ENTITY rarrap           "&#x02975;" ><!--RIGHTWARDS ARROW ABOVE ALMOST EQUAL TO -->
<!ENTITY rarrb            "&#x021E5;" ><!--RIGHTWARDS ARROW TO BAR -->
<!ENTITY rarrbfs          "&#x02920;" ><!--RIGHTWARDS ARROW FROM BAR TO BLACK DIAMOND -->
<!ENTITY rarrc            "&#x02933;" ><!--WAVE ARROW POINTING DIRECTLY RIGHT -->
<!ENTITY rarrfs           "&#x0291E;" ><!--RIGHTWARDS ARROW TO BLACK DIAMOND -->
<!ENTITY rarrhk           "&#x021AA;" ><!--RIGHTWARDS ARROW WITH HOOK -->
<!ENTITY rarrlp           "&#x021AC;" ><!--RIGHTWARDS ARROW WITH LOOP -->
<!ENTITY rarrpl           "&#x02945;" ><!--RIGHTWARDS ARROW WITH PLUS BELOW -->
<!ENTITY rarrsim          "&#x02974;" ><!--RIGHTWARDS ARROW ABOVE TILDE OPERATOR -->
<!ENTITY rarrtl           "&#x021A3;" ><!--RIGHTWARDS ARROW WITH TAIL -->
<!ENTITY rarrw            "&#x0219D;" ><!--RIGHTWARDS WAVE ARROW -->
<!ENTITY ratail           "&#x0291A;" ><!--RIGHTWARDS ARROW-TAIL -->
<!ENTITY ratio            "&#x02236;" ><!--RATIO -->
<!ENTITY rationals        "&#x0211A;" ><!--DOUBLE-STRUCK CAPITAL Q -->
<!ENTITY rbarr            "&#x0290D;" ><!--RIGHTWARDS DOUBLE DASH ARROW -->
<!ENTITY rbbrk            "&#x02773;" ><!--LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT -->
<!ENTITY rbrace           "&#x0007D;" ><!--RIGHT CURLY BRACKET -->
<!ENTITY rbrack           "&#x0005D;" ><!--RIGHT SQUARE BRACKET -->
<!ENTITY rbrke            "&#x0298C;" ><!--RIGHT SQUARE BRACKET WITH UNDERBAR -->
<!ENTITY rbrksld          "&#x0298E;" ><!--RIGHT SQUARE BRACKET WITH TICK IN BOTTOM CORNER -->
<!ENTITY rbrkslu          "&#x02990;" ><!--RIGHT SQUARE BRACKET WITH TICK IN TOP CORNER -->
<!ENTITY rcaron           "&#x00159;" ><!--LATIN SMALL LETTER R WITH CARON -->
<!ENTITY rcedil           "&#x00157;" ><!--LATIN SMALL LETTER R WITH CEDILLA -->
<!ENTITY rceil            "&#x02309;" ><!--RIGHT CEILING -->
<!ENTITY rcub             "&#x0007D;" ><!--RIGHT CURLY BRACKET -->
<!ENTITY rcy              "&#x00440;" ><!--CYRILLIC SMALL LETTER ER -->
<!ENTITY rdca             "&#x02937;" ><!--ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS -->
<!ENTITY rdldhar          "&#x02969;" ><!--RIGHTWARDS HARPOON WITH BARB DOWN ABOVE LEFTWARDS HARPOON WITH BARB DOWN -->
<!ENTITY rdquo            "&#x0201D;" ><!--RIGHT DOUBLE QUOTATION MARK -->
<!ENTITY rdquor           "&#x0201D;" ><!--RIGHT DOUBLE QUOTATION MARK -->
<!ENTITY rdsh             "&#x021B3;" ><!--DOWNWARDS ARROW WITH TIP RIGHTWARDS -->
<!ENTITY real             "&#x0211C;" ><!--BLACK-LETTER CAPITAL R -->
<!ENTITY realine          "&#x0211B;" ><!--SCRIPT CAPITAL R -->
<!ENTITY realpart         "&#x0211C;" ><!--BLACK-LETTER CAPITAL R -->
<!ENTITY reals            "&#x0211D;" ><!--DOUBLE-STRUCK CAPITAL R -->
<!ENTITY rect             "&#x025AD;" ><!--WHITE RECTANGLE -->
<!ENTITY reg              "&#x000AE;" ><!--REGISTERED SIGN -->
<!ENTITY rfisht           "&#x0297D;" ><!--RIGHT FISH TAIL -->
<!ENTITY rfloor           "&#x0230B;" ><!--RIGHT FLOOR -->
<!ENTITY rfr              "&#x1D52F;" ><!--MATHEMATICAL FRAKTUR SMALL R -->
<!ENTITY rgr              "&#x003C1;" ><!--GREEK SMALL LETTER RHO -->
<!ENTITY rhard            "&#x021C1;" ><!--RIGHTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY rharu            "&#x021C0;" ><!--RIGHTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY rharul           "&#x0296C;" ><!--RIGHTWARDS HARPOON WITH BARB UP ABOVE LONG DASH -->
<!ENTITY rho              "&#x003C1;" ><!--GREEK SMALL LETTER RHO -->
<!ENTITY rhov             "&#x003F1;" ><!--GREEK RHO SYMBOL -->
<!ENTITY rightarrow       "&#x02192;" ><!--RIGHTWARDS ARROW -->
<!ENTITY rightarrowtail   "&#x021A3;" ><!--RIGHTWARDS ARROW WITH TAIL -->
<!ENTITY rightharpoondown "&#x021C1;" ><!--RIGHTWARDS HARPOON WITH BARB DOWNWARDS -->
<!ENTITY rightharpoonup   "&#x021C0;" ><!--RIGHTWARDS HARPOON WITH BARB UPWARDS -->
<!ENTITY rightleftarrows  "&#x021C4;" ><!--RIGHTWARDS ARROW OVER LEFTWARDS ARROW -->
<!ENTITY rightleftharpoons "&#x021CC;" ><!--RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON -->
<!ENTITY rightrightarrows "&#x021C9;" ><!--RIGHTWARDS PAIRED ARROWS -->
<!ENTITY rightsquigarrow  "&#x0219D;" ><!--RIGHTWARDS WAVE ARROW -->
<!ENTITY rightthreetimes  "&#x022CC;" ><!--RIGHT SEMIDIRECT PRODUCT -->
<!ENTITY ring             "&#x002DA;" ><!--RING ABOVE -->
<!ENTITY risingdotseq     "&#x02253;" ><!--IMAGE OF OR APPROXIMATELY EQUAL TO -->
<!ENTITY rlarr            "&#x021C4;" ><!--RIGHTWARDS ARROW OVER LEFTWARDS ARROW -->
<!ENTITY rlhar            "&#x021CC;" ><!--RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON -->
<!ENTITY rlm              "&#x0200F;" ><!--RIGHT-TO-LEFT MARK -->
<!ENTITY rmoust           "&#x023B1;" ><!--UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION -->
<!ENTITY rmoustache       "&#x023B1;" ><!--UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION -->
<!ENTITY rnmid            "&#x02AEE;" ><!--DOES NOT DIVIDE WITH REVERSED NEGATION SLASH -->
<!ENTITY roang            "&#x027ED;" ><!--MATHEMATICAL RIGHT WHITE TORTOISE SHELL BRACKET -->
<!ENTITY roarr            "&#x021FE;" ><!--RIGHTWARDS OPEN-HEADED ARROW -->
<!ENTITY robrk            "&#x027E7;" ><!--MATHEMATICAL RIGHT WHITE SQUARE BRACKET -->
<!ENTITY ropar            "&#x02986;" ><!--RIGHT WHITE PARENTHESIS -->
<!ENTITY ropf             "&#x1D563;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL R -->
<!ENTITY roplus           "&#x02A2E;" ><!--PLUS SIGN IN RIGHT HALF CIRCLE -->
<!ENTITY rotimes          "&#x02A35;" ><!--MULTIPLICATION SIGN IN RIGHT HALF CIRCLE -->
<!ENTITY rpar             "&#x00029;" ><!--RIGHT PARENTHESIS -->
<!ENTITY rpargt           "&#x02994;" ><!--RIGHT ARC GREATER-THAN BRACKET -->
<!ENTITY rppolint         "&#x02A12;" ><!--LINE INTEGRATION WITH RECTANGULAR PATH AROUND POLE -->
<!ENTITY rrarr            "&#x021C9;" ><!--RIGHTWARDS PAIRED ARROWS -->
<!ENTITY rsaquo           "&#x0203A;" ><!--SINGLE RIGHT-POINTING ANGLE QUOTATION MARK -->
<!ENTITY rscr             "&#x1D4C7;" ><!--MATHEMATICAL SCRIPT SMALL R -->
<!ENTITY rsh              "&#x021B1;" ><!--UPWARDS ARROW WITH TIP RIGHTWARDS -->
<!ENTITY rsqb             "&#x0005D;" ><!--RIGHT SQUARE BRACKET -->
<!ENTITY rsquo            "&#x02019;" ><!--RIGHT SINGLE QUOTATION MARK -->
<!ENTITY rsquor           "&#x02019;" ><!--RIGHT SINGLE QUOTATION MARK -->
<!ENTITY rthree           "&#x022CC;" ><!--RIGHT SEMIDIRECT PRODUCT -->
<!ENTITY rtimes           "&#x022CA;" ><!--RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT -->
<!ENTITY rtri             "&#x025B9;" ><!--WHITE RIGHT-POINTING SMALL TRIANGLE -->
<!ENTITY rtrie            "&#x022B5;" ><!--CONTAINS AS NORMAL SUBGROUP OR EQUAL TO -->
<!ENTITY rtrif            "&#x025B8;" ><!--BLACK RIGHT-POINTING SMALL TRIANGLE -->
<!ENTITY rtriltri         "&#x029CE;" ><!--RIGHT TRIANGLE ABOVE LEFT TRIANGLE -->
<!ENTITY ruluhar          "&#x02968;" ><!--RIGHTWARDS HARPOON WITH BARB UP ABOVE LEFTWARDS HARPOON WITH BARB UP -->
<!ENTITY rx               "&#x0211E;" ><!--PRESCRIPTION TAKE -->
<!ENTITY sacute           "&#x0015B;" ><!--LATIN SMALL LETTER S WITH ACUTE -->
<!ENTITY sbquo            "&#x0201A;" ><!--SINGLE LOW-9 QUOTATION MARK -->
<!ENTITY sc               "&#x0227B;" ><!--SUCCEEDS -->
<!ENTITY scE              "&#x02AB4;" ><!--SUCCEEDS ABOVE EQUALS SIGN -->
<!ENTITY scap             "&#x02AB8;" ><!--SUCCEEDS ABOVE ALMOST EQUAL TO -->
<!ENTITY scaron           "&#x00161;" ><!--LATIN SMALL LETTER S WITH CARON -->
<!ENTITY sccue            "&#x0227D;" ><!--SUCCEEDS OR EQUAL TO -->
<!ENTITY sce              "&#x02AB0;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY scedil           "&#x0015F;" ><!--LATIN SMALL LETTER S WITH CEDILLA -->
<!ENTITY scirc            "&#x0015D;" ><!--LATIN SMALL LETTER S WITH CIRCUMFLEX -->
<!ENTITY scnE             "&#x02AB6;" ><!--SUCCEEDS ABOVE NOT EQUAL TO -->
<!ENTITY scnap            "&#x02ABA;" ><!--SUCCEEDS ABOVE NOT ALMOST EQUAL TO -->
<!ENTITY scnsim           "&#x022E9;" ><!--SUCCEEDS BUT NOT EQUIVALENT TO -->
<!ENTITY scpolint         "&#x02A13;" ><!--LINE INTEGRATION WITH SEMICIRCULAR PATH AROUND POLE -->
<!ENTITY scsim            "&#x0227F;" ><!--SUCCEEDS OR EQUIVALENT TO -->
<!ENTITY scy              "&#x00441;" ><!--CYRILLIC SMALL LETTER ES -->
<!ENTITY sdot             "&#x022C5;" ><!--DOT OPERATOR -->
<!ENTITY sdotb            "&#x022A1;" ><!--SQUARED DOT OPERATOR -->
<!ENTITY sdote            "&#x02A66;" ><!--EQUALS SIGN WITH DOT BELOW -->
<!ENTITY seArr            "&#x021D8;" ><!--SOUTH EAST DOUBLE ARROW -->
<!ENTITY searhk           "&#x02925;" ><!--SOUTH EAST ARROW WITH HOOK -->
<!ENTITY searr            "&#x02198;" ><!--SOUTH EAST ARROW -->
<!ENTITY searrow          "&#x02198;" ><!--SOUTH EAST ARROW -->
<!ENTITY sect             "&#x000A7;" ><!--SECTION SIGN -->
<!ENTITY semi             "&#x0003B;" ><!--SEMICOLON -->
<!ENTITY seswar           "&#x02929;" ><!--SOUTH EAST ARROW AND SOUTH WEST ARROW -->
<!ENTITY setminus         "&#x02216;" ><!--SET MINUS -->
<!ENTITY setmn            "&#x02216;" ><!--SET MINUS -->
<!ENTITY sext             "&#x02736;" ><!--SIX POINTED BLACK STAR -->
<!ENTITY sfgr             "&#x003C2;" ><!--GREEK SMALL LETTER FINAL SIGMA -->
<!ENTITY sfr              "&#x1D530;" ><!--MATHEMATICAL FRAKTUR SMALL S -->
<!ENTITY sfrown           "&#x02322;" ><!--FROWN -->
<!ENTITY sgr              "&#x003C3;" ><!--GREEK SMALL LETTER SIGMA -->
<!ENTITY sharp            "&#x0266F;" ><!--MUSIC SHARP SIGN -->
<!ENTITY shchcy           "&#x00449;" ><!--CYRILLIC SMALL LETTER SHCHA -->
<!ENTITY shcy             "&#x00448;" ><!--CYRILLIC SMALL LETTER SHA -->
<!ENTITY shortmid         "&#x02223;" ><!--DIVIDES -->
<!ENTITY shortparallel    "&#x02225;" ><!--PARALLEL TO -->
<!ENTITY shy              "&#x000AD;" ><!--SOFT HYPHEN -->
<!ENTITY sigma            "&#x003C3;" ><!--GREEK SMALL LETTER SIGMA -->
<!ENTITY sigmaf           "&#x003C2;" ><!--GREEK SMALL LETTER FINAL SIGMA -->
<!ENTITY sigmav           "&#x003C2;" ><!--GREEK SMALL LETTER FINAL SIGMA -->
<!ENTITY sim              "&#x0223C;" ><!--TILDE OPERATOR -->
<!ENTITY simdot           "&#x02A6A;" ><!--TILDE OPERATOR WITH DOT ABOVE -->
<!ENTITY sime             "&#x02243;" ><!--ASYMPTOTICALLY EQUAL TO -->
<!ENTITY simeq            "&#x02243;" ><!--ASYMPTOTICALLY EQUAL TO -->
<!ENTITY simg             "&#x02A9E;" ><!--SIMILAR OR GREATER-THAN -->
<!ENTITY simgE            "&#x02AA0;" ><!--SIMILAR ABOVE GREATER-THAN ABOVE EQUALS SIGN -->
<!ENTITY siml             "&#x02A9D;" ><!--SIMILAR OR LESS-THAN -->
<!ENTITY simlE            "&#x02A9F;" ><!--SIMILAR ABOVE LESS-THAN ABOVE EQUALS SIGN -->
<!ENTITY simne            "&#x02246;" ><!--APPROXIMATELY BUT NOT ACTUALLY EQUAL TO -->
<!ENTITY simplus          "&#x02A24;" ><!--PLUS SIGN WITH TILDE ABOVE -->
<!ENTITY simrarr          "&#x02972;" ><!--TILDE OPERATOR ABOVE RIGHTWARDS ARROW -->
<!ENTITY slarr            "&#x02190;" ><!--LEFTWARDS ARROW -->
<!ENTITY smallsetminus    "&#x02216;" ><!--SET MINUS -->
<!ENTITY smashp           "&#x02A33;" ><!--SMASH PRODUCT -->
<!ENTITY smeparsl         "&#x029E4;" ><!--EQUALS SIGN AND SLANTED PARALLEL WITH TILDE ABOVE -->
<!ENTITY smid             "&#x02223;" ><!--DIVIDES -->
<!ENTITY smile            "&#x02323;" ><!--SMILE -->
<!ENTITY smt              "&#x02AAA;" ><!--SMALLER THAN -->
<!ENTITY smte             "&#x02AAC;" ><!--SMALLER THAN OR EQUAL TO -->
<!ENTITY smtes            "&#x02AAC;&#x0FE00;" ><!--SMALLER THAN OR slanted EQUAL -->
<!ENTITY softcy           "&#x0044C;" ><!--CYRILLIC SMALL LETTER SOFT SIGN -->
<!ENTITY sol              "&#x0002F;" ><!--SOLIDUS -->
<!ENTITY solb             "&#x029C4;" ><!--SQUARED RISING DIAGONAL SLASH -->
<!ENTITY solbar           "&#x0233F;" ><!--APL FUNCTIONAL SYMBOL SLASH BAR -->
<!ENTITY sopf             "&#x1D564;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL S -->
<!ENTITY spades           "&#x02660;" ><!--BLACK SPADE SUIT -->
<!ENTITY spadesuit        "&#x02660;" ><!--BLACK SPADE SUIT -->
<!ENTITY spar             "&#x02225;" ><!--PARALLEL TO -->
<!ENTITY sqcap            "&#x02293;" ><!--SQUARE CAP -->
<!ENTITY sqcaps           "&#x02293;&#x0FE00;" ><!--SQUARE CAP with serifs -->
<!ENTITY sqcup            "&#x02294;" ><!--SQUARE CUP -->
<!ENTITY sqcups           "&#x02294;&#x0FE00;" ><!--SQUARE CUP with serifs -->
<!ENTITY sqsub            "&#x0228F;" ><!--SQUARE IMAGE OF -->
<!ENTITY sqsube           "&#x02291;" ><!--SQUARE IMAGE OF OR EQUAL TO -->
<!ENTITY sqsubset         "&#x0228F;" ><!--SQUARE IMAGE OF -->
<!ENTITY sqsubseteq       "&#x02291;" ><!--SQUARE IMAGE OF OR EQUAL TO -->
<!ENTITY sqsup            "&#x02290;" ><!--SQUARE ORIGINAL OF -->
<!ENTITY sqsupe           "&#x02292;" ><!--SQUARE ORIGINAL OF OR EQUAL TO -->
<!ENTITY sqsupset         "&#x02290;" ><!--SQUARE ORIGINAL OF -->
<!ENTITY sqsupseteq       "&#x02292;" ><!--SQUARE ORIGINAL OF OR EQUAL TO -->
<!ENTITY squ              "&#x025A1;" ><!--WHITE SQUARE -->
<!ENTITY square           "&#x025A1;" ><!--WHITE SQUARE -->
<!ENTITY squarf           "&#x025AA;" ><!--BLACK SMALL SQUARE -->
<!ENTITY squf             "&#x025AA;" ><!--BLACK SMALL SQUARE -->
<!ENTITY srarr            "&#x02192;" ><!--RIGHTWARDS ARROW -->
<!ENTITY sscr             "&#x1D4C8;" ><!--MATHEMATICAL SCRIPT SMALL S -->
<!ENTITY ssetmn           "&#x02216;" ><!--SET MINUS -->
<!ENTITY ssmile           "&#x02323;" ><!--SMILE -->
<!ENTITY sstarf           "&#x022C6;" ><!--STAR OPERATOR -->
<!ENTITY star             "&#x02606;" ><!--WHITE STAR -->
<!ENTITY starf            "&#x02605;" ><!--BLACK STAR -->
<!ENTITY straightepsilon  "&#x003F5;" ><!--GREEK LUNATE EPSILON SYMBOL -->
<!ENTITY straightphi      "&#x003D5;" ><!--GREEK PHI SYMBOL -->
<!ENTITY strns            "&#x000AF;" ><!--MACRON -->
<!ENTITY sub              "&#x02282;" ><!--SUBSET OF -->
<!ENTITY subE             "&#x02AC5;" ><!--SUBSET OF ABOVE EQUALS SIGN -->
<!ENTITY subdot           "&#x02ABD;" ><!--SUBSET WITH DOT -->
<!ENTITY sube             "&#x02286;" ><!--SUBSET OF OR EQUAL TO -->
<!ENTITY subedot          "&#x02AC3;" ><!--SUBSET OF OR EQUAL TO WITH DOT ABOVE -->
<!ENTITY submult          "&#x02AC1;" ><!--SUBSET WITH MULTIPLICATION SIGN BELOW -->
<!ENTITY subnE            "&#x02ACB;" ><!--SUBSET OF ABOVE NOT EQUAL TO -->
<!ENTITY subne            "&#x0228A;" ><!--SUBSET OF WITH NOT EQUAL TO -->
<!ENTITY subplus          "&#x02ABF;" ><!--SUBSET WITH PLUS SIGN BELOW -->
<!ENTITY subrarr          "&#x02979;" ><!--SUBSET ABOVE RIGHTWARDS ARROW -->
<!ENTITY subset           "&#x02282;" ><!--SUBSET OF -->
<!ENTITY subseteq         "&#x02286;" ><!--SUBSET OF OR EQUAL TO -->
<!ENTITY subseteqq        "&#x02AC5;" ><!--SUBSET OF ABOVE EQUALS SIGN -->
<!ENTITY subsetneq        "&#x0228A;" ><!--SUBSET OF WITH NOT EQUAL TO -->
<!ENTITY subsetneqq       "&#x02ACB;" ><!--SUBSET OF ABOVE NOT EQUAL TO -->
<!ENTITY subsim           "&#x02AC7;" ><!--SUBSET OF ABOVE TILDE OPERATOR -->
<!ENTITY subsub           "&#x02AD5;" ><!--SUBSET ABOVE SUBSET -->
<!ENTITY subsup           "&#x02AD3;" ><!--SUBSET ABOVE SUPERSET -->
<!ENTITY succ             "&#x0227B;" ><!--SUCCEEDS -->
<!ENTITY succapprox       "&#x02AB8;" ><!--SUCCEEDS ABOVE ALMOST EQUAL TO -->
<!ENTITY succcurlyeq      "&#x0227D;" ><!--SUCCEEDS OR EQUAL TO -->
<!ENTITY succeq           "&#x02AB0;" ><!--SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN -->
<!ENTITY succnapprox      "&#x02ABA;" ><!--SUCCEEDS ABOVE NOT ALMOST EQUAL TO -->
<!ENTITY succneqq         "&#x02AB6;" ><!--SUCCEEDS ABOVE NOT EQUAL TO -->
<!ENTITY succnsim         "&#x022E9;" ><!--SUCCEEDS BUT NOT EQUIVALENT TO -->
<!ENTITY succsim          "&#x0227F;" ><!--SUCCEEDS OR EQUIVALENT TO -->
<!ENTITY sum              "&#x02211;" ><!--N-ARY SUMMATION -->
<!ENTITY sung             "&#x0266A;" ><!--EIGHTH NOTE -->
<!ENTITY sup              "&#x02283;" ><!--SUPERSET OF -->
<!ENTITY sup1             "&#x000B9;" ><!--SUPERSCRIPT ONE -->
<!ENTITY sup2             "&#x000B2;" ><!--SUPERSCRIPT TWO -->
<!ENTITY sup3             "&#x000B3;" ><!--SUPERSCRIPT THREE -->
<!ENTITY supE             "&#x02AC6;" ><!--SUPERSET OF ABOVE EQUALS SIGN -->
<!ENTITY supdot           "&#x02ABE;" ><!--SUPERSET WITH DOT -->
<!ENTITY supdsub          "&#x02AD8;" ><!--SUPERSET BESIDE AND JOINED BY DASH WITH SUBSET -->
<!ENTITY supe             "&#x02287;" ><!--SUPERSET OF OR EQUAL TO -->
<!ENTITY supedot          "&#x02AC4;" ><!--SUPERSET OF OR EQUAL TO WITH DOT ABOVE -->
<!ENTITY suphsol          "&#x027C9;" ><!--SUPERSET PRECEDING SOLIDUS -->
<!ENTITY suphsub          "&#x02AD7;" ><!--SUPERSET BESIDE SUBSET -->
<!ENTITY suplarr          "&#x0297B;" ><!--SUPERSET ABOVE LEFTWARDS ARROW -->
<!ENTITY supmult          "&#x02AC2;" ><!--SUPERSET WITH MULTIPLICATION SIGN BELOW -->
<!ENTITY supnE            "&#x02ACC;" ><!--SUPERSET OF ABOVE NOT EQUAL TO -->
<!ENTITY supne            "&#x0228B;" ><!--SUPERSET OF WITH NOT EQUAL TO -->
<!ENTITY supplus          "&#x02AC0;" ><!--SUPERSET WITH PLUS SIGN BELOW -->
<!ENTITY supset           "&#x02283;" ><!--SUPERSET OF -->
<!ENTITY supseteq         "&#x02287;" ><!--SUPERSET OF OR EQUAL TO -->
<!ENTITY supseteqq        "&#x02AC6;" ><!--SUPERSET OF ABOVE EQUALS SIGN -->
<!ENTITY supsetneq        "&#x0228B;" ><!--SUPERSET OF WITH NOT EQUAL TO -->
<!ENTITY supsetneqq       "&#x02ACC;" ><!--SUPERSET OF ABOVE NOT EQUAL TO -->
<!ENTITY supsim           "&#x02AC8;" ><!--SUPERSET OF ABOVE TILDE OPERATOR -->
<!ENTITY supsub           "&#x02AD4;" ><!--SUPERSET ABOVE SUBSET -->
<!ENTITY supsup           "&#x02AD6;" ><!--SUPERSET ABOVE SUPERSET -->
<!ENTITY swArr            "&#x021D9;" ><!--SOUTH WEST DOUBLE ARROW -->
<!ENTITY swarhk           "&#x02926;" ><!--SOUTH WEST ARROW WITH HOOK -->
<!ENTITY swarr            "&#x02199;" ><!--SOUTH WEST ARROW -->
<!ENTITY swarrow          "&#x02199;" ><!--SOUTH WEST ARROW -->
<!ENTITY swnwar           "&#x0292A;" ><!--SOUTH WEST ARROW AND NORTH WEST ARROW -->
<!ENTITY szlig            "&#x000DF;" ><!--LATIN SMALL LETTER SHARP S -->
<!ENTITY target           "&#x02316;" ><!--POSITION INDICATOR -->
<!ENTITY tau              "&#x003C4;" ><!--GREEK SMALL LETTER TAU -->
<!ENTITY tbrk             "&#x023B4;" ><!--TOP SQUARE BRACKET -->
<!ENTITY tcaron           "&#x00165;" ><!--LATIN SMALL LETTER T WITH CARON -->
<!ENTITY tcedil           "&#x00163;" ><!--LATIN SMALL LETTER T WITH CEDILLA -->
<!ENTITY tcy              "&#x00442;" ><!--CYRILLIC SMALL LETTER TE -->
<!ENTITY tdot             " &#x020DB;" ><!--COMBINING THREE DOTS ABOVE -->
<!ENTITY telrec           "&#x02315;" ><!--TELEPHONE RECORDER -->
<!ENTITY tfr              "&#x1D531;" ><!--MATHEMATICAL FRAKTUR SMALL T -->
<!ENTITY tgr              "&#x003C4;" ><!--GREEK SMALL LETTER TAU -->
<!ENTITY there4           "&#x02234;" ><!--THEREFORE -->
<!ENTITY therefore        "&#x02234;" ><!--THEREFORE -->
<!ENTITY theta            "&#x003B8;" ><!--GREEK SMALL LETTER THETA -->
<!ENTITY thetasym         "&#x003D1;" ><!--GREEK THETA SYMBOL -->
<!ENTITY thetav           "&#x003D1;" ><!--GREEK THETA SYMBOL -->
<!ENTITY thgr             "&#x003B8;" ><!--GREEK SMALL LETTER THETA -->
<!ENTITY thickapprox      "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY thicksim         "&#x0223C;" ><!--TILDE OPERATOR -->
<!ENTITY thinsp           "&#x02009;" ><!--THIN SPACE -->
<!ENTITY thkap            "&#x02248;" ><!--ALMOST EQUAL TO -->
<!ENTITY thksim           "&#x0223C;" ><!--TILDE OPERATOR -->
<!ENTITY thorn            "&#x000FE;" ><!--LATIN SMALL LETTER THORN -->
<!ENTITY tilde            "&#x002DC;" ><!--SMALL TILDE -->
<!ENTITY times            "&#x000D7;" ><!--MULTIPLICATION SIGN -->
<!ENTITY timesb           "&#x022A0;" ><!--SQUARED TIMES -->
<!ENTITY timesbar         "&#x02A31;" ><!--MULTIPLICATION SIGN WITH UNDERBAR -->
<!ENTITY timesd           "&#x02A30;" ><!--MULTIPLICATION SIGN WITH DOT ABOVE -->
<!ENTITY tint             "&#x0222D;" ><!--TRIPLE INTEGRAL -->
<!ENTITY toea             "&#x02928;" ><!--NORTH EAST ARROW AND SOUTH EAST ARROW -->
<!ENTITY top              "&#x022A4;" ><!--DOWN TACK -->
<!ENTITY topbot           "&#x02336;" ><!--APL FUNCTIONAL SYMBOL I-BEAM -->
<!ENTITY topcir           "&#x02AF1;" ><!--DOWN TACK WITH CIRCLE BELOW -->
<!ENTITY topf             "&#x1D565;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL T -->
<!ENTITY topfork          "&#x02ADA;" ><!--PITCHFORK WITH TEE TOP -->
<!ENTITY tosa             "&#x02929;" ><!--SOUTH EAST ARROW AND SOUTH WEST ARROW -->
<!ENTITY tprime           "&#x02034;" ><!--TRIPLE PRIME -->
<!ENTITY trade            "&#x02122;" ><!--TRADE MARK SIGN -->
<!ENTITY triangle         "&#x025B5;" ><!--WHITE UP-POINTING SMALL TRIANGLE -->
<!ENTITY triangledown     "&#x025BF;" ><!--WHITE DOWN-POINTING SMALL TRIANGLE -->
<!ENTITY triangleleft     "&#x025C3;" ><!--WHITE LEFT-POINTING SMALL TRIANGLE -->
<!ENTITY trianglelefteq   "&#x022B4;" ><!--NORMAL SUBGROUP OF OR EQUAL TO -->
<!ENTITY triangleq        "&#x0225C;" ><!--DELTA EQUAL TO -->
<!ENTITY triangleright    "&#x025B9;" ><!--WHITE RIGHT-POINTING SMALL TRIANGLE -->
<!ENTITY trianglerighteq  "&#x022B5;" ><!--CONTAINS AS NORMAL SUBGROUP OR EQUAL TO -->
<!ENTITY tridot           "&#x025EC;" ><!--WHITE UP-POINTING TRIANGLE WITH DOT -->
<!ENTITY trie             "&#x0225C;" ><!--DELTA EQUAL TO -->
<!ENTITY triminus         "&#x02A3A;" ><!--MINUS SIGN IN TRIANGLE -->
<!ENTITY triplus          "&#x02A39;" ><!--PLUS SIGN IN TRIANGLE -->
<!ENTITY trisb            "&#x029CD;" ><!--TRIANGLE WITH SERIFS AT BOTTOM -->
<!ENTITY tritime          "&#x02A3B;" ><!--MULTIPLICATION SIGN IN TRIANGLE -->
<!ENTITY trpezium         "&#x023E2;" ><!--WHITE TRAPEZIUM -->
<!ENTITY tscr             "&#x1D4C9;" ><!--MATHEMATICAL SCRIPT SMALL T -->
<!ENTITY tscy             "&#x00446;" ><!--CYRILLIC SMALL LETTER TSE -->
<!ENTITY tshcy            "&#x0045B;" ><!--CYRILLIC SMALL LETTER TSHE -->
<!ENTITY tstrok           "&#x00167;" ><!--LATIN SMALL LETTER T WITH STROKE -->
<!ENTITY twixt            "&#x0226C;" ><!--BETWEEN -->
<!ENTITY twoheadleftarrow "&#x0219E;" ><!--LEFTWARDS TWO HEADED ARROW -->
<!ENTITY twoheadrightarrow "&#x021A0;" ><!--RIGHTWARDS TWO HEADED ARROW -->
<!ENTITY uArr             "&#x021D1;" ><!--UPWARDS DOUBLE ARROW -->
<!ENTITY uHar             "&#x02963;" ><!--UPWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY uacgr            "&#x003CD;" ><!--GREEK SMALL LETTER UPSILON WITH TONOS -->
<!ENTITY uacute           "&#x000FA;" ><!--LATIN SMALL LETTER U WITH ACUTE -->
<!ENTITY uarr             "&#x02191;" ><!--UPWARDS ARROW -->
<!ENTITY ubrcy            "&#x0045E;" ><!--CYRILLIC SMALL LETTER SHORT U -->
<!ENTITY ubreve           "&#x0016D;" ><!--LATIN SMALL LETTER U WITH BREVE -->
<!ENTITY ucirc            "&#x000FB;" ><!--LATIN SMALL LETTER U WITH CIRCUMFLEX -->
<!ENTITY ucy              "&#x00443;" ><!--CYRILLIC SMALL LETTER U -->
<!ENTITY udarr            "&#x021C5;" ><!--UPWARDS ARROW LEFTWARDS OF DOWNWARDS ARROW -->
<!ENTITY udblac           "&#x00171;" ><!--LATIN SMALL LETTER U WITH DOUBLE ACUTE -->
<!ENTITY udhar            "&#x0296E;" ><!--UPWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT -->
<!ENTITY udiagr           "&#x003B0;" ><!--GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS -->
<!ENTITY udigr            "&#x003CB;" ><!--GREEK SMALL LETTER UPSILON WITH DIALYTIKA -->
<!ENTITY ufisht           "&#x0297E;" ><!--UP FISH TAIL -->
<!ENTITY ufr              "&#x1D532;" ><!--MATHEMATICAL FRAKTUR SMALL U -->
<!ENTITY ugr              "&#x003C5;" ><!--GREEK SMALL LETTER UPSILON -->
<!ENTITY ugrave           "&#x000F9;" ><!--LATIN SMALL LETTER U WITH GRAVE -->
<!ENTITY uharl            "&#x021BF;" ><!--UPWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY uharr            "&#x021BE;" ><!--UPWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY uhblk            "&#x02580;" ><!--UPPER HALF BLOCK -->
<!ENTITY ulcorn           "&#x0231C;" ><!--TOP LEFT CORNER -->
<!ENTITY ulcorner         "&#x0231C;" ><!--TOP LEFT CORNER -->
<!ENTITY ulcrop           "&#x0230F;" ><!--TOP LEFT CROP -->
<!ENTITY ultri            "&#x025F8;" ><!--UPPER LEFT TRIANGLE -->
<!ENTITY umacr            "&#x0016B;" ><!--LATIN SMALL LETTER U WITH MACRON -->
<!ENTITY uml              "&#x000A8;" ><!--DIAERESIS -->
<!ENTITY uogon            "&#x00173;" ><!--LATIN SMALL LETTER U WITH OGONEK -->
<!ENTITY uopf             "&#x1D566;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL U -->
<!ENTITY uparrow          "&#x02191;" ><!--UPWARDS ARROW -->
<!ENTITY updownarrow      "&#x02195;" ><!--UP DOWN ARROW -->
<!ENTITY upharpoonleft    "&#x021BF;" ><!--UPWARDS HARPOON WITH BARB LEFTWARDS -->
<!ENTITY upharpoonright   "&#x021BE;" ><!--UPWARDS HARPOON WITH BARB RIGHTWARDS -->
<!ENTITY uplus            "&#x0228E;" ><!--MULTISET UNION -->
<!ENTITY upsi             "&#x003C5;" ><!--GREEK SMALL LETTER UPSILON -->
<!ENTITY upsih            "&#x003D2;" ><!--GREEK UPSILON WITH HOOK SYMBOL -->
<!ENTITY upsilon          "&#x003C5;" ><!--GREEK SMALL LETTER UPSILON -->
<!ENTITY upuparrows       "&#x021C8;" ><!--UPWARDS PAIRED ARROWS -->
<!ENTITY urcorn           "&#x0231D;" ><!--TOP RIGHT CORNER -->
<!ENTITY urcorner         "&#x0231D;" ><!--TOP RIGHT CORNER -->
<!ENTITY urcrop           "&#x0230E;" ><!--TOP RIGHT CROP -->
<!ENTITY uring            "&#x0016F;" ><!--LATIN SMALL LETTER U WITH RING ABOVE -->
<!ENTITY urtri            "&#x025F9;" ><!--UPPER RIGHT TRIANGLE -->
<!ENTITY uscr             "&#x1D4CA;" ><!--MATHEMATICAL SCRIPT SMALL U -->
<!ENTITY utdot            "&#x022F0;" ><!--UP RIGHT DIAGONAL ELLIPSIS -->
<!ENTITY utilde           "&#x00169;" ><!--LATIN SMALL LETTER U WITH TILDE -->
<!ENTITY utri             "&#x025B5;" ><!--WHITE UP-POINTING SMALL TRIANGLE -->
<!ENTITY utrif            "&#x025B4;" ><!--BLACK UP-POINTING SMALL TRIANGLE -->
<!ENTITY uuarr            "&#x021C8;" ><!--UPWARDS PAIRED ARROWS -->
<!ENTITY uuml             "&#x000FC;" ><!--LATIN SMALL LETTER U WITH DIAERESIS -->
<!ENTITY uwangle          "&#x029A7;" ><!--OBLIQUE ANGLE OPENING DOWN -->
<!ENTITY vArr             "&#x021D5;" ><!--UP DOWN DOUBLE ARROW -->
<!ENTITY vBar             "&#x02AE8;" ><!--SHORT UP TACK WITH UNDERBAR -->
<!ENTITY vBarv            "&#x02AE9;" ><!--SHORT UP TACK ABOVE SHORT DOWN TACK -->
<!ENTITY vDash            "&#x022A8;" ><!--TRUE -->
<!ENTITY vangrt           "&#x0299C;" ><!--RIGHT ANGLE VARIANT WITH SQUARE -->
<!ENTITY varepsilon       "&#x003F5;" ><!--GREEK LUNATE EPSILON SYMBOL -->
<!ENTITY varkappa         "&#x003F0;" ><!--GREEK KAPPA SYMBOL -->
<!ENTITY varnothing       "&#x02205;" ><!--EMPTY SET -->
<!ENTITY varphi           "&#x003D5;" ><!--GREEK PHI SYMBOL -->
<!ENTITY varpi            "&#x003D6;" ><!--GREEK PI SYMBOL -->
<!ENTITY varpropto        "&#x0221D;" ><!--PROPORTIONAL TO -->
<!ENTITY varr             "&#x02195;" ><!--UP DOWN ARROW -->
<!ENTITY varrho           "&#x003F1;" ><!--GREEK RHO SYMBOL -->
<!ENTITY varsigma         "&#x003C2;" ><!--GREEK SMALL LETTER FINAL SIGMA -->
<!ENTITY varsubsetneq     "&#x0228A;&#x0FE00;" ><!--SUBSET OF WITH NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY varsubsetneqq    "&#x02ACB;&#x0FE00;" ><!--SUBSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY varsupsetneq     "&#x0228B;&#x0FE00;" ><!--SUPERSET OF WITH NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY varsupsetneqq    "&#x02ACC;&#x0FE00;" ><!--SUPERSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY vartheta         "&#x003D1;" ><!--GREEK THETA SYMBOL -->
<!ENTITY vartriangleleft  "&#x022B2;" ><!--NORMAL SUBGROUP OF -->
<!ENTITY vartriangleright "&#x022B3;" ><!--CONTAINS AS NORMAL SUBGROUP -->
<!ENTITY vcy              "&#x00432;" ><!--CYRILLIC SMALL LETTER VE -->
<!ENTITY vdash            "&#x022A2;" ><!--RIGHT TACK -->
<!ENTITY vee              "&#x02228;" ><!--LOGICAL OR -->
<!ENTITY veebar           "&#x022BB;" ><!--XOR -->
<!ENTITY veeeq            "&#x0225A;" ><!--EQUIANGULAR TO -->
<!ENTITY vellip           "&#x022EE;" ><!--VERTICAL ELLIPSIS -->
<!ENTITY verbar           "&#x0007C;" ><!--VERTICAL LINE -->
<!ENTITY vert             "&#x0007C;" ><!--VERTICAL LINE -->
<!ENTITY vfr              "&#x1D533;" ><!--MATHEMATICAL FRAKTUR SMALL V -->
<!ENTITY vltri            "&#x022B2;" ><!--NORMAL SUBGROUP OF -->
<!ENTITY vnsub            "&#x02282;&#x020D2;" ><!--SUBSET OF with vertical line -->
<!ENTITY vnsup            "&#x02283;&#x020D2;" ><!--SUPERSET OF with vertical line -->
<!ENTITY vopf             "&#x1D567;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL V -->
<!ENTITY vprop            "&#x0221D;" ><!--PROPORTIONAL TO -->
<!ENTITY vrtri            "&#x022B3;" ><!--CONTAINS AS NORMAL SUBGROUP -->
<!ENTITY vscr             "&#x1D4CB;" ><!--MATHEMATICAL SCRIPT SMALL V -->
<!ENTITY vsubnE           "&#x02ACB;&#x0FE00;" ><!--SUBSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY vsubne           "&#x0228A;&#x0FE00;" ><!--SUBSET OF WITH NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY vsupnE           "&#x02ACC;&#x0FE00;" ><!--SUPERSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY vsupne           "&#x0228B;&#x0FE00;" ><!--SUPERSET OF WITH NOT EQUAL TO - variant with stroke through bottom members -->
<!ENTITY vzigzag          "&#x0299A;" ><!--VERTICAL ZIGZAG LINE -->
<!ENTITY wcirc            "&#x00175;" ><!--LATIN SMALL LETTER W WITH CIRCUMFLEX -->
<!ENTITY wedbar           "&#x02A5F;" ><!--LOGICAL AND WITH UNDERBAR -->
<!ENTITY wedge            "&#x02227;" ><!--LOGICAL AND -->
<!ENTITY wedgeq           "&#x02259;" ><!--ESTIMATES -->
<!ENTITY weierp           "&#x02118;" ><!--SCRIPT CAPITAL P -->
<!ENTITY wfr              "&#x1D534;" ><!--MATHEMATICAL FRAKTUR SMALL W -->
<!ENTITY wopf             "&#x1D568;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL W -->
<!ENTITY wp               "&#x02118;" ><!--SCRIPT CAPITAL P -->
<!ENTITY wr               "&#x02240;" ><!--WREATH PRODUCT -->
<!ENTITY wreath           "&#x02240;" ><!--WREATH PRODUCT -->
<!ENTITY wscr             "&#x1D4CC;" ><!--MATHEMATICAL SCRIPT SMALL W -->
<!ENTITY xcap             "&#x022C2;" ><!--N-ARY INTERSECTION -->
<!ENTITY xcirc            "&#x025EF;" ><!--LARGE CIRCLE -->
<!ENTITY xcup             "&#x022C3;" ><!--N-ARY UNION -->
<!ENTITY xdtri            "&#x025BD;" ><!--WHITE DOWN-POINTING TRIANGLE -->
<!ENTITY xfr              "&#x1D535;" ><!--MATHEMATICAL FRAKTUR SMALL X -->
<!ENTITY xgr              "&#x003BE;" ><!--GREEK SMALL LETTER XI -->
<!ENTITY xhArr            "&#x027FA;" ><!--LONG LEFT RIGHT DOUBLE ARROW -->
<!ENTITY xharr            "&#x027F7;" ><!--LONG LEFT RIGHT ARROW -->
<!ENTITY xi               "&#x003BE;" ><!--GREEK SMALL LETTER XI -->
<!ENTITY xlArr            "&#x027F8;" ><!--LONG LEFTWARDS DOUBLE ARROW -->
<!ENTITY xlarr            "&#x027F5;" ><!--LONG LEFTWARDS ARROW -->
<!ENTITY xmap             "&#x027FC;" ><!--LONG RIGHTWARDS ARROW FROM BAR -->
<!ENTITY xnis             "&#x022FB;" ><!--CONTAINS WITH VERTICAL BAR AT END OF HORIZONTAL STROKE -->
<!ENTITY xodot            "&#x02A00;" ><!--N-ARY CIRCLED DOT OPERATOR -->
<!ENTITY xopf             "&#x1D569;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL X -->
<!ENTITY xoplus           "&#x02A01;" ><!--N-ARY CIRCLED PLUS OPERATOR -->
<!ENTITY xotime           "&#x02A02;" ><!--N-ARY CIRCLED TIMES OPERATOR -->
<!ENTITY xrArr            "&#x027F9;" ><!--LONG RIGHTWARDS DOUBLE ARROW -->
<!ENTITY xrarr            "&#x027F6;" ><!--LONG RIGHTWARDS ARROW -->
<!ENTITY xscr             "&#x1D4CD;" ><!--MATHEMATICAL SCRIPT SMALL X -->
<!ENTITY xsqcup           "&#x02A06;" ><!--N-ARY SQUARE UNION OPERATOR -->
<!ENTITY xuplus           "&#x02A04;" ><!--N-ARY UNION OPERATOR WITH PLUS -->
<!ENTITY xutri            "&#x025B3;" ><!--WHITE UP-POINTING TRIANGLE -->
<!ENTITY xvee             "&#x022C1;" ><!--N-ARY LOGICAL OR -->
<!ENTITY xwedge           "&#x022C0;" ><!--N-ARY LOGICAL AND -->
<!ENTITY yacute           "&#x000FD;" ><!--LATIN SMALL LETTER Y WITH ACUTE -->
<!ENTITY yacy             "&#x0044F;" ><!--CYRILLIC SMALL LETTER YA -->
<!ENTITY ycirc            "&#x00177;" ><!--LATIN SMALL LETTER Y WITH CIRCUMFLEX -->
<!ENTITY ycy              "&#x0044B;" ><!--CYRILLIC SMALL LETTER YERU -->
<!ENTITY yen              "&#x000A5;" ><!--YEN SIGN -->
<!ENTITY yfr              "&#x1D536;" ><!--MATHEMATICAL FRAKTUR SMALL Y -->
<!ENTITY yicy             "&#x00457;" ><!--CYRILLIC SMALL LETTER YI -->
<!ENTITY yopf             "&#x1D56A;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL Y -->
<!ENTITY yscr             "&#x1D4CE;" ><!--MATHEMATICAL SCRIPT SMALL Y -->
<!ENTITY yucy             "&#x0044E;" ><!--CYRILLIC SMALL LETTER YU -->
<!ENTITY yuml             "&#x000FF;" ><!--LATIN SMALL LETTER Y WITH DIAERESIS -->
<!ENTITY zacute           "&#x0017A;" ><!--LATIN SMALL LETTER Z WITH ACUTE -->
<!ENTITY zcaron           "&#x0017E;" ><!--LATIN SMALL LETTER Z WITH CARON -->
<!ENTITY zcy              "&#x00437;" ><!--CYRILLIC SMALL LETTER ZE -->
<!ENTITY zdot             "&#x0017C;" ><!--LATIN SMALL LETTER Z WITH DOT ABOVE -->
<!ENTITY zeetrf           "&#x02128;" ><!--BLACK-LETTER CAPITAL Z -->
<!ENTITY zeta             "&#x003B6;" ><!--GREEK SMALL LETTER ZETA -->
<!ENTITY zfr              "&#x1D537;" ><!--MATHEMATICAL FRAKTUR SMALL Z -->
<!ENTITY zgr              "&#x003B6;" ><!--GREEK SMALL LETTER ZETA -->
<!ENTITY zhcy             "&#x00436;" ><!--CYRILLIC SMALL LETTER ZHE -->
<!ENTITY zigrarr          "&#x021DD;" ><!--RIGHTWARDS SQUIGGLE ARROW -->
<!ENTITY zopf             "&#x1D56B;" ><!--MATHEMATICAL DOUBLE-STRUCK SMALL Z -->
<!ENTITY zscr             "&#x1D4CF;" ><!--MATHEMATICAL SCRIPT SMALL Z -->
<!ENTITY zwj              "&#x0200D;" ><!--ZERO WIDTH JOINER -->
<!ENTITY zwnj             "&#x0200C;" ><!--ZERO WIDTH NON-JOINER -->
]>]]></xsl:variable>

    <!-- this identity template will by default copy elements with all attributes and nodes unchanged unless a more specific template is invoked -->
    <!-- mode="#all" for the <xsl:template> will make this identity template the default template in all modes -->
    <!-- mode="#current" for the <xsl:apply-templates> will make sure children are processed in the same mode this template was called from.
         This is important for the micro-pipeline to function as intended. -->

    <xsl:template match="@*|node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
   <!-- phase-0 -->

    <xsl:template match="course" mode="phase-0">
        <course>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </course>
    </xsl:template>
    

    <!-- phase-1 -->
    
    <xsl:template match="course" mode="phase-1">
        <xsl:variable name="course-doc" select="doc(concat($f_root,'/course/' , @url_name , '.xml'))"/>
        <course>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$course-doc/*/@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
            <xsl:sequence select="$course-doc/*/node()"/>
        </course>
    </xsl:template>
    
    <xsl:template match="chapter" mode="phase-2">
        <xsl:variable name="chapter-doc" select="doc(concat($f_chapter,@url_name,'.xml'))"/>
        <chapter>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$chapter-doc/*/(@*|node())"/>
        </chapter>
    </xsl:template>    

    <!-- phase-2 -->
    
    <xsl:template match="sequential" mode="phase-3">
        <xsl:variable name="sequential-doc" select="doc(concat($f_sequential,@url_name,'.xml'))"/>
        <sequential>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$sequential-doc/*/(@*|node())"/>
        </sequential>
    </xsl:template>

    <!-- phase-3 -->
    
    <xsl:template match="vertical" mode="phase-4">
        <xsl:variable name="vertical-doc" select="doc(concat($f_vertical,@url_name,'.xml'))"/>
        <vertical>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$vertical-doc/*/(@*|node())"/>
        </vertical>
    </xsl:template>
    
    <!-- phase-4 -->
    
    <xsl:template match="html" mode="phase-5">
        <xsl:variable name="html-doc" select="doc(concat($f_html,@url_name,'.xml'))"/>
        <html>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$html-doc/*/(@*|node())"/>
        </html>
    </xsl:template>
    
    <xsl:template match="video" mode="phase-5">
        <xsl:variable name="video-doc" select="doc(concat($f_video,@url_name,'.xml'))"/>
        <video>
            <xsl:apply-templates select="@*"/>
            <xsl:sequence select="$video-doc/*/(@*|node())"/>
        </video>
    </xsl:template>
    
    <!-- phase-5 -->
    
    <xsl:template match="html" mode="phase-6">
        <xsl:variable name="html-doc" select="unparsed-text(concat($f_html,@url_name,'.html'))"/>
        
        <!-- prepend a entities doctype before html element, to define html entities -->
        <xsl:variable name="rooted-html-doc-string" select="concat($w3c_entities_local,'&lt;html>',$html-doc,'&lt;/html>')"/>
        <xsl:variable name="rooted-html-doc-string-self-closed-images">
            <xsl:analyze-string select="$rooted-html-doc-string" regex="(&lt;img[^>]+[^/])>">
                <xsl:matching-substring><xsl:value-of select="concat(regex-group(1),'/>')"/></xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!--  remove    <o:p></o:p>                -->
                    <xsl:analyze-string select="." regex="(&lt;o:p.*?>.*?&lt;/o:p>)">
                        <xsl:matching-substring><xsl:message ><xsl:text>Removed: </xsl:text><xsl:value-of select="replace(.,'&gt;','>')"/><xsl:text></xsl:text></xsl:message></xsl:matching-substring>
                        <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
<!--        <xsl:variable name="rooted-html-doc-string" select="concat($html_doctype_entities_w3c,'&lt;html>',$html-doc,'&lt;/html>')"/>-->
        <xsl:variable name="rooted-html-doc-xml" select="parse-xml($rooted-html-doc-string-self-closed-images)"/>
<!--        <html>-->
<!--            <xsl:apply-templates select="@*"/>-->
            <xsl:sequence select="$rooted-html-doc-xml/*/(@*|node())"/>
        <!--</html>-->
        
    </xsl:template>

    <xsl:template name="main">
        
        <xsl:variable name="phase-0-output">
            <xsl:apply-templates select="$input" mode="phase-0"/>
        </xsl:variable>
        
        <xsl:variable name="phase-1-output">
            <xsl:apply-templates select="$phase-0-output" mode="phase-1"/>
        </xsl:variable>
        
        <xsl:variable name="phase-2-output">
            <xsl:apply-templates select="$phase-1-output" mode="phase-2"/>
        </xsl:variable>
        
        <xsl:variable name="phase-3-output">
            <xsl:apply-templates select="$phase-2-output" mode="phase-3"/>
        </xsl:variable>
        
        <xsl:variable name="phase-4-output">
            <xsl:apply-templates select="$phase-3-output" mode="phase-4"/>
        </xsl:variable>
        
        <xsl:variable name="phase-5-output">
            <xsl:apply-templates select="$phase-4-output" mode="phase-5"/>
        </xsl:variable>
        
        <xsl:variable name="phase-6-output">
            <xsl:apply-templates select="$phase-5-output" mode="phase-6"/>
        </xsl:variable>
        
        <xsl:result-document>
            <xsl:sequence select="$phase-6-output"/>
        </xsl:result-document>

    </xsl:template>
    
</xsl:stylesheet>
