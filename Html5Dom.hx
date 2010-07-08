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

import js.Dom;

typedef CanvasGradient = {
	function addColorStop(offset:Float, color:String):Void;
}

typedef CanvasPattern = {}

extern class CanvasPixelArray implements ArrayAccess<Int> {
	var length(default,null):Int;
}

typedef HtmlCanvasElement = { > HtmlDom,
	var width:Int;
	var height:Int;
	function toDataURL( ?type:String ):String;
	function getContext( contextId:String ):CanvasRenderingContext2D;
	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function removeEventListener( type:String, listener:EventListener,useCapture:Bool ):Void;
	function dispatchEvent( event:Event ):Void;
}

typedef Html5Node = { > HtmlDom,
	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function removeEventListener( type:String, listener:EventListener,useCapture:Bool ):Void;
	function dispatchEvent( event:Event ):Void;
}

typedef NamedNodeMap = {
	function item(index:Int):Html5Node;
	var length:Int;
}

typedef ImageData = {
	var width:Int;
	var height:Int;
	var data:CanvasPixelArray;
}

typedef TextMetrics = {
	var width(default,null):Float;
}

typedef UInt = Int;

typedef CanvasRenderingContext2D = {

	// back-reference to the canvas
	var canvas(default,null):HtmlCanvasElement;

	// state
	function save():Void; // push state on state stack
	function restore():Void; // pop state stack and restore state

	// transformations (default transform is the identity matrix)
	function scale( x:Float,  y:Float):Void;
	function rotate( angle:Float):Void;
	function translate( x:Float, y:Float):Void;
	function transform( m11:Float, m12:Float, m21:Float, m22:Float, dx:Float, dy:Float):Void;
	function setTransform(m11:Float, m12:Float, m21:Float, m22:Float, dx:Float, dy:Float):Void;

	// compositing
	var globalAlpha:Float; // (default 1.0)
	var globalCompositeOperation:String; // (default source-over)

	// colors and styles
	var strokeStyle:Dynamic; // (default black)
	var fillStyle:Dynamic; // (default black)
	function createLinearGradient(x0:Float, y0:Float, x1:Float, y1:Float):CanvasGradient;
	function createRadialGradient(x0:Float, y0:Float, r0:Float, x1:Float, y1:Float, r1:Float):CanvasGradient;
	function createPattern( image:Dynamic, repetition:String):CanvasPattern;

	// line caps/joins
	var lineWidth:Float;
	var lineCap:String;
	var lineJoin:String;
	var miterLimit:Float;

	// shadows
	var shadowOffsetX:Float;
	var shadowOffsetY:Float;
	var shadowBlur:Float;
	var shadowColor:String;

	// rects
	function clearRect( x:Float, y:Float, w:Float, h:Float):Void;
	function fillRect( x:Float, y:Float, w:Float, h:Float):Void;
	function strokeRect( x:Float, y:Float, w:Float, h:Float):Void;

	// path API
	function beginPath():Void;
	function closePath():Void;
	function moveTo( x:Float, y:Float):Void;
	function lineTo( x:Float, y:Float):Void;
	function quadraticCurveTo( cpx:Float, cpy:Float, x:Float, y:Float):Void;
	function bezierCurveTo( cp1x:Float, cp1y:Float, cp2x:Float, cp2y:Float, x:Float, y:Float):Void;
	function arcTo( x1:Float, y1:Float, x2:Float, y2:Float, radius:Float):Void;
	function rect( x:Float, y:Float, w:Float, h:Float):Void;
	function arc( x:Float, y:Float, radius:Float, startAngle:Float, endAngle:Float, anticlockwise:Bool):Void;
	function fill():Void;
	function stroke():Void;
	function clip():Void;
	function isPointInPath( x:Float, y:Float):Bool;

	// text
	var font:String;
	var textAlign:String;
	var textBaseline:String;
	function fillText( text:String, x:Float, y:Float, ?maxWidth:Float):Void;
	function strokeText( text:String, x:Float, y:Float, ?maxWidth:Float):Void;
	function measureText( text:String ):TextMetrics;

	// drawing images
	function drawImage( image:Html5Node, sx:Float, sy:Float, ?sw:Float, ?sh:Float, ?dx:Float, ?dy:Float, ?dw:Float, ?dh:Float):Void;

	// pixel manipulation
	function createImageData(sw:Float, sh:Float):ImageData;
	function getImageData(sx:Float, sy:Float, sw:Float, sh:Float):ImageData;
	function putImageData( imagedata:ImageData, dx:Float, dy:Float, ?dirtyX:Float, ?dirtyY:Float, ?dirtyWidth:Float, ?dirtyHeight:Float):Void;
}

