package jeash.text;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.display.InteractiveObject;
import flash.text.FontInstance;
import flash.display.DisplayObject;
import flash.text.FontManager;
import flash.text.TextFormatAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.text.KeyCode;

#if !js
import nme.Manager;
#else
import flash.Manager;
#end

typedef SpanAttribs =
{
   var face:String;
   var height:Int;
   var colour:Int;
   var align:String;
}

typedef Span = 
{
   var font:FontInstance;
   var text:String;
}

typedef Paragraph =
{
   var align:String;
   var spans: Array<Span>;
}

typedef Paragraphs = Array<Paragraph>;

typedef LineInfo =
{
   var mY0:Int;
   var mIndex:Int;
   var mX:Array<Int>;
}

typedef RowChar =
{
   var x:Int;
   var fh:Int;
   var adv:Int;
   var chr:Int;
   var font:FontInstance;
   var sel:Bool;
}

typedef RowChars = Array<RowChar>;

class NeashText extends flash.display.InteractiveObject
{
   public var htmlText(GetHTMLText,SetHTMLText):String;
   public var text(GetText,SetText):String;
   public var textColor(GetTextColour,SetTextColour):Int;
   public var textWidth(GetTextWidth,null):Int;
   public var textHeight(GetTextHeight,null):Int;
   public var defaultTextFormat(getDefaultTextFormat,setTextFormat) : TextFormat;
   public static var mDefaultFont = "Times.ttf";

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
   public var caretPos(GetCaret,null) : Int;
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


   public var selectionBeginIndex : Int;
   public var selectionEndIndex : Int;
   public var caretIndex : Int;
   public var mParagraphs:Paragraphs;
   public var mTryFreeType:Bool;

   var mLineInfo:Array<LineInfo>;

   static var sSelectionOwner:NeashText = null;

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
   var mCaretGfx:Graphics;

   public function new()
   {
      super();
      mWidth = 40;
      mHeight = 20;
      mHTMLMode = false;
      multiline = false;
      mGraphics = new Graphics();
      mCaretGfx = new Graphics();
      mFace = mDefaultFont;
      mAlign = flash.text.TextFormatAlign.LEFT;
      mParagraphs = new Paragraphs();
      mSelStart = -1;
      mSelEnd = -1;
      mScrollH = 0;
      mScrollV = 1;

      mType = flash.text.TextFieldType.DYNAMIC;
      autoSize = flash.text.TextFieldAutoSize.NONE;
      mTextHeight = 12;
      mMaxHeight = mTextHeight;
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

      mLineInfo = [];



      borderColor = 0x000000;
      border = false;
      backgroundColor = 0xffffff;
      background = false;
   }

   public function ClearSelection()
   {
      mSelStart = mSelEnd = -1; mSelectionAnchored = false;
      Rebuild();
   }

   public function DeleteSelection()
   {
      if (mSelEnd > mSelStart && mSelStart>=0)
      {
         mText = mText.substr(0,mSelStart) + mText.substr(mSelEnd);
         mInsertPos = mSelStart;
         mSelStart = mSelEnd = -1;
         mSelectionAnchored = false;
      }
   }

   public function OnMoveKeyStart(inShift:Bool)
   {
      if (inShift && selectable)
      {
         if (!mSelectionAnchored)
         {
            mSelectionAnchored = true;
            mSelectionAnchor = mInsertPos;
            if (sSelectionOwner!=this)
            {
               if (sSelectionOwner!=null)
                 sSelectionOwner.ClearSelection();
               sSelectionOwner = this;
            }
         }
      }
      else
         ClearSelection();
   }

   public function OnMoveKeyEnd()
   {
      if (mSelectionAnchored)
      {
         if (mInsertPos<mSelectionAnchor)
         {
            mSelStart = mInsertPos;
            mSelEnd =mSelectionAnchor;
         }
         else
         {
            mSelStart = mSelectionAnchor;
            mSelEnd =mInsertPos;
         }
      }
   }


