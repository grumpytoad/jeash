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

typedef LoadData = {
	var image : HTMLImageElement;
	var texture:HTMLCanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
}

class ImageDataLease {
	public var seed:Float;
	public var time:Float;
	public function new () {}
	public function set(s,t) { 
		this.seed = s; 
		this.time = t; 
	}
	public function clone() {
		var leaseClone = new ImageDataLease();
		leaseClone.seed = seed;
		leaseClone.time = time;
		return leaseClone;
	}
}

typedef CopyPixelAtom = {
	var handle:HTMLCanvasElement;
	var sourceX:Float;
	var sourceY:Float;
	var sourceWidth:Float;
	var sourceHeight:Float;
	var destX:Float;
	var destY:Float;
}

class BitmapData implements IBitmapDrawable {
	private var mTextureBuffer:HTMLCanvasElement;
	private var jeashTransparent:Bool;

	public var width(getWidth,null):Int;
	public var height(getHeight,null):Int;
	public var rect : Rectangle;

	var jeashImageData:ImageData;
	var jeashImageDataChanged:Bool;
	var jeashCopyPixelList:Array<CopyPixelAtom>;
	var jeashLocked:Bool;
	var jeashLease:ImageDataLease;
	var jeashLeaseNum:Int;
	var jeashAssignedBitmaps:Int;
	var jeashInitColor:Int;