typedef Image = { > Html5Node,
	var align : String;
	var alt : String;
	var border : String;
	var height : Int;
	var hspace : Int;
	var isMap : Bool;
	var name : String;
	var src : String;
	var useMap : String;
	var vspace : Int;
	var width : Int;

	var complete : Bool;
	var lowsrc : String;

}

typedef EventTarget = {
	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function removeEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function dispatchEvent( evt:Event ):Bool;
}

typedef EventListener = Event -> Void;

extern class Event {
	static var CAPTURING_PHASE = 1;
	static var AT_TARGET = 2;
	static var BUBBLING_PHASE = 3;

	var type(default,null):String;
	var target(default,null):EventTarget;
	var currentTarget(default,null):EventTarget;
	var eventPhase(default,null):Int;
	var bubbles(default,null):Bool;
	var cancelable(default,null):Bool;
	var timeStamp(default,null):Int;
	function stopPropagation():Void;
	function preventDefault():Void;
	function initEvent(eventTypeArg:String, canBubbleArg:Bool, cancelableArg:Bool):Void;
}

extern class DocumentEvent extends Event {
	function createEvent( eventType:String ):Event;
}

extern class UIEvent extends Event {
	var view(default,null):Dynamic;
	var detail(default,null):Int;
	function initUIEvent(typeArg:String, canBubbleArg:Bool, cancelableArg:Bool, viewArg:Dynamic, detailArg:Int):Void;
}

extern class MouseEvent extends UIEvent {
	var screenX:Int;
	var screenY:Int;
	var clientX:Int;
	var clientY:Int;
	var ctrlKey:Bool;
	var shiftKey:Bool;
	var altKey:Bool;
	var metaKey:Bool;
	var button:Int;
	var relatedTarget:EventTarget;
	function initMouseEvent(typeArg:String, canBubbleArg:Bool, cancelableArg:Bool, viewArg:Dynamic, detailArg:Int, screenXArg:Int, screenYArg:Int, clientXArg:Int, clientYArg:Int, ctrlKeyArg:Bool, altKeyArg:Bool, shiftKeyArg:Bool, metaKeyArg:Bool, buttonArg:Int, relatedTargetArg:EventTarget):Void;
}

extern class MutationEvent extends Event {
	static var MODIFICATION = 1;
	static var ADDITION = 2;
	static var REMOVAL = 3;

	var relatedNode:Dynamic; // should be DOM level 2 "Node" 
	var prevValue:String;
	var newValue:String;
	var attrName:String;
	var attrChange:Int;
	function initMutationEvent(typeArg:String, canBubbleArg:Bool, cancelableArg:Bool, relatedNodeArg:Dynamic, prevValueArg:String, newValueArg:String, attrNameArg:String, attrChangeArg:Int):Void;

}

extern class HtmlAudioElement extends HtmlMediaElement {
	public function new(?src:String):Void;
}
extern class HtmlMediaElement {

	// error state
	var error(default, null):MediaError;

	// network state
	var src:String;
	var currentSrc(default, null):String;
	static var NETWORK_EMPTY = 0;
	static var NETWORK_IDLE = 1;
	static var NETWORK_LOADING = 2;
	static var NETWORK_NO_SOURCE = 3;

	var networkState(default, null):Int;
	var preload:String;
	var buffered:TimeRanges;
	function load():Void;
	function canPlayType(type:String):String;

	// ready state
	static var HAVE_NOTHING = 0;
	static var HAVE_METADATA = 1;
	static var HAVE_CURRENT_DATA = 2;
	static var HAVE_FUTURE_DATA = 3;
	static var HAVE_ENOUGH_DATA = 4;

	var readyState(default, null):Int;
	var seeking:Bool;

	// playback state
	var currentTime:Float;
	var startTime(default, null):Float;
	var duration(default, null):Float;
	var paused(default, null):Bool;
	var defaultPlaybackRate:Float;
	var playbackRate:Float;
	var played(default, null):TimeRanges;
	var seekable(default, null):TimeRanges;
	var ended(default, null):Bool;
	var loop:Bool;

	function play():Void;
	function pause():Void;

	// controls
	var controls:Bool;
	var volume:Float;
	var muted:Bool;

	// HtmlElement - @TODO: put this in a super class
	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function removeEventListener( type:String, listener:EventListener,useCapture:Bool ):Void;
	function dispatchEvent( evt:Event ):Bool;
}

extern class MediaError {
	static var MEDIA_ERR_ABORTED = 1;
	static var MEDIA_ERR_NETWORK = 2;
	static var MEDIA_ERR_DECODE = 3;
	static var MEDIA_ERR_SRC_NOT_SUPPORTED = 4;
	var code(default, null):Int;
}

typedef TimeRanges = {
	var length(default, null):Int;
	function start(index:Int):Float;
	function end(index:Int):Float;
}
