package jeash.text;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.display.InteractiveObject;
import flash.display.DisplayObject;
import flash.text.TextFormatAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.text.KeyCode;
import flash.text.TextFormat;
import flash.text.TextFieldType;

import js.Dom;

import flash.Manager;

class TextField extends flash.display.InteractiveObject
{
   public var htmlText(GetHTMLText,SetHTMLText):String;
   public var text(GetText,SetText):String;
   public var textColor(GetTextColour,SetTextColour):Int;
   public static var mDefaultFont = "Times";

   private var mHTMLText:String;
   private var mText:String;
   private var mTextColour:Int;
   private var mType:String;

   public var autoSize(default,SetAutoSize) : String;
   public var selectable : Bool;
   public var multiline : Bool;
   public var embedFonts : Bool;
   public var borderColor(default,SetBorderColor) : Int;
   public var background(default,SetBackground) : Bool;
   public var backgroundColor(default,SetBackgroundColor) : Int;
   public var displayAsPassword : Bool;
   public var border(default,SetBorder) : Bool;
   public var wordWrap(default,SetWordWrap) : Bool;
   public var maxChars : Int;
   public var restrict : String;
   public var type(GetType,SetType) : String;
   public var antiAliasType : String;
   public var sharpness : Float;
   public var gridFitType : String;
   public var length(default,null) : Int;
   public var mTextHeight:Int;
   public var mFace:String;
   public var mDownChar:Int;

   public var defaultTextFormat : TextFormat;

   public var selectionBeginIndex : Int;
   public var selectionEndIndex : Int;
   public var caretIndex : Int;
   //public var mParagraphs:Paragraphs;
   public var mTryFreeType:Bool;

   //var mLineInfo:Array<LineInfo>;

   static var sSelectionOwner:TextField = null;

   var mAlign:String;
   var mHTMLMode:Bool;
   var mSelStart:Int;
   var mSelEnd:Int;
   var mInsertPos:Int;
   var mSelectDrag:Int;
   var mInput:Bool;

   var mWidth:Float;
   var mHeight:Float;

   var mSelectionAnchored:Bool;
   var mSelectionAnchor:Int;

   var mScrollH:Int;
   var mScrollV:Int;

   var mGraphics:Graphics;
   var mCaretGfx:HtmlDom;

			var mOffsetTop:Int;
			var mOffsetLeft:Int;

   public function new()
   {
      super();
      mChanged = true;
						/*
      mWidth = 40;
      mHeight = 20;
						*/
      mHTMLMode = false;
      multiline = false;
      mGraphics = new Graphics();

      mCaretGfx = js.Lib.document.createElement('div');
      var scr = untyped Manager.__scr;
      scr.parentNode.appendChild( mCaretGfx );
      mCaretGfx.style.position = 'absolute';
      mOffsetTop = scr.offsetTop;
      mOffsetLeft = scr.offsetLeft;

      var ctx = Manager.getScreen();
      // FIXME: [offset*] probably not cross-browser
      mCaretGfx.style.left = Std.string( scr.offsetLeft );
      mCaretGfx.style.top = Std.string( scr.offsetTop );
      mCaretGfx.style.lineHeight = '20px';

      mFace = mDefaultFont;
      mAlign = flash.text.TextFormatAlign.LEFT;
      defaultTextFormat = new TextFormat();
      //mParagraphs = new Paragraphs();
      mSelStart = -1;
      mSelEnd = -1;
      mScrollH = 0;
      mScrollV = 1;

      mType = flash.text.TextFieldType.DYNAMIC;
      autoSize = flash.text.TextFieldAutoSize.NONE;
      mTextHeight = 12;
      mHTMLText = " ";
      mText = " ";
      mTextColour = 0x000000;
      tabEnabled = false;
      mFace = mDefaultFont;
      mTryFreeType = true;
      selectable = true;
      mInsertPos = 0;
      mInput = false;
      mDownChar = 0;
      mSelectDrag = -1;

      //mLineInfo = [];



      borderColor = 0x000000;
      border = false;
      backgroundColor = 0xffffff;
      background = false;
   }

   override public function GetWidth() : Float { return mWidth; }
   override public function GetHeight() : Float { return mHeight; }
   override public function SetWidth(inWidth:Float) : Float
   {
      mChanged = true;
      if (inWidth!=mWidth)
      {
         mWidth = inWidth;
      }
      return mWidth;
   }

   override public function SetHeight(inHeight:Float) : Float
   {
      mChanged = true;
      if (inHeight!=mHeight)
      {
         mHeight = inHeight;
      }
      return mHeight;
   }