   override public function OnKey(inKey:KeyboardEvent):Void
   {
      if (inKey.type!=KeyboardEvent.KEY_DOWN)
         return;

      var key = inKey.keyCode;
      //trace(key);
      var ascii = inKey.charCode;
      var shift = inKey.shiftKey;

      // ctrl-c
      if ( ascii==3 )
      {
         if (mSelEnd > mSelStart && mSelStart>=0)
            Manager.setClipboardString( text.substr(mSelStart,mSelEnd-mSelStart) );
         return;
      }

      if (mInput)
      {
         if (key==KeyCode.LEFT)
         {
            OnMoveKeyStart(shift);
            mInsertPos--;
            OnMoveKeyEnd();
         }
         else if (key==KeyCode.RIGHT)
         {
            OnMoveKeyStart(shift);
            mInsertPos++;
            OnMoveKeyEnd();
         }
         else if (key==KeyCode.HOME)
         {
            OnMoveKeyStart(shift);
            mInsertPos = 0;
            OnMoveKeyEnd();
         }
         else if (key==KeyCode.END)
         {
            OnMoveKeyStart(shift);
            mInsertPos = mText.length;
            OnMoveKeyEnd();
         }
         #if neko
         else if ( (key==KeyCode.INSERT && shift) || ascii==22)
         {
            DeleteSelection();
            var str = Manager.getClipboardString();
            if (str!=null && str!="")
            {
               mText = mText.substr(0,mInsertPos) + str + mText.substr(mInsertPos);
               mInsertPos += str.length;
            }
         }
         else if ( ascii==24 || (key==KeyCode.DELETE && shift) )
         {
            if (mSelEnd > mSelStart && mSelStart>=0)
            {
               Manager.setClipboardString( mText.substr(mSelStart,mSelEnd-mSelStart) );
               if (ascii!=3)
                  DeleteSelection();
            }
         }

         #end
         else if (key==KeyCode.DELETE || key==KeyCode.BACKSPACE)
         {
            if (mSelEnd> mSelStart && mSelStart>=0)
               DeleteSelection();
            else
            {
               if (key==KeyCode.BACKSPACE && mInsertPos>0)
                  mInsertPos--;
               var l = mText.length;
               if (mInsertPos>l)
               {
                  if (l>0)
                     mText = mText.substr(0,l-1);
               }
               else
               {
                   mText = mText.substr(0,mInsertPos) + mText.substr(mInsertPos+1);
               }
            }
         }
         else if (ascii>=32 && ascii<128)
         {
            if (mSelEnd> mSelStart && mSelStart>=0)
               DeleteSelection();
            mText = mText.substr(0,mInsertPos) + String.fromCharCode(ascii) + mText.substr(mInsertPos);
            mInsertPos++;
         }

         if (mInsertPos<0)
            mInsertPos = 0;
         var l = mText.length;
         if (mInsertPos>l)
            mInsertPos = l;

         RebuildText();
      }
   }

   override public function OnFocusIn(inMouse:Bool)
   {
      if (mInput && selectable && !inMouse)
      {
         mSelStart = 0;
         mSelEnd = mText.length;
         RebuildText();
      }
   }

   override public function GetWidth() : Float { return mWidth; }
   override public function GetHeight() : Float { return mHeight; }
   override public function SetWidth(inWidth:Float) : Float
   {
      if (inWidth!=mWidth)
      {
         mWidth = inWidth;
         Rebuild();
      }
      return mWidth;
   }

   override public function SetHeight(inHeight:Float) : Float
   {
      if (inHeight!=mHeight)
      {
         mHeight = inHeight;
         Rebuild();
      }
      return mHeight;
   }

   public function GetType() { return mType; }
   public function SetType(inType:String) : String
   {
      mType = inType;

      mInput = mType == TextFieldType.INPUT;
      if (mInput && mHTMLMode)
         ConvertHTMLToText(true);

      tabEnabled = type == TextFieldType.INPUT;
      Rebuild();
      return inType;
   }

