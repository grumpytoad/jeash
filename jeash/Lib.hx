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

import Html5Dom;
import jeash.display.Stage;
import jeash.display.MovieClip;
import jeash.display.Graphics;
import jeash.events.Event;
import jeash.events.MouseEvent;
import jeash.events.KeyboardEvent;
import jeash.events.EventPhase;
import jeash.display.DisplayObjectContainer;
import jeash.display.DisplayObject;
import jeash.display.InteractiveObject;
import jeash.text.TextField;
import jeash.geom.Rectangle;
import jeash.geom.Matrix;
import jeash.geom.Point;
import jeash.net.URLRequest;

class Lib {
	var mKilled:Bool;
	static var mMe:Lib;
	static inline var DEFAULT_PRIORITY = ["2d", "swf"];
	public static var context(default,null):String;
	public static var current(jeashGetCurrent,null):MovieClip;
	public static var glContext(default,null):WebGLRenderingContext;
	public static var canvas(jeashGetCanvas,null):HTMLCanvasElement;
	static var mShowCursor = true;
	static var mShowFPS = false;

	var mRequestedWidth:Int;
	var mRequestedHeight:Int;
	var mResizePending:Bool;
	static var mFullscreen:Bool= false;
	public static var mCollectEveryFrame:Bool = false;

	public static var mQuitOnEscape:Bool = true;
	static var mStage:jeash.display.Stage;
	static var mMainClassRoot:jeash.display.MovieClip;
	static var mCurrent:jeash.display.MovieClip;
	static var mRolling:InteractiveObject;
	static var mDownObj:InteractiveObject;
	static var mMouseX:Int;
	static var mMouseY:Int;

	public static var mLastMouse:jeash.geom.Point = new jeash.geom.Point();

	var __scr : HTMLDivElement;
	var mArgs:Array<String>;

	static inline var VENDOR_HTML_TAG = "data-";
	static inline var HTML_DIV_EVENT_TYPES = [ 'resize', 'mouseup', 'mouseover', 'mouseout', 'mousemove', 'mousedown', 'mousewheel', 'dblclick', 'click' ];
	static inline var HTML_WINDOW_EVENT_TYPES = [ 'keyup', 'keypress', 'keydown', 'resize' ];
	static inline var HTML_TOUCH_EVENT_TYPES = [ 'touchstart', 'touchmove', 'touchend' ]; 

	static inline var JEASH_IDENTIFIER = 'haxe:jeash';
	static inline var DEFAULT_WIDTH = 500;
	static inline var DEFAULT_HEIGHT = 500;

	var jeashTraceTextField:jeash.text.TextField;

	function new(title:String, width:Int, height:Int)
	{
		mKilled = false;
		mRequestedWidth = width;
		mRequestedHeight = height;
		mResizePending = false;

		// ... this should go in Stage.hx
		__scr = cast js.Lib.document.getElementById(title);
		if ( __scr == null ) throw "Element with id '" + title + "' not found";
		__scr.style.setProperty("overflow", "hidden", "");
		__scr.style.setProperty("position", "absolute", ""); // necessary for chrome ctx.isPointInPath
		__scr.appendChild( Lib.canvas );

	}

	static public function trace( arg:Dynamic ) {
		untyped {
#if debug
			if (mMe.jeashTraceTextField != null)
				mMe.jeashTraceTextField.text += arg + "\n";
			else if (window.console != null)
				window.console.log(arg);
#else
			if (window.console != null)
				window.console.log(arg);
			else if (mMe.jeashTraceTextField != null)
				mMe.jeashTraceTextField.text += arg + "\n";
#end
		}
	}

	static public function getURL( request:URLRequest, ?target:String )
	{
		var document : HTMLDocument = cast js.Lib.document;
		var window : Window = cast js.Lib.window;
		if (target == null || target == "_self")
		{
			document.open(request.url);
		} else {
			switch (target)
			{
				case "_blank": window.open(request.url);
				case "_parent": window.parent.open(request.url);
				case "_top": window.top.open(request.url);
			}
		}
	}

	static function jeashGetCanvas() : HTMLCanvasElement
	{
		untyped
		{
			if ( Lib.canvas == null )
			{
				if ( document == null ) throw "Document not loaded yet, cannot create root canvas!";
				Lib.canvas = document.createElement("canvas");
				Lib.canvas.id = "Root Surface";
				Lib.context = "2d";

				jeashBootstrap();

				starttime = haxe.Timer.stamp();

			}
			return Lib.canvas;
		}
	}

