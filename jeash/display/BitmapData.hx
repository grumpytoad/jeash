package jeash.display;

import Html5Dom;
import flash.Lib;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.Int32;
import flash.display.BlendMode;
import flash.display.IBitmapDrawable;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.ColorTransform;

import haxe.xml.Check;

class BitmapData implements IBitmapDrawable
{
	private var mTextureBuffer:HtmlCanvasElement;

	public var width(getWidth,null):Int;
	public var height(getHeight,null):Int;
	public var graphics(getGraphics,null):Graphics;

	public function new(inWidth:Int, inHeight:Int,
			?inTransparent:Bool = true,
			?inFillColour:Int)
	{

		// TODO: this was a hack in the canvas-nme days in order to
		// load embedded resources, in order to emulate the embed tag
		// in flex. IMO this sort of feature should be replaced by
		// supporting the -resource haXe compiler flag.

		var el : Dynamic = js.Lib.document.getElementById( Type.getClassName( Type.getClass( this ) ) );
		if ( el != null ) {
			mTextureBuffer = el;
		} else if (inWidth<1 || inHeight<1) {
			mTextureBuffer = null;
		} else {
			mTextureBuffer = cast js.Lib.document.createElement('canvas');
			mTextureBuffer.width = inWidth;
			mTextureBuffer.height = inHeight;
		}
	}

	public var rect : Rectangle;

	public function draw( source:IBitmapDrawable,
			matrix:Matrix = null,
			colorTransform:ColorTransform = null,
			blendMode:String = null, 
			clipRect:Rectangle = null,
			smoothing:Bool = false ):Void
	{
		source.drawToSurface(mTextureBuffer, matrix, colorTransform, blendMode, clipRect, smoothing);
	}

	public function getColorBoundsRect( a:Int, b:Int, c:Bool ) : Rectangle {
		return new Rectangle();
	}

	public function dispose() : Void {
	}

	public function compare ( inBitmapTexture : BitmapData ) : Int {
		throw "Not implemented. compare";
		return 0x00000000;
	}

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point,
			?alphaBitmapData:BitmapData, ?alphaPoint:Point, mergeAlpha:Bool = false):Void
	{
		if (sourceBitmapData.handle() == null || mTextureBuffer == null)
			return;

		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		ctx.drawImage(sourceBitmapData.handle(), sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
	}

	public function fillRect(rect: Rectangle, color: Int) : Void {
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');

		var r:Float;
		var g:Float;
		var b:Float;
		r = (0xFF0000 & color) >> 16;
		g = (0x00FF00 & color) >> 8; b = (0x0000FF & color);
		ctx.fillStyle = 'rgba' + '(' + r + ',' + g + ',' + b + ',' + 1 + ')';
		ctx.fillRect(rect.x, rect.y, rect.width, rect.height);

	}

	public function getPixels(rect:Rectangle):ByteArray
	{
		var bytes = haxe.io.Bytes.alloc(cast(3 * rect.width * rect.height, Int));
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(rect.x, rect.y, rect.width, rect.height);
		for (i in 0...imagedata.data.length) {
			bytes.set(i, imagedata.data[i]);
		}
		return new ByteArray(bytes);
	}

	public function getPixel(x:Int, y:Int) : Int
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x, y, 1, 1);
		return imagedata.data[3] << 6 | imagedata.data[0] << 4 | imagedata.data[1] << 2 | imagedata.data[2];
	}

	public function getPixel32(x:Int, y:Int) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x, y, 1, 1);
		return imagedata.data[0] << 4 | imagedata.data[1] << 2 | imagedata.data[2];
	}

	public function setPixel(x:Int, y:Int, color:UInt) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imageData = ctx.createImageData( 1, 1 );
		imageData.data[0] = (color & 0xFF0000) >>> 16;
		imageData.data[1] = (color & 0x00FF00) >>> 8;
		imageData.data[2] = (color & 0x0000FF) ;
		imageData.data[3] = 0xFF;
		ctx.putImageData(imageData, x, y);
	}

	public function setPixel32(x:Int, y:Int, color:UInt) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imageData = ctx.createImageData( 1, 1 );
		imageData.data[0] = (color & 0xFF0000) >>> 16;
		imageData.data[1] = (color & 0x00FF00) >>> 8;
		imageData.data[2] = (color & 0x0000FF) ;
		imageData.data[3] = 0xFF;
		ctx.putImageData(imageData, x, y);
	}

	public function clone() : BitmapData {
		return this;
	}

	public function getGraphics() : Graphics
	{
		if (graphics==null)
			graphics = new Graphics(mTextureBuffer);
		return graphics;
	}
	public function flushGraphics()
	{
		if (graphics!=null)
			graphics.flush();
	}

	public function handle() { 
		return mTextureBuffer; 
	}

	public function getWidth() : Int { 
		if ( mTextureBuffer != null ) {
			return mTextureBuffer.width;
		} else {
			return 0;
		}
	}
	public function getHeight()  : Int { 
		if ( mTextureBuffer != null ) {
			return mTextureBuffer.height;
		} else {
			return 0;
		}
	}


	public function destroy()
	{
		mTextureBuffer = null;
	}

	public function LoadFromFile(inFilename:String, ?inLoader:LoaderInfo)
	{
		var image : Image = cast js.Lib.document.createElement("img");
		if ( inLoader != null ) {
			var me = this;
			image.addEventListener( "load", function (_) {
				me.mTextureBuffer = cast js.Lib.document.createElement('canvas');
				me.mTextureBuffer.width = image.width;
				me.mTextureBuffer.height = image.height;
				var ctx : CanvasRenderingContext2D = me.mTextureBuffer.getContext('2d');
				ctx.drawImage(untyped image, 0, 0);
				var e = new flash.events.Event( flash.events.Event.COMPLETE );
				e.target = inLoader;
				inLoader.dispatchEvent( e );
			}, false );
		}
		image.src = inFilename;
	}


	static public function CreateFromHandle(inHandle:HtmlCanvasElement) : BitmapData
	{
		var result = new BitmapData(0,0);
		result.mTextureBuffer = inHandle;
		return result;
	}

	public function lock() : Void
	{
	}

	public function unlock(?changeRect : flash.geom.Rectangle) : Void
	{
	}

	// IBitmapDrawable inferface...
	public function drawToSurface(inSurface : Dynamic,
			matrix:flash.geom.Matrix,
			colorTransform:flash.geom.ColorTransform,
			blendMode: String,
			clipRect:Rectangle,
			smothing:Bool):Void
	{
		var ctx : CanvasRenderingContext2D = inSurface.getContext('2d');
		ctx.save();
		if (matrix != null) {
			ctx.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		}
		ctx.drawImage(handle(), 0, 0);
		ctx.restore();
	}
}