   public function GetCaret() { return mInsertPos; }
   override public function GetGraphics() : flash.display.Graphics { return mGraphics; }

   public function getLineIndexAtPoint(inX:Float,inY:Float) : Int
   {
      if (mLineInfo.length<1) return -1;
      if (inY<=0) return 0;

      for(l in 0...mLineInfo.length)
         if (mLineInfo[l].mY0 > inY)
            return l==0 ? 0 : l-1;
      return mLineInfo.length-1;
   }

   public function getCharIndexAtPoint(inX:Float,inY:Float) : Int
   {
      var li = getLineIndexAtPoint(inX,inY);
      if (li<0)
         return -1;

      var line = mLineInfo[li];
      var idx = line.mIndex;
      for(x in line.mX)
      {
         if (x>inX) return idx;
         idx++;
      }
      return idx;

   }

   public function getCharBoundaries( a:Int ) : Rectangle {
     // TODO
     return null;
   }

   override public function OnMouseDown(inX:Int, inY:Int)
   {
      if (tabEnabled || selectable)
      {
         if (sSelectionOwner != null)
            sSelectionOwner.ClearSelection();

         sSelectionOwner = this;

         stage.focus = this;
         var gx = inX/stage.scaleX;
         var gy = inY/stage.scaleY;
         var pos = globalToLocal( new flash.geom.Point(gx,gy) );

         mSelectDrag = getCharIndexAtPoint(pos.x,pos.y);
         if (tabEnabled)
            mInsertPos = mSelectDrag;
         mSelStart = mSelEnd = -1;
         RebuildText();
      }
   }
   override public function OnMouseDrag(inX:Int, inY:Int)
   {
      if ( (tabEnabled||selectable) && mSelectDrag>=0)
      {
         var gx = inX/stage.scaleX;
         var gy = inY/stage.scaleY;
         var pos = globalToLocal( new flash.geom.Point(gx,gy) );
         var idx = getCharIndexAtPoint(pos.x,pos.y);
         if (sSelectionOwner!=this)
         {
           if (sSelectionOwner!=null)
              sSelectionOwner.ClearSelection();
           sSelectionOwner = this;
         }

         if (idx<mSelectDrag)
         {
            mSelStart = idx;
            mSelEnd = mSelectDrag;
         }
         else if (idx>mSelectDrag)
         {
            mSelStart = mSelectDrag;
            mSelEnd = idx;
         }
         else
            mSelStart = mSelEnd = -1;

         if (tabEnabled)
            mInsertPos = idx;
         RebuildText();
      }
   }
   override public function OnMouseUp(inX:Int, inY:Int)
   {
      mSelectDrag = -1;
   }



   var mMaxWidth:Int;
   var mMaxHeight:Int;
   var mLimitRenderX:Int;

