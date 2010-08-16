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
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.display.DisplayObjectContainer;
import flash.display.IBitmapDrawable;
import flash.display.InteractiveObject;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;
import flash.Manager;
import flash.filters.BitmapFilterSet;
import flash.filters.FilterSet;
import flash.display.BitmapData;


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
	public var alpha:Float;
	public var name(default,default):String;
	public var cacheAsBitmap:Bool;
	public var width(GetWidth,SetWidth):Float;
	public var height(GetHeight,SetHeight):Float;
	public var visible(default,default):Bool;
	public var opaqueBackground(GetOpaqueBackground,SetOpaqueBackground):Null<Int>;
	public var mouseX(GetMouseX,null):Float;
	public var mouseY(GetMouseY,null):Float;
	public var parent(GetParent,null):DisplayObjectContainer;
	public var stage(GetStage,null):Stage;
	public var root(GetStage,null):Stage;
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
	public var mTextureCoords:Array<Float>;
	public var mIndices:Array<Int>;

	var mVertexBuffer(default,null):WebGLBuffer;
	var mTextureCoordsBuffer(default,null):WebGLBuffer;
	var mIndicesBuffer(default,null):WebGLBuffer;

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
	var mParent:DisplayObjectContainer;
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
		mParent = null;
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

		visible = true;

		if ( jeash.Lib.mOpenGL )
		{

			// Default to a simple two polygon square face - by
			// updating these array buffers, it is possible to have
			// a full GPU accelerated 3D environment.

			mVertices = [      
				0.0,  1.0,  0.0,
			       -1.0, -1.0,  0.0,
			        1.0, -1.0,  0.0
			];
			mTextureCoords = [
				0.0, 0.0,
				1.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,
			];
			mIndices = [
				0, 1, 2,      
				0, 2, 3
			];

			var gl : WebGLRenderingContext = jeash.Lib.canvas.getContext(jeash.Lib.context);
			mVertexBuffer 		= gl.createBuffer();
			mTextureCoordsBuffer 	= gl.createBuffer();
			mIndicesBuffer		= gl.createBuffer();
			
			gl.bindBuffer(gl.ARRAY_BUFFER, mVertexBuffer);
			gl.bindBuffer(gl.ARRAY_BUFFER, mTextureCoordsBuffer);
			gl.bindBuffer(gl.ARRAY_BUFFER, mIndicesBuffer);

			UpdateBuffers();
		}
	}

	public function UpdateBuffers()
	{
		var gl : WebGLRenderingContext = jeash.Lib.canvas.getContext(jeash.Lib.context);

		gl.bufferData(gl.ARRAY_BUFFER, new WebGLFloatArray(mVertices), gl.STATIC_DRAW);
		gl.bufferData(gl.ARRAY_BUFFER, new WebGLFloatArray(mTextureCoords), gl.STATIC_DRAW);
		gl.bufferData(gl.ARRAY_BUFFER, new WebGLUnsignedShortArray(mIndices), gl.STATIC_DRAW);
		
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

	public function SetParent(inParent:DisplayObjectContainer)
	{
		if (inParent == mParent)
			return;

		if (mParent != null)
			mParent.__removeChild(this);

		if (mParent==null && inParent!=null)
		{
			mParent = inParent;
			DoAdded(this);
		}
		else if (mParent!=null && inParent==null)
		{
			mParent = inParent;
			DoRemoved(this);
		}
		else
			mParent = inParent;

	}


	public function GetX() { return mX; }
	public function GetParent() { return mParent; }
	public function GetY() { return mY; }
	public function SetX(inX:Float) { mX = inX; UpdateMatrix(); return mX; }
	public function SetY(inY:Float) { mY = inY; UpdateMatrix();return mY; }
	public function GetStage() { return flash.Lib.GetStage(); }
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

	public function AsInteractiveObject() : flash.display.InteractiveObject
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

	// TODO:
	public function GetMouseX() { return globalToLocal(flash.Lib.mLastMouse).x; }
	public function GetMouseY() { return globalToLocal(flash.Lib.mLastMouse).y; }

	//#if !js
	public function GetTransform() { return  new Transform(this); }
	/*#else
	  var mTransform : Transform;
	  public function GetTransform() {
	  if ( mTransform == null ) {
	  mTransform = new Transform(this);
	  }
	  return mTransform;
	  }
#end*/

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
		//return GetMatrix().invert().transformPoint(inPos);
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
		//gfx.mCanvas.height = Std.int(inHeight);
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
		//gfx.mCanvas.width = Std.int(inWidth);
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

	public function __RenderGfx(inScrollRect:Rectangle,
			inMask:HTMLCanvasElement,inTX:Float,inTY:Float)
	{
		var gfx = GetGraphics();

		if (gfx!=null)
		{
			var blend:Int = __BlendIndex();

			Graphics.setBlendMode(blend);

			var gl : WebGLRenderingContext = null;
			if (jeash.Lib.mOpenGL)
			{
				gl = jeash.Lib.canvas.getContext(jeash.Lib.context);
				gl.bindBuffer(gl.ARRAY_BUFFER, mVertexBuffer);
				gl.enableVertexAttribArray( gl.getAttribLocation(gfx.mShaderGL, "mVertices") );
				gl.vertexAttribPointer( gl.getAttribLocation( gfx.mShaderGL, "mVertices" ), Std.int(mVertices.length / 3), gl.FLOAT, false, 0, 0 );
				gl.vertexAttribPointer( gl.getAttribLocation( gfx.mShaderGL, "mTextureCoords" ), Std.int(mTextureCoords.length / 2), gl.FLOAT, false, 0, 0 );
				
			}

			if (inScrollRect!=null)
			{
				var m = mFullMatrix.clone();
				m.tx -= inTX;
				m.ty -= inTY;
				gfx.__Render(m,inMask,inScrollRect);
			}
			else
				gfx.__Render(mFullMatrix,inMask,null);

			if (jeash.Lib.mOpenGL)
			{

				gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mVertexBuffer);

				gl.uniformMatrix4fv( gl.getUniformLocation( gfx.mShaderGL, "uPMatrix" ), false, new WebGLFloatArray( [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0] ) );
				gl.uniformMatrix4fv( gl.getUniformLocation( gfx.mShaderGL, "uMVMatrix" ), false, new WebGLFloatArray( GetGLMatrix(mFullMatrix) ) );

				gl.drawElements(gl.TRIANGLES, mIndices.length, gl.UNSIGNED_SHORT, 0);

			}
		}

	}

	// TODO: make this externally modify-able
	static inline function GetGLMatrix( m:Matrix )
	{
		return [
			m.a, m.b, 0, m.tx,
			m.c, m.d, 0, m.ty,
			0, 0, 1, 0,
			0, 0, 0, 1
		];
	}

	public function __Render(inParentMask:HTMLCanvasElement,inScrollRect:Rectangle,inTX:Int,inTY:Int)
	{
		__RenderGfx(inScrollRect,inParentMask,inTX,inTY );
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


	public function GetObj(inX:Int,inY:Int, inObj:InteractiveObject ) : InteractiveObject
	{
		if (!visible || mMaskingObj!=null)
			return null;

		var gfx = GetGraphics();
		if (gfx!=null && gfx.HitTest(inX,inY))
		{
			var i = AsInteractiveObject();
			return i==null ? inObj : i;
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
				mBoundsRect = gfx.GetExtent(mFullMatrix);
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
	public inline function __BlendIndex():Int
	{
		return blendMode == null ? Graphics.BLEND_NORMAL : Type.enumIndex(blendMode);
	}

}