	static public function jeashGetCurrent() : MovieClip
	{
		Lib.canvas;
		if ( mMainClassRoot == null )
		{
			mMainClassRoot = new MovieClip();
			mCurrent = mMainClassRoot;
			mCurrent.name = "Root MovieClip";

		}
		return mMainClassRoot;
	}

	public static function as<T>( v : Dynamic, c : Class<T> ) : Null<T>
	{
		return Std.is(v,c) ? v : null;
	}

	static var starttime : Float;
	public static function getTimer() : Int { 
		return Std.int((haxe.Timer.stamp() - starttime )*1000); 
	}

	public static function jeashGetStage() { 
		Lib.canvas;
		if ( mStage == null )
		{
			var width = jeashGetWidth();
			var height = jeashGetHeight();
			mStage = new jeash.display.Stage(width, height);

			mStage.addChild(jeashGetCurrent());
		}

		return mStage; 
	}

	public static function jeashAppendSurface(surface:HTMLElement, ?before:HTMLElement) {
		if (mMe.__scr != null) {
			surface.style.setProperty("position", "absolute", "");
			surface.style.setProperty("left", "0px", "");
			surface.style.setProperty("top", "0px", "");

			surface.style.setProperty("-moz-transform-origin", "0 0", "");
			surface.style.setProperty("-webkit-transform-origin", "0 0", "");
			surface.style.setProperty("-o-transform-origin", "0 0", "");
			surface.style.setProperty("-ms-transform-origin", "0 0", "");

			// disable blue selection rectangle 
			untyped {
				try {
					surface.onmouseover = surface.onselectstart = function () { return false; }
				} catch (e:Dynamic) {}
			}

			if (before != null)
				mMe.__scr.insertBefore(surface, before);
			else
				mMe.__scr.appendChild(surface);
		}
	}

	public static function jeashSwapSurface(surface1:HTMLElement, surface2:HTMLElement) {
		var c1 : Int = -1;
		var c2 : Int = -1;
		var swap : Node;
		for ( i in 0...mMe.__scr.childNodes.length )
			if ( mMe.__scr.childNodes[i] == surface1 ) c1 = i;
			else if  ( mMe.__scr.childNodes[i] == surface2 ) c2 = i;

		if ( c1 != -1 && c2 != -1 )
		{
			swap = jeashRemoveSurface(cast mMe.__scr.childNodes[c1]);
			if (c2>c1) c2--;
			if (c2 < mMe.__scr.childNodes.length-1)
			{
				mMe.__scr.insertBefore(swap, mMe.__scr.childNodes[c2++]);
			} else {
				mMe.__scr.appendChild(swap);
			}

			swap = jeashRemoveSurface(cast mMe.__scr.childNodes[c2]);
			if (c1>c2) c1--;
			if (c1 < mMe.__scr.childNodes.length-1)
			{
				mMe.__scr.insertBefore(swap, mMe.__scr.childNodes[c1++]);
			} else {
				mMe.__scr.appendChild(swap);
			}
		}
	}

	public static function jeashIsOnStage(surface:HTMLElement) {
		for ( i in 0...mMe.__scr.childNodes.length )
			if ( mMe.__scr.childNodes[i] == surface ) {
				return true;
			}

		return false;
	}

	public static function jeashRemoveSurface(surface:HTMLElement) {
		if (mMe.__scr != null) {
			var anim = surface.getAttribute("data-jeash-anim");
			if (anim != null) {
			       var style = js.Lib.document.getElementById(anim);
			       if (style != null) mMe.__scr.removeChild(cast style);
			}
			mMe.__scr.removeChild(surface);
		}
		return surface;
	}

