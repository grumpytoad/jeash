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
import flash.filters.BitmapFilterSet;
import flash.filters.FilterSet;
import flash.display.BitmapData;

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
	public var x(GetX,SetX):Float;
	public var y(GetY,SetY):Float;
	public var scaleX(GetScaleX,SetScaleX):Float;
	public var scaleY(GetScaleY,SetScaleY):Float;
#if !js
	public var scale9Grid(GetScale9Grid,SetScale9Grid):Rectangle;
#end
	public var accessibilityProperties:AccessibilityProperties;
	public var alpha(default,SetAlpha):Float;
	public var name(default,default):String;
	public var cacheAsBitmap:Bool;
	public var width(GetWidth,SetWidth):Float;
	public var height(GetHeight,SetHeight):Float;
	public var visible(default,default):Bool;
	public var opaqueBackground(GetOpaqueBackground,SetOpaqueBackground):Null<Int>;
	public var mouseX(jeashGetMouseX, jeashSetMouseX):Float;
	public var mouseY(jeashGetMouseY, jeashSetMouseY):Float;
	public var parent(GetParent,null):DisplayObjectContainer;
	public var stage(GetStage,null):Stage;
	public var rotation(GetRotation,SetRotation):Float;
	public var scrollRect(GetScrollRect,SetScrollRect):Rectangle;
	public var mask(GetMask,SetMask):DisplayObject;
	public var filters(GetFilters,SetFilters):Array<Dynamic>;
	public var blendMode : flash.display.BlendMode;
	public var loaderInfo:LoaderInfo;


	// This is used by the swf-code for z-sorting
	public var __swf_depth:Int;

	public var transform(GetTransform,SetTransform):Transform;
	public var mChanged(default,null):Bool;

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

	var mX:Float;
	var mY:Float;
	var mSizeDirty:Bool;
	var mBoundsRect : Rectangle;
	var mGraphicsBounds : Rectangle;
	var mScale9Grid : Rectangle;
	var mBoundsDirty : Bool;

	static var mNameID = 0;


	var mScaleX:Float;
	var mScaleY:Float;
	var mTransformed:Bool;
	var mRotation:Float;
	var jeashParent:DisplayObjectContainer;
	var mScrollRect:Rectangle;
	var mOpaqueBackground:Null<Int>;

	var mMask:DisplayObject;
	var mMaskingObj:DisplayObject;
	var mMaskHandle:Dynamic;
	var mFilters:Array<Dynamic>;
	var mFilterSet:FilterSet;

	var mCacheAsBitmap:Bool;
	var mCachedBitmap:BitmapData;
	var mFilteredBitmap:BitmapData;
	var mCachedBitmapTx:Float;
	var mCachedBitmapTy:Float;
	var mCachedBoundsRect : Rectangle;
	var mCCLeft:Bool;
	var mCCRight:Bool;
	var mCCTop:Bool;
	var mCCBottom:Bool;

	var mMatrix:Matrix;
	var mFullMatrix:Matrix;

	static var TRANSLATE_CHANGE     = 0x01;
	static var NON_TRANSLATE_CHANGE = 0x02;
	static var GRAPHICS_CHANGE      = 0x04;

	public function new()
	{
		jeashParent = null;
		super(null);
		mX = mY = 0;
		mScaleX = mScaleY = 1.0;
		alpha = 1.0;
		mTransformed = false;
		mRotation = 0.0;
		__swf_depth = 0;
		mMatrix = new Matrix();
		mFullMatrix = new Matrix();
		mMask = null;
		mMaskingObj = null;
		mCacheAsBitmap = false;
		mCachedBitmap = null;
		mFilteredBitmap = null;
		mCachedBitmapTx = 0;
		mCachedBitmapTy = 0;
		mBoundsDirty = true;
		mBoundsRect = new Rectangle();
		mGraphicsBounds = null;
		mMaskHandle = null;
		mCCLeft = mCCRight = mCCTop = mCCBottom = false;
		name = "DisplayObject " + mNameID++;
		mChanged = true;
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
		var gfx = GetGraphics();
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

	function DoAdded(inObj:DisplayObject)
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

	function DoRemoved(inObj:DisplayObject)
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
	}
	public function DoMouseEnter() {}
	public function DoMouseLeave() {}

	public function jeashSetParent(inParent:DisplayObjectContainer)
	{
		if (inParent == jeashParent)
			return;

		if (jeashParent != null)
			jeashParent.__removeChild(this);

		if (jeashParent==null && inParent!=null)
		{
			jeashParent = inParent;
			DoAdded(this);
		}
		else if (jeashParent!=null && inParent==null)
		{
			jeashParent = inParent;
			DoRemoved(this);
		}
		else
			jeashParent = inParent;

	}


	public function GetX() { return mX; }
	public function GetParent() { return jeashParent; }
	public function GetY() { return mY; }
	public function SetX(inX:Float) { mX = inX; UpdateMatrix(); return mX; }
	public function SetY(inY:Float) { mY = inY; UpdateMatrix();return mY; }
	public function GetStage() { return flash.Lib.jeashGetStage(); }
	public function AsContainer() : DisplayObjectContainer { return null; }

	public function GetScaleX() { return mScaleX; }
	public function GetScaleY() { return mScaleY; }
	public function SetScaleX(inS:Float)
	{ mScaleX = inS; UpdateMatrix(); return inS; }
	public function SetScaleY(inS:Float)
	{ mScaleY = inS; UpdateMatrix(); return inS; }



	public function SetRotation(inRotation:Float)
	{
		mRotation = inRotation * Math.PI / 180.0;
		UpdateMatrix();
		return inRotation;
	}
	public function GetRotation()
	{
		return mRotation * (180.0 / Math.PI);
	}

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
		throw "DisplayObject.hitTestObject not implemented in Jeash";
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
		mTransformed = true;
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
		mTransformed = mMatrix.a!=1 || mMatrix.b!=0 || mMatrix.tx!=0 ||
			mMatrix.c!=0 || mMatrix.d!=1 || mMatrix.ty!=0;
		return inMatrix;
	}

	public function UpdateMatrix()
	{
		mMatrix = new Matrix(mScaleX,0.0, 0.0,mScaleY);
		if (mRotation!=0.0)
			mMatrix.rotate(mRotation);
		mMatrix.tx = mX;
		mMatrix.ty = mY;
		mTransformed = mMatrix.a!=1 || mMatrix.c!=0 || mMatrix.tx!=0 ||
			mMatrix.b!=0 || mMatrix.d!=1 || mMatrix.ty!=0;
		mBoundsDirty = true;

		// HACK, until we get CSS matrix transforms working 
		var gfx = GetGraphics();
		if (gfx != null)
			Reflect.setField(gfx, 'mChanged', true);
	}

	public function GetGraphics() : flash.display.Graphics
	{ return null; }


	public function SetupRender(inParentMatrix:Matrix) : Int
	{
		var result = 0;
		var m:Matrix;

		if (mTransformed)
		{
			m = mMatrix.mult(inParentMatrix);
		}
		else
			m = inParentMatrix;

		if ( m.a!=mFullMatrix.a || m.b!=mFullMatrix.b ||
				m.c!=mFullMatrix.c || m.d!=mFullMatrix.d )
			result |= DisplayObject.NON_TRANSLATE_CHANGE;

		if (m.tx!=mFullMatrix.tx || m.ty!=mFullMatrix.ty )
			result |= DisplayObject.TRANSLATE_CHANGE;

		var gfx = GetGraphics();
		/*
		if (gfx!=null)
		{
			if (gfx.mChanged)
			{
				result |= DisplayObject.NON_TRANSLATE_CHANGE | DisplayObject.GRAPHICS_CHANGE;
				mGraphicsBounds = null;
			}
		}
		*/
		result |= DisplayObject.NON_TRANSLATE_CHANGE | DisplayObject.GRAPHICS_CHANGE;
		mGraphicsBounds = null;

		if ( (result & DisplayObject.NON_TRANSLATE_CHANGE) !=0)
			mBoundsDirty = true;
		else if (result!=0)
		{
			mBoundsRect.x += m.tx - mFullMatrix.tx;
			mBoundsRect.y += m.ty - mFullMatrix.ty;

			// See if translation exposes a new bit of previously clipped cached bitmap...
			var dx = mFullMatrix.tx + mCachedBitmapTx;
			var dy = mFullMatrix.ty + mCachedBitmapTy;
			if ( (mCCLeft && (dx<0)) || (mCCRight && (dx>0)) ||
					(mCCBottom && (dy<0)) || (mCCTop && (dy>0)) )
			{
				mCachedBitmap = null;
			}
		}


		mFullMatrix = m;

		if (result!=0)
			mMaskHandle = null;


		return result;
	}

	public function GetHeight() : Float
	{
		BuildBounds();
		return mBoundsRect.height;
	}
	public function SetHeight(inHeight:Float) : Float
	{
		BuildBounds();
		var h = mBoundsRect.height;
		if (inHeight!=h)
		{
			if (h<=0) return 0;
			mScaleY *= inHeight/h;
			UpdateMatrix();
		}
		return inHeight;
	}



	public function GetWidth() : Float
	{
		BuildBounds();
		return mBoundsRect.width;
	}

	public function SetWidth(inWidth:Float) : Float
	{
		BuildBounds();
		var w = mBoundsRect.width;
		if (w!=inWidth)
		{
			if (w<=0) return 0;
			mScaleX *= inWidth/w;
			UpdateMatrix();
		}
		return inWidth;
	}

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
			var gfx = GetGraphics();
			if (gfx!=null)
				mGraphicsBounds = gfx.GetExtent(new Matrix());
		}
		return mGraphicsBounds;
	}

	public function __Render(?inMask:HTMLCanvasElement, inTX:Int = 0, inTY:Int = 0)
	{
		var gfx = GetGraphics();

		if (gfx!=null)
		{
			var blend:Int = __BlendIndex();

			Graphics.setBlendMode(blend);

			var m = mFullMatrix.clone();
			gfx.__Render(m, inMask);

			if (!jeash.Lib.mOpenGL)
			{
				var extent = gfx.GetExtent(new Matrix());
				gfx.mSurface.style.left = ((Math.isNaN(m.tx)?0:m.tx)  + inTX + extent.x) + "px";
				gfx.mSurface.style.top = ((Math.isNaN(m.ty)?0:m.ty) + inTY + extent.y) + "px";

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

	function RenderContentsToCache(inCanvas:HTMLCanvasElement, inTX:Int, inTY:Int)
	{
		__Render(inCanvas, inTX, inTY);
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
			blendMode:String,
			clipRect:flash.geom.Rectangle,
			smoothing:Bool):Void
	{
		if (matrix==null) matrix = new Matrix();
		SetupRender(matrix);
		// TODO
		//RenderContentsToCache(inSurface,0,0);
	}

	public function jeashGetObjectUnderPoint(point:Point)
	{
		var gfx = GetGraphics();
		if (gfx != null)
		{
			var local = globalToLocal(point);
			switch (stage.jeashPointInPathMode)
			{
				case USER_SPACE:
					if (gfx.jeashHitTest(local.x, local.y))
					{
						var i = jeashAsInteractiveObject();
						return i == null ? null : i;
					}
				case DEVICE_SPACE:

					var extent = gfx.GetExtent(new Matrix());
					if (gfx.jeashHitTest((local.x-(extent.x))*scaleX, (local.y-(extent.y))*scaleY))
					{
						var i = jeashAsInteractiveObject();
						return i == null ? null : i;
					}
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

	// Bitmap caching
	public function SetFilters(inFilters:Array<Dynamic>)
	{
		var f = new Array<Dynamic>();
		if (inFilters!=null)
			for(filter in inFilters)
				f.push( filter.clone() );
		mFilters = f;
		// Regenerate next render ...
		mCachedBitmap = null;
		mFilteredBitmap = null;

		if (mFilters.length<1)
			mFilterSet = null;
		else
			mFilterSet = new FilterSet(mFilters);

		return GetFilters();
	}

	public function GetFilters()
	{
		var f = new Array<Dynamic>();
		if (mFilters!=null)
		{
			for(filter in mFilters)
				f.push( filter.clone() );
		}
		return f;
	}

	function BuildBounds()
	{
		if (mBoundsDirty || mBoundsRect==null)
		{
			mBoundsDirty = false;
			var gfx = GetGraphics();
			if (gfx==null)
				mBoundsRect = new Rectangle(mFullMatrix.tx,mFullMatrix.ty,0,0);
			else
			{
				var m = mFullMatrix.clone(); m.tx = 0; m.ty = 0;
				mBoundsRect = gfx.GetExtent(m);
				if (mScale9Grid!=null)
				{
					mBoundsRect.width *= scaleX;
					mBoundsRect.height *= scaleY;
				}
			}
		}
	}

	function GetScreenBounds()
	{
		BuildBounds();
		return mBoundsRect.clone();
	}

	// We have detected that a cached bitmap has been hit - check to
	//  see it it was actually one of the child objects.  This will
	//  be overwritten by DisplayObjectContainer.
	/*
	public function GetChildCachedObj(inX:Int,inY:Int,inObj:InteractiveObject) : InteractiveObject
	{
		return inObj;
	}

	public function CacheGetObj(inX:Int,inY:Int, inObj:InteractiveObject ) : InteractiveObject
	{
		var tx = Std.int(mFullMatrix.tx + mCachedBitmapTx + 0.5);
		var ty = Std.int(mFullMatrix.ty + mCachedBitmapTy + 0.5);
		if (inX>=tx && inY>=ty && inX<tx+mCachedBitmap.width && inY<ty+mCachedBitmap.height)
		{
			// TODO : Check alpha ?
			var i = AsInteractiveObject();
			return GetChildCachedObj(inX-tx,inY-ty,i==null ? inObj : i);
		}
		return null;
	}
	*/
	public function GetFocusObjects(outObjs:Array<InteractiveObject>) { }
	inline function __BlendIndex():Int
	{
		return blendMode == null ? Graphics.BLEND_NORMAL : Type.enumIndex(blendMode);
	}

	function SetAlpha(alpha:Float):Float
	{
		var gfx = GetGraphics();
		if (gfx!=null && alpha >= 0.0 && alpha <= 1.0) gfx.mSurfaceAlpha = alpha;
		return alpha;
	}

	public function jeashGetInteractiveObjectStack(outStack:Array<InteractiveObject>)
	{
		var io = jeashAsInteractiveObject();
		if (io!=null)
			outStack.push(io);
		if (jeashParent!=null)
			jeashParent.jeashGetInteractiveObjectStack(outStack);
	}


	// @r551
	public function jeashFireEvent(event:flash.events.Event)
	{
		var stack:Array<InteractiveObject> = [];
		if (jeashParent != null)
			jeashParent.jeashGetInteractiveObjectStack(stack);
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

}
