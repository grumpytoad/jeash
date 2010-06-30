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

import Html5Dom;

import flash.Manager;

class TextField extends flash.display.InteractiveObject
{
	public var htmlText(GetHTMLText,SetHTMLText):String;
	public var text(GetText,SetText):String;
	public var textColor(GetTextColour,SetTextColour):Int;
	public static var mDefaultFont = "Times";

	private var mHTMLText:String;
	private var mText:String;
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
	public var mDownChar:Int;

	public var defaultTextFormat : TextFormat;
	var mTextFormat : TextFormat;

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
	var mUnderline:Bool;

	var mWidth:Float;
	var mHeight:Float;

	var mSelectionAnchored:Bool;
	var mSelectionAnchor:Int;

	var mScrollH:Int;
	var mScrollV:Int;

	var mGraphics:Graphics;
	public var mSurface(default,null):HtmlCanvasElement;

	public function new()
	{
		super();
		mChanged = true;
		mSurface = cast js.Lib.document.createElement("canvas");

		mHTMLMode = false;
		multiline = false;

		mSelStart = -1;
		mSelEnd = -1;
		mScrollH = 0;
		mScrollV = 1;

		mType = flash.text.TextFieldType.DYNAMIC;
		autoSize = flash.text.TextFieldAutoSize.NONE;

		defaultTextFormat = new TextFormat( mDefaultFont, 12, 0x000000, false, false, false, null, null, flash.text.TextFormatAlign.LEFT );
		mHTMLText = " ";
		mText = " ";
		tabEnabled = false;
		selectable = true;
		mInsertPos = 0;
		mInput = false;
		mDownChar = 0;
		mSelectDrag = -1;


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

	override public function __Render(inParentMask:HtmlCanvasElement,inScrollRect:Rectangle,inTX:Int,inTY:Int):HtmlCanvasElement
	{
		//mGraphics.clear();

		if (CheckChanged()) {
			var ctxt = mSurface.getContext("2d");

			ctxt.save();

			untyped console.log( mTextFormat );
			var textFormat = mTextFormat != null ? mTextFormat : defaultTextFormat;
			var size = textFormat.size;
			var font = textFormat.font;
			var bold = textFormat.bold == false ? 100 : 400;
			var align = textFormat.align;
			var color = textFormat.color;

			untyped console.log( defaultTextFormat.color );

			ctxt.font = bold + " " + size + "px " + font;
			ctxt.textAlign = mAlign;
			//ctxt.textBaseline = "baseline";
			ctxt.fillStyle = '#' + StringTools.hex(color);
			ctxt.fillText(mHTMLText, 2, 1 + size);
			if ( textFormat.underline )
			{
				//ctxt.beginPath();
				//ctxt.moveTo(
			}
			
			ctxt.restore();

		}

		// merge into parent canvas context
		if (inParentMask != null)
		{
			var maskCtx = inParentMask.getContext('2d');
			maskCtx.drawImage(mSurface, inTX, inTY);
		}

		return mSurface;

	}

	public function GetTextColour() { return mTextFormat.color; }
	public function SetTextColour(inCol)
	{
		mTextFormat.color = inCol;
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
		return mTextFormat;
	}

	public function setTextFormat(inFmt:TextFormat, ?beginIndex:Int, ?endIndex:Int)
	{
		mChanged = true;
		mTextFormat = inFmt;
	}

}