   public function GetType() { return mType; }
   public function SetType(inType:String) : String
   {
      mChanged = true;
      mType = inType;

      mInput = mType == TextFieldType.INPUT;
      if (mInput && mHTMLMode)
         ConvertHTMLToText(true);

      tabEnabled = type == TextFieldType.INPUT;
      return inType;
   }

   public function getCharBoundaries( a:Int ) : Rectangle {
     // TODO
     return null;
   }

   private function CheckChanged() : Bool
   {
      var result = mChanged;
      mChanged = false;
      return result;
   }

   public function Render(inMask:Dynamic,inScrollRect:Rectangle,inTX:Int,inTY:Int):Dynamic
  {
    mGraphics.clear();

    if ( mCaretGfx.innerHTML != mHTMLText && CheckChanged() ) {
      mCaretGfx.innerHTML = mHTMLText;

      // TODO: support -moz-transform / -webkit-transform and IE equivalent
      // and apply mFullMatrix to this mCaretGfx
      mCaretGfx.style.left = Std.string( mX + mOffsetLeft + inTX ) + 'px';
      mCaretGfx.style.top = Std.string( mY + mOffsetTop + inTY ) + 'px';

      if ( mWidth != null && autoSize == flash.text.TextFieldAutoSize.NONE )
	mCaretGfx.style.width = Std.string( mWidth ) + 'px';

      if ( mHeight != null && autoSize == flash.text.TextFieldAutoSize.NONE ) {
	mCaretGfx.style.lineHeight = Std.string( mHeight ) + 'px';
      }

      mCaretGfx.style.fontFamily = mFace;
      mCaretGfx.style.textAlign = mAlign;
      mCaretGfx.style.fontSize = Std.string( mTextHeight ) + 'px';
      mCaretGfx.style.color = mTextColour;

      if ( border ) 
	mCaretGfx.style.border = 'solid 1px #' + StringTools.lpad( StringTools.hex( borderColor ), '0', 6 );

      if ( background ) 
	mCaretGfx.style.backgroundColor = '#' + StringTools.lpad( StringTools.hex( backgroundColor ), '0', 6 );

    }

  }

   public function GetTextColour() { return mTextColour; }
   public function SetTextColour(inCol)
   {
      mTextColour = inCol;
      return inCol;
   }

   public function GetText()
   {
      if (mHTMLMode)
         ConvertHTMLToText(false);
      return mText;
   }

   public function SetText(inText:String)
   {
      mText = inText;
      mHTMLText = inText;
      mHTMLMode = false;
      return mText;
   }

   public function ConvertHTMLToText(inUnSetHTML:Bool)
   {

     var reg : EReg = ~/<\/?[^>]*>/;
     mText = reg.replace( mHTMLText, '' );

     if (inUnSetHTML)
     {
       mHTMLMode = false;
     }
   }

   public function SetAutoSize(inAutoSize:String) : String
   {
      mChanged = true;
      autoSize = inAutoSize;
      return inAutoSize;
   }

   public function SetWordWrap(inWordWrap:Bool) : Bool
   {
      mChanged = true;
      wordWrap = inWordWrap;
      return wordWrap;
   }

   public function SetBorder(inBorder:Bool) : Bool
   {
      mChanged = true;
      border = inBorder;
      return inBorder;
   }

   public function SetBorderColor(inBorderCol:Int) : Int
   {
      mChanged = true;
      borderColor = inBorderCol;
      return inBorderCol;
   }

   public function SetBackgroundColor(inCol:Int) : Int
   {
      mChanged = true;
      backgroundColor = inCol;
      return inCol;
   }

   public function SetBackground(inBack:Bool) : Bool
   {
      mChanged = true;
      background = inBack;
      return inBack;
   }


   public function GetHTMLText() { return mHTMLText; }

   public function SetHTMLText(inHTMLText:String)
   {
      mChanged = true;
      //mParagraphs = new Paragraphs();
      mHTMLText = inHTMLText;
      mHTMLMode = true;
      if (mInput)
         ConvertHTMLToText(true);
      return mHTMLText;
   }

   public function setSelection(beginIndex : Int, endIndex : Int)
   {
      // TODO:
   }

   public function getTextFormat(?beginIndex : Int, ?endIndex : Int) : TextFormat
   {
     return new TextFormat();
   }

   public function setTextFormat(inFmt:TextFormat)
   {
     mChanged = true;
     if (inFmt.font!=null)
       mFace = inFmt.font;
     if (inFmt.size!=null)
       mTextHeight = inFmt.size;
     if (inFmt.align!=null)
       mAlign = inFmt.align;
     if (inFmt.color!=null)
       mTextColour = inFmt.color;

   }

}