   function RenderRow(inRow:RowChars, inY:Int, inCharIdx:Int,inAlign:String, ?inInsert:Int) : Int
   {
      var h = 0;
      var w = 0;
      for(chr in inRow)
      {
         if (chr.fh > h)
            h = chr.fh;
         w+=chr.adv;
      }
      if (w>mMaxWidth)
         mMaxWidth = w;

      var full_height = Std.int(h*1.2);


      var align_x = 0;
      var insert_x = 0;
      if (inInsert!=null)
      {
         if (autoSize != flash.text.TextFieldAutoSize.NONE)
         {
            mScrollH = 0;
            insert_x = inInsert;
         }
         else
         {
            insert_x = inInsert - mScrollH;
            if (insert_x<0)
            {
               mScrollH -= ( (mLimitRenderX*3)>>2 ) - insert_x;
            }
            else if (insert_x > mLimitRenderX)
            {
               mScrollH +=  insert_x - ((mLimitRenderX*3)>>2);
            }
            if (mScrollH<0)
               mScrollH = 0;
         }
      }

      if (autoSize == flash.text.TextFieldAutoSize.NONE && w<=mLimitRenderX)
      {
         if (inAlign == TextFormatAlign.CENTER)
            align_x = (mLimitRenderX-w)>>1;
         else if (inAlign == TextFormatAlign.RIGHT)
            align_x = (mLimitRenderX-w);
      }

      var x_list = new Array<Int>();
      mLineInfo.push( { mY0:inY, mIndex:inCharIdx, mX:x_list } );

      var cache_sel_font : FontInstance = null;
      var cache_normal_font : FontInstance = null;

      var x = align_x-mScrollH;
      var x0 = x;
      for(chr in inRow)
      {
         var adv = chr.adv;
         if (x+adv>mLimitRenderX)
            break;

         x_list.push(x);

         if (x>=0)
         {
            var font = chr.font;
            if (chr.sel)
            {
               mGraphics.lineStyle();
               mGraphics.beginFill(0x202060);
               mGraphics.drawRect(x,inY,adv,full_height);
               mGraphics.endFill();

               if (cache_normal_font == chr.font)
               {
                  font = cache_sel_font;
               }
               else
               {
                  font = FontInstance.CreateSolid( chr.font.GetFace(), chr.fh, 0xffffff,1.0 );
                  cache_sel_font = font;
                  cache_normal_font = chr.font;
               }
            }
#if !js
												// Typing issue on js target
            font.RenderChar(mGraphics,chr.chr,x,Std.int(inY + (h-chr.fh)));
#end
         }

         x+=adv;
      }

      x+=mScrollH;


      if (inInsert!=null)
      {
         mCaretGfx.lineStyle(1,mTextColour);
         mCaretGfx.moveTo(inInsert+align_x-mScrollH ,inY);
         mCaretGfx.lineTo(inInsert+align_x-mScrollH ,inY+full_height);
      }

      return full_height;
   }




   function Rebuild()
   {
      mLineInfo = [];

      mGraphics.clear();
      mCaretGfx.clear();

      if (background)
      {
         mGraphics.beginFill(backgroundColor);
         mGraphics.drawRect(-2,-2,width+4,height+4);
         mGraphics.endFill();
      }
      mGraphics.lineStyle(mTextColour);

      var insert_x:Null<Int> = null;

      mMaxWidth = 0;
      mLimitRenderX = (autoSize == flash.text.TextFieldAutoSize.NONE) ? Std.int(width) : 999999;
      var wrap = (wordWrap && !mInput) ? mLimitRenderX : 999999;
      var char_idx = 0;
      var h = 0;

      var s0 = mSelStart;
      var s1 = mSelEnd;

      for(paragraph in mParagraphs)
      {
         var row:RowChars = [];
         var row_width = 0;
         var last_word_break = 0;
         var last_word_break_width = 0;
         var last_word_char_idx = 0;
         var start_idx = char_idx;
         var tx = 0;


         for(span in paragraph.spans)
         {
            var text = span.text;
            var font = span.font;
            var fh = font.height;
            last_word_break = row.length;
            last_word_break_width = row_width;
            last_word_char_idx = char_idx;

            #if (neko||cpp)
            font.mTryFreeType = mTryFreeType;
            #end

            for(ch in 0...text.length)
            {
               if (char_idx == mInsertPos && mInput)
                  insert_x = tx;

               var g = text.charCodeAt(ch);
               var adv = font.GetAdvance(g);
               if (g==32)
               {
                  last_word_break = row.length;
                  last_word_break_width = tx;
                  last_word_char_idx = char_idx;
               }

               if ( (tx+adv)>wrap )
               {
                  if (last_word_break>0)
                  {
                     var row_end = row.splice(last_word_break, row.length-last_word_break);
                     h+=RenderRow(row,h,start_idx,paragraph.align);
                     row = row_end;
                     tx -= last_word_break_width;
                     start_idx = last_word_char_idx;

                     last_word_break = 0;
                     last_word_break_width = 0;
                     last_word_char_idx = 0;
                     if (row_end.length>0 && row_end[0].chr==32)
                     {
                        row_end.shift();
                        start_idx ++;
                     }
                  }
                  else
                  {
                     h+=RenderRow(row,h,char_idx,paragraph.align);
                     row = [];
                     tx = 0;
                     start_idx = char_idx;
                  }
               }
               row.push( { font:font, chr:g, x:tx, fh: fh,
                           sel:(char_idx>=s0 && char_idx<s1), adv:adv } );
               tx += adv;
               char_idx++;
            }
         }
         if (row.length>0)
         {
            var pos = (mInput && insert_x==null) ? tx : (insert_x==null ? 0 : insert_x);
            h+=RenderRow(row,h,start_idx,paragraph.align,pos);
         }
      }


      var w = mMaxWidth;
      if (h<mTextHeight)
        h = mTextHeight;
      mMaxHeight = h;

      switch(autoSize)
      {
         case flash.text.TextFieldAutoSize.LEFT:
            width = w;
            height = h;
         case flash.text.TextFieldAutoSize.RIGHT:
            var x0 = x + width;
            width = w;
            height = h;
            x = x0 - w;
         case flash.text.TextFieldAutoSize.CENTER:
            var x0 = x + width/2;
            width = w;
            height = h;
            x = x0 - w/2;
         default:
            if (wordWrap)
               height = h;
      }


      if (char_idx==0 && mInput)
      {
         var x = 0;
         if (mAlign==TextFormatAlign.CENTER)
            x = Std.int(width/2);
         else if (mAlign==TextFormatAlign.RIGHT)
            x = Std.int(width) - 1;

         mCaretGfx.lineStyle(1,mTextColour);
         mCaretGfx.moveTo(x ,0);
         mCaretGfx.lineTo(x ,mTextHeight);
      }



      if (border)
      {
         mGraphics.endFill();
         mGraphics.lineStyle(1,borderColor);
         mGraphics.drawRect(-2,-2,width+4,height+4);
      }
   }

