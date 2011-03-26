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

import flash.accessibility.AccessibilityProperties;
import flash.display.Stage;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.EventPhase;
import flash.display.DisplayObjectContainer;
import flash.display.IBitmapDrawable;
import flash.display.InteractiveObject;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;
import flash.filters.BitmapFilter;
import flash.display.BitmapData;
import flash.Lib;

typedef BufferData =
{
	var buffer:WebGLBuffer;
	var size:Int;
	var location:GLint;
}

/**
 * @author	Niel Drummond
 * @author	Hugh Sanderson
 * @author	Russell Weir
 */
class DisplayObject extends EventDispatcher, implements IBitmapDrawable
{
	public var x:Float;
	public var y:Float;
	//public var scaleX:Float;
	//public var scaleY:Float;

	public var scaleX(jeashGetScaleX,jeashSetScaleX):Float;
	public var scaleY(jeashGetScaleY,jeashSetScaleY):Float;

	public var accessibilityProperties:AccessibilityProperties;
	public var alpha:Float;
	public var name(default,default):String;
	public var cacheAsBitmap:Bool;
	//public var width:Float;
	//public var height:Float;
	public var width(jeashGetWidth,jeashSetWidth):Float;
	public var height(jeashGetHeight,jeashSetHeight):Float;

	public var visible(default,jeashSetVisible):Bool;
	public var opaqueBackground(GetOpaqueBackground,SetOpaqueBackground):Null<Int>;
	public var mouseX(jeashGetMouseX, jeashSetMouseX):Float;
	public var mouseY(jeashGetMouseY, jeashSetMouseY):Float;
	public var parent:DisplayObjectContainer;
	public var stage(GetStage,null):Stage;
	public var rotation:Float;
	public var scrollRect(GetScrollRect,SetScrollRect):Rectangle;
	public var mask(GetMask,SetMask):DisplayObject;
	public var filters(jeashGetFilters,jeashSetFilters):Array<Dynamic>;
	public var blendMode : flash.display.BlendMode;
	public var loaderInfo:LoaderInfo;


	// This is used by the swf-code for z-sorting
	public var __swf_depth:Int;

	public var transform(GetTransform,SetTransform):Transform;

	// Variables for manipulating OpenGL co-ordinate system
	public var mVertices:Array<Float>;
	public var mNormals:Array<Float>;
	public var mTextureCoords:Array<Float>;
	public var mIndices:Array<Int>;
	
	public var mVertexItemSize:Int;
	public var mNormItemSize:Int;
	public var mTexCoordItemSize:Int;

	public var mVertexBuffer(default,null):WebGLBuffer;
	public var mNormBuffer(default,null):WebGLBuffer;
	public var mTextureCoordBuffer(default,null):WebGLBuffer;
	public var mIndexBuffer(default,null):WebGLBuffer;
	public var mIndicesCount(default,null):Int;
	public var mBuffers : Hash<BufferData>;

	var mSizeDirty:Bool;
	var mBoundsRect : Rectangle;
	var mGraphicsBounds : Rectangle;
	var mScale9Grid : Rectangle;

	var jeashScaleX : Float;
	var jeashScaleY : Float;

	static var mNameID = 0;

	var mScrollRect:Rectangle;
	var mOpaqueBackground:Null<Int>;

	var mMask:DisplayObject;
	var mMaskingObj:DisplayObject;
	var mMaskHandle:Dynamic;
	var jeashFilters:Array<BitmapFilter>;

	var mMatrix:Matrix;
	var mFullMatrix:Matrix;

	public function new()
	{
		parent = null;
		super(null);
		x = y = 0;
		jeashScaleX = jeashScaleY = 1.0;
		alpha = 1.0;
		rotation = 0.0;
		__swf_depth = 0;
		mMatrix = new Matrix();
		mFullMatrix = new Matrix();
		mMask = null;
		mMaskingObj = null;
		mBoundsRect = new Rectangle();
		mGraphicsBounds = null;
		mMaskHandle = null;
		name = "DisplayObject " + mNameID++;
		mBuffers = new Hash();

		visible = true;

		if (jeash.Lib.mOpenGL && !Std.is(this, Stage))
		{

			// Default to a simple two polygon square face - by
			// updating these array buffers, it is possible to have
			// a full GPU accelerated 3D environment.

			var aBuffers = new Hash();
			var vertices = [
				1.0,  1.0,  0.0,
				-1.0, 1.0,  0.0,
				1.0, -1.0,  0.0,
				-1.0, -1.0, 0.0
					];

			aBuffers.set( "aVertPos", {
					data: vertices,
					size: 3
				    });

			var texCoords = [
				1.0, 0.0,
				0.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,
				];
			aBuffers.set( "aTexCoord", {
					data: texCoords,
					size: 2
				    });

			SetBuffers(aBuffers);

		}
	}

