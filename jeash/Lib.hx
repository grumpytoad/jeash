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
import flash.display.Stage;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.EventPhase;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.geom.Rectangle;

import flash.geom.Point;

import flash.display.Graphics;

/**
 * @author	Hugh Sanderson
 * @author	Lee Sylvester
 * @author	Niel Drummond
 * @author	Russell Weir
 *
 */
class Lib
{
	var mKilled:Bool;
	static var mMe:Lib;
	static var mPriority = ["2d", "swf"];
	public static var context(default,null):String;
	public static var current(jeashGetCurrent,null):MovieClip;
	public static var glContext(default,null):WebGLRenderingContext;
	public static var debug = false;
	public static var canvas(jeashGetCanvas,null):HTMLCanvasElement;
	static var mShowCursor = true;
	static var mShowFPS = false;

	static public var mOpenGL:Bool = false;
	var mRequestedWidth:Int;
	var mRequestedHeight:Int;
	var mResizePending:Bool;
	static var mFullscreen:Bool= false;
	public static var mCollectEveryFrame:Bool = false;

	public static var mQuitOnEscape:Bool = true;
	static var mStage:flash.display.Stage;
	static var mMainClassRoot:flash.display.MovieClip;
	static var mCurrent:flash.display.MovieClip;
	static var mRolling:InteractiveObject;
	static var mDownObj:InteractiveObject;
	static var mMouseX:Int;
	static var mMouseY:Int;

	public static var mLastMouse:flash.geom.Point = new flash.geom.Point();

	var __scr : HTMLDivElement;
	var mArgs:Array<String>;

	static inline var VENDOR_HTML_TAG = "data-";
	static inline var HTML_EVENT_TYPES = [ 'resize', 'mouseup', 'mouseover', 'mouseout', 'mousemove', 'mousedown', 'mousewheel', 'keyup', 'keypress', 'keydown', 'focus', 'dblclick', 'click', 'blur' ];
	static inline var JEASH_IDENTIFIER = 'haxe:jeash';
	static var DEFAULT_WIDTH = 500;
	static var DEFAULT_HEIGHT = 500;

	function new(title:String, width:Int, height:Int)
	{
		mKilled = false;
		mRequestedWidth = width;
		mRequestedHeight = height;
		mResizePending = false;

		// ... this should go in Stage.hx
		__scr = cast js.Lib.document.getElementById(title);
		if ( __scr == null ) throw "Element with id '" + title + "' not found";
		__scr.style.overflow = "none";
		__scr.style.position = "absolute"; // necessary for chrome ctx.isPointInPath
		__scr.appendChild( Lib.canvas );
		
	}

	static public function trace( arg:Dynamic ) 
	{
		untyped
		{
			if ( window.console != null )
				window.console.log( arg );
			else
				trace( arg );
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
				ParsePriority();

				var eReg = ~/^swf.*\(([^)]*)\)$/;
				for (ctx in mPriority)
					try
					{

						if (StringTools.startsWith(ctx, "swf") && eReg.match( ctx ))
						{
							Lib.context = ctx;
							if (jeashLoadSwf(eReg.matched(1))) break;

						} else if (Lib.canvas.getContext(ctx)!=null) {
							Lib.context = ctx;
							if ( ctx.indexOf("webgl") >= 0 )
								mOpenGL = true;
							break;
						}
					} catch (e:Dynamic) { }

				// fallback to 2d context (even if it doesn't work)
				if ( Lib.context == null ) Lib.context = "2d";

				jeashBootstrap();

				if ( !StringTools.startsWith(Lib.context, "swf") )
				{
					if ( mOpenGL ) jeashInitGL();
					starttime = haxe.Timer.stamp();
				} else {
					//throw "Swf deployed, forcing execution failure.";
				}

			}
			return Lib.canvas;
		}
	}

	static function jeashLoadSwf(url:String)
	{
		var navigator : Navigator = cast js.Lib.window.navigator;
		if (navigator.plugins != null && navigator.plugins.length > 0)
			if ( untyped !navigator.plugins['Shockwave Flash'] ) return false;

		var object : HTMLObjectElement = cast js.Lib.document.createElement("object");
		object.type = "application/x-shockwave-flash";
		if (js.Lib.isIE)
		{
			var param : HTMLParamElement = cast js.Lib.document.createElement("param");
			param.name = "movie";
			param.value = url;
			object.appendChild(param);
		} else {
			object.data = url;
		}

		Lib.canvas = untyped object;

		return true;
		
	}

	static function jeashInitGL()
	{
		var gl : WebGLRenderingContext = Lib.canvas.getContext(Lib.context);
		Lib.glContext = gl;

		gl.viewport(0, 0, Lib.canvas.width, Lib.canvas.height);

		// TODO: implement background color
		gl.clearColor(1.0, 1.0, 1.0, 1.0);
		gl.clearDepth(1.0);
		gl.enable(gl.DEPTH_TEST);
		gl.depthFunc(gl.LEQUAL);
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
	public static function getTimer() :Int 
	{ 
		return Std.int((haxe.Timer.stamp() - starttime )*1000); 
	}

	public static function jeashGetStage() 
	{ 
		Lib.canvas;
		if ( mStage == null )
		{
			mStage = new flash.display.Stage(jeashGetWidth(), jeashGetHeight());
			mStage.addChild(jeashGetCurrent());
		}

		return mStage; 
	}

	public static function jeashAppendSurface(surface:HTMLCanvasElement, x:Int, y:Int)
	{
		if (mMe.__scr != null)
		{
			surface.style.position = "absolute";
			surface.style.left = x + "px";
			surface.style.top = y + "px";
			mMe.__scr.appendChild(surface);
		}
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

				for (type in HTML_EVENT_TYPES) 
					tgt.addEventListener(type, jeashGetStage().jeashProcessStageEvent, true);

				jeashGetStage().backgroundColor = if (tgt.style.backgroundColor != null && tgt.style.backgroundColor != "")
					ParseColor( tgt.style.backgroundColor, function (res, pos, cur) { 
							return switch (pos) {
							case 0: res | (cur << 16);
							case 1: res | (cur << 8);
							case 2: res | (cur);
							}
							});

				jeashGetStage().jeashUpdateNextWake();
			}

			return mMe;
	}

	static function ParseColor( str:String, cb: Int -> Int -> Int -> Int) 
	{
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

	static inline function ParsePriority()
	{
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		var attr : Attr = cast tgt.attributes.getNamedItem(VENDOR_HTML_TAG + 'priority');
		if ( attr != null ) mPriority = attr.value.split(':');
	}

	static function jeashGetWidth()
	{
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		return tgt.clientWidth > 0 ? tgt.clientWidth : Lib.DEFAULT_WIDTH;
	}

	static function jeashGetHeight()
	{
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		return tgt.clientHeight > 0 ? tgt.clientHeight : Lib.DEFAULT_HEIGHT;
	}

	static function jeashBootstrap()
	{
		var tgt : HTMLDivElement = cast js.Lib.document.getElementById(JEASH_IDENTIFIER);
		var lib = Run(tgt, jeashGetWidth(), jeashGetHeight());
		return lib;
	}

}