   #if (neko||cpp)
   override public function DoMouseEnter() { flash.Lib.SetTextCursor(true); }
   override public function DoMouseLeave() { flash.Lib.SetTextCursor(false); }

   override public function GetObj(inX:Int,inY:Int, inObj:InteractiveObject ) : InteractiveObject
   {
      var inv = mFullMatrix.clone();
      inv.invert();
      var px = inv.a*inX + inv.c*inY + inv.tx;
      var py = inv.b*inX + inv.d*inY + inv.ty;

      if (px>0 && px<width && py>0 && py<height)
      {
         return this;
      }

      return null;
   }

   override public function GetBackgroundRect() : Rectangle
   {
      if (border)
         return new Rectangle(-2,-2,width+4,height+4);
      else
         return new Rectangle(0,0,width,height);
   }


   override public function __Render(inMask:Dynamic,inScrollRect:Rectangle,inTX:Int,inTY:Int):Dynamic
   {
      if (!visible) return null;

      inMask = super.__Render(inMask,inScrollRect,inTX,inTY);
      if (mInput && stage.focus==this)
      {
         if ( (Std.int(flash.Lib.getTimer()*0.002) & 1) == 1 )
         {
            if (inScrollRect!=null)
            {
               var m = mFullMatrix.clone();
               m.tx -= inTX;
               m.ty -= inTY;
               mCaretGfx.render(m,null,inMask,inScrollRect);
            }
            else
               mCaretGfx.render(mFullMatrix,null,inMask);
         }
      }

      return inMask;
   }

   #end


   public function GetTextWidth() : Int{ return mMaxWidth; }
   public function GetTextHeight() : Int{ return mMaxHeight; }

   public function GetTextColour() { return mTextColour; }
   public function SetTextColour(inCol)
   {
      mTextColour = inCol;
      RebuildText();
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
      RebuildText();
      return mText;
   }

   public function ConvertHTMLToText(inUnSetHTML:Bool)
   {
      mText = "";

      for(paragraph in mParagraphs)
      {
         for(span in paragraph.spans)
         {
            mText += span.text;
         }
         // + \n ?
      }

      if (inUnSetHTML)
      {
         mHTMLMode = false;
         RebuildText();
      }
   }

