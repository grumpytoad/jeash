/**
 * Copyright (c) 2010, Jeash contributors.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

package jeash;

class KeyCode
{
    public static var KEY_0			= 48;
    public static var KEY_1			= 49;
    public static var KEY_2			= 50;
    public static var KEY_3			= 51;
    public static var KEY_4			= 52;
    public static var KEY_5			= 53;
    public static var KEY_6			= 54;
    public static var KEY_7			= 55;
    public static var KEY_8			= 56;
    public static var KEY_9			= 57; 
    public static var A			    = 65;
    public static var B			    = 66;
    public static var C			    = 67;
    public static var D			    = 68;
    public static var E			    = 69;
    public static var F			    = 70;
    public static var G			    = 71;
    public static var H			    = 72;
    public static var I			    = 73;
    public static var J			    = 74;
    public static var K			    = 75;
    public static var L			    = 76;
    public static var M			    = 77;
    public static var N			    = 78;
    public static var O			    = 79;
    public static var P			    = 80;
    public static var Q			    = 81;
    public static var R			    = 82;
    public static var S			    = 83;
    public static var T			    = 84;
    public static var U			    = 85;
    public static var V			    = 86;
    public static var W			    = 87;
    public static var X			    = 88;
    public static var Y			    = 89;
    public static var Z			    = 90;
    
    /* Numeric keypad */
    public static var KP0		    = 96;
    public static var KP1		    = 97;
    public static var KP2		    = 98;
    public static var KP3		    = 99;
    public static var KP4		    = 100;
    public static var KP5		    = 101;
    public static var KP6		    = 102;
    public static var KP7		    = 103;
    public static var KP8		    = 104;
    public static var KP9		    = 105;
    public static var KP_MULTIPLY   = 106;
    public static var KP_ADD        = 107;
    public static var KP_ENTER      = 108;
    public static var KP_SUBTRACT   = 109;
    public static var KP_PERIOD     = 110;
    public static var KP_DIVIDE     = 111;
    
    /* Function keys */
    public static var F1			= 112;
    public static var F2			= 113;
    public static var F3			= 114;
    public static var F4			= 115;
    public static var F5			= 116;
    public static var F6			= 117;
    public static var F7			= 118;
    public static var F8			= 119;
    public static var F9			= 120;
    //  F10 is used by flash.
    public static var F11		    = 122;
    public static var F12		    = 123;
    public static var F13		    = 124;
    public static var F14		    = 125;
    public static var F15		    = 126;
    
    public static var BACKSPACE		= 8;
    public static var TAB		    = 9;
    public static var ENTER		    = 13;
    public static var SHIFT		    = 16;
    public static var CONTROL		= 17;
    public static var CAPSLOCK		= 20; //diff
    public static var ESCAPE		= 27;
    public static var SPACE		    = 32;
    public static var PAGEUP		= 33;
    public static var PAGEDOWN		= 34;
    public static var END		    = 35;
    public static var HOME		    = 36;
    public static var LEFT		    = 37;
    public static var RIGHT		    = 39;//diff
    public static var UP		    = 38;//diff
    public static var DOWN		    = 40;
    public static var INSERT		= 45;
    public static var DELETE		= 46;
    public static var NUMLOCK		= 144;
    public static var BREAK		    = 19;
    
    
	
	/* The keyboard syms have been cleverly chosen to map to ASCII */
/*   public static var UNKNOWN		= 0;
   public static var FIRST		= 0;
   public static var BACKSPACE		= 8;
   public static var TAB		= 9;
   public static var CLEAR		= 12;
   public static var RETURN		= 13;
   public static var PAUSE		= 19;
   public static var ESCAPE		= 27;
   public static var SPACE		= 32;
   public static var EXCLAIM		= 33;
   public static var QUOTEDBL		= 34;
   public static var HASH		= 35;
   public static var DOLLAR		= 36;
   public static var AMPERSAND		= 38;
   public static var QUOTE		= 39;
   public static var LEFTPAREN		= 40;
   public static var RIGHTPAREN		= 41;
   public static var ASTERISK		= 42;
   public static var PLUS		= 43;
   public static var COMMA		= 44;
   public static var MINUS		= 45;
   public static var PERIOD		= 46;
   public static var SLASH		= 47;
   public static var KEY_0			= 48;
   public static var KEY_1			= 49;
   public static var KEY_2			= 50;
   public static var KEY_3			= 51;
   public static var KEY_4			= 52;
   public static var KEY_5			= 53;
   public static var KEY_6			= 54;
   public static var KEY_7			= 55;
   public static var KEY_8			= 56;
   public static var KEY_9			= 57;
   public static var COLON		= 58;
   public static var SEMICOLON		= 59;
   public static var LESS		= 60;
   public static var EQUALS		= 61;
   public static var GREATER		= 62;
   public static var QUESTION		= 63;
   public static var AT			= 64;*/
	/* 
	   Skip uppercase letters
	 */
