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
import flash.ui.Keyboard;
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
	public var alwaysShowSelection : Bool;
	public var antiAliasType : String;
	public var mouseWheelEnabled : Bool;
	public var scrollH : Int;
	public var scrollV : Int;
	public var maxScrollH : Int;
	public var maxScrollV : Int;
	public var sharpness : Float;
	public var gridFitType : String;
	public var length(default,null) : Int;
	public var numLines(GetNumLines,null) : Int;

	public var defaultTextFormat (default,SetDefaultTextFormat): TextFormat;
	var mTextFormat : TextFormat;

	public var selectionBeginIndex : Int;
	public var selectionEndIndex : Int;
	public var selectedText(GetSelectedText,null) : String;
	public var caretIndex : Int;
	//public var mParagraphs:Paragraphs;

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

	var mGraphics:Graphics;
	var mSurface(default,null):HTMLCanvasElement;

	public var mTryFreeType:Bool;
	public var mDownChar:Int;

	public function new()
	{
		super();
		mChanged = true;
		mSurface = cast js.Lib.document.createElement("canvas");

		mHTMLMode = false;
		multiline = false;

		mSelStart = -1;
		mSelEnd = -1;
		scrollH = 0;
		scrollV = 1;
		maxScrollH = 0;
		maxScrollV = 1;

		mType = flash.text.TextFieldType.DYNAMIC;
		autoSize = flash.text.TextFieldAutoSize.NONE;
		mouseWheelEnabled = true;
		alwaysShowSelection = false;

		defaultTextFormat = new TextFormat( mDefaultFont, 12, 0x000000, false, false, false, null, null, flash.text.TextFormatAlign.LEFT );
		mHTMLText = " ";
		mText = " ";
		tabEnabled = false;
		selectable = true;
		mInsertPos = 0;
		mInput = false;
		mDownChar = 0;
		mSelectDrag = -1;

		//mTextFormat = defaultTextFormat;

		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;
	}

	public function replaceSelectedText( value:String )
	{
		mHTMLText = mHTMLText.substr( 0, selectionBeginIndex - 1 ) + value + mHTMLText.substr( selectionEndIndex );
	}

	public function replaceText( beginIndex:Int, endIndex:Int, newText:String )
	{
		mHTMLText = mHTMLText.substr( 0, beginIndex - 1 ) + newText + mHTMLText.substr( endIndex );
	}

	public function getCharIndexAtPoint(x:Float, y:Float):Int
	{
		throw "TextField.getCharIndexAtPoint not implemented in Jeash";
		return 0;
	}
	
	public function getLineIndexAtPoint(x:Float, y:Float):Int
	{
		var textFormat = EvaluateTextFormat( mTextFormat, defaultTextFormat );
		var size = textFormat.size;
		if ( border == false )
			return Math.floor( y / (1. + size) );
		else 
			return Math.floor( y / (11. + size) );
	}

	public function getLineIndexOfChar(charIndex:Int):Int
	{
		throw "TextField.getLineIndexOfChar not implemented in Jeash";
		return 0;
	}

	public function getCharBoundaries( a:Int ) : Rectangle {
		// TODO
		return null;
	}

	public function setSelection(beginIndex : Int, endIndex : Int)
	{
		throw "TextField.setSelection not implemented in Jeash";
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

	function GetNumLines()
	{
		throw "Textfield.numLines is not implemented in Jeash";
		return 0;
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

	function GetType() { return mType; }
	function SetType(inType:String) : String
	{
		mChanged = true;
		mType = inType;

		mInput = mType == TextFieldType.INPUT;
		if (mInput && mHTMLMode)
			ConvertHTMLToText(true);

		tabEnabled = type == TextFieldType.INPUT;
		return inType;
	}

	function GetSelectedText()
	{
		return mHTMLText.substr( selectionBeginIndex, selectionEndIndex );
	}

	private function CheckChanged() : Bool
	{
		var result = mChanged;
		mChanged = false;
		return result;
	}

	function EvaluateTextFormat( tf:TextFormat, dtf:TextFormat )
	{
		if ( tf == null ) return dtf;
		if ( tf.size == null ) tf.size = dtf.size;
		if ( tf.font == null ) tf.font = dtf.font;
		if ( tf.bold == null ) tf.bold = dtf.bold;
		if ( tf.align == null ) tf.align = dtf.align;
		if ( tf.color == null ) tf.color = dtf.color;
		if ( tf.underline == null ) tf.underline = dtf.underline;
		return tf;
	}

	override public function __Render(inParentMask:HTMLCanvasElement,inScrollRect:Rectangle,inTX:Int,inTY:Int)
	{
		//mGraphics.clear();

		if (CheckChanged()) {
			var ctxt = mSurface.getContext("2d");

			ctxt.save();

			ctxt.setTransform(mFullMatrix.a, mFullMatrix.b, mFullMatrix.c, mFullMatrix.d, mFullMatrix.tx, mFullMatrix.ty);

			var textFormat = EvaluateTextFormat( mTextFormat, defaultTextFormat );
			var size = textFormat.size;
			var font = textFormat.font;
			var bold = textFormat.bold == false ? 400 : 700;
			var align = textFormat.align;
			var color = textFormat.color;

			// smaller flash fonts seem to be bolder than in HTML
			if ( size < 18 ) bold += 300;

			var posX = null, posY = null;
			if ( border == false )
			{
				posX = 2.;
				posY = 1. + size;
			} else {
				posX = 12.;
				posY = 11. + size;
			}

			ctxt.font = bold + " " + size + "px " + font;

			if ( mAlign != null )
				ctxt.textAlign = mAlign;

			ctxt.fillStyle = '#' + StringTools.hex(color);
			var pos = 0;
			while (pos < mHTMLText.length - 1)
			{
				var index = mHTMLText.indexOf(" ", pos);
				var c = (index < 0 ) ? mHTMLText.substr(pos) : mHTMLText.substr(pos, index - pos) + " ";
				pos += c.length;
				var estX = ctxt.measureText(c).width;
				if ( wordWrap && posX + estX > mWidth )
				{
					if ( posY + 12 + size > mHeight ) break;
					posX = border ? 12 : 2;
					if ( wordWrap )
						posY += 8 + size;
				}

				ctxt.fillText(c, posX, posY);
				posX += estX;

			}
			
			ctxt.restore();
			ctxt.save();

			if ( border )
			{
				ctxt.beginPath();
				ctxt.strokeStyle = '#' + StringTools.hex(color);
				ctxt.strokeRect(10, 10, mWidth+2, mHeight+2 );
			}

			ctxt.restore();

		}

		// merge into parent canvas context
		if (inParentMask != null)
		{
			var maskCtx = inParentMask.getContext('2d');
			untyped console.log(inTX, inTY);
			maskCtx.drawImage(mSurface, inTX, inTY);
		}

	}

	function SetDefaultTextFormat( tf:TextFormat )
	{
		this.defaultTextFormat = EvaluateTextFormat( tf, this.defaultTextFormat );
		return this.defaultTextFormat;
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

}

