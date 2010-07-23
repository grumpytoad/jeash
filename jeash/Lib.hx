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

#if !flash
import flash.text.KeyCode;
import jeash.Manager;
#end

import flash.geom.Point;

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
#if js
	public static var canvas(GetCanvas,null):HtmlCanvasElement;
#end
	public static var current(GetCurrent,null):MovieClip;
	public static var debug = false;
	static var mShowCursor = true;
	static var mShowFPS = false;

	static var mDragObject:DisplayObject = null;
	static var mDragRect:Rectangle = null;
	static var mDragOffsetX:Float = 0;
	static var mDragOffsetY:Float = 0;
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

	var mManager : Manager;
	var mArgs:Array<String>;

	function new(inName:String,inWidth:Int,inHeight:Int,?inFullScreen:Null<Bool>,?inResizable:Null<Bool>,?cb:Void->Void)
	{
		mKilled = false;
		mRequestedWidth = inWidth;
		mRequestedHeight = inHeight;
		mResizePending = false;

		mManager = new Manager( inWidth, inHeight, inName, cb );
		var evTypes = [ 
			'scroll', 
			'resize', 
			'mouseup', 
			'mouseover', 
			'mouseout', 
			'mousemove', 
			'mousedown', 
			'keyup', 
			'keypress', 
			'keydown', 
			'focus', 
			'dblclick', 
			'click', 
			'blur' 
			];
		var tgt = Lib.canvas;
		for (type in evTypes) 
			tgt.addEventListener(type, CaptureEvent, false);

		var listener = function (_)
		{ 
			var evt : Html5Dom.MouseEvent = cast _; 
			Lib.mMouseX = evt.clientX; 
			Lib.mMouseY = evt.clientY; 
		}
		tgt.addEventListener("onmousemove", listener, true ); 

		mStage = new flash.display.Stage(inWidth,inHeight,mManager);
		mStage.frameRate = 100;
		mMainClassRoot = new MovieClip();
		mStage.addChild(mMainClassRoot);
		mCurrent = mMainClassRoot;
		mCurrent.name = "Root MovieClip";

	}

	public function OnResize(inW:Int, inH:Int)
	{
		mManager.OnResize(inW,inH);
		mStage.OnResize(inW,inH);
	}

	static public function SetTextCursor(inText:Bool)
	{
		if (inText)
			flash.Manager.SetCursor( 2 );
		else
			flash.Manager.SetCursor( mShowCursor ? 1 : 0 );
	}

	static public function GetCanvas() : HtmlCanvasElement
	{
		return untyped Manager.__scr;
	}

	static public function GetCurrent() : MovieClip
	{
		return mMainClassRoot;
	}

	public static function as<T>( v : Dynamic, c : Class<T> ) : Null<T>
	{
		return Std.is(v,c) ? v : null;
	}

	static var starttime : Float = haxe.Timer.stamp();
	static public function getTimer() :Int { return ( Std.int(haxe.Timer.stamp() - starttime )*1000); }

