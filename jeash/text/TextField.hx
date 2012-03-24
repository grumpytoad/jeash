/** * Copyright (c) 2010, Jeash contributors.
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

package jeash.text;

import jeash.display.Graphics;
import jeash.geom.Matrix;
import jeash.geom.Rectangle;
import jeash.geom.Point;
import jeash.display.InteractiveObject;
import jeash.display.DisplayObject;
import jeash.text.TextFormatAlign;
import jeash.events.Event;
import jeash.events.KeyboardEvent;
import jeash.events.FocusEvent;
import jeash.ui.Keyboard;

import Html5Dom;

typedef SpanAttribs = {
	var face:String;
	var height:Int;
	var colour:Int;
	var align:TextFormatAlign;
}

typedef Span = {
	var font:FontInstance;
	var text:String;
}

typedef Paragraph = {
	var align:TextFormatAlign;
	var spans: Array<Span>;
}

typedef Paragraphs = Array<Paragraph>;

typedef LineInfo = {
	var mY0:Int;
	var mIndex:Int;
	var mX:Array<Int>;
}

typedef RowChar = {
	var x:Int;
	var fh:Int;
	var adv:Int;
	var chr:Int;
	var font:FontInstance;
	var sel:Bool;
}

typedef RowChars = Array<RowChar>;

class TextField extends jeash.display.InteractiveObject {
	public var htmlText(GetHTMLText,SetHTMLText):String;
	public var text(GetText,SetText):String;
	public var textColor(GetTextColour,SetTextColour):Int;
	public var textWidth(GetTextWidth,null):Float;
	public var textHeight(GetTextHeight,null):Float;
	public var defaultTextFormat(jeashGetDefaultTextFormat,jeashSetDefaultTextFormat) : TextFormat;
	public static var mDefaultFont = Font.DEFAULT_FONT_NAME;

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

	static var sSelectionOwner:TextField = null;

	var mAlign:TextFormatAlign;
	var mHTMLMode:Bool;
	var mSelStart:Int;
	var mSelEnd:Int;
	var mInsertPos:Int;
	var mSelectDrag:Int;
	var jeashInputEnabled:Bool;

	var mWidth:Float;
	var mHeight:Float;

	var mSelectionAnchored:Bool;
	var mSelectionAnchor:Int;

	var mScrollH:Int;
	var mScrollV:Int;

	var jeashGraphics:Graphics;
	var mCaretGfx:Graphics;

	var jeashCaretTimer:haxe.Timer;
	var jeashCaretVisible:Bool;

	static var CARET_BLINK_SPEED = 1000;

	public function new() {
		super();
		mWidth = 100;
		mHeight = 20;
		mHTMLMode = false;
		multiline = false;
		jeashGraphics = new Graphics();
		mCaretGfx = new Graphics();
		mFace = mDefaultFont;
		mAlign = jeash.text.TextFormatAlign.LEFT;
		mParagraphs = new Paragraphs();
		mSelStart = -1;
		mSelEnd = -1;
		mScrollH = 0;
		mScrollV = 1;

		mType = jeash.text.TextFieldType.DYNAMIC;
		autoSize = jeash.text.TextFieldAutoSize.NONE;
		mTextHeight = 12;
		mMaxHeight = mTextHeight;
		mHTMLText = " ";
		mText = " ";
		mTextColour = 0x000000;
		tabEnabled = false;
		mTryFreeType = true;
		selectable = true;
		mInsertPos = 0;
		jeashInputEnabled = false;
		mDownChar = 0;
		mSelectDrag = -1;

		mLineInfo = [];
		defaultTextFormat = new TextFormat();

		name = "TextField " + jeash.display.DisplayObject.mNameID++;
		Lib.jeashSetSurfaceId(jeashGraphics.jeashSurface, name);

		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;

		jeashCaretVisible = false;
		jeashCaretTimer = new haxe.Timer(CARET_BLINK_SPEED);

	}

	public function jeashClearSelection() {
		mSelStart = mSelEnd = -1; mSelectionAnchored = false;
		Rebuild();
	}

	public function jeashDeleteSelection() {
		if (mSelEnd > mSelStart && mSelStart>=0) {
			mText = mText.substr(0,mSelStart) + mText.substr(mSelEnd);
			mInsertPos = mSelStart;
			mSelStart = mSelEnd = -1;
			mSelectionAnchored = false;
		}
	}

	public function jeashOnMoveKeyStart(inShift:Bool) {
		if (inShift && selectable) {
			if (!mSelectionAnchored) {
				mSelectionAnchored = true;
				mSelectionAnchor = mInsertPos;
				if (sSelectionOwner!=this) {
					if (sSelectionOwner!=null)
						sSelectionOwner.jeashClearSelection();
					sSelectionOwner = this;
				}
			}
		} else jeashClearSelection();
	}

	public function jeashOnMoveKeyEnd() {
		if (mSelectionAnchored) {
			if (mInsertPos<mSelectionAnchor) {
				mSelStart = mInsertPos;
				mSelEnd =mSelectionAnchor;
			} else {
				mSelStart = mSelectionAnchor;
				mSelEnd =mInsertPos;
			}
		}
	}

	public function jeashOnKey(inKey:KeyboardEvent):Void {
		if (inKey.type!=KeyboardEvent.KEY_DOWN)
			return;

		var key = inKey.keyCode;
		var ascii = inKey.charCode;
		var shift = inKey.shiftKey;

		/* TODO: What's this ? remove ?
		// ctrl-c
		if ( ascii==3 ) {
			if (mSelEnd > mSelStart && mSelStart>=0)
				throw "To implement setClipboardString. TextField.OnKey";
			return;
		} */

		if (jeashInputEnabled) {
			if (key==Keyboard.LEFT) {
				jeashOnMoveKeyStart(shift);
				mInsertPos--;
				jeashOnMoveKeyEnd();
			} else if (key==Keyboard.RIGHT) {
				jeashOnMoveKeyStart(shift);
				mInsertPos++;
				jeashOnMoveKeyEnd();
			} else if (key==Keyboard.HOME) {
				jeashOnMoveKeyStart(shift);
				mInsertPos = 0;
				jeashOnMoveKeyEnd();
			} else if (key==Keyboard.END) {
				jeashOnMoveKeyStart(shift);
				mInsertPos = mText.length;
				jeashOnMoveKeyEnd();
			} else if (key==Keyboard.ENTER) {
				if (mSelEnd> mSelStart && mSelStart>=0)
					jeashDeleteSelection();
				mText = mText.substr(0,mInsertPos) + "\n" + mText.substr(mInsertPos);
				mInsertPos++;
			} else if (key==Keyboard.SPACE) {
				if (mSelEnd> mSelStart && mSelStart>=0)
					jeashDeleteSelection();
				mText = mText.substr(0,mInsertPos) + " " + mText.substr(mInsertPos);
				mInsertPos++;
			} else if (key==Keyboard.TAB) {
				if (mSelEnd> mSelStart && mSelStart>=0)
					jeashDeleteSelection();
				mText = mText.substr(0,mInsertPos) + "\t" + mText.substr(mInsertPos);
			}
			/* TODO: implement copy&paste - cross-browser solution ?
			else if ( (key==Keyboard.INSERT && shift) || ascii==22)
			{
				jeashDeleteSelection();
				var str = Manager.getClipboardString();
				if (str!=null && str!="")
				{
					mText = mText.substr(0,mInsertPos) + str + mText.substr(mInsertPos);
					mInsertPos += str.length;
				}
			}
			else if ( ascii==24 || (key==Keyboard.DELETE && shift) )
			{
				if (mSelEnd > mSelStart && mSelStart>=0)
				{
					Manager.setClipboardString( mText.substr(mSelStart,mSelEnd-mSelStart) );
					if (ascii!=3)
						jeashDeleteSelection();
				}
			}
			 */
			else if (key==Keyboard.DELETE || key==Keyboard.BACKSPACE) {
				if (mSelEnd> mSelStart && mSelStart>=0)
					jeashDeleteSelection();
				else {
					var l = mText.length;
					if (key==Keyboard.BACKSPACE && mInsertPos>0)
						mInsertPos--;

					if (mInsertPos>l) {
						if (l>0)
							mText = mText.substr(0,l-1);
					} else if (mInsertPos==0 && key==Keyboard.BACKSPACE) {
						// no-op
					} else {
						mText = mText.substr(0,mInsertPos) + mText.substr(mInsertPos+1);
					}
				}
			} else if (ascii>=48 && ascii<128) {
				if (mSelEnd> mSelStart && mSelStart>=0)
					jeashDeleteSelection();
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

	function jeashCaretTimerCallback () {
		if (visible && jeashInputEnabled && stage.focus == this) {
			jeashCaretVisible = !jeashCaretVisible;
			Lib.jeashSetSurfaceVisible(mCaretGfx.jeashSurface, jeashCaretVisible);
		}
	}

	/* Not implemented - AVM2 focus model
	public function jeashOnFocusIn(event:jeash.events.FocusEvent) {
		if (jeashInputEnabled && selectable && !inMouse) {
			mSelStart = 0;
			mSelEnd = mText.length;
			RebuildText();
		}
	} */

	function jeashOnMouseDown(event:jeash.events.MouseEvent) {
		if (tabEnabled || selectable) {
			if (mHTMLMode) {
				Lib.jeashDesignMode(true);
			} else {
				if (sSelectionOwner != null)
					sSelectionOwner.jeashClearSelection();

				sSelectionOwner = this;

				mSelectDrag = getCharIndexAtPoint(event.localX, event.localY);
				if (tabEnabled)
					mInsertPos = mSelectDrag;
				mSelStart = mSelEnd = -1;
				RebuildText();
			}
		}
	}

	function jeashOnMouseDrag(event:jeash.events.MouseEvent) {
		if ( (tabEnabled||selectable) && mSelectDrag>=0 && !mHTMLMode) {
			var idx = getCharIndexAtPoint(event.localX, event.localY)+1;
			if (sSelectionOwner!=this) {
				if (sSelectionOwner!=null)
					sSelectionOwner.jeashClearSelection();
				sSelectionOwner = this;
			}

			if (idx<mSelectDrag) {
				mSelStart = idx;
				mSelEnd = mSelectDrag;
			} else if (idx>mSelectDrag) {
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

	function jeashOnMouseUp(event:jeash.events.MouseEvent) {
		mSelectDrag = -1;
		if (mHTMLMode) Lib.jeashDesignMode(false);
	}

	function jeashOnMouseOver(_) { jeash.Lib.jeashSetCursor(Text); }
	function jeashOnMouseOut(_) { jeash.Lib.jeashSetCursor(Default); }

	override public function jeashGetWidth() : Float { 
		return getBounds(this.stage).width;
	}
	override public function jeashGetHeight() : Float { 
		return getBounds(this.stage).height;
	}
	override public function jeashSetWidth(inWidth:Float) : Float {

		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();

		if (inWidth!=mWidth) {
			mWidth = inWidth;
			Rebuild();
		}

		return mWidth;
	}

	override public function jeashSetHeight(inHeight:Float) : Float {
		
		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();
		
		if (inHeight!=mHeight) {
			mHeight = inHeight;
			Rebuild();
		}

		return mHeight;
	}

	public function GetType() { return mType; }
	public function SetType(inType:String) : String {
		mType = inType;

		jeashInputEnabled = mType == TextFieldType.INPUT;
		if (mHTMLMode) {
			if (jeashInputEnabled) {
				Lib.jeashSetContentEditable(jeashGraphics.jeashSurface, true);
			} else {
				Lib.jeashSetContentEditable(jeashGraphics.jeashSurface, false);
			}
		}

		tabEnabled = type == TextFieldType.INPUT;
		Rebuild();
		return inType;
	}

	public function GetCaret() { return mInsertPos; }
	override function jeashGetGraphics() : jeash.display.Graphics { return jeashGraphics; }

	public function getLineIndexAtPoint(inX:Float,inY:Float) : Int {
		if (mLineInfo.length<1) return -1;
		if (inY<=0) return 0;

		for(l in 0...mLineInfo.length)
			if (mLineInfo[l].mY0 > inY)
				return l==0 ? 0 : l-1;
		return mLineInfo.length-1;
	}

	public function getCharIndexAtPoint(inX:Float,inY:Float) : Int {
		var li = getLineIndexAtPoint(inX,inY);
		if (li<0)
			return -1;

		var line = mLineInfo[li];
		var idx = line.mIndex;
		for(x in line.mX) {
			if (x>inX) return idx;
			idx++;
		}
		return idx;

	}

	public function getCharBoundaries( a:Int ) : Rectangle {
		// TODO
		return null;
	}

	var mMaxWidth:Float;
	var mMaxHeight:Float;
	var mLimitRenderX:Int;

	function RenderRow(inRow:Array<RowChar>, inY:Int, inCharIdx:Int, inAlign:TextFormatAlign, ?inInsert:Int) : Int {
		var h = 0;
		var w = 0;
		for(chr in inRow) {
			if (chr.fh > h)
				h = chr.fh;
			w+=chr.adv;
		}
		if (w>mMaxWidth)
			mMaxWidth = w;

		var full_height = Std.int(h*1.2);


		var align_x = 0;
		var insert_x = 0;
		if (inInsert!=null) {
			// TODO: check if this is necessary.
			if (autoSize != jeash.text.TextFieldAutoSize.NONE) {
				mScrollH = 0;
				insert_x = inInsert;
			} else {
				insert_x = inInsert - mScrollH;
				if (insert_x<0) {
					mScrollH -= ( (mLimitRenderX*3)>>2 ) - insert_x;
				} else if (insert_x > mLimitRenderX) {
					mScrollH +=  insert_x - ((mLimitRenderX*3)>>2);
				}
				if (mScrollH<0)
					mScrollH = 0;
			}
		}

		if (autoSize == jeash.text.TextFieldAutoSize.NONE && w<=mLimitRenderX) {
			if (inAlign == TextFormatAlign.CENTER)
				align_x = (mLimitRenderX-w)>>1;
			else if (inAlign == TextFormatAlign.RIGHT)
				align_x = (mLimitRenderX-w);
		}

		var x_list = new Array<Int>();
		mLineInfo.push( { mY0:inY, mIndex:inCharIdx-1, mX:x_list } );

		var cache_sel_font : FontInstance = null;
		var cache_normal_font : FontInstance = null;

		var x = align_x-mScrollH;
		var x0 = x;
		for(chr in inRow) {
			var adv = chr.adv;
			if (x+adv>mLimitRenderX)
				break;

			x_list.push(x);

			if (x>=0) {
				var font = chr.font;
				if (chr.sel) {
					jeashGraphics.lineStyle();
					jeashGraphics.beginFill(0x202060);
					jeashGraphics.drawRect(x,inY,adv,full_height);
					jeashGraphics.endFill();

					if (cache_normal_font == chr.font) {
						font = cache_sel_font;
					} else {
						font = FontInstance.CreateSolid( chr.font.GetFace(), chr.fh, 0xffffff,1.0 );
						cache_sel_font = font;
						cache_normal_font = chr.font;
					}
				}
				font.RenderChar(jeashGraphics,chr.chr,x,Std.int(inY + (h-chr.fh)));
			}

			x+=adv;
		}

		x+=mScrollH;


		if (inInsert!=null) {
			mCaretGfx.lineStyle(1, mTextColour);
			mCaretGfx.moveTo(inInsert+align_x-mScrollH ,inY);
			mCaretGfx.lineTo(inInsert+align_x-mScrollH ,inY+full_height);
		}

		return full_height;
	}

	function Rebuild() {

		if (mHTMLMode) return;

		mLineInfo = [];

		jeashGraphics.clear();
		mCaretGfx.clear();

		if (background) {
			jeashGraphics.beginFill(backgroundColor);
			jeashGraphics.drawRect(-2,-2,width+4,height+4);
			jeashGraphics.endFill();
		}

		jeashGraphics.lineStyle(mTextColour);

		var insert_x:Null<Int> = null;

		mMaxWidth = 0;
		//mLimitRenderX = (autoSize == jeash.text.TextFieldAutoSize.NONE) ? Std.int(width) : 999999;
		var wrap = mLimitRenderX = (wordWrap && !jeashInputEnabled) ? Std.int(mWidth) : 999999;
		var char_idx = 0;
		var h:Int = 0;

		var s0 = mSelStart;
		var s1 = mSelEnd;

		for(paragraph in mParagraphs) {
			var row:Array<RowChar> = [];
			var row_width = 0;
			var last_word_break = 0;
			var last_word_break_width = 0;
			var last_word_char_idx = 0;
			var start_idx = char_idx;
			var tx = 0;

			for(span in paragraph.spans) {
				var text = span.text;
				var font = span.font;
				var fh = font.height;
				last_word_break = row.length;
				last_word_break_width = row_width;
				last_word_char_idx = char_idx;

				for(ch in 0...text.length) {
					if (char_idx == mInsertPos && jeashInputEnabled)
						insert_x = tx;

					var g = text.charCodeAt(ch);
					var adv = font.jeashGetAdvance(g);
					if (g==32) {
						last_word_break = row.length;
						last_word_break_width = tx;
						last_word_char_idx = char_idx;
					}

					if ( (tx+adv)>wrap ) {
						if (last_word_break>0) {
							var row_end = row.splice(last_word_break, row.length-last_word_break);
							h+=RenderRow(row,h,start_idx,paragraph.align);
							row = row_end;
							tx -= last_word_break_width;
							start_idx = last_word_char_idx;

							last_word_break = 0;
							last_word_break_width = 0;
							last_word_char_idx = 0;
							if (row_end.length>0 && row_end[0].chr==32) {
								row_end.shift();
								start_idx ++;
							}
						} else {
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
			if (row.length>0) {
				h+=RenderRow(row,h,start_idx,paragraph.align,insert_x);
				insert_x = null;
			}
		}

		var w = mMaxWidth;
		if (h<mTextHeight)
			h = mTextHeight;
		mMaxHeight = h;

		switch(autoSize) {
			case jeash.text.TextFieldAutoSize.LEFT:
			case jeash.text.TextFieldAutoSize.RIGHT:
				var x0 = x + width;
				x = mWidth - x0;
			case jeash.text.TextFieldAutoSize.CENTER:
				var x0 = x + width/2;
				x = mWidth/2 - x0;
			default:
				if (wordWrap)
					height = h;
		}

		if (char_idx==0 && jeashInputEnabled) {
			var x = 0;
			if (mAlign==TextFormatAlign.CENTER)
				x = Std.int(width/2);
			else if (mAlign==TextFormatAlign.RIGHT)
				x = Std.int(width) - 1;

			mCaretGfx.lineStyle(1,mTextColour);
			mCaretGfx.moveTo(x ,0);
			mCaretGfx.lineTo(x ,mTextHeight);
		}

		if (border) {
			jeashGraphics.endFill();
			jeashGraphics.lineStyle(1,borderColor);
			jeashGraphics.drawRect(-2,-2,width+4,height+4);
		}

		mCaretGfx.jeashRender();
		Lib.jeashSetSurfaceTransform(mCaretGfx.jeashSurface, mFullMatrix.clone());
	}

	override public function GetBackgroundRect() : Rectangle {
		if (border)
			return new Rectangle(-2,-2,width+4,height+4);
		else
			return new Rectangle(0,0,width,height);
	}


	public function GetTextWidth() : Float{ return mMaxWidth; }
	public function GetTextHeight() : Float{ return mMaxHeight; }

	public function GetTextColour() { return mTextColour; }
	public function SetTextColour(inCol) {
		mTextColour = inCol;
		RebuildText();
		return inCol;
	}

	public function GetText() {
		if (mHTMLMode)
			ConvertHTMLToText(false);
		return mText;
	}

	public function SetText(inText:String) {
		mText = inText;
		//mHTMLText = inText;
		mHTMLMode = false;
		RebuildText();
		jeashInvalidateBounds();
		return mText;
	}

	public function ConvertHTMLToText(inUnSetHTML:Bool) {
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

	public function SetAutoSize(inAutoSize:String) : String {
		autoSize = inAutoSize;
		Rebuild();
		return inAutoSize;
	}

	public function SetWordWrap(inWordWrap:Bool) : Bool {
		wordWrap = inWordWrap;
		Rebuild();
		return wordWrap;
	}
	public function SetBorder(inBorder:Bool) : Bool {
		border = inBorder;
		Rebuild();
		return inBorder;
	}

	public function SetBorderColor(inBorderCol:Int) : Int {
		borderColor = inBorderCol;
		Rebuild();
		return inBorderCol;
	}

	public function SetBackgroundColor(inCol:Int) : Int {
		backgroundColor = inCol;
		Rebuild();
		return inCol;
	}

	public function SetBackground(inBack:Bool) : Bool {
		background = inBack;
		Rebuild();
		return inBack;
	}


	public function GetHTMLText() { return mHTMLText; }

	function DecodeColour(col:String) {
		return Std.parseInt("0x"+col.substr(1));
	}

	public function RebuildText() {
		mParagraphs = [];

		if (!mHTMLMode) {
			var font = FontInstance.CreateSolid( mFace, mTextHeight, mTextColour, 1.0  );
			var paras = mText.split("\n");
			for(paragraph in paras)
				mParagraphs.push( { align:mAlign, spans: [ { font : font, text:paragraph+"\n" }] } );
		}
		Rebuild();
	}

	public function SetHTMLText(inHTMLText:String) {
		mParagraphs = new Paragraphs();
		mHTMLText = inHTMLText;

		if (!mHTMLMode) {
			var wrapper : HTMLCanvasElement = cast js.Lib.document.createElement("div");
			wrapper.innerHTML = inHTMLText;

			var destination = new Graphics(wrapper);

			var jeashSurface = jeashGraphics.jeashSurface;
			if (Lib.jeashIsOnStage(jeashSurface)) {
				Lib.jeashAppendSurface(wrapper);
				Lib.jeashCopyStyle(jeashSurface, wrapper);
				Lib.jeashSwapSurface(jeashSurface, wrapper);
				Lib.jeashRemoveSurface(jeashSurface);
			}

			jeashGraphics = destination;
			jeashGraphics.jeashExtent.width = wrapper.width;
			jeashGraphics.jeashExtent.height = wrapper.height;

		} else {
			jeashGraphics.jeashSurface.innerHTML = inHTMLText;
		}

		mHTMLMode = true;
		RebuildText();
		jeashInvalidateBounds();

		return mHTMLText;
	}

	public function setSelection(beginIndex : Int, endIndex : Int) {
		// TODO:
	}

	public function jeashGetDefaultTextFormat() 
		return defaultTextFormat

	function jeashSetDefaultTextFormat(inFmt:TextFormat) {
		setTextFormat(inFmt);
		return inFmt;
	}

	public function getTextFormat(?beginIndex : Int, ?endIndex : Int) : TextFormat {
		return new TextFormat();
	}

	public function setTextFormat(inFmt:TextFormat, ?beginIndex:Int, ?endIndex:Int) {
		if (inFmt.font!=null)
			mFace = inFmt.font;
		if (inFmt.size!=null)
			mTextHeight = Std.int(inFmt.size);
		if (inFmt.align!=null)
			mAlign = inFmt.align;
		if (inFmt.color!=null)
			mTextColour = inFmt.color;

		RebuildText();
		jeashInvalidateBounds();
		return getTextFormat();
	}

	override function jeashDoAdded(inObj:DisplayObject) {
		super.jeashDoAdded(inObj);
		if (inObj==this) {
			addEventListener(jeash.events.MouseEvent.MOUSE_DOWN, jeashOnMouseDown);
			stage.addEventListener(jeash.events.MouseEvent.MOUSE_UP, jeashOnMouseUp);
			addEventListener(jeash.events.MouseEvent.MOUSE_MOVE, jeashOnMouseDrag);
			addEventListener(jeash.events.MouseEvent.MOUSE_OVER, jeashOnMouseOver);
			addEventListener(jeash.events.MouseEvent.MOUSE_OUT, jeashOnMouseOut);
			addEventListener(jeash.events.KeyboardEvent.KEY_DOWN, jeashOnKey);

			jeashCaretTimer.run = jeashCaretTimerCallback;
		}
	}

	override function jeashDoRemoved(inObj:DisplayObject) {
		super.jeashDoRemoved(inObj);
		if (inObj==this) {
			removeEventListener(jeash.events.MouseEvent.MOUSE_DOWN, jeashOnMouseDown);
			stage.removeEventListener(jeash.events.MouseEvent.MOUSE_UP, jeashOnMouseUp);
			removeEventListener(jeash.events.MouseEvent.MOUSE_MOVE, jeashOnMouseDrag);
			removeEventListener(jeash.events.KeyboardEvent.KEY_DOWN, jeashOnKey);
			removeEventListener(jeash.events.MouseEvent.MOUSE_OVER, jeashOnMouseOver);
			removeEventListener(jeash.events.MouseEvent.MOUSE_OUT, jeashOnMouseOut);

			Lib.jeashRemoveSurface(mCaretGfx.jeashSurface);
			jeashCaretTimer.stop();
		}
	}

	override function jeashAddToStage() {
		Lib.jeashAppendSurface(jeashGraphics.jeashSurface);
		Lib.jeashAppendSurface(mCaretGfx.jeashSurface);
		Lib.jeashSetSurfaceVisible(mCaretGfx.jeashSurface, jeashCaretVisible);
	}

	override public function jeashGetObjectUnderPoint(point:Point):DisplayObject 
		if (!visible) return null; 
		else if (this.mText.length > 1) {
			var local = globalToLocal(point);
			if (local.x < 0 || local.y < 0 || local.x > mMaxWidth || local.y > mMaxHeight) return null; else return cast this;
		}
		else return super.jeashGetObjectUnderPoint(point)

}

import jeash.geom.Matrix;
import jeash.display.Graphics;
import jeash.display.BitmapData;

enum FontInstanceMode {
	fimSolid;
}

class FontInstance {
	static var mSolidFonts = new Hash<FontInstance>();

	var mMode : FontInstanceMode;
	var mColour : Int;
	var mAlpha : Float;
	var mFont : Font;
	var mHeight: Int;
	var mGlyphs: Array<HTMLElement>;
	var mCacheAsBitmap:Bool;
	public var mTryFreeType:Bool;

	public var height(jeashGetHeight,null):Int;

	function new(inFont:Font,inHeight:Int) {
		mFont = inFont;
		mHeight = inHeight;
		mTryFreeType = true;
		mGlyphs = [];
		mCacheAsBitmap = false;
	}

	public function toString() : String {
		return "FontInstance:" + mFont + ":" + mColour + "(" + mGlyphs.length + ")";
	}

	public function GetFace() {
		return mFont.fontName;
	}

	static public function CreateSolid(inFace:String,inHeight:Int,inColour:Int, inAlpha:Float) {
		var id = "SOLID:" + inFace+ ":" + inHeight + ":" + inColour + ":" + inAlpha;
		var f:FontInstance =  mSolidFonts.get(id);
		if (f!=null)
			return f;

		var font : Font = new Font();
		font.jeashSetScale(inHeight);
		font.fontName = inFace;

		if (font==null)
			return null;

		f = new FontInstance(font,inHeight);
		f.SetSolid(inColour,inAlpha);
		mSolidFonts.set(id,f);
		return f;
	}

	function jeashGetHeight():Int { return mHeight; }

	function SetSolid(inCol:Int, inAlpha:Float) {
		mColour = inCol;
		mAlpha = inAlpha;
		mMode = fimSolid;
	}

	public function RenderChar(inGraphics:Graphics,inGlyph:Int,inX:Int, inY:Int) {
		inGraphics.jeashClearLine();
		inGraphics.beginFill(mColour,mAlpha);
		mFont.jeashRender(inGraphics,inGlyph,inX,inY,mTryFreeType);
		inGraphics.endFill();
	}

	public function jeashGetAdvance(inChar:Int) : Int {
		if (mFont==null) return 0;
		return mFont.jeashGetAdvance(inChar, mHeight);
	}
}

