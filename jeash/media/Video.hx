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

package jeash.media;
import flash.events.Event;
import haxe.Timer;
import Html5Dom;
import jeash.display.BitmapData;
import jeash.display.DisplayObject;
import jeash.display.Graphics;
import jeash.display.Stage;
import jeash.geom.Matrix;
import jeash.geom.Point;
import jeash.Lib;
import jeash.net.NetStream;
import js.Dom;
import jeash.media.VideoElement;

class Video extends DisplayObject {
	
	private var mGraphics:Graphics;
	
	private var windowHack:Bool;
	private var netStream:NetStream;
	private var renderHandler:Event->Void;

	private var videoElement(default,null):HTMLVideoElement;
	
	public var deblocking:Int;
	public var smoothing:Bool;
	
	/*
	 * 
	 * todo: netstream/camera
	 * 			check compat with flash events
	 */
	
	public function new(width : Int = 320, height : Int = 240) : Void {
		super();
		
		mGraphics = new Graphics();
		mGraphics.drawRect(0, 0, width, height);
		
		this.width = width;
		this.height = height;
		
		name = "Video_" + DisplayObject.mNameID++;
		
		this.smoothing = false;
		this.deblocking = 0;
		
		this.addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	private function added(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	//displayobject override
	override public function GetGraphics():Graphics
	{ 
		return mGraphics; 
	}
	
	/*
	public function attachCamera(camera : jeash.net.Camera) : Void;
	{
		// (html5 <device/> 
		throw "not implemented";
	}
	*/
	
	public function attachNetStream(ns:NetStream) : Void
	{
		this.netStream = ns;
		var scope:Video = this;
		
		mGraphics.SetSurface(ns.jeashVideoElement);

		ns.jeashVideoElement.width = width;
		ns.jeashVideoElement.height = height;

		ns.jeashVideoElement.play();
	}
	
	public function clear():Void
	{
		if (mGraphics != null)
			jeash.Lib.jeashRemoveSurface(mGraphics.mSurface);
		mGraphics = new Graphics();
		mGraphics.drawRect(0, 0, width, height);
	}

	override public function __Render(?inMask:HTMLCanvasElement, inTX:Int = 0, inTY:Int = 0)
	{
		var gfx = GetGraphics();

		if (gfx!=null)
		{
			Lib.jeashSetSurfaceTransform(gfx.mSurface, mFullMatrix);
		}
	}
	
	override public function jeashGetObjectUnderPoint(point:Point)
	{
		var local = globalToLocal(point);
		if (local.x >= 0 && local.y >= 0 && local.x <= width && local.y <= height)

		{
			// NOTE: bad cast, should be InteractiveObject... 
			return cast this;
		}
		else
			return null;
	}
}