#if !flash
	static public function GetStage() { return mStage; }

	public function ProcessKeys( code:Int , pressed : Bool, inChar:Int,
			ctrl:Bool, alt:Bool, shift:Bool )
	{
		if (code== KeyCode.ESCAPE && mQuitOnEscape)
		{
			mKilled = true;
			return;
		}

		switch code
		{
			// You might want to disable this in production

			case KeyCode.TAB:
				mStage.TabChange( shift ? -1 : 1,code);

			default:
				var event = new KeyboardEvent(
						pressed ? KeyboardEvent.KEY_DOWN:
						KeyboardEvent.KEY_UP,
						true,false,
						inChar,
						KeyCode.ConvertCode(code),
						KeyCode.ConvertLocation(code),
						ctrl,alt,shift);

				mStage.HandleKey(event);
		}
	}

	function CreateMouseEvent(inObj:InteractiveObject,inRelatedObj:InteractiveObject,
			inMouse:Html5Dom.MouseEvent,inType:String): flash.events.MouseEvent
	{
		var bubble = inType!=flash.events.MouseEvent.ROLL_OUT && inType!=flash.events.MouseEvent.ROLL_OVER;
		var pos = new flash.geom.Point(inMouse.clientX,inMouse.clientY);
		if (inObj!=null)
			pos = inObj.globalToLocal(pos);

		var result =  new flash.events.MouseEvent(inType,
				bubble, false,
				inMouse.clientX,inMouse.clientY,
				inRelatedObj,
				inMouse.ctrlKey,
				inMouse.altKey,
				inMouse.shiftKey,
				true, // buttonDown = left mouse button, 
				2);

		result.stageX = inMouse.clientX/mStage.scaleX;
		result.stageY = inMouse.clientY/mStage.scaleY;
		result.target = inObj;
		return result;
	}

	function GetInteractiveObjectAtPos(inX:Int,inY:Int) : InteractiveObject
	{
		return mStage.GetInteractiveObjectAtPos(inX,inY);
	}

	static function FireEvents(inEvt:flash.events.Event,inList:Array<InteractiveObject>)
	{
		var l = inList.length;
		if (l==0)
			return;

		// First, the "capture" phase ...
		inEvt.SetPhase(EventPhase.CAPTURING_PHASE);
		for(i in 0...l-1)
		{
			var obj = inList[i];
			inEvt.currentTarget = obj;
			obj.dispatchEvent(inEvt);
			if (inEvt.IsCancelled())
				return;
		}

		// Next, the "target"
		inEvt.SetPhase(EventPhase.AT_TARGET);
		inEvt.currentTarget = inList[l-1];
		inList[l-1].dispatchEvent(inEvt);
		if (inEvt.IsCancelled())
			return;

		// Last, the "bubbles" phase
		if (inEvt.bubbles)
		{
			inEvt.SetPhase(EventPhase.BUBBLING_PHASE);
			var i=l-2;
			while(i>=0)
			{
				var obj = inList[i];
				inEvt.currentTarget = obj;
				obj.dispatchEvent(inEvt);
				if (inEvt.IsCancelled())
					return;
				--i;
			}

		}
	}


	static public function SendEventToObject(inEvent:flash.events.Event,inObj:InteractiveObject) : Void
	{
		var objs = GetAnscestors(inObj);
		objs.reverse();
		FireEvents(inEvent,objs);
	}

	static function GetAnscestors(inObj:DisplayObject) : Array<InteractiveObject>
	{
		var result:Array<InteractiveObject> = [];

		while(inObj!=null)
		{
			var interactive = inObj.AsInteractiveObject();
			if (interactive!=null)
				result.push(interactive);
			inObj = inObj.GetParent();
		}

		result.reverse();
		return result;
	}

	static public function SetDragged(inObj:DisplayObject,?inCentre:Bool, ?inRect:Rectangle)
	{
		mDragObject = inObj;
		mDragRect = inRect;
		if (mDragObject!=null)
		{
			if (inCentre!=null && inCentre)
			{
				mDragOffsetX = -inObj.width/2;
				mDragOffsetY = -inObj.height/2;
			}
			else
			{
				var mouse = new Point( mMouseX, mMouseY );
				mouse.x /= mStage.scaleX;
				mouse.y /= mStage.scaleY;
				var p = mDragObject.parent;
				if (p!=null)
					mouse = p.globalToLocal(mouse);

				mDragOffsetX = inObj.x-mouse.x;
				mDragOffsetY = inObj.y-mouse.y;
			}
		}
	}

	function DragObject(inX:Float, inY:Float)
	{
		var pos = new Point(inX,inY);
		var p = mDragObject.parent;
		if (p!=null)
			pos = p.globalToLocal(pos);

		if (mDragRect!=null)
		{
			if (pos.x < mDragRect.x) pos.x = mDragRect.x;
			else if (pos.x > mDragRect.right) pos.x = mDragRect.right;

			if (pos.y < mDragRect.y) pos.y = mDragRect.y;
			else if (pos.y > mDragRect.bottom) pos.y = mDragRect.bottom;
		}

		mDragObject.x = pos.x + mDragOffsetX;
		mDragObject.y = pos.y + mDragOffsetY;
	}


	function DoMouse(evt:Html5Dom.MouseEvent)
	{
		var x = Std.int(evt.clientX);
		var y = Std.int(evt.clientY);

		mLastMouse.x  = x;
		mLastMouse.y =  y;

		var type = switch (evt.type) {
			case flash.events.MouseEvent.MOUSE_DOWN.toLowerCase(): flash.events.MouseEvent.MOUSE_DOWN;
			case flash.events.MouseEvent.MOUSE_MOVE.toLowerCase(): flash.events.MouseEvent.MOUSE_MOVE;
			case flash.events.MouseEvent.MOUSE_UP.toLowerCase(): flash.events.MouseEvent.MOUSE_UP;
			case flash.events.MouseEvent.MOUSE_OVER.toLowerCase(): flash.events.MouseEvent.MOUSE_OVER;
			case flash.events.MouseEvent.MOUSE_OUT.toLowerCase(): flash.events.MouseEvent.MOUSE_OUT;
		}

		if (mDragObject!=null)
			DragObject(x/mStage.scaleX,y/mStage.scaleY);

		var obj = GetInteractiveObjectAtPos(x,y);

		var new_list:Array<InteractiveObject> = obj!=null ?  GetAnscestors(obj) : [];
		var nl = new_list.length;


		// Handle roll-over/roll-out events ...
		if (obj!=mRolling)
		{
			if (mRolling!=null)
			{
				mRolling.DoMouseLeave();
				var evt = CreateMouseEvent( mRolling, obj, evt, flash.events.MouseEvent.MOUSE_OUT);
				mRolling.dispatchEvent(evt);
			}

			var old_list = GetAnscestors(mRolling);
			var ol = old_list.length;

			// Find common parents...
			var common=0;
			var stop = ol<nl ? ol:nl;

			while(common<stop && old_list[common]==new_list[common])
				common++;

			if (ol>common)
			{
				var evt = CreateMouseEvent(mRolling, obj, evt, flash.events.MouseEvent.ROLL_OUT);
				for(o in common...ol)
				{
					evt.target = old_list[o];
					old_list[o].dispatchEvent(evt);
				}
			}

			if (nl>common)
			{
				var evt = CreateMouseEvent(obj, mRolling, evt, flash.events.MouseEvent.ROLL_OVER);
				for(o in common...nl)
				{
					evt.target = new_list[o];
					new_list[o].dispatchEvent(evt);
				}
			}

			mRolling = obj;
			if (mRolling!=null)
			{
				mRolling.DoMouseEnter();
				var evt = CreateMouseEvent(mRolling, obj, evt, flash.events.MouseEvent.MOUSE_OVER);
				mRolling.dispatchEvent(evt);
			}

		}

		// Send event directly to InteractiveObject for internal processing
		if (type==flash.events.MouseEvent.MOUSE_DOWN)
		{
			mDownObj = obj;
			if (obj!=null)
				obj.OnMouseDown(x,y);
		}
		else if (type==flash.events.MouseEvent.MOUSE_MOVE && mDownObj!=null)
			mDownObj.OnMouseDrag(x,y);
		else if (type==flash.events.MouseEvent.MOUSE_UP)
		{
			// trace("Up :" + obj + "/" + mDownObj);

			if (mDownObj!=null)
			{
				mDownObj.OnMouseUp(x,y);

				if (obj==mDownObj)
				{
					//trace("CLICK!");
					var evt = CreateMouseEvent(obj, null, evt, flash.events.MouseEvent.CLICK);
					FireEvents(evt,new_list);
				}
				else
				{
					// Send up event to same place as down event...
					obj = mDownObj;
					new_list = GetAnscestors(obj);
				}
			}

			mDownObj = null;
		}


		if (nl>0 && (type==flash.events.MouseEvent.MOUSE_DOWN || type==flash.events.MouseEvent.MOUSE_UP) ||
				type==flash.events.MouseEvent.MOUSE_MOVE )
		{
			var evt = CreateMouseEvent(obj, null, evt, type);
			FireEvents(evt, new_list);
		}

		// trace(type + " obj = " + (obj==null?"null":"something") );


		//var event =CreateMouseEvent(inEvent,type);
	}

