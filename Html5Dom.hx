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
	function dispatchEvent( event:Event ):Void;
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
	function drawImage( image:HtmlCanvasElement, sx:Float, sy:Float, ?sw:Float, ?sh:Float, ?dx:Float, ?dy:Float, ?dw:Float, ?dh:Float):Void;

	// pixel manipulation
	function createImageData(sw:Float, sh:Float):ImageData;
	function getImageData(sx:Float, sy:Float, sw:Float, sh:Float):ImageData;
	function putImageData( imagedata:ImageData, dx:Float, dy:Float, ?dirtyX:Float, ?dirtyY:Float, ?dirtyWidth:Float, ?dirtyHeight:Float):Void;
}

typedef Image = { > HtmlDom,
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

	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function dispatchEvent( event:js.Event ):Void;
}

typedef EventTarget = {
	function addEventListener( type:String, listener:EventListener, useCapture:Bool ):Void;
	function removeListener( type:String, listener:EventListener, useCapture:Bool ):Void;
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
