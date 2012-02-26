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

import jeash.accessibility.AccessibilityProperties;
import jeash.display.Stage;
import jeash.display.Graphics;
import jeash.events.EventDispatcher;
import jeash.events.Event;
import jeash.events.EventPhase;
import jeash.display.DisplayObjectContainer;
import jeash.display.IBitmapDrawable;
import jeash.display.InteractiveObject;
import jeash.geom.Rectangle;
import jeash.geom.Matrix;
import jeash.geom.Point;
import jeash.geom.Transform;
import jeash.filters.BitmapFilter;
import jeash.display.BitmapData;
import jeash.Lib;

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
	
	public var x(jeashGetX,jeashSetX):Float;
	public var y(jeashGetY,jeashSetY):Float;
	public var scaleX(jeashGetScaleX,jeashSetScaleX):Float;
	public var scaleY(jeashGetScaleY,jeashSetScaleY):Float;
	public var rotation(jeashGetRotation,jeashSetRotation):Float;
	
	public var accessibilityProperties:AccessibilityProperties;
	public var alpha:Float;
	public var name(default,default):String;
	public var cacheAsBitmap:Bool;
	public var width(jeashGetWidth,jeashSetWidth):Float;
	public var height(jeashGetHeight,jeashSetHeight):Float;

	public var visible(jeashGetVisible,jeashSetVisible):Bool;
	public var opaqueBackground(GetOpaqueBackground,SetOpaqueBackground):Null<Int>;
	public var mouseX(jeashGetMouseX, jeashSetMouseX):Float;
	public var mouseY(jeashGetMouseY, jeashSetMouseY):Float;
	public var parent:DisplayObjectContainer;
	public var stage(GetStage,null):Stage;
	
	public var scrollRect(GetScrollRect,SetScrollRect):Rectangle;
	public var mask(GetMask,SetMask):DisplayObject;
	public var filters(jeashGetFilters,jeashSetFilters):Array<Dynamic>;
	public var blendMode : jeash.display.BlendMode;
	public var loaderInfo:LoaderInfo;


	// This is used by the swf-code for z-sorting
	public var __swf_depth:Int;

	public var transform(GetTransform,SetTransform):Transform;

	var mBoundsDirty:Bool;
	var mMtxChainDirty:Bool;
	var mMtxDirty:Bool;
	
	var mBoundsRect : Rectangle;
	var mGraphicsBounds : Rectangle;
	var mScale9Grid : Rectangle;
	var mMatrix:Matrix;
	var mFullMatrix:Matrix;
	
	var jeashX : Float;
	var jeashY : Float;
	var jeashScaleX : Float;
	var jeashScaleY : Float;
	var jeashRotation : Float;
	var jeashVisible : Bool;

	static var mNameID = 0;

	var mScrollRect:Rectangle;
	var mOpaqueBackground:Null<Int>;

	var mMask:DisplayObject;
	var mMaskingObj:DisplayObject;
	var mMaskHandle:Dynamic;
	var jeashFilters:Array<BitmapFilter>;
	
	
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
		mBoundsDirty = true;
		mGraphicsBounds = null;
		mMaskHandle = null;
		name = "DisplayObject " + mNameID++;

		visible = true;
	}

	override public function toString() { return name; }

	function jeashDoAdded(inObj:DisplayObject)
	{
		if (inObj==this)
		{
			var evt = new jeash.events.Event(jeash.events.Event.ADDED, true, false);
			evt.target = inObj;
			dispatchEvent(evt);
		}

		var evt = new jeash.events.Event(jeash.events.Event.ADDED_TO_STAGE, false, false);
		evt.target = inObj;
		dispatchEvent(evt);
	}

	function jeashDoRemoved(inObj:DisplayObject)
	{
		if (inObj==this)
		{
			var evt = new jeash.events.Event(jeash.events.Event.REMOVED, true, false);
			evt.target = inObj;
			dispatchEvent(evt);
		}
		var evt = new jeash.events.Event(jeash.events.Event.REMOVED_FROM_STAGE, false, false);
		evt.target = inObj;
		dispatchEvent(evt);

		var gfx = jeashGetGraphics();
		if (gfx != null)
			Lib.jeashRemoveSurface(gfx.jeashSurface);
	}
	public function DoMouseEnter() {}
	public function DoMouseLeave() {}

	public function jeashSetParent(parent:DisplayObjectContainer)
	{
		if (parent == this.parent)
			return;

		mMtxChainDirty=true;

		if (this.parent != null)
		{
			this.parent.__removeChild(this);
			this.parent.jeashInvalidateBounds();	
		}
		
		if(parent != null)
		{
			parent.jeashInvalidateBounds();
		}

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
		else{
			this.parent = parent;
		}

	}

	public function GetStage() { return jeash.Lib.jeashGetStage(); }
	public function AsContainer() : DisplayObjectContainer { return null; }

	public function GetScrollRect() : Rectangle
	{
		if (mScrollRect==null) return null;
		return mScrollRect.clone();
	}

	public function jeashAsInteractiveObject() : jeash.display.InteractiveObject
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

	function jeashGetMouseX() { return globalToLocal(new Point(stage.mouseX, 0)).x; }
	function jeashSetMouseX(x:Float) { return null; }
	function jeashGetMouseY() { return globalToLocal(new Point(0, stage.mouseY)).y; }
	function jeashSetMouseY(y:Float) { return null; }

	public function GetTransform() { return  new Transform(this); }

	public function SetTransform(trans:Transform)
	{
		mMatrix = trans.matrix.clone();
		return trans;
	}
	
	public function getFullMatrix(?childMatrix:Matrix=null) {
		if(childMatrix==null) {
			return mFullMatrix.clone();
		} else {
			return childMatrix.mult(mFullMatrix);
		}
	}

	public function getBounds(targetCoordinateSpace : DisplayObject) : Rectangle 
	{		
		if(mMtxDirty || mMtxChainDirty)
			jeashValidateMatrix();
		
		if(mBoundsDirty)
		{
			BuildBounds();
		}
		
		var mtx : Matrix = mFullMatrix.clone();
		//perhaps inverse should be stored and updated lazily?
		mtx.concat(targetCoordinateSpace.mFullMatrix.clone().invert());
		var rect : Rectangle = mBoundsRect.transform(mtx);	//transform does cloning
		return rect;
	}

	public function getRect(targetCoordinateSpace : DisplayObject) : Rectangle 
	{
		// TODO
		return null;
	}

	public function globalToLocal(inPos:Point) 
		return mFullMatrix.clone().invert().transformPoint(inPos)
	
	public function jeashGetNumChildren() return 0

	public function jeashGetMatrix() return mMatrix.clone()

	public function jeashSetMatrix(inMatrix:Matrix) {
		mMatrix = inMatrix.clone();
		return inMatrix;
	}

	function jeashGetGraphics() : jeash.display.Graphics return null

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
				mGraphicsBounds = gfx.jeashExtent.clone();
		}
		return mGraphicsBounds;
	}
	
	/**
	 * Bounds are invalidated when:
	 * - a child is added or removed from a container
	 * - a child is scaled, rotated, translated, or skewed
	 * - the display of an object changes (graphics changed,
	 * bitmap loaded, textbox resized)
	 * - a child has its bounds invalidated
	 * ---> Invalidates down to stage
	 */
	//** internal **//
	//** FINAL **//	
	public function jeashInvalidateBounds():Void{
		//TODO :: adjust so that parent is only invalidated if it's bounds are changed by this change
		mBoundsDirty=true;
		if(parent!=null)
			parent.jeashInvalidateBounds();
	}
	
	/**
	 * Matrices are invalidated when:
	 * - the object is scaled, rotated, translated, or skewed
	 * - an object's parent has its matrices invalidated
	 * ---> 	Invalidates up through children
	 */
	function jeashInvalidateMatrix( ? local : Bool = false):Void {
		mMtxChainDirty= mMtxChainDirty || !local;	//note that a parent has an invalid matrix 
		mMtxDirty = mMtxDirty || local; //invalidate the local matrix
	}
	
	public function jeashValidateMatrix() {
		
		if(mMtxDirty || (mMtxChainDirty && parent!=null)) {
			//validate parent matrix
			if(mMtxChainDirty && parent!=null) {
				parent.jeashValidateMatrix();
			}
			
			//validate local matrix
			if(mMtxDirty) {
				//update matrix if necessary
				//set non scale elements to identity
				mMatrix.b = mMatrix.c = mMatrix.tx = mMatrix.ty = 0;
			
				//set scale
				mMatrix.a=jeashScaleX;
				mMatrix.d=jeashScaleY;
			
				//set rotation if necessary
				var rad = jeashRotation * Math.PI / 180.0;
		
				if(rad!=0.0)
					mMatrix.rotate(rad);
			
				//set translation
				mMatrix.tx=jeashX;
				mMatrix.ty=jeashY;	
			}
			
			
			if (parent!=null)
				mFullMatrix = parent.getFullMatrix(mMatrix);
			else
				mFullMatrix = mMatrix;
			
			mMtxDirty = mMtxChainDirty = false;
		}
	}
	

	public function jeashRender(parentMatrix:Matrix, ?inMask:HTMLCanvasElement) {
		
		var gfx = jeashGetGraphics();

		if (gfx!=null) {
			// Cases when the rendering phase should be skipped
			if (gfx.jeashIsTile || !jeashVisible) return;

			if(mMtxDirty || mMtxChainDirty){
				jeashValidateMatrix();
			}
			
			var m = mFullMatrix.clone();

			if (jeashFilters != null && (gfx.jeashChanged || inMask != null)) {
				if (gfx.jeashRender(inMask, m)) jeashInvalidateBounds();
				for (filter in jeashFilters) {
					filter.jeashApplyFilter(gfx.jeashSurface);
				}
			} else if (gfx.jeashRender(inMask, m)) jeashInvalidateBounds();

			m.tx = m.tx + gfx.jeashExtent.x*m.a + gfx.jeashExtent.y*m.c;
			m.ty = m.ty + gfx.jeashExtent.x*m.b + gfx.jeashExtent.y*m.d;

			if (inMask != null) {
				Lib.jeashDrawToSurface(gfx.jeashSurface, inMask, m, (parent != null ? parent.alpha : 1) * alpha);
			} else {
				Lib.jeashSetSurfaceTransform(gfx.jeashSurface, m);
				Lib.jeashSetSurfaceOpacity(gfx.jeashSurface, (parent != null ? parent.alpha : 1) * alpha);
			}

		} else {
			if(mMtxDirty || mMtxChainDirty){
				jeashValidateMatrix();
			}
		}
	}

	public function drawToSurface(inSurface : Dynamic,
			matrix:jeash.geom.Matrix,
			colorTransform:jeash.geom.ColorTransform,
			blendMode:BlendMode,
			clipRect:jeash.geom.Rectangle,
			smoothing:Bool):Void {
		if (matrix==null) matrix = new Matrix();
		jeashRender(matrix, inSurface);
	}

	public function jeashGetObjectUnderPoint(point:Point):DisplayObject {
		if (!visible) return null;
		var gfx = jeashGetGraphics();
		if (gfx != null) {
			var extX = gfx.jeashExtent.x;
			var extY = gfx.jeashExtent.y;
			var local = globalToLocal(point);
			if (local.x-extX < 0 || local.y-extY < 0 || (local.x-extX)*scaleX > width || (local.y-extY)*scaleY > height) return null; 
			switch (stage.jeashPointInPathMode) {
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
	public function jeashSetFilters(filters:Array<Dynamic>) {
		if (filters==null)
			jeashFilters = null;
		else {
			jeashFilters = new Array<BitmapFilter>();
			for(filter in filters) jeashFilters.push(filter.clone());
		}

		return filters;
	}

	// @r533
	public function jeashGetFilters() {
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
			mBoundsRect = gfx.jeashExtent.clone();
			gfx.markBoundsClean();
			if (mScale9Grid!=null)
			{
				mBoundsRect.width *= scaleX;
				mBoundsRect.height *= scaleY;
			}
		}
		mBoundsDirty=false;
	}

	function GetScreenBounds()
	{
		if(mBoundsDirty)
			BuildBounds();
		return mBoundsRect.clone();
	}

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
	public function jeashFireEvent(event:jeash.events.Event)
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
	public function jeashBroadcast(event:jeash.events.Event)
	{
		dispatchEvent(event);
	}

	function jeashAddToStage()
	{
		var gfx = jeashGetGraphics();
		if (gfx != null)
			Lib.jeashAppendSurface(gfx.jeashSurface);
	}

	function jeashInsertBefore(obj:DisplayObject)
	{
		var gfx1 = jeashGetGraphics();
		var gfx2 = obj.jeashIsOnStage() ? obj.jeashGetGraphics() : null;
		if (gfx1 != null)
		{
			if (gfx2 != null )
				Lib.jeashAppendSurface(gfx1.jeashSurface, gfx2.jeashSurface);
			 else 
				Lib.jeashAppendSurface(gfx1.jeashSurface);
		}
	}

	function jeashIsOnStage() {
		var gfx = jeashGetGraphics();
		if (gfx != null)
			return Lib.jeashIsOnStage(gfx.jeashSurface);

		return false;
	}

	function jeashGetVisible() { return jeashVisible; }
	function jeashSetVisible(visible:Bool) {
		var gfx = jeashGetGraphics();
		if (gfx != null)
			if (gfx.jeashSurface != null)
				Lib.jeashSetSurfaceVisible(gfx.jeashSurface, visible);
		jeashVisible = visible;
		return visible;
	}

	public function jeashGetHeight() : Float
	{
		BuildBounds();
		return jeashScaleY * mBoundsRect.height;
	}
	public function jeashSetHeight(inHeight:Float) : Float {
		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();
		var h = mBoundsRect.height;
		if (jeashScaleY*h != inHeight)
		{
			if (h<=0) return 0;
			jeashScaleY = inHeight/h;
			jeashInvalidateMatrix(true);
		}
		return inHeight;
	}

	public function jeashGetWidth() : Float {
		if(mBoundsDirty){
			BuildBounds();
		}
		return jeashScaleX * mBoundsRect.width;
	}

	public function jeashSetWidth(inWidth:Float) : Float {
		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();
		var w = mBoundsRect.width;
		if (jeashScaleX*w != inWidth)
		{
			if (w<=0) return 0;
			jeashScaleX = inWidth/w;
			jeashInvalidateMatrix(true);
		}
		return inWidth;
	}

	public function jeashGetX():Float{
		return jeashX;
	}
	
	public function jeashGetY():Float{
		return jeashY;
	}
	
	public function jeashSetX(n:Float):Float{
		jeashInvalidateMatrix(true);
		jeashX=n;
		if(parent!=null)
			parent.jeashInvalidateBounds();
		return n;
	}

	public function jeashSetY(n:Float):Float{
		jeashInvalidateMatrix(true);
		jeashY=n;
		if(parent!=null)
			parent.jeashInvalidateBounds();
		return n;
	}


	public function jeashGetScaleX() { return jeashScaleX; }
	public function jeashGetScaleY() { return jeashScaleY; }
	public function jeashSetScaleX(inS:Float) { 
		if(jeashScaleX==inS)
			return inS;		
		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();
		if(!mMtxDirty)
			jeashInvalidateMatrix(true);	
		jeashScaleX=inS;
		return inS;
	}

	public function jeashSetScaleY(inS:Float) { 
		if(jeashScaleY==inS)
			return inS;		
		if(parent!=null)
			parent.jeashInvalidateBounds();
		if(mBoundsDirty)
			BuildBounds();
		if(!mMtxDirty)
			jeashInvalidateMatrix(true);	
		jeashScaleY=inS;
		return inS;
	}

	private function jeashSetRotation(n:Float):Float{
		if(!mMtxDirty)
			jeashInvalidateMatrix(true);
		if(parent!=null)
			parent.jeashInvalidateBounds();

		jeashRotation = n;
		return n;
	}
	
	private function jeashGetRotation():Float{
		return jeashRotation;
	}


}
