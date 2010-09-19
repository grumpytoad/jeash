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
import flash.Manager;
import flash.geom.Matrix;
import flash.events.FocusEvent;
import flash.events.Event;
import flash.display.StageScaleMode;
import flash.geom.Point;

class Stage extends flash.display.DisplayObjectContainer
{
	var mWidth : Int;
	var mHeight : Int;
	var mWindowWidth : Int;
	var mWindowHeight : Int;
	var mTimer : Dynamic;
	var mInterval : Int;
	var mFastMode : Bool;

	public var stageWidth(GetStageWidth,null):Int;
	public var stageHeight(GetStageHeight,null):Int;
	public var frameRate(default,SetFrameRate):Float;
	public var quality(GetQuality,SetQuality):String;
	public var scaleMode:StageScaleMode;
	public var align:flash.display.StageAlign;
	public var stageFocusRect:Bool;
	public var focus(GetFocus,SetFocus):InteractiveObject;
	public var backgroundColor(default,SetBackgroundColour):Int;
	public function GetStageWidth() { return mWindowWidth; }
	public function GetStageHeight() { return mWindowHeight; }

	private var mStageMatrix:Matrix;

	private var mFocusObject : InteractiveObject;
	static inline var DEFAULT_FRAMERATE = 0.0;

	// for openGL renderers
	public var mProjMatrix : Array<Float>;
	static inline var DEFAULT_PROJ_MATRIX = [1., 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0];

	public function new(inWidth:Int,inHeight:Int)
	{
		super();
		mFocusObject = null;
		mWindowWidth = mWidth = inWidth;
		mWindowHeight = mHeight = inHeight;
		stageFocusRect = false;
		scaleMode = StageScaleMode.SHOW_ALL;
		mStageMatrix = new Matrix();
		RecalcScale();
		tabEnabled = true;
		// fast as possible ...
		frameRate=DEFAULT_FRAMERATE;
		SetBackgroundColour(0xffffff);
		name = "Stage";
		loaderInfo = LoaderInfo.create(null);
		loaderInfo.parameters.width = Std.string(mWidth);
		loaderInfo.parameters.height = Std.string(mHeight);
		mProjMatrix = DEFAULT_PROJ_MATRIX;
		
	}

	public function getObjectsUnderPoint(point:Point)
	{
		var l = mObjs.length-1, collection = [];
		for(i in 0...mObjs.length)
		{
			var result = mObjs[l-i].GetObj( Std.int(point.x), Std.int(point.y), null);
			if (result!=null)
				collection.push( result );
		}
		return collection;
	}

	public function OnResize(inW:Int, inH:Int)
	{
		mWindowWidth = mWidth = inW;
		mWindowHeight = mHeight = inH;
		RecalcScale();
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
		if (mFocusObject!=inObj)
		{
			if (mFocusObject!=null)
			{
				mFocusObject.OnFocusOut();
				var event = new flash.events.FocusEvent(flash.events.FocusEvent.FOCUS_OUT, true, false, mFocusObject );
				event.relatedObject = inObj;

				Lib.SendEventToObject(event,mFocusObject);
			}

			var old = mFocusObject;
			mFocusObject = inObj;

			if (mFocusObject!=null)
			{
				mFocusObject.OnFocusIn(inKeyCode<0);
				var event = new flash.events.FocusEvent(flash.events.FocusEvent.FOCUS_IN, true, false, inObj );
				event.relatedObject = old;

				Lib.SendEventToObject(event,mFocusObject);
			}
		}
		return inObj;
	}
	public function SetFocus(inObj:InteractiveObject) { return DoSetFocus(inObj,-1); }

	public function GetFocus() { return mFocusObject; }

	public function HandleKey(inKey:flash.events.KeyboardEvent)
	{
		if (mFocusObject!=null)
		{
			mFocusObject.OnKey(inKey);
			mFocusObject.dispatchEvent(inKey);
		}
		else
			dispatchEvent(inKey);
	}