/*   public static var LEFTBRACKET	= 91;
   public static var BACKSLASH		= 92;
   public static var RIGHTBRACKET	= 93;
   public static var CARET		= 94;
   public static var UNDERSCORE		= 95;
   public static var BACKQUOTE		= 96;
   public static var a			= 97;
   public static var b			= 98;
   public static var c			= 99;
   public static var d			= 100;
   public static var e			= 101;
   public static var f			= 102;
   public static var g			= 103;
   public static var h			= 104;
   public static var i			= 105;
   public static var j			= 106;
   public static var k			= 107;
   public static var l			= 108;
   public static var m			= 109;
   public static var n			= 110;
   public static var o			= 111;
   public static var p			= 112;
   public static var q			= 113;
   public static var r			= 114;
   public static var s			= 115;
   public static var t			= 116;
   public static var u			= 117;
   public static var v			= 118;
   public static var w			= 119;
   public static var x			= 120;
   public static var y			= 121;
   public static var z			= 122;
   public static var DELETE		= 127;*/
	/* End of ASCII mapped keysyms */

	/* International keyboard syms */
//   public static var WORLD_0		= 160;		/* 0xA0 */
/*   public static var WORLD_1		= 161;
   public static var WORLD_2		= 162;
   public static var WORLD_3		= 163;
   public static var WORLD_4		= 164;
   public static var WORLD_5		= 165;
   public static var WORLD_6		= 166;
   public static var WORLD_7		= 167;
   public static var WORLD_8		= 168;
   public static var WORLD_9		= 169;
   public static var WORLD_10		= 170;
   public static var WORLD_11		= 171;
   public static var WORLD_12		= 172;
   public static var WORLD_13		= 173;
   public static var WORLD_14		= 174;
   public static var WORLD_15		= 175;
   public static var WORLD_16		= 176;
   public static var WORLD_17		= 177;
   public static var WORLD_18		= 178;
   public static var WORLD_19		= 179;
   public static var WORLD_20		= 180;
   public static var WORLD_21		= 181;
   public static var WORLD_22		= 182;
   public static var WORLD_23		= 183;
   public static var WORLD_24		= 184;
   public static var WORLD_25		= 185;
   public static var WORLD_26		= 186;
   public static var WORLD_27		= 187;
   public static var WORLD_28		= 188;
   public static var WORLD_29		= 189;
   public static var WORLD_30		= 190;
   public static var WORLD_31		= 191;
   public static var WORLD_32		= 192;
   public static var WORLD_33		= 193;
   public static var WORLD_34		= 194;
   public static var WORLD_35		= 195;
   public static var WORLD_36		= 196;
   public static var WORLD_37		= 197;
   public static var WORLD_38		= 198;
   public static var WORLD_39		= 199;
   public static var WORLD_40		= 200;
   public static var WORLD_41		= 201;
   public static var WORLD_42		= 202;
   public static var WORLD_43		= 203;
   public static var WORLD_44		= 204;
   public static var WORLD_45		= 205;
   public static var WORLD_46		= 206;
   public static var WORLD_47		= 207;
   public static var WORLD_48		= 208;
   public static var WORLD_49		= 209;
   public static var WORLD_50		= 210;
   public static var WORLD_51		= 211;
   public static var WORLD_52		= 212;
   public static var WORLD_53		= 213;
   public static var WORLD_54		= 214;
   public static var WORLD_55		= 215;
   public static var WORLD_56		= 216;
   public static var WORLD_57		= 217;
   public static var WORLD_58		= 218;
   public static var WORLD_59		= 219;
   public static var WORLD_60		= 220;
   public static var WORLD_61		= 221;
   public static var WORLD_62		= 222;
   public static var WORLD_63		= 223;
   public static var WORLD_64		= 224;
   public static var WORLD_65		= 225;
   public static var WORLD_66		= 226;
   public static var WORLD_67		= 227;
   public static var WORLD_68		= 228;
   public static var WORLD_69		= 229;
   public static var WORLD_70		= 230;
   public static var WORLD_71		= 231;
   public static var WORLD_72		= 232;
   public static var WORLD_73		= 233;
   public static var WORLD_74		= 234;
   public static var WORLD_75		= 235;
   public static var WORLD_76		= 236;
   public static var WORLD_77		= 237;
   public static var WORLD_78		= 238;
   public static var WORLD_79		= 239;
   public static var WORLD_80		= 240;
   public static var WORLD_81		= 241;
   public static var WORLD_82		= 242;
   public static var WORLD_83		= 243;
   public static var WORLD_84		= 244;
   public static var WORLD_85		= 245;
   public static var WORLD_86		= 246;
   public static var WORLD_87		= 247;
   public static var WORLD_88		= 248;
   public static var WORLD_89		= 249;
   public static var WORLD_90		= 250;
   public static var WORLD_91		= 251;
   public static var WORLD_92		= 252;
   public static var WORLD_93		= 253;
   public static var WORLD_94		= 254;
   public static var WORLD_95		= 255;*/		/* 0xFF */

	/* Numeric keypad */
