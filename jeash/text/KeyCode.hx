package jeash.text;

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
   public static var KEY_8			= 56; public static var KEY_9			= 57; 
   public static var A			= 65;
   public static var B			= 66;
   public static var C			= 67;
   public static var D			= 68;
   public static var E			= 69;
   public static var F			= 70;
   public static var G			= 71;
   public static var H			= 72;
   public static var I			= 73;
   public static var J			= 74;
   public static var K			= 75;
   public static var L			= 76;
   public static var M			= 77;
   public static var N			= 78;
   public static var O			= 79;
   public static var P			= 80;
   public static var Q			= 81;
   public static var R			= 82;
   public static var S			= 83;
   public static var T			= 84;
   public static var U			= 85;
   public static var V			= 86;
   public static var W			= 87;
   public static var X			= 88;
   public static var Y			= 89;
   public static var Z			= 90;

	/* Numeric keypad */
   public static var KP0		= 96;
   public static var KP1		= 97;
   public static var KP2		= 98;
   public static var KP3		= 99;
   public static var KP4		= 100;
   public static var KP5		= 101;
   public static var KP6		= 102;
   public static var KP7		= 103;
   public static var KP8		= 104;
   public static var KP9		= 105;
   public static var KP_MULTIPLY	= 106;
   public static var KP_ADD		= 107;
   public static var KP_ENTER		= 108;
   public static var KP_SUBTRACT		= 109;
   public static var KP_PERIOD		= 110;
   public static var KP_DIVIDE		= 111;


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
   public static var F11		= 122;
   public static var F12		= 123;
   public static var F13		= 124;
   public static var F14		= 125;
   public static var F15		= 126;


   public static var BACKSPACE		= 8;
   public static var TAB		= 9;
   public static var ENTER		= 13;
   public static var SHIFT		= 16;
   public static var CONTROL		= 17;
   public static var CAPSLOCK		= 18;
   public static var ESCAPE		= 27;
   public static var SPACE		= 32;
   public static var PAGEUP		= 33;
   public static var PAGEDOWN		= 34;
   public static var END		= 35;
   public static var HOME		= 36;
   public static var LEFT		= 37;
   public static var RIGHT		= 38;
   public static var UP		= 39;
   public static var DOWN		= 40;
   public static var INSERT		= 45;
   public static var DELETE		= 46;
   public static var NUMLOCK		= 144;
   public static var BREAK		= 19;



/*
      case nme.KeyCode.COLON : return COLON;
      case nme.KeyCode.SEMICOLON : return SEMICOLON;
      case nme.KeyCode.LESS : return LESS;
      case nme.KeyCode.EQUALS : return EQUALS;
      case nme.KeyCode.GREATER : return GREATER;
      case nme.KeyCode.QUESTION : return QUESTION;
      case nme.KeyCode.AT : return AT;
      case nme.KeyCode.EXCLAIM : return EXCLAIM;
      case nme.KeyCode.QUOTEDBL : return QUOTEDBL;
      case nme.KeyCode.HASH : return HASH;
      case nme.KeyCode.DOLLAR : return DOLLAR;
      case nme.KeyCode.AMPERSAND : return AMPERSAND;
      case nme.KeyCode.QUOTE : return QUOTE;
      case nme.KeyCode.LEFTPAREN : return LEFTPAREN;
      case nme.KeyCode.RIGHTPAREN : return RIGHTPAREN;
      case nme.KeyCode.ASTERISK : return ASTERISK;
      case nme.KeyCode.PLUS : return PLUS;
      case nme.KeyCode.COMMA : return COMMA;
      case nme.KeyCode.MINUS : return MINUS;
      case nme.KeyCode.PERIOD : return PERIOD;
      case nme.KeyCode.SLASH : return SLASH;
      case nme.KeyCode.COLON : return COLON;
      case nme.KeyCode.SEMICOLON : return SEMICOLON;
      case nme.KeyCode.LESS : return LESS;
      case nme.KeyCode.EQUALS : return EQUALS;
      case nme.KeyCode.GREATER : return GREATER;
      case nme.KeyCode.QUESTION : return QUESTION;
      case nme.KeyCode.LEFTBRACKET : return LEFTBRACKET;
      case nme.KeyCode.BACKSLASH : return BACKSLASH;
      case nme.KeyCode.RIGHTBRACKET : return RIGHTBRACKET;
      case nme.KeyCode.CARET : return CARET;
      case nme.KeyCode.UNDERSCORE : return UNDERSCORE;
      case nme.KeyCode.BACKQUOTE : return BACKQUOTE;
      case nme.KeyCode.SCROLLOCK : return SCROLLOCK;
      case nme.KeyCode.RALT : return RALT;
      case nme.KeyCode.LALT : return LALT;
      case nme.KeyCode.RMETA : return RMETA;
      case nme.KeyCode.LMETA : return LMETA;
      case nme.KeyCode.LSUPER : return LSUPER;
      case nme.KeyCode.RSUPER : return RSUPER;
      case nme.KeyCode.MODE : return MODE;
      case nme.KeyCode.COMPOSE : return COMPOSE;
      case nme.KeyCode.HELP : return HELP;
      case nme.KeyCode.PRINT : return PRINT;
      case nme.KeyCode.SYSREQ : return SYSREQ;
      case nme.KeyCode.BREAK : return BREAK;
      case nme.KeyCode.MENU : return MENU;
      case nme.KeyCode.POWER : return POWER;
      case nme.KeyCode.EURO : return EURO;
      case nme.KeyCode.UNDO : return UNDO;
*/

