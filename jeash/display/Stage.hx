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

package jeash.display;

import Html5Dom;

import flash.Lib;
import flash.ui.Keyboard;
import flash.geom.Matrix;
import flash.events.FocusEvent;
import flash.events.Event;
import flash.display.StageScaleMode;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

class Stage extends flash.display.DisplayObjectContainer
{
	var jeashWidth : Int;
	var jeashHeight : Int;
	var jeashWindowWidth : Int;
	var jeashWindowHeight : Int;
	var jeashTimer : Dynamic;
	var jeashInterval : Int;
	var jeashFastMode : Bool;
	var jeashDragObject:DisplayObject;
	var jeashDragBounds:Rectangle;
	var jeashDragOffsetX:Float;
	var jeashDragOffsetY:Float;
	var jeashMouseOverObjects:Array<InteractiveObject>;
	var jeashStageMatrix:Matrix;

	public var jeashPointInPathMode(default,null):PointInPathMode;

	public var stageWidth(GetStageWidth,null):Int;
	public var stageHeight(GetStageHeight,null):Int;
	public var frameRate(default,jeashSetFrameRate):Float;
	public var quality(jeashGetQuality,jeashSetQuality):String;
	public var scaleMode:StageScaleMode;
	public var align:flash.display.StageAlign;
	public var stageFocusRect:Bool;
	public var focus(GetFocus,SetFocus):InteractiveObject;
	public var backgroundColor(default,SetBackgroundColour):Int;
	public function GetStageWidth() { return jeashWindowWidth; }
	public function GetStageHeight() { return jeashWindowHeight; }

	private var mFocusObject : InteractiveObject;
	static var jeashMouseChanges : Array<String> = [ jeash.events.MouseEvent.MOUSE_OUT, jeash.events.MouseEvent.MOUSE_OVER, jeash.events.MouseEvent.ROLL_OUT, jeash.events.MouseEvent.ROLL_OVER ];
	static inline var DEFAULT_FRAMERATE = 60.0;

	// for openGL renderers
	public var mProjMatrix : Array<Float>;
	static inline var DEFAULT_PROJ_MATRIX = [1., 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0];

	public function new(width:Int, height:Int)
	{
		super();
		mFocusObject = null;
		jeashWindowWidth = jeashWidth = width;
		jeashWindowHeight = jeashHeight = height;
		stageFocusRect = false;
		scaleMode = StageScaleMode.SHOW_ALL;
		jeashStageMatrix = new Matrix();
		tabEnabled = true;
		frameRate=DEFAULT_FRAMERATE;
		SetBackgroundColour(0xffffff);
		name = "Stage";
		loaderInfo = LoaderInfo.create(null);
		loaderInfo.parameters.width = Std.string(jeashWidth);
		loaderInfo.parameters.height = Std.string(jeashHeight);
		mProjMatrix = DEFAULT_PROJ_MATRIX;
		jeashPointInPathMode = Graphics.jeashDetectIsPointInPathMode();
		jeashMouseOverObjects = [];
	}

	// @r551
	public function jeashStartDrag(sprite:Sprite, lockCenter:Bool = false, ?bounds:Rectangle)
	{
		jeashDragBounds = (bounds==null) ? null : bounds.clone();
		jeashDragObject = sprite;

		if (jeashDragObject!=null)
		{
			if (lockCenter)
			{
				jeashDragOffsetX = -jeashDragObject.width/2;
				jeashDragOffsetY = -jeashDragObject.height/2;
			}
			else
			{
				var mouse = new Point(mouseX,mouseY);
				var p = jeashDragObject.parent;

				if (p!=null)
					mouse = p.globalToLocal(mouse);

				jeashDragOffsetX = jeashDragObject.x - mouse.x;
				jeashDragOffsetY = jeashDragObject.y - mouse.y;
			}
		}
	}

	// @r551
	function jeashDrag(point:Point)
	{
		var p = jeashDragObject.parent;
		if (p!=null)
			point = p.globalToLocal(point);

		var x = point.x + jeashDragOffsetX;
		var y = point.y + jeashDragOffsetY;

		if (jeashDragBounds!=null)
		{
			if (x < jeashDragBounds.x) x = jeashDragBounds.x;
			else if (x > jeashDragBounds.right) x = jeashDragBounds.right;

			if (y < jeashDragBounds.y) y = jeashDragBounds.y;
			else if (y > jeashDragBounds.bottom) y = jeashDragBounds.bottom;
		}

		jeashDragObject.x = x;
		jeashDragObject.y = y;
	}

	public function jeashStopDrag(sprite:Sprite) : Void
	{
		jeashDragBounds = null;
		jeashDragObject = null;
	}