/*   public static var KP0		= 256;
   public static var KP1		= 257;
   public static var KP2		= 258;
   public static var KP3		= 259;
   public static var KP4		= 260;
   public static var KP5		= 261;
   public static var KP6		= 262;
   public static var KP7		= 263;
   public static var KP8		= 264;
   public static var KP9		= 265;
   public static var KP_PERIOD		= 266;
   public static var KP_DIVIDE		= 267;
   public static var KP_MULTIPLY	= 268;
   public static var KP_MINUS		= 269;
   public static var KP_PLUS		= 270;
   public static var KP_ENTER		= 271;
   public static var KP_EQUALS		= 272;*/

	/* Arrows + Home/End pad */
/*   public static var UP			= 273;
   public static var DOWN		= 274;
   public static var RIGHT		= 275;
   public static var LEFT		= 276;
   public static var INSERT		= 277;
   public static var HOME		= 278;
   public static var END		= 279;
   public static var PAGEUP		= 280;
   public static var PAGEDOWN		= 281;*/

	/* Function keys */
/*   public static var F1			= 282;
   public static var F2			= 283;
   public static var F3			= 284;
   public static var F4			= 285;
   public static var F5			= 286;
   public static var F6			= 287;
   public static var F7			= 288;
   public static var F8			= 289;
   public static var F9			= 290;
   public static var F10		= 291;
   public static var F11		= 292;
   public static var F12		= 293;
   public static var F13		= 294;
   public static var F14		= 295;
   public static var F15		= 296;*.

	/* Key state modifier keys */
/*   public static var NUMLOCK		= 300;
   public static var CAPSLOCK		= 301;
   public static var SCROLLOCK		= 302;
   public static var RSHIFT		= 303;
   public static var LSHIFT		= 304;
   public static var RCTRL		= 305;
   public static var LCTRL		= 306;
   public static var RALT		= 307;
   public static var LALT		= 308;
   public static var RMETA		= 309;
   public static var LMETA		= 310;*/
//   public static var LSUPER		= 311;		/* Left "Windows" key */
//   public static var RSUPER		= 312;		/* Right "Windows" key */
//   public static var MODE		= 313;		/* "Alt Gr" key */
//   public static var COMPOSE		= 314;		/* Multi-key compose key */

	/* Miscellaneous function keys */
/*   public static var HELP		= 315;
   public static var PRINT		= 316;
   public static var SYSREQ		= 317;
   public static var BREAK		= 318;
   public static var MENU		= 319;*/
//   public static var POWER		= 320;		/* Power Macintosh power key */
//   public static var EURO		= 321;		/* Some european keyboards */
//   public static var UNDO		= 322;		/* Atari keyboard has Undo */

}