#if !flash
   static public function ConvertCode(inNME:Int) : Int
   {
      if (inNME<=32 || (inNME>=KEY_0 && inNME<=KEY_9))
         return inNME;

      if (inNME>=97 && inNME<=122)
         return inNME - 97 + 65;

#if (neko || cpp)
      if (inNME>=nme.KeyCode.F1 && inNME<=nme.KeyCode.F15)
         return inNME - nme.KeyCode.F1 + KeyCode.F1;

      if (inNME>=nme.KeyCode.KP0 && inNME<=nme.KeyCode.KP9)
         return inNME - nme.KeyCode.KP0 + KeyCode.KP0;
#elseif js
      if (inNME>=flash.KeyCode.F1 && inNME<=flash.KeyCode.F15)
         return inNME - flash.KeyCode.F1 + KeyCode.F1;

      if (inNME>=flash.KeyCode.KP0 && inNME<=flash.KeyCode.KP9)
         return inNME - flash.KeyCode.KP0 + KeyCode.KP0;
#end

      switch(inNME)
      {
#if (neko || cpp)
         case nme.KeyCode.KP_PERIOD : return KP_PERIOD;
         case nme.KeyCode.KP_DIVIDE : return KP_DIVIDE;
         case nme.KeyCode.KP_MULTIPLY : return KP_MULTIPLY;
         case nme.KeyCode.KP_MINUS : return KP_SUBTRACT;
         case nme.KeyCode.KP_PLUS : return KP_ADD;
         case nme.KeyCode.KP_ENTER : return KP_ENTER;

         case nme.KeyCode.UP : return UP;
         case nme.KeyCode.DOWN : return DOWN;
         case nme.KeyCode.RIGHT : return RIGHT;
         case nme.KeyCode.LEFT : return LEFT;
         case nme.KeyCode.INSERT : return INSERT;
         case nme.KeyCode.DELETE : return DELETE;
         case nme.KeyCode.HOME : return HOME;
         case nme.KeyCode.END : return END;
         case nme.KeyCode.PAGEUP : return PAGEUP;
         case nme.KeyCode.PAGEDOWN : return PAGEDOWN;

         case nme.KeyCode.NUMLOCK : return NUMLOCK;
         case nme.KeyCode.CAPSLOCK : return CAPSLOCK;

         case nme.KeyCode.RSHIFT : return SHIFT;
         case nme.KeyCode.LSHIFT : return SHIFT;
         case nme.KeyCode.RCTRL : return CONTROL;
         case nme.KeyCode.LCTRL : return CONTROL;
#elseif js
         case flash.KeyCode.UP : return UP;
         case flash.KeyCode.RIGHT : return RIGHT;
         case flash.KeyCode.CAPSLOCK : return CAPSLOCK;
         default: return inNME;
#end

      }

      return 0;
   }

   static public function ConvertASCII(inNME:Int, inShift:Bool, inControl:Bool )
   {
      if (inNME>= 97 && inNME<=122 && inShift)
         return inNME - 97 + 65;
      else if (inNME>= 97 && inNME<=122 && inControl)
         return inNME - 97 + 1;

      if (inNME<128)
         return inNME;

      return 0;
   }

   static public function ConvertLocation(inNME:Int)
   {
#if (neko || cpp)
      if (inNME == nme.KeyCode.RCTRL || inNME==nme.KeyCode.RSHIFT)
         return 1;
#elseif js
      if (inNME == flash.KeyCode.CONTROL || inNME==flash.KeyCode.SHIFT)
         return 1;
#end

      return 0;
   }

#end

}