	function RecalcScale()
	{
		mScaleX = mScaleY = 1.0;
		switch(scaleMode)
		{
			case StageScaleMode.EXACT_FIT:
				mScaleX = mWindowWidth/mWidth; mScaleY=mWindowHeight/mHeight;
			case StageScaleMode.NO_SCALE:
			case StageScaleMode.SHOW_ALL:
				// Fit width ...
				if (mWidth*mWindowHeight > mHeight*mWindowWidth)
					mScaleY = mScaleX = mWindowWidth/mWidth;
				// Fit height ...
				else
					mScaleY = mScaleX = mWindowHeight/mHeight;
			case StageScaleMode.NO_BORDER:
				// Fit width ...
				if (mWidth*mWindowHeight < mHeight*mWindowWidth)
					mScaleX = mScaleY = mWindowWidth/mWidth;
				// Fit height ...
				else
					mScaleX = mScaleY = mWindowHeight/mHeight;
			default:
		}

		mStageMatrix = new Matrix(mScaleX,0,0,mScaleY);
	}

	public function Clear()
	{
		var ctx = Lib.canvas.getContext(Lib.context);
		if ( Lib.mOpenGL )
		{
			ctx.clear(ctx.COLOR_BUFFER_BIT | ctx.DEPTH_BUFFER_BIT);
		} else {
			// ideally stage should have a graphic instance
			ctx.translate( 0, 0 );
			ctx.fillStyle = 'rgba(255,255,255,1);';
			ctx.fillRect( 0, 0, GetStageWidth(), GetStageHeight() );
		}

	}

	public function RenderAll()
	{
		Clear();

		SetupRender(mStageMatrix);

		__Render(Lib.canvas,null,0,0);
	}

	public function TabChange(inDiff:Int, inFromKey:Int)
	{
		var tabs = new Array<InteractiveObject>();

		for(i in 0...mObjs.length)
			mObjs[i].GetFocusObjects(tabs);

		var l = tabs.length;
		if (l==0)
			focus = null;
		else
		{
			var found = -1;
			if (mFocusObject!=null)
			{
				for(i in 0...l)
					if (tabs[i]==mFocusObject)
					{
						found = i;
						break;
					}
			}

			if (found<0)
				DoSetFocus(inDiff>0 ? tabs[0] : tabs[l-1], inFromKey);
			else
				DoSetFocus(tabs[ (l+inDiff+found) % l ], inFromKey);
		}
	}


	public function GetInteractiveObjectAtPos(inX:Int,inY:Int) : InteractiveObject
	{
		var l = mObjs.length-1;
		for(i in 0...mObjs.length)
		{
			var result = mObjs[l-i].GetObj(inX,inY,null);
			if (result!=null)
				return result;
		}
		return this;
	}

	public function SetQuality(inQuality:String):String
	{
		Manager.draw_quality = inQuality==StageQuality.LOW ? 0 : 1;
		return inQuality;
	}

	public function GetQuality():String
	{
		var q:Int = Manager.draw_quality;

		switch(q)
		{
			case 0: return StageQuality.LOW;
			case 1: return StageQuality.MEDIUM;
			case 2: return StageQuality.HIGH;
		}
		return StageQuality.BEST;
	}

	function SetFrameRate(speed:Float):Float
	{
		if ( StringTools.startsWith(Lib.context, "swf") ) return speed;

		var window : Window = cast js.Lib.window;
		if (speed == 0 && window.postMessage != null)
			mFastMode = true;
		else
		{
			mFastMode = false;
			mInterval = Std.int( 1000.0/speed );
		}

		SetTimer();

		this.frameRate = speed;
		return speed;
	}

	public function SetTimer () 
	{
		var window : Window = cast js.Lib.window;
		window.clearInterval( mTimer );
		if ( mFastMode )
		{
			window.addEventListener( 'message', Step, false );
			window.postMessage('a', cast window.location);
		} else {
			mTimer = window.setInterval( Step, mInterval, [] );
		}
	}

	function Step (?_) 
	{

		this.Clear();
		//mManager.clear(mStage.backgroundColor);

		// Send frame-enter event
		var event = new flash.events.Event( flash.events.Event.ENTER_FRAME );
		this.Broadcast(event);
		this.RenderAll();

		if ( mFastMode )
			untyped window.postMessage('a', window.location);
	}

}

