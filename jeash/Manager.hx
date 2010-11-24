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
import flash.display.Graphics;
import flash.text.TextField;
import flash.events.Event;
import flash.ui.Keyboard;
import flash.Lib;

enum EventType
{
	et_noevent;
	et_active;
	et_keydown;
	et_keyup;
	et_mousemove;
	et_mousebutton_down;
	et_mousebutton_up;
	et_joystickmove;
	et_joystickball;
	et_joystickhat;
	et_joystickbutton;
	et_resize;
	et_quit;
	et_user;
	et_syswm;
}

enum MouseEventType
{
	met_Move;
	met_LeftUp;
	met_LeftDown;
	met_MiddleUp;
	met_MiddleDown;
	met_RightUp;
	met_RightDown;
	met_MouseWheelUp;
	met_MouseWheelDown;
}

typedef MouseEvent =
{
	var type : MouseEventType;
	var x : Int;
	var y : Int;
	var shift : Bool;
	var ctrl : Bool;
	var alt : Bool;
	var leftIsDown : Bool;
	var middleIsDown : Bool;
	var rightIsDown : Bool;
}

typedef KeyEvent =
{
	var isDown : Bool;
	// See nme.KeyCode ...
	var code : Int;
	var shift : Bool;
	var ctrl : Bool;
	var alt : Bool;
}

typedef CanvasEvent = {
	var type : Int;
	var key : Int;
	var char : Int;
	var ctrl : Bool;
	var alt : Bool;
	var shift : Bool;
}

typedef MouseEventCallback = MouseEvent -> Void;
typedef MouseEventCallbackList = Array<MouseEventCallback>;

typedef KeyEventCallback = KeyEvent -> Void;
typedef KeyEventCallbackList = Array<KeyEventCallback>;

typedef UpdateCallback = Float -> Void;
typedef UpdateCallbackList = Array<UpdateCallback>;

typedef RenderCallback = Void -> Void;
typedef RenderCallbackList = Array<RenderCallback>;

class Manager
{
	static var __scr : HTMLElement;
	static var __evt : Dynamic;

	// Set this to something else if yo do not want it...
	static var closeKey = 27;
	static var pauseUpdates = Keyboard.F11;
	static var toggleQuality = Keyboard.F12;

	static var FULLSCREEN = 0x0001;
	static var OPENGL     = 0x0002;
	static var RESIZABLE  = 0x0004;

	static var DEFAULT_WIDTH = 400;
	static var DEFAULT_HEIGHT = 400;

	static public var graphics(default,null):Graphics;
	static public var draw_quality(get_draw_quality,set_draw_quality):Int;

	public var mainLoopRunning:Bool;
	public var mouseEventCallbacks:MouseEventCallbackList;
	public var mouseClickCallbacks:MouseEventCallbackList;
	public var keyEventCallbacks:KeyEventCallbackList;
	public var updateCallbacks:UpdateCallbackList;
	public var renderCallbacks:RenderCallbackList;

	public var mPaused:Bool;

	public var tryQuitFunction: Void->Bool;

	private var timerStack : List < haxe.Timer > ;
	private var mFrameCount : Int;

	public function new( width : Int, height : Int, title : String, ?cb : Dynamic )
	{
		__scr = untyped document.getElementById(title);
		if ( __scr == null ) throw "Element with id '" + title + "' not found";
		__scr.appendChild( Lib.canvas );

		mFrameCount = 0;

		//__scr.onkeydown = setEvent;
		//__scr.onkeyup = setEvent;
	}

	public function OnResize(inW:Int, inH:Int)
	{
		throw "Not implemented. OnResize. ";
		graphics.SetSurface(__scr);
	}

	static var CURSOR_NONE = 0;
	static var CURSOR_NORMAL = 1;
	static var CURSOR_TEXT = 2;

	public static function SetCursor(inCursor:Int)
	{
		if ( inCursor == 0 ) {
			__scr.style.cursor = 'url("blank.cur"), pointer';
		} else {
			__scr.style.cursor = 'auto';
		}
	}

	static public function GetMouse() : flash.geom.Point
	{
		throw "Not implemented. GetMouse";
		return null;
	}

	public static function mouseEvent(inType:MouseEventType)
	{
		return 
		{
			type : inType,
			x : SmouseX(),
			y : SmouseY(),
			shift : false,
			ctrl : false,
			alt : false,
			leftIsDown : mouseButtonState()!=0,
			middleIsDown : false,
			rightIsDown : false
		};
	}

	public function lastKey() : Int
	{
		return Reflect.field( __evt, "key" );
	}
	public function lastChar() : Int
	{
		return Reflect.field( __evt, "char" );
	}
	public function lastKeyShift() : Bool
	{
		return Reflect.field( __evt, "shift" );
	}
	public function lastKeyCtrl() : Bool
	{
		return Reflect.field( __evt, "ctrl" );
	}
	public function lastKeyAlt() : Bool
	{
		return Reflect.field( __evt, "alt" );
	}


	public function mouseButton() : Int
	{
		return Reflect.field( __evt, "button" );
	}

	public static function mouseButtonState() : Int
	{
		return Reflect.field( __evt, "state" );
	}

	// Static versions
	public static function SmouseX() : Int
	{ return Reflect.field( __evt, "x" ); }

	public static function SmouseY() : Int
	{ return Reflect.field( __evt, "y" ); }

	static function set_draw_quality(inQuality:Int) : Int
	{
		throw "Not implemented. set_draw_quality. ";
		return null;
	}

	static function get_draw_quality() : Int
	{
		throw "Not implemented. get_draw_quality.";
		return null;
	}

	public static function setClipboardString(inString:String)
	{
		throw "Not implemented. setClipboardString.";
	}

	var mFrameCountStack : Array<Float>;
	var mT0 : Float;
	public function ResetFPS()
	{
		mT0 = haxe.Timer.stamp();
		mFrameCountStack = [];
	}
	var textField : TextField;
	public function RenderFPS()
	{
#if debug
		var t =  haxe.Timer.stamp() - mT0;
		var n = mFrameCountStack.length;
		mFrameCountStack[n] = t;
		while(mFrameCountStack[0] < (t-1) )
			mFrameCountStack.shift();

		var text = "FPS:" + mFrameCountStack.length;
		untyped document.title = text;
#end
	}

}
