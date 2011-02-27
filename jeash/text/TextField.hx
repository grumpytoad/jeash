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
	public var antiAliasType : AntiAliasType;
	public var mouseWheelEnabled : Bool;
	public var scrollH : Int;
	public var scrollV : Int;
	public var maxScrollH : Int;
	public var maxScrollV : Int;
	public var sharpness : Float;
	public var gridFitType : String;
	public var length(default,null) : Int;
	public var numLines(GetNumLines, null) : Int;
	
	public var condenseWhite:Bool;

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

	var jeashGraphics:Graphics;
	var mSurface(default,null):HTMLCanvasElement;

	public var mTryFreeType:Bool;
	public var mDownChar:Int;

	var jeashChanged:Bool;

	public function new()
	{
		super();
		mSurface = cast js.Lib.document.createElement("div");
		Lib.jeashSetSurfacePadding(mSurface, 0, 0, true);
		jeashGraphics = new Graphics( mSurface );

		mHTMLMode = false;
		multiline = false;

		mSelStart = -1;
		mSelEnd = -1;
		scrollH = 0;
		scrollV = 1;
		maxScrollH = 0;
		maxScrollV = 1;

		mWidth = 100;
		mHeight = 100;

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

		jeashChanged = true;
	}

	public function replaceSelectedText( value:String )
	{
		mHTMLText = mHTMLText.substr( 0, selectionBeginIndex - 1 ) + value + mHTMLText.substr( selectionEndIndex );
		jeashChanged = true;
	}

	public function replaceText( beginIndex:Int, endIndex:Int, newText:String )
	{
		mHTMLText = mHTMLText.substr( 0, beginIndex - 1 ) + newText + mHTMLText.substr( endIndex );
		jeashChanged = true;
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
		mTextFormat = inFmt;
	}

	function GetNumLines()
	{
		throw "Textfield.numLines is not implemented in Jeash";
		return 0;
	}

	override public function jeashUpdateMatrix(parentMatrix:Matrix)
	{
		var h = mSurface.clientHeight;

		if (this.height == null) this.height = h;

		var w = mSurface.clientWidth;

		if (this.width == null) this.width = w;

		// TODO: scaleX / scaleY

		if (wordWrap)
			mMatrix = new Matrix(1.0, 0.0, 0.0, 1.0);
		else
			mMatrix = new Matrix(this.scaleX, 0.0, 0.0, this.scaleY);

		var rad = this.rotation * Math.PI / 180.0;
		if (rad != 0.0)
			mMatrix.rotate(rad);

		mMatrix.tx = this.x;
		mMatrix.ty = this.y;

		mFullMatrix = mMatrix.mult(parentMatrix);

	}

	function GetType() { return mType; }
	function SetType(inType:String) : String
	{
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

	override public function jeashRender(parentMatrix:Matrix, ?mask:HTMLCanvasElement)
	{

		if (jeashChanged)
		{

			var textFormat = EvaluateTextFormat( mTextFormat, defaultTextFormat );
			var size = textFormat.size;
			var lineHeight = Std.int(size) + 1;
			flash.Lib.trace(size);
			var font = textFormat.font;
			var bold = textFormat.bold == false ? 400 : 700;
			var align = textFormat.align;
			var color = textFormat.color;

			var posX = null, posY = null;
			if ( border == false )
			{
				posX = 2.;
				posY = 1. + size;
			} else {
				posX = 12.;
				posY = 11. + size;
			}

			var span : HTMLElement = cast js.Lib.document.createElement("span");
			Lib.jeashSetSurfaceFont(span, font, bold, size, color, mAlign, lineHeight);
			Lib.jeashAppendText(mSurface, span, mHTMLText);

			Lib.jeashSetSurfacePadding(span, 0, 0, true);

			if ( border )
				// prevent applying border on multiline inline HTML elements.
				if ( wordWrap )
					Lib.jeashSetSurfaceBorder(mSurface, color, 1);
				else
					Lib.jeashSetSurfaceBorder(span, color, 1);

			Lib.jeashSetTextDimensions(mSurface, width, height, autoSize.toLowerCase());

			jeashChanged = false;
		} 

		jeashUpdateMatrix(parentMatrix);
		var m = mFullMatrix.clone();

		if (mask != null)
		{
			throw "Cannot render DIV to surface";
		} else {
			Lib.jeashSetSurfaceTransform(mSurface, m);
			Lib.jeashSetSurfaceOpacity(mSurface, parent.alpha * alpha);
		}
	}

	function SetDefaultTextFormat( tf:TextFormat )
	{
		this.defaultTextFormat = EvaluateTextFormat( tf, this.defaultTextFormat );
		jeashChanged = true;
		return this.defaultTextFormat;
	}

	public function GetTextColour() { return mTextFormat.color; }
	public function SetTextColour(inCol)
	{
		mTextFormat.color = inCol;
		jeashChanged = true;
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
		jeashChanged = true;
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
		autoSize = inAutoSize;
		return inAutoSize;
	}

	public function SetWordWrap(inWordWrap:Bool) : Bool
	{
		wordWrap = inWordWrap;
		return wordWrap;
	}

	public function SetBorder(inBorder:Bool) : Bool
	{
		border = inBorder;
		return inBorder;
	}

	public function SetBorderColor(inBorderCol:Int) : Int
	{
		borderColor = inBorderCol;
		return inBorderCol;
	}

	public function SetBackgroundColor(inCol:Int) : Int
	{
		backgroundColor = inCol;
		return inCol;
	}

	public function SetBackground(inBack:Bool) : Bool
	{
		background = inBack;
		return inBack;
	}


	public function GetHTMLText() { return mHTMLText; }

	public function SetHTMLText(inHTMLText:String)
	{
		//mParagraphs = new Paragraphs();
		mHTMLText = inHTMLText;
		mHTMLMode = true;
		if (mInput)
			ConvertHTMLToText(true);
		jeashChanged = true;
		return mHTMLText;
	}

	override function jeashGetGraphics() : flash.display.Graphics
	{ return jeashGraphics; }

}