	public static function jeashSetSurfaceTransform(surface:HTMLElement, matrix:Matrix) {
		if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) {
			surface.style.left = matrix.tx + "px";
			surface.style.top = matrix.ty + "px";
		} else {
			surface.style.setProperty("-moz-transform", matrix.toMozString(), "");
			surface.style.setProperty("-webkit-transform", matrix.toString(), "");
			surface.style.setProperty("-o-transform", matrix.toString(), "");
			surface.style.setProperty("-ms-transform", matrix.toString(), "");
		}
	}

	public static function jeashSetSurfaceOpacity(surface:HTMLElement, alpha:Float) {
		surface.style.setProperty("opacity", Std.string(alpha), "" );
	}

	public static function jeashSetSurfaceFont(surface:HTMLElement, font:String, bold:Int, size:Float, color:Int, align:String, lineHeight:Int) {
		surface.style.setProperty("font-family", font, "");
		surface.style.setProperty("font-weight", Std.string(bold) , "");
		surface.style.setProperty("color", '#' + StringTools.hex(color) , "");
		surface.style.setProperty("font-size", size + 'px', "");
		surface.style.setProperty("text-align", align, "");
		surface.style.setProperty("line-height", lineHeight + 'px', "");
	}

	public static function jeashSetSurfaceBorder(surface:HTMLElement, color:Int, size:Int) {
		surface.style.setProperty("border-color", '#' + StringTools.hex(color) , "");
		surface.style.setProperty("border-style", 'solid' , "");
		surface.style.setProperty("border-width", size + 'px', "");
		surface.style.setProperty("border-collapse", "collapse", "");
	}

	public static function jeashSetSurfacePadding(surface:HTMLElement, padding:Float, margin:Float, display:Bool)
	{
		surface.style.setProperty("padding", padding + 'px', "");
		surface.style.setProperty("margin", margin + 'px' , "");
		surface.style.setProperty("top", (padding+2) + "px", "");
		surface.style.setProperty("right", (padding+1) + "px", "");
		surface.style.setProperty("left", (padding+1) + "px", "");
		surface.style.setProperty("bottom", (padding+1) + "px", "");
		surface.style.setProperty("display", (display ? "inline" : "block") , "");
	}

	public static function jeashAppendText(surface:HTMLElement, container:HTMLElement, text:String, wrap:Bool, isHtml:Bool)
	{
		for ( i in 0...surface.childNodes.length )
			surface.removeChild(surface.childNodes[i]);

		if (isHtml)
			container.innerHTML = text;
		else
			container.appendChild(cast js.Lib.document.createTextNode(text));

		container.style.setProperty("position", "relative", "");
		container.style.setProperty("cursor", "default", "");
		if (!wrap) container.style.setProperty("white-space", "nowrap", "");

		surface.appendChild(cast container);
	}

	public static function jeashSetTextDimensions(surface:HTMLElement, width:Float, height:Float, align:String)
	{
		surface.style.setProperty("width", width + "px", "");
		surface.style.setProperty("height", height + "px", "");
		surface.style.setProperty("overflow", "hidden", "");
		surface.style.setProperty("text-align", align, "");
	}

	public static function jeashSetSurfaceAlign(surface:HTMLElement, align:String)
	{
		surface.style.setProperty("text-align", align, "");
	}

	public static function jeashSetContentEditable(surface:HTMLElement, contentEditable:Bool = true) {
		surface.setAttribute("contentEditable", contentEditable ? "true" : "false");
	}

	public static function jeashDesignMode(mode:Bool) {
		var document:HTMLDocument = cast js.Lib.document;
		document.designMode = mode ? 'on' : 'off';
	}

	public static function jeashSurfaceHitTest(surface:HTMLElement, x:Float, y:Float)
	{
		for ( i in 0...surface.childNodes.length )
		{
			var node : HTMLElement = cast surface.childNodes[i];
			if ( x >= node.offsetLeft && x <= (node.offsetLeft + node.offsetWidth) && y >= node.offsetTop && y <= (node.offsetTop + node.offsetHeight) ) return true;
		}
		return false;
	}

	public static function jeashCopyStyle(src:HTMLElement, tgt:HTMLElement) 
	{
		tgt.id = src.id;
		for (prop in ["left", "top", "-moz-transform", "-moz-transform-origin", "-webkit-transform", "-webkit-transform-origin", "-o-transform", "-o-transform-origin", "opacity", "display"])
			tgt.style.setProperty(prop, src.style.getPropertyValue(prop), "");
		
	}

	public static function jeashDrawToSurface(surface:HTMLCanvasElement, tgt:HTMLCanvasElement, matrix:Matrix = null, alpha:Float = 1.0) {
		var srcCtx = surface.getContext("2d");
		var tgtCtx = tgt.getContext("2d");

		if (alpha != 1.0)
			tgtCtx.globalAlpha = alpha;

		if (surface.width > 0 && surface.height > 0)
			if (matrix != null) {
				tgtCtx.save();
				if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) 
					tgtCtx.translate(matrix.tx, matrix.ty);
				else 
					tgtCtx.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
				tgtCtx.drawImage(surface, 0, 0);
				tgtCtx.restore();
			} else
				tgtCtx.drawImage(surface, 0, 0);
	}

	public static function jeashDisableRightClick() {
		if (mMe != null)
			untyped {
				try {
					mMe.__scr.oncontextmenu = function () { return false; }
				} catch (e:Dynamic) {
					jeash.Lib.trace("Disable right click not supported in this browser.");
				}
			}
	}

	public static function jeashEnableRightClick()
	{
		if (mMe != null)
			untyped {
				try {
					mMe.__scr.oncontextmenu = null;
				} catch (e:Dynamic) {}
			}
	}

	public static function jeashEnableFullScreen()
	{
		if (mMe != null)
		{
			var origWidth = mMe.__scr.style.getPropertyValue("width");
			var origHeight = mMe.__scr.style.getPropertyValue("height");
			mMe.__scr.style.setProperty("width", "100%", "");
			mMe.__scr.style.setProperty("height", "100%", "");
			Lib.jeashDisableFullScreen = function () {
				mMe.__scr.style.setProperty("width", origWidth, "");
				mMe.__scr.style.setProperty("height", origHeight, "");
			}
		}
	}

	public dynamic static function jeashDisableFullScreen() {}
	public inline static function jeashFullScreenWidth() 
	{ 
		var window : Window = cast js.Lib.window;
		return window.innerWidth; 
	}
	public inline static function jeashFullScreenHeight() { 
		var window : Window = cast js.Lib.window;
		return window.innerHeight; 
	}

	public static function jeashSetCursor(type:CursorType) {
		if (mMe != null) 
			mMe.__scr.style.cursor = switch (type) {
				case Pointer: "pointer";
				case Text: "text";
				default: "default";
			}
	}

	public inline static function jeashSetSurfaceVisible(surface:HTMLElement, visible:Bool) {
		if (visible) 
			surface.style.setProperty("display", "block", "");
		else
			surface.style.setProperty("display", "none", "");
	}

	public inline static function jeashSetSurfaceId(surface:HTMLElement, name:String) { surface.id = name; }

	public inline static function jeashDrawSurfaceRect(surface:HTMLElement, tgt:HTMLCanvasElement, x:Float, y:Float, rect:Rectangle) {
		var tgtCtx = tgt.getContext('2d');
		tgt.width = cast rect.width;
		tgt.height = cast rect.height;
		tgtCtx.drawImage(surface, rect.x, rect.y, rect.width, rect.height, 0, 0, rect.width, rect.height);
		tgt.style.left = (x) + "px";
		tgt.style.top = (y) + "px";
	}

	public inline static function jeashSetSurfaceScale(surface:HTMLElement, scale:Float) {
		surface.style.setProperty("-moz-transform", "scale(" + scale + ")", "");
		surface.style.setProperty("-webkit-transform", "scale(" + scale + ")", "");
		surface.style.setProperty("-o-transform", "scale(" + scale + ")", "");
		surface.style.setProperty("-ms-transform", "scale(" + scale + ")", "");
	}

	public inline static function jeashSetSurfaceRotation(surface:HTMLElement, rotate:Float) {
		surface.style.setProperty("-moz-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty("-webkit-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty("-o-transform", "rotate(" + rotate + "deg)", "");
		surface.style.setProperty("-ms-transform", "rotate(" + rotate + "deg)", "");
	}

	public static function jeashSetSurfaceAnimation(surface:HTMLCanvasElement, spec:Array<AnimationFrame>, id:String) {
		if (spec.length == 0 || id.length == 0 || !jeashIsOnStage(surface)) return;
		var document:HTMLDocument = cast js.Lib.document;
		var div:HTMLDivElement = cast document.createElement("div");

		// TODO: sanitize id

		// TODO: to be revisited... (see webkit-canvas and -moz-element)
		div.style.backgroundImage = "url(" + surface.toDataURL("image/png", {}) + ")";

		var style: Dynamic = cast mMe.__scr.appendChild(document.createElement("style"));
		style.sheet.id = "__jeash_anim_" + id + "__";

		// clean-up reference
		div.setAttribute("data-jeash-anim", style.sheet.id);

		var keyframeStylesheetRule = "";
		var keyframeTpl = new haxe.Template("::perc::% { -moz-transform: ::matrixMoz::; -webkit-transform: ::matrixReg::; -o-transform: ::matrixReg::; -ms-transform: ::matrixReg::; background-position: ::left::px ::top::px; width: ::width::px; height: ::height::px; opacity: ::alpha::; } ");

		for (i in 0...spec.length) {
			var perc = i/(spec.length) * 100;
			var frame = spec[i];
			keyframeStylesheetRule += keyframeTpl.execute({
				perc: perc,
				matrixMoz: frame.matrix.toMozString(),
				matrixReg: frame.matrix.toString(),
				left: - frame.clip.x,
				top: - frame.clip.y,
				width: frame.clip.width,
				height: frame.clip.height,
				alpha: frame.opacity
			});
		}

		var animationTpl = new haxe.Template("#::id:: { -webkit-animation: ::id:: ::duration::s steps(::steps::, end) infinite; }");
		var animationStylesheetRule = animationTpl.execute({
			id: id,
			duration: spec.length/Lib.current.stage.frameRate,
			steps: 1
		});
			
		style.sheet.insertRule("@-webkit-keyframes " + id + " {" + keyframeStylesheetRule + "}", 0);
		style.sheet.insertRule(animationStylesheetRule, 1);

		Lib.jeashAppendSurface(div);
		Lib.jeashCopyStyle(surface, div);
		Lib.jeashSwapSurface(surface, div);
		Lib.jeashRemoveSurface(surface);
	}

	static function Run( tgt:HTMLDivElement, width:Int, height:Int ) 
	{
			mMe = new Lib( tgt.id, width, height );

			Lib.canvas.width = width;
			Lib.canvas.height = height;

			if ( !StringTools.startsWith(Lib.context, "swf") )
			{
				for ( i in 0...tgt.attributes.length)
				{
					var attr : Attr = cast tgt.attributes.item(i);
					if (StringTools.startsWith(attr.name, VENDOR_HTML_TAG))
					{
						switch (attr.name)
						{
							case VENDOR_HTML_TAG + 'framerate':
								jeashGetStage().frameRate = Std.parseFloat(attr.value);
							default:
						}
					}
				}

				for (type in HTML_TOUCH_EVENT_TYPES) {
					tgt.addEventListener(type, jeashGetStage().jeashProcessStageEvent, true);
				}

				for (type in HTML_DIV_EVENT_TYPES) 
					tgt.addEventListener(type, jeashGetStage().jeashProcessStageEvent, true);


				for (type in HTML_WINDOW_EVENT_TYPES) 

				{
					var window : Window = cast js.Lib.window;
					window.addEventListener(type, jeashGetStage().jeashProcessStageEvent, false);
				}

				jeashGetStage().backgroundColor = if (tgt.style.backgroundColor != null && tgt.style.backgroundColor != "")
					jeashParseColor( tgt.style.backgroundColor, function (res, pos, cur) { 
							return switch (pos) {
							case 0: res | (cur << 16);
							case 1: res | (cur << 8);
							case 2: res | (cur);
							}
							}); else 0xFFFFFF;

				// This ensures that a canvas hitTest hits the root movieclip
				Lib.current.graphics.beginFill(jeashGetStage().backgroundColor);
				Lib.current.graphics.drawRect(0, 0, width, height);
				Lib.current.graphics.jeashSurface.id = "Root MovieClip";

				mMe.jeashTraceTextField = new TextField();
				mMe.jeashTraceTextField.width = jeashGetStage().stageWidth;
				mMe.jeashTraceTextField.wordWrap = true;
				Lib.current.addChild(mMe.jeashTraceTextField);

				jeashGetStage().jeashUpdateNextWake();
			}

			return mMe;
	}

	static function jeashParseColor( str:String, cb: Int -> Int -> Int -> Int) {
		var re = ~/rgb\(([0-9]*), ?([0-9]*), ?([0-9]*)\)/;
		var hex = ~/#([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])([0-9a-zA-Z][0-9a-zA-Z])/;
		if ( re.match(str) )
		{
			var col = 0;
			for ( pos in 1...4 )
			{
				var v = Std.parseInt(re.matched(pos));
				col = cb(col,pos-1,v);
			}
			return col;
		} else if ( hex.match(str) ) {
			var col = 0;
			for ( pos in 1...4 )
			{
				var v : Int = untyped ("0x" + hex.matched(pos)) & 0xFF;
				v = cb(col,pos-1,v);
			}
			return col;
		} else {
			throw "Cannot parse color '" + str + "'.";
		}
	}

	static public function jeashGetWidth() {
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		return tgt.clientWidth > 0 ? tgt.clientWidth : Lib.DEFAULT_WIDTH;
	}

	static public function jeashGetHeight() {
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		return tgt.clientHeight > 0 ? tgt.clientHeight : Lib.DEFAULT_HEIGHT;
	}

	static function jeashBootstrap() {
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		var lib = Run(tgt, jeashGetWidth(), jeashGetHeight());
		return lib;
	}

}

typedef AnimationFrame = {
	matrix: Matrix,
	opacity: Float,
	clip: Rectangle
}

private enum CursorType {
	Pointer;
	Text;
	Default;
}
