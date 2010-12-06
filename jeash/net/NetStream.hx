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

package jeash.net;
//import haxe.remoting.Connection;
import haxe.Timer;
import jeash.display.Graphics;
import jeash.events.Event;
import jeash.events.EventDispatcher;

import jeash.Lib;
import Html5Dom;

class NetStream extends EventDispatcher {
	/*
	 * todo:
	var audioCodec(default,null) : UInt;
	var bufferLength(default,null) : Float;
	var bufferTime :s Float;
	var bytesLoaded(default,null) : UInt;
	var bytesTotal(default,null) : UInt;
	var checkPolicyFile : Bool;
	var client : Dynamic;
	var currentFPS(default,null) : Float;
	var decodedFrames(default,null) : UInt;
	var liveDelay(default,null) : Float;
	var objectEncoding(default,null) : UInt;
	var soundTransform : flash.media.SoundTransform;
	var time(default,null) : Float;
	var videoCodec(default,null) : UInt;
	*/
	
	public var play:Dynamic;
	public var client:Dynamic;
	private static inline var fps:Int = 30;
	/**
	* handle to HTMLVideoElement, for windowed (performance) mode 
	*/
	public var videoElement(default, null):HTMLVideoElement;
	
	private var windowHack:Bool;
	
	/* buffer for incoming netstream */
	public var mTextureBuffer:HTMLCanvasElement;
	
	private var timer:Timer;

	/* events */
	public static inline var BUFFER_UPDATED:String = "jeash.net.NetStream.updated";
	
	public function new(connection:NetConnection) : Void
	{	
		super();
		windowHack = false;
		play = Reflect.makeVarArgs(js_play);
		
		mTextureBuffer = cast js.Lib.document.createElement('canvas');
		
		var nc:NetConnection = connection;
	}
	
	function js_play(val:Array<Dynamic>) : Void
	{
		handleVideo(val[0]);
		/* todo handling of filetypes:
		var r:EReg = ~/(?<=.)([^.]+)$/g;
		trace(val[0]);
		trace(r.match(val[0]));
		var ext:String; //get extension
		switch(val[0])
		{
			default:
			
		}
		*/
	}
	
	private function handleVideo(url:String):Void
	{
		videoElement = cast js.Lib.document.createElement("video");

		mTextureBuffer = cast js.Lib.document.createElement('canvas');

		//todo vid events as netstream events
		var obj:Dynamic = { video: videoElement };
		videoElement.addEventListener( "loadedmetadata", callback(handleVideoMetaData, obj ), false );
		
		videoElement.src = url;
		videoElement.play();
	}
	
	private function handleVideoMetaData(data:Dynamic, e):Void
	{
		mTextureBuffer.width = (jeash.Lib.mOpenGL)? Graphics.GetSizePow2(data.video.videoWidth) : data.video.videoWidth;
		mTextureBuffer.height = (jeash.Lib.mOpenGL)? Graphics.GetSizePow2(data.video.videoHeight) : data.video.videoHeight;
		if (!windowHack) //skip heavy load when pseudo windowless
		{
			var scope:NetStream = this;
			timer = new Timer(Math.round(1000 / (((Lib.GetStage().frameRate < NetStream.fps) ? NetStream.fps : Lib.GetStage().frameRate) * 2))); //dsp nyquist: fmax = fsample/2
			timer.run = function():Void 
			{
			  scope.mTextureBuffer.getContext("2d").drawImage(data.video, 0, 0, scope.mTextureBuffer.width, scope.mTextureBuffer.height);
			  scope.dispatchEvent(new Event(NetStream.BUFFER_UPDATED, false, false));
			}
		}
	}

	/**
	 * enable performance windowed mode;
	 * @return Bool succes.
	 */
	public function js_windowed_hack():Bool
	{
		windowHack = true;
		if (timer != null)
		{
			timer.stop();
			timer = null;
			return true;
		}
		return false;
	}
	
	/*
	todo:
	function attachAudio(microphone : flash.media.Microphone) : Void;
	function attachCamera(theCamera : flash.media.Camera, ?snapshotMilliseconds : Int) : Void;
	function close() : Void;
	function pause() : Void;
	function publish(?name : String, ?type : String) : Void;
	function receiveAudio(flag : Bool) : Void;
	function receiveVideo(flag : Bool) : Void;
	function receiveVideoFPS(FPS : Float) : Void;
	function resume() : Void;
	function seek(offset : Float) : Void;
	function send(handlerName : String, ?p1 \: Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
	function togglePause() : Void;

	#if flash10
	var maxPauseBufferTime : Float;
	var farID(default,null) : String;
	var farNonce(default,null) : String;
	var info(default,null) : NetStreamInfo;
	var nearNonce(default,null) : String;
	var peerStreams(default,null) : Array<Dynamic>;

	function onPeerConnect( subscriber : NetStream ) : Bool;
	function play2( param : NetStreamPlayOptions ) : Void;

	static var DIRECT_CONNECTIONS : String;
	#end
	*/
}
