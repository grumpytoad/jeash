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

import flash.Lib;
#if !js
import nme.Manager;
import nme.geom.Matrix;
#else
import flash.Manager;
import flash.geom.Matrix;
#end
import flash.events.FocusEvent;
import flash.events.Event;
import flash.display.StageScaleMode;


class Stage extends flash.display.DisplayObjectContainer
{
	var mManager:Manager;
	var mWidth:Int;
	var mHeight:Int;
	var mWindowWidth:Int;
	var mWindowHeight:Int;

	public var stageWidth(GetStageWidth,null):Int;
	public var stageHeight(GetStageHeight,null):Int;
	public var frameRate(default,default):Float;
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

	public function new(inWidth:Int,inHeight:Int,inManager:Manager)
	{
		super();
		mFocusObject = null;
		mManager = inManager;
		mWindowWidth = mWidth = inWidth;
		mWindowHeight = mHeight = inHeight;
		stageFocusRect = false;
		scaleMode = StageScaleMode.SHOW_ALL;
		mStageMatrix = new Matrix();
		RecalcScale();
		tabEnabled = true;
		// fast as possible ...
		frameRate=0;
		SetBackgroundColour(0xffffff);
		name = "Stage";
	}

	public function OnResize(inW:Int, inH:Int)
	{
		mWindowWidth = inW;
		mWindowHeight = inH;
		RecalcScale();
		var event = new Event( Event.RESIZE );
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
				var event = new FocusEvent(FocusEvent.FOCUS_OUT, true, false, mFocusObject );
				event.relatedObject = inObj;

				Lib.SendEventToObject(event,mFocusObject);
			}

			var old = mFocusObject;
			mFocusObject = inObj;

			if (mFocusObject!=null)
			{
				mFocusObject.OnFocusIn(inKeyCode<0);
				var event = new FocusEvent(FocusEvent.FOCUS_IN, true, false, inObj );
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
		// ideally stage should have a graphic instance
		var ctx = Lib.canvas.getContext("2d");
		ctx.translate( 0, 0 );
		ctx.fillStyle = 'rgba(255,255,255,1);';
		ctx.fillRect( 0, 0, GetStageWidth(), GetStageHeight() );

	}

	public function RenderAll()
	{
		//mManager.clear(backgroundColor);
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


#if !js
	static var nme_init_view = nme.Loader.load("nme_init_view",2);
#end

}

