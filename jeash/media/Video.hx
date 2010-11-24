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
import jeash.Lib;
import jeash.net.NetStream;
import js.Dom;

class Video extends DisplayObject {
	
	private var mGraphics:Graphics;
	
	public var deblocking:Int;
	public var smoothing:Bool;
	
	/*
	 * 
	 * todo: netstream/camera
	 * 			check compat with flash events
	var deblocking : Int;
	var smoothing : Bool;
	var videoHeight(default,null) : Int;
	var videoWidth(default,null) : Int;
	function new(?width : Int, ?height : Int) : Void;
	function attachCamera(camera : Camera) : Void; // (html5 <device/> : 
	function attachNetStream(netStream : flash.net.NetStream) : Void;  // dummy object for compat
	function clear() : Void;
	*/
	
	public function new(?Windowed:Bool = false) : Void {
		
		mGraphics = new Graphics();
		
		mGraphics.beginFill(0xDEADBEEF);
		mGraphics.drawRect(0,0,720,404);
		mGraphics.endFill();
		
		super();
		name = "Video " + DisplayObject.mNameID++;
		
		this.smoothing = false;
		this.deblocking = 0;
		
		this.addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	private function added(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		
		//var vid:HTMLVideoElement = cast js.Lib.document.createElement("video");
		//var mTextureBuffer:HTMLCanvasElement = cast js.Lib.document.createElement('canvas');
		//mTextureBuffer.width = 720;
		//mTextureBuffer.height = 404;
		//var ctx:CanvasRenderingContext2D =  mTextureBuffer.getContext("2d");
		
		//var data:Dynamic = { video: vid, texture: mTextureBuffer, context: ctx, graphics: mGraphics };
		//vid.addEventListener( "loadeddata", callback(OnLoad, data), false ); //
		//vid.addEventListener( "loadedmetadata", callback(OnLoad, data), false ); //
		
		//vid.addEventListener( "timeupdate", callback(TimeUpdate, data), false ); //
		
		//vid.src = _url;
		
		//vid.play();
		
		//this.mGraphics.SetSurface(mTextureBuffer);
		
		/*
		Lib.GetStage().addEventListener(Event.ENTER_FRAME, function(e:Event):Void
		{
			me.updateGraphics(vid, ctx, mGraphics_ref, mTextureBuffer);
		});
		*/
		/*
		var t:Timer = new Timer(Math.round(1000 / (((stage.frameRate < Video.fps) ? Video.fps : stage.frameRate) * 2))); //dsp nyquist: fmax = fsample/2
		var mGraphics_ref:Graphics = this.mGraphics;
		var me:Video = this;
		t.run = function():Void 
		{ 
			me.updateGraphics(vid, ctx, mGraphics_ref, mTextureBuffer);
		}
		
		vid.addEventListener( "ended", callback(function(e):Void { trace("stop!"); t.stop();  } ), false );
		*/
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
		if (true)// pseudo windowed hack
		{
			var canvas:HtmlDom = cast Lib.canvas;
			canvas.style.zIndex = 3;
			canvas.style.position = 'absolute';
			var el:HtmlDom = cast ns.videoElement;
			js.Lib.document.body.appendChild(el);
			el.style.position = 'absolute';
			el.style.top = "0px";
			el.style.left = "0px";
			el.style.zIndex = 2;
			
			var offsetLeft = canvas.offsetLeft;
			var offsetTop = canvas.offsetTop;
			
			// do this after rendering pass:
			var instance:Video = this;
			this.addEventListener(Event.RENDER, function(e:Event):Void 
			{  
				//todo get stage x/y
				var px = instance.parent.x;
				var py = instance.parent.y;
				
				var ctx = Lib.canvas.getContext('2d');
				ctx.clearRect(px, py, 720, 404);	
				el.style.top = py + offsetTop + "px";
				el.style.left = px + offsetLeft + "px";
			} );
		}
		else
		{
			//windowless
			var scope:Video = this;
			ns.addEventListener(NetStream.BUFFER_UPDATED, function(e:Event):Void
			{
				scope.mGraphics.clear();
				
				#if !js
					scope.mGraphics.blit(BitmapData.CreateFromHandle(ns.mTextureBuffer));
				#end
				
				#if js
					scope.mGraphics.beginBitmapFill(BitmapData.CreateFromHandle(ns.mTextureBuffer), null, false, false);
					scope.mGraphics.drawRect(0,0,720, 404);
				#end
			});
		}
	}
}