	// @r551 without touch events
	function jeashCheckInOuts(event:jeash.events.MouseEvent, stack:Array<InteractiveObject>)
	{
		var prev = jeashMouseOverObjects;
		var events = jeashMouseChanges;

		var new_n = stack.length;
		var new_obj:InteractiveObject = new_n>0 ? stack[new_n-1] : null;
		var old_n = prev.length;
		var old_obj:InteractiveObject = old_n>0 ? prev[old_n-1] : null;
		if (new_obj!=old_obj)
		{
			// mouseOut/MouseOver goes up the object tree...
			if (old_obj!=null)
				old_obj.jeashFireEvent( event.jeashCreateSimilar(events[0], new_obj, old_obj) );

			if (new_obj!=null)
				new_obj.jeashFireEvent( event.jeashCreateSimilar(events[1], old_obj) );

			// rollOver/rollOut goes only over the non-common objects in the tree...
			var common = 0;
			while(common<new_n && common<old_n && stack[common] == prev[common] )
				common++;

			var rollOut = event.jeashCreateSimilar(events[2], new_obj, old_obj);
			var i = old_n-1;
			while(i>=common)
			{
				prev[i].dispatchEvent(rollOut);
				i--;
			}

			var rollOver = event.jeashCreateSimilar(events[3],old_obj);
			var i = new_n-1;
			while(i>=common)
			{
				stack[i].dispatchEvent(rollOver);
				i--;
			}

			jeashMouseOverObjects = stack;
		}
	}

	public function jeashProcessStageEvent(evt:Html5Dom.Event)
	{
		evt.preventDefault();
		evt.stopPropagation();
		switch(evt.type)
		{
			case (flash.events.KeyboardEvent.KEY_DOWN.toLowerCase()):
				var evt:KeyboardEvent = cast evt; 
				jeashOnKey( evt.keyLocation, true,
						evt.keyIdentifier.charCodeAt(0),
						evt.ctrlKey, evt.altKey,
						evt.shiftKey );
			case (flash.events.KeyboardEvent.KEY_UP.toLowerCase()):
				var evt:KeyboardEvent = cast evt; 
				jeashOnKey( evt.keyLocation, false,
						evt.keyIdentifier.charCodeAt(0),
						evt.ctrlKey, evt.altKey,
						evt.shiftKey );

			case (flash.events.MouseEvent.MOUSE_MOVE.toLowerCase()):
				jeashOnMouse(cast evt, flash.events.MouseEvent.MOUSE_MOVE);

			case (flash.events.MouseEvent.MOUSE_DOWN.toLowerCase()):
				jeashOnMouse(cast evt, flash.events.MouseEvent.MOUSE_DOWN);

			case (flash.events.MouseEvent.MOUSE_UP.toLowerCase()):
				jeashOnMouse(cast evt, flash.events.MouseEvent.MOUSE_UP);

			case (flash.events.MouseEvent.CLICK.toLowerCase()):
				jeashOnMouse(cast evt, flash.events.MouseEvent.CLICK);

			case (flash.events.MouseEvent.MOUSE_WHEEL.toLowerCase()):
				jeashOnMouse(cast evt, flash.events.MouseEvent.MOUSE_WHEEL);

			default:
				
		}
	}

	// @r551
	function jeashOnMouse(event:Html5Dom.MouseEvent, type:String)
	{
		var point : Point = untyped
		{
			new Point(event.clientX - Lib.mMe.__scr.offsetLeft, event.clientY - Lib.mMe.__scr.offsetTop);
		}

		if (jeashDragObject!=null)
			jeashDrag(point);

		var obj = jeashGetObjectUnderPoint(point); 

		// used in drag implementation
		mouseX = point.x;
		mouseY = point.y;

		var stack = new Array<InteractiveObject>();
		if (obj!=null)
			obj.jeashGetInteractiveObjectStack(stack);

		if (stack.length > 0)
		{
			//var global = obj.localToGlobal(point);
			var obj = stack[0];
			stack.reverse();
			var local = obj.globalToLocal(point);

			var evt = jeashCreateMouseEvent(type, event, local, cast obj);

			jeashCheckInOuts(evt, stack);

			obj.jeashFireEvent(evt);
		} else {
			var evt = jeashCreateMouseEvent(type, event, point, null);

			jeashCheckInOuts(evt, stack);
		}
	}