   override public function GetFocusObjects(outObjs:Array<InteractiveObject>)
   {
      if (mInput)
         outObjs.push(this);
   }


   public function SetAutoSize(inAutoSize:String) : String
   {
      autoSize = inAutoSize;
      Rebuild();
      return inAutoSize;
   }

   public function SetWordWrap(inWordWrap:Bool) : Bool
   {
      wordWrap = inWordWrap;
      Rebuild();
      return wordWrap;
   }
   public function SetBorder(inBorder:Bool) : Bool
   {
      border = inBorder;
      Rebuild();
      return inBorder;
   }

   public function SetBorderColor(inBorderCol:Int) : Int
   {
      borderColor = inBorderCol;
      Rebuild();
      return inBorderCol;
   }

   public function SetBackgroundColor(inCol:Int) : Int
   {
      backgroundColor = inCol;
      Rebuild();
      return inCol;
   }

   public function SetBackground(inBack:Bool) : Bool
   {
      background = inBack;
      Rebuild();
      return inBack;
   }


   public function GetHTMLText() { return mHTMLText; }

   function DecodeColour(col:String)
   {
      return Std.parseInt("0x"+col.substr(1));
   }

   function AddXML(x:Xml,a:SpanAttribs)
   {
      var type = x.nodeType;
      if (type==Xml.Document || type==Xml.Element)
      {
         if (type==Xml.Element)
         {
            a = {face:a.face, height:a.height, colour:a.colour, align:a.align};
            switch(x.nodeName)
            {
               case "p":
                  var l = mParagraphs.length;
                  var align = x.get("align");
                  if (align!=null)
                    a.align = align;

                  if (l>0 && mParagraphs[l-1].spans.length>0 && multiline)
                     mParagraphs.push( { align:a.align, spans:[] } );

               case "font":
                  var face = x.get("face");
                  if (face!=null) a.face = face;
                  var height = x.get("size");
                  if (height!=null) a.height = Std.int(Std.parseFloat(height));
                  var col = x.get("color");
                  if (col!=null) a.colour = DecodeColour(col);
            }
         }
         for(child in x)
         {
            AddXML(child,a);
         }
      }
      else
      {
         var text = x.nodeValue;
         var font = FontInstance.CreateSolid( a.face, a.height, a.colour, 1.0  );

         if (font!=null && text!="")
         {
            //trace("Add span " + a.face + "/" + a.height + "/" + a.colour );
            var span : Span = { text: text, font:font };

            var l =  mParagraphs.length;
            if (mParagraphs.length<1)
               mParagraphs.push( { align : a.align, spans: [ span ] } );
            else
               mParagraphs[l-1].spans.push(span);
         }
      }
   }

   public function RebuildText()
   {
      mParagraphs = [];

      if (mHTMLMode)
      {
         var xml = Xml.parse(mHTMLText);

         var a  = { face:mFace, height:mTextHeight, colour:mTextColour, align: mAlign };

         AddXML(xml,a);
      }
      else
      {
         var font = FontInstance.CreateSolid( mFace, mTextHeight, mTextColour, 1.0  );
         var paras = mText.split("\n");
         for(paragraph in paras)
            mParagraphs.push( { align:mAlign, spans: [ { font : font, text:paragraph }] } );
      }
      Rebuild();
   }

   public function SetHTMLText(inHTMLText:String)
   {
      mParagraphs = new Paragraphs();
      mHTMLText = inHTMLText;
      mHTMLMode = true;
      RebuildText();
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

    public function getDefaultTextFormat() : TextFormat
    {
       return new TextFormat();
    }


    public function setTextFormat(inFmt:TextFormat)
    {
       if (inFmt.font!=null)
          mFace = inFmt.font;
       if (inFmt.size!=null)
          mTextHeight = Std.int(inFmt.size);
       if (inFmt.align!=null)
          mAlign = inFmt.align;
       if (inFmt.color!=null)
          mTextColour = inFmt.color;

       RebuildText();
       return getTextFormat();
    }

}

