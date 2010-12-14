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
import flash.display.BlendMode;
import flash.display.IBitmapDrawable;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.filters.BitmapFilter;

import haxe.xml.Check;

typedef LoadData =
{
	var image : HTMLImageElement;
	var texture:HTMLCanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
}

class BitmapData implements IBitmapDrawable
{
	private var mTextureBuffer:HTMLCanvasElement;
	private var mTransparent:Bool;

	public var width(getWidth,null):Int;
	public var height(getHeight,null):Int;
	public var graphics(getGraphics,null):Graphics;

	public function new(inWidth:Int, inHeight:Int,
			?inTransparent:Bool = true,
			?inFillColour:Int)
	{

		// Load embedded images in the HTML file

		var image : Dynamic = js.Lib.document.getElementById( Type.getClassName( Type.getClass( this ) ) );
		if ( image != null ) {
			mTextureBuffer = cast js.Lib.document.createElement('canvas');
			var data : LoadData = {image:image, texture: mTextureBuffer, inLoader:null, bitmapData:this};
			if (!image.complete)
				image.addEventListener( "load", callback(OnLoad, data), false );
			else
				OnLoad(data, null);
		} else {
			mTextureBuffer = cast js.Lib.document.createElement('canvas');
			mTextureBuffer.width = inWidth;
			mTextureBuffer.height = inHeight;

			mTransparent = inTransparent;
			if ( inFillColour != null )
			{
				if (!mTransparent)
					inFillColour |= 0xFF000000;

				var rect = new Rectangle(0,0,inWidth,inHeight);
				fillRect(rect,inFillColour);
				var imgdata = mTextureBuffer.getContext("2d").getImageData(0,0,inWidth,inHeight);
			}
		}
	}

	public var rect : Rectangle;

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter)
	{
		throw "BitmapData.applyFilter not implemented in Jeash";
	}

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

	private function clipRect (r: Rectangle): Rectangle
	{
		if (r.x < 0)
		{
			r.width -= -r.x;
			r.x = 0;
			if (r.x + r.width <= 0)
				return null;
		}
		if (r.y < 0)
		{
			r.height -= -r.y;
			r.y = 0;
			if (r.y + r.height <= 0)
				return null;
		}
		if (r.x + r.width >= getWidth ())
		{
			r.width -= r.x + r.width - getWidth ();
			if (r.width <= 0)
				return null;
		}
		if (r.y + r.height >= getHeight ())
		{
			r.height -= r.y + r.height - getHeight ();
			if (r.height <= 0)
				return null;
		}
		return r;
	}

	public function fillRect(rect: Rectangle, color: UInt) : Void
	{
		rect = clipRect (rect);
		if (rect == null) return;

		var r: Int = (color & 0xFF0000) >>> 16;
		var g: Int = (color & 0x00FF00) >>> 8;
		var b: Int = (color & 0x0000FF);
		var a: Int = (mTransparent)? (color >>> 24) : 0xFF;

		var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData (rect.x, rect.y, rect.width, rect.height);
		for (i in 0...imagedata.data.length >> 2)
		{
			imagedata.data[i * 4] = r;
			imagedata.data[i * 4 + 1] = g;
			imagedata.data[i * 4 + 2] = b;
			imagedata.data[i * 4 + 3] = a;
		}
		ctx.putImageData (imagedata, rect.x, rect.y);
	}

	public function getPixels(rect:Rectangle):ByteArray
	{
		var byteArray = new ByteArray();

		rect = clipRect (rect);
		if (rect == null) return byteArray;

		var bytes = haxe.io.Bytes.alloc(cast(3 * rect.width * rect.height, Int));
		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(rect.x, rect.y, rect.width, rect.height);
		for (i in 0...imagedata.data.length) {
			bytes.set(i, imagedata.data[i]);
		}
		for ( i in 0...bytes.length )
			byteArray.writeByte( bytes.get(i) );
		return byteArray;
	}

	public function getPixel(x:Int, y:Int) : UInt
	{
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return 0;

		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x, y, 1, 1);
		return (imagedata.data[0] << 16) | (imagedata.data[1] << 8) | (imagedata.data[2]);
	}

	public function getPixel32(x:Int, y:Int)
	{
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return 0;

		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imagedata = ctx.getImageData(x, y, 1, 1);
		return (imagedata.data[3] << 24) | (imagedata.data[0] << 16) | imagedata.data[1] << 8 | imagedata.data[2];
	}

	public function setPixel(x:Int, y:Int, color:UInt)
	{
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return;

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
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return;

		var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		var imageData = ctx.createImageData( 1, 1 );
		imageData.data[0] = (color & 0xFF0000) >>> 16;
		imageData.data[1] = (color & 0x00FF00) >>> 8;
		imageData.data[2] = (color & 0x0000FF) ;
		if (mTransparent)
			imageData.data[3] = color >>> 24;
		else
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
	public function getHeight() : Int {
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

	function OnLoad( data:LoadData, e)
	{
		var canvas : HTMLCanvasElement = cast data.texture;
		var width = (jeash.Lib.mOpenGL)? Graphics.GetSizePow2(data.image.width) : data.image.width;
		var height = (jeash.Lib.mOpenGL)? Graphics.GetSizePow2(data.image.height) : data.image.height;
		canvas.width = width;
		canvas.height = height;

		var ctx : CanvasRenderingContext2D = canvas.getContext("2d");
		ctx.drawImage(data.image, 0, 0, width, height);

		data.bitmapData.width = width;
		data.bitmapData.height = height;

		if (data.inLoader != null)
		{
			data.inLoader.content.width = width;
			data.inLoader.content.height = height;

			var e = new flash.events.Event( flash.events.Event.COMPLETE );
			e.target = data.inLoader;
			data.inLoader.dispatchEvent( e );
		}
	}

	public function LoadFromFile(inFilename:String, ?inLoader:LoaderInfo)
	{
		var image : HTMLImageElement = cast js.Lib.document.createElement("img");
		if ( inLoader != null )
		{
			var data : LoadData = {image:image, texture: mTextureBuffer, inLoader:inLoader, bitmapData:this};
			image.addEventListener( "load", callback(OnLoad, data), false );
		}
		image.src = inFilename;
	}

	static public function CreateFromHandle(inHandle:HTMLCanvasElement) : BitmapData
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
