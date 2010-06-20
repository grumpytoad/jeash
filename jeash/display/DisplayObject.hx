package jeash.display;

import Html5Dom;
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
	public var alpha:Float;
	public var name(default,default):String;
	public var width(GetWidth,SetWidth):Float;
	public var height(GetHeight,SetHeight):Float;
	public var visible(default,default):Bool;
	public var opaqueBackground(GetOpaqueBackground,SetOpaqueBackground):Null<Int>;
	public var mouseX(GetMouseX,null):Float;
	public var mouseY(GetMouseY,null):Float;
	public var parent(GetParent,null):DisplayObjectContainer;
	public var stage(GetStage,null):Stage;
	public var rotation(GetRotation,SetRotation):Float;
	public var scrollRect(GetScrollRect,SetScrollRect):Rectangle;
	public var mask(GetMask,SetMask):DisplayObject;
	public var filters(GetFilters,SetFilters):Array<Dynamic>;
	public var blendMode : flash.display.BlendMode;


	// This is used by the swf-code for z-sorting
	public var __swf_depth:Int;

	public var transform(GetTransform,SetTransform):Transform;

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

	public var mChanged(default,null):Bool;

	var mMatrix:Matrix;
	var mFullMatrix:Matrix;

	static var TRANSLATE_CHANGE     = 0x01;
	static var NON_TRANSLATE_CHANGE = 0x02;
	static var GRAPHICS_CHANGE      = 0x04;

	public function new()
	{
		mParent = null;
		super();
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
	}

	public function toString() { return name; }


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

	public function getBounds(targetCoordinateSpace : DisplayObject) : Rectangle {
		// TODO
		return null;
		//BuildBounds();
		//return mBoundsRect.clone();
	}
	public function getRect(targetCoordinateSpace : DisplayObject) : Rectangle {
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
		if (gfx!=null)
		{
			if (gfx.CheckChanged())
			{
				result |= DisplayObject.NON_TRANSLATE_CHANGE | DisplayObject.GRAPHICS_CHANGE;
				mGraphicsBounds = null;
			}
		}

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

	public function __RenderGfx(inTarget:BitmapData,inScrollRect:Rectangle,
			inMask:HtmlCanvasElement,inTX:Float,inTY:Float)
	{
		var gfx = GetGraphics();

		if (gfx!=null)
		{
			var blend:Int = __BlendIndex();
			var handle = inTarget==null ? gfx.mSurface : inTarget.handle();

			Graphics.setBlendMode(blend);

			if (inScrollRect!=null || inTarget!=null)
			{
				var m = mFullMatrix.clone();
				m.tx -= inTX;
				m.ty -= inTY;
				gfx.__Render(m,handle,inMask,inScrollRect);
			}
			else
				gfx.__Render(mFullMatrix,handle,inMask,null);
			return handle;
		}

		return null;

	}

	public function __Render(inParentMask:HtmlCanvasElement,inScrollRect:Rectangle,inTX:Int,inTY:Int):HtmlCanvasElement
	{
		return __RenderGfx(null,inScrollRect,inParentMask,inTX,inTY );
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
		RenderContentsToCache(inSurface,0,0);
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

	function RenderContentsToCache(inBitmap:BitmapData,inTX:Float,inTY:Float)
	{
		// trace("RenderContentsToCache " + toString() + ":" + inBitmap.width + "," + inBitmap.height );
		__RenderGfx(inBitmap,null,null,inTX,inTY );
	}

	// We have detected that a cached bitmap has been hit - check to
	//  see it it was actually one of the child objects.  This will
	//  be overwritten by DisplayObjectContainer.
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
	public function GetFocusObjects(outObjs:Array<InteractiveObject>) { }
	public inline function __BlendIndex():Int
	{
		return blendMode == null ? Graphics.BLEND_NORMAL : Type.enumIndex(blendMode);
	}

}