#end

#if js
	var timer : Dynamic;
	var frame : Int;
	static var interval : Int;
	function setTimer ( ?next :Int ) {
		//if (mShowFPS)
		mManager.RenderFPS();

		if ( timer != null ) untyped window.clearInterval( timer );
		if ( next == null ) {
			if ( mStage != null ) {
				if ( interval == null ) interval = Std.int( 1000.0/mStage.frameRate );
				next = interval;
			} else {
				next = 1;
			}
		}

		timer = untyped window.setInterval( Step, next );
	}
#end

	function Step () {


		mStage.Clear();
		//mManager.clear(mStage.backgroundColor);

		// Process pending timers ...
		flash.Timer.CheckTimers();
		// Send frame-enter event
		var event = new flash.events.Event( flash.events.Event.ENTER_FRAME );
		mStage.Broadcast(event);
		mStage.RenderAll();

		setTimer();
	}

	function CaptureEvent(evt:Event)
	{
		switch(evt.type)
		{
			case flash.events.KeyboardEvent.KEY_DOWN.toLowerCase():
				var code = mManager.lastKey();
				ProcessKeys( code, true,
						mManager.lastChar(),
						mManager.lastKeyCtrl(), mManager.lastKeyAlt(),
						mManager.lastKeyShift() );
			case flash.events.KeyboardEvent.KEY_UP.toLowerCase():
				var code = mManager.lastKey();
				ProcessKeys( code, false,
						mManager.lastChar(),
						mManager.lastKeyCtrl(), mManager.lastKeyAlt(),
						mManager.lastKeyShift() );

			case flash.events.MouseEvent.MOUSE_MOVE.toLowerCase():
				DoMouse(cast evt);
			case flash.events.MouseEvent.MOUSE_DOWN.toLowerCase():
				DoMouse(cast evt);

			case flash.events.MouseEvent.MOUSE_UP.toLowerCase():
				DoMouse(cast evt);

			default:
				
		}
	}


	function MyRun( )
	{
		mManager.ResetFPS();
		setTimer();
	}

	static public function Run( name:String, width:Int, height:Int ) 
	{
		if ( js.Lib.document != null )
		{
			mMe = new Lib( name, width, height );
			var tgt = js.Lib.document.getElementById(name);
			mStage.backgroundColor = if (tgt.style.backgroundColor != null && tgt.style.backgroundColor != "")
				ParseColor( tgt.style.backgroundColor, function (res, pos, cur) { 
						return switch (pos) {
						case 0: res | (cur << 16);
						case 1: res | (cur << 8);
						case 2: res | (cur);
						}
						});

			mMe.MyRun();
		} else {
			haxe.Timer.delay( callback( Run, name, width, height ), 10 );
		}
	}

	public static function close()
	{
		mMe.mKilled = true;
	}


	public static function Init(inName:String,inWidth:Int,inHeight:Int,
			?inFullScreen:Null<Bool>,?inResizable:Null<Bool>,?cb:Void->Void)
	{
		mMe = new Lib(inName,inWidth,inHeight,inFullScreen,inResizable,cb);
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


	static function __init__()
	{
		untyped
		{
			var els = document.getElementsByTagName('canvas');
			if ( els.length > 0 )
			{
				var tgt = els[0];
				var width : Int = tgt.getAttribute('width') != null ? cast tgt.getAttribute('width') : Manager.DEFAULT_WIDTH;
				var height : Int = tgt.getAttribute('height') != null ? cast tgt.getAttribute('height') : Manager.DEFAULT_HEIGHT;
				var name = tgt.getAttribute('id') != null ? tgt.getAttribute('id') : 'Container';


				Run(name, width, height);
			}
		}
	}

}
