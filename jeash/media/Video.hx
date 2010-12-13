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
	
	public var deblocking:Int;
	public var smoothing:Bool;
	public var videoHeight(default,null) : Int;
	public var videoWidth(default, null) : Int;
	
	/*
	 * 
	 * todo: netstream/camera
	 * 			check compat with flash events
	 */
	
	public function new(?width : Int, ?height : Int, ?Windowed:Bool = false) : Void {
		super();
		
		mGraphics = new Graphics();
		windowHack = Windowed;
		
		this.videoWidth = width;
		this.videoHeight = height;
		
		mGraphics.beginFill(0xDEADBEEF);
		mGraphics.drawRect(0,0,width,height);
		mGraphics.endFill();
		
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
		
		/*
		if (ns.videoElement.readyState == Type.enumIndex(ReadyState.HAVE_NOTHING))
		{
			trace(this + " attach should be done after connected event.");
			//return;
		}
		*/
		
		ns.videoElement.width = this.videoWidth;
		ns.videoElement.height = this.videoHeight;
		
		ns.mTextureBuffer.width = this.videoWidth;
		ns.mTextureBuffer.height = this.videoHeight;
		
		if (this.windowHack)// pseudo windowed hack
		{
			var canvas:HtmlDom = cast Lib.canvas;
			canvas.style.zIndex = 3;
			canvas.style.position = 'absolute';
			var el:HtmlDom = cast ns.videoElement;
			//js.Lib.document.body.appendChild(el);
			canvas.parentNode.appendChild(el);
			//canvas.parentNode.style.overflow = 'hidden';
			el.style.position = 'absolute';
			el.style.top = "0px";
			el.style.left = "0px";
			el.style.zIndex = 2;
			
			var offsetLeft = canvas.offsetLeft;
			var offsetTop = canvas.offsetTop;
			
			ns.js_windowed_hack();
			
			this.renderHandler = function(e:Event):Void 
			{  
				scope.SetupRender(new Matrix()); //dirty reset matrix
				
				//todo get stage x/y
				var g:Point = scope.localToGlobal(new Point(0, 0));
				var px = g.x; var py = g.y;
				
				var ctx:CanvasRenderingContext2D = Lib.canvas.getContext('2d');
				ctx.clearRect(px, py, scope.width, scope.height);	
				
				//todo get overlapping displayobjects, and render them after clearrect;
				ctx.fillStyle = "rgba(255, 0, 0, 0.2)";
				ctx.fillRect(px, py, scope.width/2, scope.height);
				el.style.top = py + offsetTop + "px";
				el.style.left = px + offsetLeft + "px";				
			}
			
			// do this after rendering pass:
			this.addEventListener(Event.RENDER, this.renderHandler );
		}
		else
		{
			// 'windowless'
			scope.renderHandler = function(e:Event):Void
			{
				scope.SetupRender(new Matrix()); //ugly reset matrix..
				
				//todo:revise:something brokehn
				scope.mGraphics.clear();
				/*
				var bd:BitmapData = new BitmapData(scope.videoWidth, scope.videoHeight);
				var m:Matrix = new Matrix();
				m.scale(scope.videoWidth / ns.mTextureBuffer.width, scope.videoHeight / ns.mTextureBuffer.height);
				bd.draw( BitmapData.CreateFromHandle(ns.mTextureBuffer), m);
				*/
				var bd:BitmapData = BitmapData.CreateFromHandle(ns.mTextureBuffer);
				
				#if !js
					scope.mGraphics.blit(bd);
				#end
				
				#if js
					scope.mGraphics.beginBitmapFill(bd, null, false, false);
					//scope.mGraphics.beginFill(0x00FF00);
					//scope.mGraphics.drawRect(0, 0, scope.width, scope.height);
					scope.mGraphics.drawRect(0, 0, ns.mTextureBuffer.width, ns.mTextureBuffer.height);
					scope.mGraphics.endFill();
					
					//hrrm: not finished->
					//scope.UpdateMatrix();
					//scope.drawToSurface(ns.mTextureBuffer, null, null, null, null, true);
				#end
			}
			
			ns.addEventListener(NetStream.BUFFER_UPDATED, renderHandler);
		}
	}
	
	public function clear():Void
	{
		if (this.renderHandler != null)
		{
			if (!this.windowHack)
			{
				this.netStream.removeEventListener(NetStream.BUFFER_UPDATED, renderHandler);
			}
			else
			{
				this.removeEventListener(Event.RENDER, renderHandler );
			}
			this.mGraphics.clear();
		}
	}
}