	// @r551 should be in MouseEvent.hx, haxe issue 300
	public function jeashCreateMouseEvent(type:String, event:Html5Dom.MouseEvent, local:Point, target:InteractiveObject): flash.events.MouseEvent
	{
		var bubble = true;
		// cross-browser delta sniff
		var delta = if ( type == flash.events.MouseEvent.MOUSE_WHEEL )
		{
			var mouseEvent : Dynamic = event;
			if (mouseEvent.wheelDelta) { /* IE/Opera. */
				if ( js.Lib.isOpera )
					Std.int(mouseEvent.wheelDelta/40);
				else
					Std.int(mouseEvent.wheelDelta/120);
			} else if (mouseEvent.detail) { /** Mozilla case. */
				Std.int(-mouseEvent.detail);
			}

		} else { 2; }

		var pseudoEvent =  new flash.events.MouseEvent(type,
				bubble, false,
				local.x,local.y,
				null,
				event.ctrlKey,
				event.altKey,
				event.shiftKey,
				event.button != null, // buttonDown = left mouse button, 
				delta);

		pseudoEvent.stageX = event.x;
		pseudoEvent.stageY = event.y;
		pseudoEvent.target = target;
		return pseudoEvent;
	}

	function jeashOnKey( code:Int , pressed : Bool, inChar:Int,
			ctrl:Bool, alt:Bool, shift:Bool )
	{
		// currently non-functioning
		var event = new flash.events.KeyboardEvent(
				pressed ? flash.events.KeyboardEvent.KEY_DOWN:
				flash.events.KeyboardEvent.KEY_UP,
				true,false,
				inChar,
				Keyboard.ConvertCode(code, shift),
				Keyboard.ConvertLocation(code),
				ctrl,alt,shift);

		dispatchEvent(event);
	}

	public function jeashOnResize(inW:Int, inH:Int)
	{
		jeashWindowWidth = jeashWidth = inW;
		jeashWindowHeight = jeashHeight = inH;
		//RecalcScale();
		var event = new flash.events.Event( flash.events.Event.RESIZE );
		event.target = this;
		Broadcast(event);
	}


	public function SetBackgroundColour(col:Int) : Int
	{
		backgroundColor = col;
		return col;
	}

	public function DoSetFocus(inObj:InteractiveObject,inKeyCode:Int)
	{
		// TODO
		return inObj;
	}

	public function SetFocus(inObj:InteractiveObject) { return DoSetFocus(inObj,-1); }

	public function GetFocus() { return mFocusObject; }

	public function jeashClear()
	{
		if ( Lib.mOpenGL )
		{
			var ctx = Lib.glContext;
			ctx.clear(ctx.COLOR_BUFFER_BIT | ctx.DEPTH_BUFFER_BIT);
		}

	}

	public function jeashRenderAll()
	{
		jeashClear();

		SetupRender(jeashStageMatrix);

		__Render();
	}

	public function jeashRenderToCanvas(canvas:HTMLCanvasElement)
	{
		canvas.width = canvas.width;

		SetupRender(jeashStageMatrix);

		RenderContentsToCache(canvas,0,0);
	}

	public function jeashSetQuality(inQuality:String):String
	{
		this.quality = inQuality;
		return inQuality;
	}

	public function jeashGetQuality():String
	{
		return if (this.quality != null)
			this.quality;
		else
			StageQuality.BEST;
	}

	function jeashSetFrameRate(speed:Float):Float
	{
		if ( StringTools.startsWith(Lib.context, "swf") ) return speed;

		var window : Window = cast js.Lib.window;
		if (speed == 0 && window.postMessage != null)
			jeashFastMode = true;
		else
		{
			jeashFastMode = false;
			jeashInterval = Std.int( 1000.0/speed );
		}

		jeashUpdateNextWake();

		this.frameRate = speed;
		return speed;
	}

	public function jeashUpdateNextWake () 
	{
		var window : Window = cast js.Lib.window;
		window.clearInterval( jeashTimer );
		if ( jeashFastMode )
		{
			window.addEventListener( 'message', jeashRender, false );
			window.postMessage('a', cast window.location);
		} else {
			jeashTimer = window.setInterval( jeashRender, jeashInterval, [] );
		}
	}

	function jeashRender (?_) 
	{
		this.jeashClear();

		var event = new flash.events.Event( flash.events.Event.ENTER_FRAME );
		this.Broadcast(event);

		this.jeashRenderAll();
		
		var event = new flash.events.Event( flash.events.Event.RENDER );
		this.Broadcast(event);

		if ( jeashFastMode )
			untyped window.postMessage('a', window.location);
	}

	override function jeashGetMouseX() { return this.mouseX; }
	override function jeashSetMouseX(x:Float) { this.mouseX = x; return x; }
	override function jeashGetMouseY() { return this.mouseY; }
	override function jeashSetMouseY(y:Float) { this.mouseY = y; return y; }
}