	public function new(inWidth:Int, inHeight:Int,
			?inTransparent:Bool = true,
			?inFillColor:Int) {

		jeashLocked = false;
		jeashLeaseNum = 0;
		jeashLease = new ImageDataLease();
		jeashBuildLease();

		mTextureBuffer = cast js.Lib.document.createElement('canvas');
		mTextureBuffer.width = inWidth;
		mTextureBuffer.height = inHeight;

		jeashTransparent = inTransparent;
		rect = new Rectangle(0,0,inWidth,inHeight);

		if ( inFillColor != null ) {
			if (!jeashTransparent) inFillColor |= 0xFF000000;
			jeashInitColor = inFillColor;
			fillRect(rect, inFillColor);
		}

	}

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter) {
		throw "BitmapData.applyFilter not implemented in Jeash";
	}

	public function draw( source:IBitmapDrawable,
			matrix:Matrix = null,
			colorTransform:ColorTransform = null,
			blendMode:BlendMode = null,
			clipRect:Rectangle = null,
			smoothing:Bool = false ):Void {
		jeashBuildLease();
		source.drawToSurface(mTextureBuffer, matrix, colorTransform, blendMode, clipRect, smoothing);
	}

	public function getColorBoundsRect(mask:Int, color:Int, findColor:Bool = true) : Rectangle {
		var me = this;
		
		var doGetColorBoundsRect = function(data:CanvasPixelArray) {
			var minX = me.width, maxX = 0, minY = me.height, maxY = 0, i = 0;
			while (i < data.length) {
				var value = me.getInt32(i, data);
				if (findColor) {
					if ((value & mask) == color) {
						var x = Math.round((i % (me.width*4))/4);
						var y = Math.round(i / (me.width*4));
						if (x < minX) minX = x;
						if (x > maxX) maxX = x;
						if (y < minY) minY = y;
						if (y > maxY) maxY = y;
					}
				} else {
					if ((value & mask) != color) {
						var x = Math.round((i % (me.width*4))/4);
						var y = Math.round(i / (me.width*4));
						if (x < minX) minX = x;
						if (x > maxX) maxX = x;
						if (y < minY) minY = y;
						if (y > maxY) maxY = y;
					}
				}
				i += 4;
			}

			if (minX < maxX && minY < maxY)
				return new Rectangle(minX, minY, maxX-minX+1 /* +1 - bug? */, maxY-minY);
			else
				return new Rectangle(0, 0, me.width, me.height);
		}

		if (!jeashLocked) {
			var ctx = mTextureBuffer.getContext('2d');
			var imageData = ctx.getImageData(0, 0, width, height);

			return doGetColorBoundsRect(imageData.data);

		} else 
			return doGetColorBoundsRect(jeashImageData.data);
	}

	public function dispose() : Void {
	}

	public function compare ( inBitmapTexture : BitmapData ) : Int {
		throw "Not implemented. compare";
		return 0x00000000;
	}

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point,
			?alphaBitmapData:BitmapData, ?alphaPoint:Point, mergeAlpha:Bool = false):Void {
		if (sourceBitmapData.handle() == null || mTextureBuffer == null || sourceRect.width <= 0 || sourceRect.height <= 0 ) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.handle().width) sourceRect.width = sourceBitmapData.handle().width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.handle().height) sourceRect.height = sourceBitmapData.handle().height - sourceRect.y;

		if (!jeashLocked) {
			jeashBuildLease();

			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			ctx.drawImage(sourceBitmapData.handle(), sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
		} else {
			jeashCopyPixelList[jeashCopyPixelList.length] = {handle:sourceBitmapData.handle(), sourceX:sourceRect.x, sourceY:sourceRect.y, sourceWidth:sourceRect.width, sourceHeight:sourceRect.height, destX:destPoint.x, destY:destPoint.y};
		}
	}

	private function clipRect (r: Rectangle): Rectangle {
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

	inline public function jeashClearCanvas() mTextureBuffer.width = mTextureBuffer.width

	public function fillRect(rect: Rectangle, color: UInt) : Void {
		if (rect == null) return;
		if (rect.width <= 0 || rect.height <= 0) return;
		if (rect.x == 0 && rect.y == 0 && rect.width == mTextureBuffer.width && rect.height == mTextureBuffer.height)
			if (jeashTransparent) {
				if ((color >>> 24 == 0) || color == jeashInitColor) { return jeashClearCanvas(); } 
			} else {
				if ((color | 0xFF000000) == (jeashInitColor | 0xFF000000)) { return jeashClearCanvas(); }
			}

		jeashBuildLease();

		var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');

		var r: Int = (color & 0xFF0000) >>> 16;
		var g: Int = (color & 0x00FF00) >>> 8;
		var b: Int = (color & 0x0000FF);
		var a: Int = (jeashTransparent)? (color >>> 24) : 0xFF;

		if (!jeashLocked) {
			var style = 'rgba('; style += r; style += ', '; style += g; style += ', '; style += b; style += ', '; style += (a/256); style += ')';
			ctx.fillStyle = style;
			ctx.fillRect(rect.x, rect.y, rect.width, rect.height);
		} else {
			var s = 4 * (Math.round(rect.x) + (Math.round(rect.y) * jeashImageData.width));
			var offsetY : Int;
			var offsetX : Int;
			for (i in 0...Math.round(rect.height))
			{
				offsetY = (i * jeashImageData.width);
				for (j in 0...Math.round(rect.width))
				{
					offsetX = 4 * (j + offsetY);
					jeashImageData.data[s + offsetX] = r;
					jeashImageData.data[s + offsetX + 1] = g;
					jeashImageData.data[s + offsetX + 2] = b;
					jeashImageData.data[s + offsetX + 3] = a;
				}
			}
			jeashImageDataChanged = true;
			ctx.putImageData (jeashImageData, 0, 0, rect.x, rect.y, rect.width, rect.height);
		}
		return;
	}

	public function getPixels(rect:Rectangle):ByteArray {
		var byteArray = new ByteArray();

		rect = clipRect (rect);
		if (rect == null) return byteArray;

		var len = Math.round(4 * rect.width * rect.height);
		if (!jeashLocked) {
			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imagedata = ctx.getImageData(rect.x, rect.y, rect.width, rect.height);

			for (i in 0...len) {
				byteArray.writeByte( imagedata.data[i] );
			}

		} else {
			var offset = Math.round(4 * jeashImageData.width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round(4*(rect.x + rect.width));

			for (i in 0...len) {
				if (((pos) % (jeashImageData.width*4)) > boundR - 1)  
					pos += jeashImageData.width*4 - boundR;
				byteArray.writeByte(jeashImageData.data[pos]);
				pos++;
			}
		}

		byteArray.position = 0;
		return byteArray;
	}

	public function getPixel(x:Int, y:Int) : UInt {
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return 0;

		if (!jeashLocked) {
			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imagedata = ctx.getImageData(x, y, 1, 1);
			return (imagedata.data[0] << 16) | (imagedata.data[1] << 8) | (imagedata.data[2]);
		} else {
			var offset = (4 * y * width + x * 4);

			return (jeashImageData.data[offset] << 16) | (jeashImageData.data[offset + 1] << 8) | (jeashImageData.data[offset + 2]);
		}
	}

	// code to deal with 31-bit ints.
	private function getInt32 (offset:Int, data:CanvasPixelArray) {
		var b5, b6, b7, b8, pow = Math.pow;
		b5 = data[offset+3] & 0xFF;
		b6 = data[offset] & 0xFF;
		b7 = data[offset+1] & 0xFF;
		b8 = data[offset+2] & 0xFF;
		return untyped {
			parseInt(((b5 >> 7) * pow(2,31)).toString(2), 2) +
				parseInt((((b5&0x7F) << 24) | (b6 << 16) | (b7 << 8) | b8).toString(2), 2);	
		}
	}

	public function getPixel32(x:Int, y:Int) {
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return 0;

		if (!jeashLocked) {
			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			return getInt32(0, ctx.getImageData(x, y, 1, 1).data);
		} else {
			return getInt32((4 * y * mTextureBuffer.width + x * 4), jeashImageData.data);
		}
	}

	public function setPixel(x:Int, y:Int, color:UInt) {
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return;

		if (!jeashLocked) {
			jeashBuildLease();

			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imageData = ctx.createImageData( 1, 1 );
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF) ;
			if (jeashTransparent)
				imageData.data[3] = (0xFF);

			ctx.putImageData(imageData, x, y);
		} else {
			var offset = (4 * y * jeashImageData.width + x * 4);
			jeashImageData.data[offset] = (color & 0xFF0000) >>> 16;
			jeashImageData.data[offset + 1] = (color & 0x00FF00) >>> 8;
			jeashImageData.data[offset + 2] = (color & 0x0000FF) ;
			if (jeashTransparent)
				jeashImageData.data[offset + 3] = (0xFF);
			jeashImageDataChanged = true;
		}
	}

	public function setPixel32(x:Int, y:Int, color:UInt) {
		if (x < 0 || y < 0 || x >= getWidth () || y >= getHeight ()) return;

		if (!jeashLocked) {
			jeashBuildLease();

			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imageData = ctx.createImageData( 1, 1 );
			imageData.data[0] = (color & 0xFF0000) >>> 16;
			imageData.data[1] = (color & 0x00FF00) >>> 8;
			imageData.data[2] = (color & 0x0000FF);
			if (jeashTransparent)
				imageData.data[3] = (color & 0xFF000000) >>> 24;
			else
				imageData.data[3] = (0xFF);
			ctx.putImageData(imageData, x, y);
		} else {
			var offset = (4 * y * jeashImageData.width + x * 4);
			jeashImageData.data[offset] = (color & 0x00FF0000) >>> 16;
			jeashImageData.data[offset + 1] = (color & 0x0000FF00) >>> 8;
			jeashImageData.data[offset + 2] = (color & 0x000000FF);
			if (jeashTransparent)
				jeashImageData.data[offset + 3] = (color & 0xFF000000) >>> 24;
			else
				jeashImageData.data[offset + 3] = (0xFF);
			jeashImageDataChanged = true;
		}
	}

	public function setPixels(rect:Rectangle, byteArray:ByteArray) {
		rect = clipRect (rect);
		if (rect == null) return;
		
		var len = Math.round(4 * rect.width * rect.height);
		if (!jeashLocked) {
			var ctx : CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imageData = ctx.createImageData( rect.width, rect.height );
			for (i in 0...len)
				imageData.data[i] = byteArray.readByte();
			ctx.putImageData(imageData, rect.x, rect.y);
		} else {
			var offset = Math.round(4 * jeashImageData.width * rect.y + rect.x * 4);
			var pos = offset;
			var boundR = Math.round(4*(rect.x + rect.width));

			for (i in 0...len) {
				if (((pos) % (jeashImageData.width*4)) > boundR - 1)  
					pos += jeashImageData.width*4 - boundR;
				jeashImageData.data[pos] = byteArray.readByte();
				pos++;
			}
			jeashImageDataChanged = true;
		}
	}

	public function clone() : BitmapData {
		var bitmapData = new BitmapData(width, height, jeashTransparent);

		var rect = new Rectangle(0, 0, width, height);
		bitmapData.setPixels(rect, getPixels(rect));
		bitmapData.jeashBuildLease();

		return bitmapData;
	}

	public inline function handle() return mTextureBuffer

	inline function getWidth() : Int {
		if ( mTextureBuffer != null ) {
			return mTextureBuffer.width;
		} else {
			return 0;
		}
	}

	inline function getHeight() : Int {
		if ( mTextureBuffer != null ) {
			return mTextureBuffer.height;
		} else {
			return 0;
		}
	}

	public function destroy() mTextureBuffer = null

	function jeashOnLoad( data:LoadData, e) {
		var canvas : HTMLCanvasElement = cast data.texture;
		var width = data.image.width;
		var height = data.image.height;
		canvas.width = width;
		canvas.height = height;

		var ctx : CanvasRenderingContext2D = canvas.getContext("2d");
		ctx.drawImage(data.image, 0, 0, width, height);

		data.bitmapData.width = width;
		data.bitmapData.height = height;
		data.bitmapData.rect = new Rectangle(0,0,width,height);

		data.bitmapData.jeashBuildLease();

		if (data.inLoader != null)
		{
			var e = new flash.events.Event( flash.events.Event.COMPLETE );
			e.target = data.inLoader;
			data.inLoader.dispatchEvent( e );
		}
	}

	public function jeashLoadFromFile(inFilename:String, ?inLoader:LoaderInfo) {
		var image : HTMLImageElement = cast js.Lib.document.createElement("img");
		if ( inLoader != null ) {
			var data : LoadData = {image:image, texture: mTextureBuffer, inLoader:inLoader, bitmapData:this};
			image.addEventListener( "load", callback(jeashOnLoad, data), false );
		}
		image.src = inFilename;
	}

	static public function jeashCreateFromHandle(inHandle:HTMLCanvasElement) : BitmapData {
		var result = new BitmapData(0,0);
		result.mTextureBuffer = inHandle;
		return result;
	}

	public function lock() : Void {
		jeashLocked = true;

		var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		jeashImageData = ctx.getImageData (0, 0, width, height);
		jeashImageDataChanged = false;
		jeashCopyPixelList = [];

	}

	public function unlock(?changeRect : flash.geom.Rectangle) : Void {
		jeashLocked = false;

		var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
		if (jeashImageDataChanged)
			if (changeRect != null)
				ctx.putImageData (jeashImageData, 0, 0, changeRect.x, changeRect.y, changeRect.width, changeRect.height);
			else
				ctx.putImageData (jeashImageData, 0, 0);

		for (copyCache in jeashCopyPixelList) {
			ctx.drawImage(copyCache.handle, copyCache.sourceX, copyCache.sourceY, copyCache.sourceWidth, copyCache.sourceHeight, copyCache.destX, copyCache.destY, copyCache.sourceWidth, copyCache.sourceHeight);
		}

		jeashBuildLease();
	}

	public function drawToSurface(inSurface : Dynamic,
			matrix:flash.geom.Matrix,
			colorTransform:flash.geom.ColorTransform,
			blendMode: BlendMode,
			clipRect:Rectangle,
			smothing:Bool):Void {
		var ctx : CanvasRenderingContext2D = inSurface.getContext('2d');
		ctx.save();
		if (matrix != null) {
			ctx.save();
			if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) 
				ctx.translate(matrix.tx, matrix.ty);
			else
				ctx.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
			ctx.restore();
		}

		jeashBuildLease();

		ctx.drawImage(handle(), 0, 0);
		ctx.restore();
	}

	public function colorTransform(rect:Rectangle, colorTransform:ColorTransform) {
		rect = clipRect (rect);
		if (rect == null) return;

		if (!jeashLocked) {
			jeashBuildLease();
			var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');

			var imagedata = ctx.getImageData (rect.x, rect.y, rect.width, rect.height);
			var offsetX : Int;
			for (i in 0...imagedata.data.length >> 2) {
				offsetX = i * 4;
				imagedata.data[offsetX] = Std.int((imagedata.data[offsetX] * colorTransform.redMultiplier) + colorTransform.redOffset);
				imagedata.data[offsetX + 1] = Std.int((imagedata.data[offsetX + 1] * colorTransform.greenMultiplier) + colorTransform.greenOffset);
				imagedata.data[offsetX + 2] = Std.int((imagedata.data[offsetX + 2] * colorTransform.blueMultiplier) + colorTransform.blueOffset);
				imagedata.data[offsetX + 3] = Std.int((imagedata.data[offsetX + 3] * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
			}
			ctx.putImageData (imagedata, rect.x, rect.y);
		} else {
			var s = 4 * (Math.round(rect.x) + (Math.round(rect.y) * jeashImageData.width));
			var offsetY : Int;
			var offsetX : Int;

			for (i in 0...Math.round(rect.height)) {
				offsetY = (i * jeashImageData.width);
				for (j in 0...Math.round(rect.width)) {
					offsetX = 4 * (j + offsetY);
					jeashImageData.data[s + offsetX] = Std.int((jeashImageData.data[s + offsetX] * colorTransform.redMultiplier) + colorTransform.redOffset);
					jeashImageData.data[s + offsetX + 1] = Std.int((jeashImageData.data[s + offsetX + 1] * colorTransform.greenMultiplier) + colorTransform.greenOffset);
					jeashImageData.data[s + offsetX + 2] = Std.int((jeashImageData.data[s + offsetX + 2] * colorTransform.blueMultiplier) + colorTransform.blueOffset);
					jeashImageData.data[s + offsetX + 3] = Std.int((jeashImageData.data[s + offsetX + 3] * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
				}
			}
			jeashImageDataChanged = true;
		}
	}

	public function copyChannel(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:Int, destChannel:Int) {
		rect = clipRect (rect);
		if (rect == null) return;

		if (sourceBitmapData.handle() == null || mTextureBuffer == null || sourceRect.width <= 0 || sourceRect.height <= 0 ) return;
		if (sourceRect.x + sourceRect.width > sourceBitmapData.handle().width) sourceRect.width = sourceBitmapData.handle().width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceBitmapData.handle().height) sourceRect.height = sourceBitmapData.handle().height - sourceRect.y;

		var doChannelCopy = function (imageData:ImageData) {
			var srcCtx : CanvasRenderingContext2D = sourceBitmapData.handle().getContext('2d');
			var srcImageData = srcCtx.getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);

			var destIdx = if (destChannel == BitmapDataChannel.ALPHA) { 3;
			} else if (destChannel == BitmapDataChannel.BLUE) { 2;
			} else if (destChannel == BitmapDataChannel.GREEN) { 1;
			} else if (destChannel == BitmapDataChannel.RED) { 0;
			} else throw "Invalid destination BitmapDataChannel passed to BitmapData::copyChannel.";

			var pos = 4 * (Math.round(destPoint.x) + (Math.round(destPoint.y) * imageData.width)) + destIdx;
			var boundR = Math.round(4*(destPoint.x + sourceRect.width));
			var setPos = function (val:Int) {
				if ((pos % (imageData.width*4)) > boundR - 1)  
					pos += imageData.width*4 - boundR;
				imageData.data[pos] = val;
				pos += 4;
			}

			var srcIdx = if (sourceChannel == BitmapDataChannel.ALPHA) { 3;
			} else if (sourceChannel == BitmapDataChannel.BLUE) { 2;
			} else if (sourceChannel == BitmapDataChannel.GREEN) { 1;
			} else if (sourceChannel == BitmapDataChannel.RED) { 0;
			} else throw "Invalid source BitmapDataChannel passed to BitmapData::copyChannel.";

			while (srcIdx < srcImageData.data.length) {
				setPos(srcImageData.data[srcIdx]);
				srcIdx += 4;
			}
		}

		if (!jeashLocked) {
			jeashBuildLease();

			var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			doChannelCopy(imageData);
			ctx.putImageData (imageData, 0, 0);
		} else {
			doChannelCopy(jeashImageData);
			jeashImageDataChanged = true;
		}
	}

	public function hitTest(firstPoint:Point, firstAlphaThreshold:UInt, secondObject:Dynamic, secondBitmapDataPoint:Point = null, secondAlphaThreshold:UInt = 1):Bool {
		var type = Type.getClassName(Type.getClass(secondObject));
		firstAlphaThreshold = firstAlphaThreshold & 0xFFFFFFFF;

		var me = this;
		var doHitTest = function (imageData:ImageData) {
			if (secondObject.__proto__ == null 
					|| secondObject.__proto__.__class__ == null 
					|| secondObject.__proto__.__class__.__name__ == null) return false;

			switch(secondObject.__proto__.__class__.__name__[2]) {
				case "Rectangle":
					var rect : Rectangle = cast secondObject;

					rect.x -= firstPoint.x;
					rect.y -= firstPoint.y;

					rect = me.clipRect (me.rect);
					if (me.rect == null) return false;

					var boundingBox = new Rectangle(0, 0, me.width, me.height);
					if (!rect.intersects(boundingBox)) return false;

					var diff = rect.intersection(boundingBox);
					var offset = 4 * (Math.round(diff.x) + (Math.round(diff.y) * imageData.width)) + 3;
					var pos = offset;
					var boundR = Math.round(4*(diff.x + diff.width));

					while (pos < offset + Math.round(4 * (diff.width + imageData.width * diff.height))) {
						if ((pos % (imageData.width*4)) > boundR - 1)  
							pos += imageData.width*4 - boundR;
						if (imageData.data[pos] - firstAlphaThreshold >= 0) return true;
						pos += 4;
					}

					return false;
				case "Point":
					var point : Point = cast secondObject;

					var x = point.x - firstPoint.x, y = point.y - firstPoint.y;

					if (x < 0 || y < 0 || x >= me.width || y >= me.height) return false;
					if (imageData.data[Math.round(4 * (y * me.width + x)) + 3] - firstAlphaThreshold > 0) return true;

					return false;
				case "Bitmap":
					throw "BitmapData::hitTest secondObject argument as BitmapData is not (yet) supported.";

					return false;

				case "BitmapData":
					throw "BitmapData::hitTest secondObject argument as BitmapData is not (yet) supported.";

					return false;
				default:
					throw "BitmapData::hitTest secondObject argument must be either a Rectangle, a Point, a Bitmap or a BitmapData object.";
					return false;
			}
		}

		if (!jeashLocked) {
			jeashBuildLease();

			var ctx: CanvasRenderingContext2D = mTextureBuffer.getContext('2d');
			var imageData = ctx.getImageData (0, 0, width, height);
			return doHitTest(imageData);
			ctx.putImageData (imageData, 0, 0);
		} else {
			return doHitTest(jeashImageData);
			jeashImageDataChanged = true;
		}
	}

	public function scroll(x:Int, y:Int)
		throw "Not implemented yet, patches welcome. BitmapData::scroll."

	public inline function jeashGetLease() return jeashLease

	public function jeashGetNumRefBitmaps() return jeashAssignedBitmaps
	public function jeashIncrNumRefBitmaps() jeashAssignedBitmaps++
	public function jeashDecrNumRefBitmaps() jeashAssignedBitmaps--
	inline function jeashBuildLease() jeashLease.set(jeashLeaseNum++, Date.now().getTime())

}
