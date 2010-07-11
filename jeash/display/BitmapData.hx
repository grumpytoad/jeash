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

		// TODO: the following was a hack in the canvas-nme days in
		// order to load embedded resources, in order to emulate the
		// embed tag in flex. This sort of feature should be
		// replaced by supporting the -resource haXe compiler flag.

		var el : Dynamic = js.Lib.document.getElementById( Type.getClassName( Type.getClass( this ) ) );
		if ( el != null ) {
			mTextureBuffer = el;
		} else {
			mTextureBuffer = cast js.Lib.document.createElement('canvas');
			mTextureBuffer.width = inWidth;
			mTextureBuffer.height = inHeight;
			if ( inFillColour != null )
			{
				// TODO: need support for inTransparent
				graphics.beginFill(inFillColour);
				graphics.drawRect(0,0,inWidth,inHeight);
				graphics.endFill();
				var imgdata = mTextureBuffer.getContext("2d").getImageData(0,0,inWidth,inHeight);
			}
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
		graphics.beginFill(color);
		graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		graphics.endFill();
	}

	public function getPixels(rect:Rectangle):ByteArray
	{
		var bytes = haxe.io.Bytes.alloc(cast(3 * rect.width * rect.height, Int));
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(rect.x + graphics.mSurfaceOffset, rect.y + graphics.mSurfaceOffset, rect.width, rect.height);
		for (i in 0...imagedata.data.length) {
			bytes.set(i, imagedata.data[i]);
		}
		return new ByteArray(bytes);
	}

	public function getPixel(x:Int, y:Int) : Int
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x + graphics.mSurfaceOffset, y + graphics.mSurfaceOffset, 1, 1);
		return (imagedata.data[0] << 16) | (imagedata.data[1] << 8) | (imagedata.data[2]);
	}

	public function getPixel32(x:Int, y:Int) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x + graphics.mSurfaceOffset, y + graphics.mSurfaceOffset, 1, 1);
		return (imagedata.data[3] << 24) | (imagedata.data[0] << 16) | imagedata.data[1] << 8 | imagedata.data[2];
	}

	public function setPixel(x:Int, y:Int, color:UInt) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imageData = ctx.createImageData( 1, 1 );
		imageData.data[0] = (color & 0xFF0000) >>> 16;
		imageData.data[1] = (color & 0x00FF00) >>> 8;
		imageData.data[2] = (color & 0x0000FF) ;
		imageData.data[3] = 0xFF;
		ctx.putImageData(imageData, x + graphics.mSurfaceOffset, y + graphics.mSurfaceOffset);
	}

	public function setPixel32(x:Int, y:Int, color:UInt) 
	{
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imageData = ctx.createImageData( 1, 1 );
		imageData.data[0] = (color & 0xFF0000) >>> 16;
		imageData.data[1] = (color & 0x00FF00) >>> 8;
		imageData.data[2] = (color & 0x0000FF) ;
		imageData.data[3] = 0xFF;
		ctx.putImageData(imageData, x + graphics.mSurfaceOffset, y + graphics.mSurfaceOffset);
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

	public inline function handle() 
	{
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

	function OnLoad( data:{image:Image, canvas:HtmlCanvasElement, inLoader:LoaderInfo}, e)
	{
		data.canvas.width = data.image.width;
		data.canvas.height = data.image.height;

		var ctx : CanvasRenderingContext2D = data.canvas.getContext('2d');
		ctx.drawImage(data.image, 0, 0);

		var e = new flash.events.Event( flash.events.Event.COMPLETE );
		e.target = data.inLoader;
		data.inLoader.dispatchEvent( e );
	}

	public function LoadFromFile(inFilename:String, ?inLoader:LoaderInfo)
	{
		var image : Image = cast js.Lib.document.createElement("img");
		if ( inLoader != null ) 
			image.addEventListener( "load", callback(OnLoad,{image:image, canvas:mTextureBuffer, inLoader:inLoader}), false );
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