	public function SetBuffers<T>( inputData:Hash<{ size:Int, data:Array<Float>}>, ?indices:Array<Int> )
	{
		var gl : WebGLRenderingContext = jeash.Lib.glContext;
		var gfx = jeashGetGraphics();
		if (gfx == null) return;

		gl.useProgram(gfx.mShaderGL);

		for (key in inputData.keys())
		{
			var bufferArray = inputData.get(key);
			if (bufferArray.data != null && bufferArray.size != null)
			{
				var data = mBuffers.get(key);
				if (data != null) 
				{ 
					if (data.buffer != null)
						gl.deleteBuffer(data.buffer);
					mBuffers.remove(key);
				}
				var buffer = gl.createBuffer();

				gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
				gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(bufferArray.data), gl.STATIC_DRAW);

				var location = gl.getAttribLocation( gfx.mShaderGL, key );
				if ( location < 0 ) 
					trace("Invalid attribute for shader: " + key);
				var bufferData : BufferData = { buffer:buffer, location:location, size:bufferArray.size };
				mBuffers.set(key, bufferData );

			}
		}


		if (indices != null)
		{
			if (mIndexBuffer != null) gl.deleteBuffer(mIndexBuffer);
			mIndexBuffer = gl.createBuffer();

			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mIndexBuffer);
			gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW);

			mIndicesCount = indices.length;
		} else if (inputData.exists("aVertPos")) {
			// still a bit ugly...
			var vertData = inputData.get("aVertPos");

			mIndicesCount = Std.int(vertData.data.length/vertData.size);
		}

	}

	override public function toString() { return name; }

	function jeashDoAdded(inObj:DisplayObject)
	{
		if (inObj==this)
		{
			var evt = new flash.events.Event(flash.events.Event.ADDED, true, false);
			evt.target = inObj;
			dispatchEvent(evt);
		}

		var evt = new flash.events.Event(flash.events.Event.ADDED_TO_STAGE, false, false);
		evt.target = inObj;
		dispatchEvent(evt);
	}

	function jeashDoRemoved(inObj:DisplayObject)
	{
		if (inObj==this)
		{
			var evt = new flash.events.Event(flash.events.Event.REMOVED, true, false);
			evt.target = inObj;
			dispatchEvent(evt);
		}
		var evt = new flash.events.Event(flash.events.Event.REMOVED_FROM_STAGE, false, false);
		evt.target = inObj;
		dispatchEvent(evt);

		var gfx = jeashGetGraphics();
		if (gfx != null)
			Lib.jeashRemoveSurface(gfx.mSurface);
	}
	public function DoMouseEnter() {}
	public function DoMouseLeave() {}

	public function jeashSetParent(parent:DisplayObjectContainer)
	{
		if (parent == this.parent)
			return;

		if (this.parent != null)
			this.parent.__removeChild(this);

		if (this.parent==null && parent!=null)
		{
			this.parent = parent;
			jeashDoAdded(this);

		}
		else if (this.parent != null && parent==null)
		{
			this.parent = parent;
			jeashDoRemoved(this);
		}
		else
			this.parent = parent;

	}

	public function GetStage() { return flash.Lib.jeashGetStage(); }
	public function AsContainer() : DisplayObjectContainer { return null; }

	public function GetScrollRect() : Rectangle
	{
		if (mScrollRect==null) return null;
		return mScrollRect.clone();
	}

	public function jeashAsInteractiveObject() : flash.display.InteractiveObject
	{ return null; }

	public function SetScrollRect(inRect:Rectangle)
	{
		mScrollRect = inRect;
		return GetScrollRect();
	}

	public function hitTestObject(obj:DisplayObject)
	{
		return false;
	}

	public function hitTestPoint(x:Float, y:Float, ?shapeFlag:Bool)
	{
		var bounding_box:Bool = shapeFlag==null ? true : !shapeFlag;

		// TODO:
		return true;
	}

	public function localToGlobal( point:Point )
	{
		if ( this.parent == null )
		{
			return new Point( this.x + point.x, this.y + point.y );
		} else {
			point.x = point.x + this.x;
			point.y = point.y + this.y;
			return this.parent.localToGlobal( point );
		}
	}

	function jeashGetMouseX() { return stage.mouseX; }
	function jeashSetMouseX(x:Float) { return null; }
	function jeashGetMouseY() { return stage.mouseY; }
	function jeashSetMouseY(y:Float) { return null; }

	public function GetTransform() { return  new Transform(this); }

	public function SetTransform(trans:Transform)
	{
		mMatrix = trans.matrix.clone();
		return trans;
	}

	public function getBounds(targetCoordinateSpace : DisplayObject) : Rectangle 
	{
		// TODO: map to co-ordinate space
		BuildBounds();
		return mBoundsRect.clone();
	}
	public function getRect(targetCoordinateSpace : DisplayObject) : Rectangle 
	{
		// TODO
		return null;
	}

	public function globalToLocal(inPos:Point) : Point
	{
		return mFullMatrix.clone().invert().transformPoint(inPos);
	}
	
	// This tells us we are an empty container, or not a container at all
	public function GetNumChildren() { return 0; }


	public function GetMatrix()
	{
		return mMatrix.clone();
	}
	public function SetMatrix(inMatrix:Matrix)
	{
		mMatrix = inMatrix.clone();
		return inMatrix;
	}

	function jeashGetGraphics() : flash.display.Graphics
	{ return null; }

	public function GetOpaqueBackground() { return mOpaqueBackground; }
	public function SetOpaqueBackground(inBG:Null<Int>)
	{
		mOpaqueBackground = inBG;
		return mOpaqueBackground;
	}

	public function GetBackgroundRect()
	{
		if (mGraphicsBounds==null)
		{
			var gfx = jeashGetGraphics();
			if (gfx!=null)
				mGraphicsBounds = gfx.GetExtent(new Matrix());
		}
		return mGraphicsBounds;
	}

	public function jeashRender(parentMatrix:Matrix, ?inMask:HTMLCanvasElement)
	{
		jeashUpdateMatrix();

		var gfx = jeashGetGraphics();

		if (gfx!=null)
		{
			mFullMatrix = mMatrix.mult(parentMatrix);
			var m = mFullMatrix.clone();
			gfx.jeashRender(inMask, m);

			if (!jeash.Lib.mOpenGL)
			{
				var extent = gfx.GetExtent(new Matrix());
				// detect draw beyond boundary, do not adjust matrix
				if (gfx.jeashShift)
				{
					m.tx = m.tx + extent.x*m.a + extent.y*m.c;
					m.ty = m.ty + extent.x*m.b + extent.y*m.d;
				}

				if (inMask != null)
				{
					Lib.jeashDrawToSurface(gfx.mSurface, inMask, m, (parent != null ? parent.alpha : 1) * alpha);
				} else {
					Lib.jeashSetSurfaceTransform(gfx.mSurface, m);
					Lib.jeashSetSurfaceOpacity(gfx.mSurface, (parent != null ? parent.alpha : 1) * alpha);
				}

			} else {
				if (mBuffers.exists("aVertPos"))
				{
					var gl : WebGLRenderingContext = jeash.Lib.glContext;

					gl.useProgram(gfx.mShaderGL);

					for(key in mBuffers.keys())
					{
						var data = mBuffers.get(key);
						if (data.buffer != null && data.location != null && data.size != null)
						{
							gl.bindBuffer(gl.ARRAY_BUFFER, data.buffer);
							gl.vertexAttribPointer(data.location, data.size, gl.FLOAT, false, 0, 0);
						}
					}

					if (gfx.mTextureGL != null && gl.getUniformLocation(gfx.mShaderGL, "uSurface") != null)
					{
						gl.activeTexture(gl.TEXTURE0);
						gl.bindTexture(gl.TEXTURE_2D, gfx.mTextureGL);

						gl.uniform1i(gl.getUniformLocation(gfx.mShaderGL, "uSurface"), 0);
					}

					if (mIndexBuffer != null)
					{
						gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mIndexBuffer);
						if (MatrixUniforms())
							gl.drawElements(gl.TRIANGLES, mIndicesCount, gl.UNSIGNED_SHORT, 0);
					} else {
						gl.uniformMatrix4fv( gl.getUniformLocation( gfx.mShaderGL, "uProjMatrix" ), false, stage.mProjMatrix );
						gl.uniformMatrix4fv( gl.getUniformLocation( gfx.mShaderGL, "uViewMatrix" ), false, GetFlatGLMatrix( mFullMatrix ) );
						gl.drawArrays(gl.TRIANGLE_STRIP, 0, mIndicesCount);
					}

				}
			}
		}
	}

	function jeashRenderContentsToCache(parentMatrix:Matrix, canvas:HTMLCanvasElement)
	{
		jeashRender(parentMatrix, canvas);
	}

	dynamic public function MatrixUniforms()
	{
		return false;
	}

	static inline function GetFlatGLMatrix( m:Matrix )
	{
		return [
			m.a, m.b, 0, m.tx,
			m.c, m.d, 0, m.ty,
			0, 0, 1, 0,
			0, 0, -1, 1
		];
	}


	public function drawToSurface(inSurface : Dynamic,
			matrix:flash.geom.Matrix,
			colorTransform:flash.geom.ColorTransform,
			blendMode:BlendMode,
			clipRect:flash.geom.Rectangle,
			smoothing:Bool):Void
	{
		if (matrix==null) matrix = new Matrix();
		jeashRenderContentsToCache(matrix, inSurface);
	}

	public function jeashGetObjectUnderPoint(point:Point):DisplayObject
	{
		var gfx = jeashGetGraphics();
		if (gfx != null)
		{
			var local = globalToLocal(point);
			switch (stage.jeashPointInPathMode)
			{
				case USER_SPACE:
					if (gfx.jeashHitTest(local.x, local.y))
						return cast this;
				case DEVICE_SPACE:

					if (gfx.jeashHitTest((local.x)*scaleX, (local.y)*scaleY))
						return cast this;
			}
		}

		return null;
	}


	// Masking
	public function GetMask() : DisplayObject { return mMask; }

	public function SetMask(inMask:DisplayObject) : DisplayObject
	{
		if (mMask!=null)
			mMask.mMaskingObj = null;
		mMask = inMask;
		if (mMask!=null)
			mMask.mMaskingObj = this;
		return mMask;
	}

	// @r533
	public function jeashSetFilters(filters:Array<Dynamic>)
	{
		if (filters==null)
			jeashFilters = null;
		else
		{
			jeashFilters = new Array<BitmapFilter>();
			for(filter in filters)
				jeashFilters.push(filter.clone());
		}

		return filters;
	}

	// @r533
	public function jeashGetFilters()
	{
		if (jeashFilters==null) return [];
		var result = new Array<BitmapFilter>();
		for(filter in jeashFilters)
			result.push(filter.clone());
		return result;
	}

	function BuildBounds()
	{
		var gfx = jeashGetGraphics();
		if (gfx==null)
			mBoundsRect = new Rectangle(x,y,0,0);
		else
		{
			mBoundsRect = gfx.GetExtent(new Matrix());
			if (mScale9Grid!=null)
			{
				mBoundsRect.width *= scaleX;
				mBoundsRect.height *= scaleY;
			}
		}
	}

	function GetScreenBounds()
	{
		BuildBounds();
		return mBoundsRect.clone();
	}

	public function GetFocusObjects(outObjs:Array<InteractiveObject>) { }
	inline function __BlendIndex():Int
	{
		return blendMode == null ? Graphics.BLEND_NORMAL : Type.enumIndex(blendMode);
	}

	public function jeashGetInteractiveObjectStack(outStack:Array<InteractiveObject>)
	{
		var io = jeashAsInteractiveObject();
		if (io != null)
			outStack.push(io);
		if (this.parent != null)
			this.parent.jeashGetInteractiveObjectStack(outStack);
	}


	// @r551
	public function jeashFireEvent(event:flash.events.Event)
	{
		var stack:Array<InteractiveObject> = [];
		if (this.parent != null)
			this.parent.jeashGetInteractiveObjectStack(stack);
		var l = stack.length;

		if (l>0)
		{
			// First, the "capture" phase ...
			event.jeashSetPhase(EventPhase.CAPTURING_PHASE);
			stack.reverse();
			for(obj in stack)
			{
				event.currentTarget = obj;
				obj.dispatchEvent(event);
				if (event.jeashGetIsCancelled())
					return;
			}
		}

		// Next, the "target"
		event.jeashSetPhase(EventPhase.AT_TARGET);
		event.currentTarget = this;
		dispatchEvent(event);
		if (event.jeashGetIsCancelled())
			return;

		// Last, the "bubbles" phase
		if (event.bubbles)
		{
			event.jeashSetPhase(EventPhase.BUBBLING_PHASE);
			stack.reverse();
			for(obj in stack)
			{
				event.currentTarget = obj;
				obj.dispatchEvent(event);
				if (event.jeashGetIsCancelled())
					return;
			}
		}
	}

	// @533
	public function jeashBroadcast(event:flash.events.Event)
	{
		dispatchEvent(event);
	}

	function jeashAddToStage()
	{
		var gfx = jeashGetGraphics();
		if (gfx != null)
			Lib.jeashAppendSurface(gfx.mSurface, 0, 0);
	}

	function jeashInsertBefore(obj:DisplayObject)
	{
		var gfx1 = jeashGetGraphics();
		var gfx2 = obj.jeashIsOnStage() ? obj.jeashGetGraphics() : null;
		if (gfx1 != null)
		{
			if (gfx2 != null )
				Lib.jeashAppendSurface(gfx1.mSurface, gfx2.mSurface, 0, 0);
			 else 
				Lib.jeashAppendSurface(gfx1.mSurface, 0, 0);
			
		}
	}

	function jeashIsOnStage()
	{
		var gfx = jeashGetGraphics();
		if (gfx != null)
			return Lib.jeashIsOnStage(gfx.mSurface);
		return false;
	}

	function jeashSetVisible(visible:Bool)
	{
		if (visible == this.visible) return visible;
		var gfx = jeashGetGraphics();
		if (gfx != null)
			if (visible)
				Lib.jeashSetSurfaceVisible(gfx.mSurface, true);
			else
				Lib.jeashSetSurfaceVisible(gfx.mSurface, false);
		this.visible = visible;
		return visible;
	}

	public function jeashGetHeight() : Float
	{
		BuildBounds();
		return jeashScaleY * mBoundsRect.height;
	}
	public function jeashSetHeight(inHeight:Float) : Float
	{
		BuildBounds();
		var h = mBoundsRect.height;
		if (inHeight!=h)
		{
			if (h<=0) return 0;
			jeashScaleY *= inHeight/h;
			//untyped __js__("this.height = inHeight");
			jeashUpdateMatrix();
		}
		return inHeight;
	}

	public function jeashGetWidth() : Float
	{
		BuildBounds();
		return jeashScaleX * mBoundsRect.width;
	}

	public function jeashSetWidth(inWidth:Float) : Float
	{
		BuildBounds();
		var w = mBoundsRect.width;
		if (w!=inWidth)
		{
			if (w<=0) return 0;
			jeashScaleX *= inWidth/w;
			//untyped __js__("this.width = inWidth");
			jeashUpdateMatrix();
		}
		return inWidth;
	}

	public function jeashGetScaleX() { return jeashScaleX; }
	public function jeashGetScaleY() { return jeashScaleY; }
	public function jeashSetScaleX(inS:Float)
	{ jeashScaleX = inS; jeashUpdateMatrix(); return inS; }
	public function jeashSetScaleY(inS:Float)
	{ jeashScaleY = inS; jeashUpdateMatrix(); return inS; }

	public function jeashUpdateMatrix()
	{
/*
		
		var h = mBoundsRect.height;

		if (this.height == null) this.height = h;
		if (jeashBoundsHeight == null) jeashBoundsHeight = h;

		if (scaleY != jeashScaleY)
			jeashScaleY = scaleY;
		else
			if (this.height != scaleY*jeashBoundsHeight && h>0)
				this.jeashScaleY = this.height/jeashBoundsHeight;

		jeashBoundsHeight = h;
		this.height = jeashScaleY*h;
		scaleY = jeashScaleY;

		var w = mBoundsRect.width;

		if (this.width == null) this.width = w;
		if (jeashBoundsWidth == null) jeashBoundsWidth = w;

		if (scaleX != jeashScaleX)
			jeashScaleX = scaleX;
		else
			if (this.width != jeashScaleX*jeashBoundsWidth && w>0)
				this.jeashScaleX = this.width/jeashBoundsWidth;

		jeashBoundsWidth = w;
		this.width = jeashScaleX*w;
		scaleX = jeashScaleX;
*/
		var w = mBoundsRect.width;
		if (untyped __js__("this.width"))
			jeashScaleX = untyped __js__("this.width")/w;


		var h = mBoundsRect.height;
		if (untyped __js__("this.height"))
			jeashScaleY = untyped __js__("this.height")/h;

		mMatrix = new Matrix(this.scaleX, 0.0, 0.0, this.scaleY);

		var rad = this.rotation * Math.PI / 180.0;
		if (rad != 0.0)
			mMatrix.rotate(rad);

		mMatrix.tx = this.x;
		mMatrix.ty = this.y;

	}


}
