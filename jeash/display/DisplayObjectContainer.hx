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
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;


/**
* @author	Hugh Sanderson
* @author	Lee Sylvester
* @author	Niel Drummond
* @author	Russell Weir
*/
class DisplayObjectContainer extends InteractiveObject
{
	var mObjs : Array<DisplayObject>;
	var mLastSetupObjs : Array<DisplayObject>;
	public var numChildren(GetNumChildren,null):Int;
	public var mouseChildren:Bool;

	public function new()
	{
		mObjs = new Array<DisplayObject>();
		mLastSetupObjs = new Array<DisplayObject>();
		mouseChildren = true;
		super();
		name = "DisplayObjectContainer " +  flash.display.DisplayObject.mNameID++;
	}

	override public function AsContainer() { return this; }

	public function Broadcast(inEvent:flash.events.Event)
	{
		dispatchEvent(inEvent);
		for(obj in mObjs)
		{
			var container = obj.AsContainer();
			//#if !js
			if (container!=null)
				container.Broadcast(inEvent);
			else
			//#end
				obj.dispatchEvent(inEvent);
		}

	}

	override function BuildBounds()
	{
		//if (mBoundsDirty)
		{
			super.BuildBounds();
			for(obj in mObjs)
			{
				if (obj.visible)
				{
					var r = obj.GetScreenBounds();
					if (r.width!=0 || r.height!=0)
					{
						if (mBoundsRect.width==0 && mBoundsRect.height==0)
							mBoundsRect = r.clone();
						else
							mBoundsRect.extendBounds(r);
					}
				}
			}
		}
	}

	override function DoAdded(inObj:DisplayObject)
	{
		super.DoAdded(inObj);
		for(child in mObjs)
			child.DoAdded(inObj);
	}

	override function DoRemoved(inObj:DisplayObject)
	{
		super.DoAdded(inObj);
		for(child in mObjs)
			child.DoRemoved(inObj);
	}

	override public function GetBackgroundRect()
	{
		var r = super.GetBackgroundRect();
		if (r!=null) r = r.clone();

		for(obj in mObjs)
		{
			if (obj.visible)
			{
				var o = obj.GetBackgroundRect();
				if (o!=null)
				{
				var trans = o.transform(obj.mMatrix);
				if (r==null || r.width==0 || r.height==0)
					r = trans;
				else if (trans.width!=0 && trans.height!=0)
					r.extendBounds(trans);
				}
			}
		}
		return r;
	}

	override public function GetFocusObjects(outObjs:Array<InteractiveObject>)
	{
		for(obj in mObjs)
			obj.GetFocusObjects(outObjs);
	}

   override public function GetChildCachedObj(inX:Int,inY:Int,inObj:InteractiveObject) : InteractiveObject
   {
      // Start at end and work backwards (find topmost)
      var l = mObjs.length-1;
      for(i in 0...mObjs.length)
      {
         var result = mObjs[l-i].GetObj(inX,inY,this);
         if (result!=null)
            return result;
      }

      return inObj;
   }


	public override function GetNumChildren() {
		return mObjs.length;
	}

	override public function GetObj(inX:Int,inY:Int, inObj:InteractiveObject) : InteractiveObject
	{
		if (!visible || mMaskingObj!=null)
			return null;

		// Start at end and work backwards (find topmost)
		var l = mObjs.length-1;
		for(i in 0...mObjs.length)
		{
			var result = mObjs[l-i].GetObj(inX,inY,this);
			if (result!=null)
				return result;
		}

		return super.GetObj(inX,inY,this);
	}

	override public function __Render(inMask:HtmlCanvasElement,inScrollRect:Rectangle,inTX:Int, inTY:Int) : HtmlCanvasElement
	{

		if (!visible || mMaskingObj!=null) return null;

		super.__Render(inMask,inScrollRect,inTX,inTY);
		for(obj in mObjs)
		{
			if (obj.visible && obj.mMaskingObj==null)
			{
				var scroll = obj.mScrollRect;
				if (scroll!=null)
				{
					// Convert scrollrect into display coordinates.
					// Use a simple transform for efficiency
					var m = obj.mFullMatrix;
					var x0 = m.tx;
					var y0 = m.ty;
					var x1 = m.a * scroll.width + m.tx;
					var y1 = m.d * scroll.height + m.ty;
					var display_rect = new Rectangle(x0,y0,x1-x0,y1-y0);
					if (inScrollRect!=null)
						display_rect = display_rect.intersection(inScrollRect);

					if (!display_rect.isEmpty())
					{
						var tx = inTX + Std.int(scroll.x*m.a);
						var ty = inTY + Std.int(scroll.y*m.d);

						obj.__Render(inMask,display_rect,tx,ty);
					}
				}
				else
				{
					obj.__Render(inMask,inScrollRect,inTX,inTY);
				}

			}
		}

		return inMask;
	}

	override function RenderContentsToCache(inBitmap:BitmapData,inTX:Float,inTY:Float)
	{
		super.RenderContentsToCache(inBitmap,inTX,inTY);
		for(obj in mObjs)
			obj.RenderContentsToCache(inBitmap,inTX,inTY);
	}

	override public function SetupRender(inParentMatrix:Matrix) : Int
	{
		var super_result = super.SetupRender(inParentMatrix);

		var child_result = 0;

		for(obj in mObjs)
		{
			if (obj.visible)
				child_result |= obj.SetupRender(mFullMatrix);
		}
		if (mLastSetupObjs.length != mObjs.length)
			child_result |= DisplayObject.NON_TRANSLATE_CHANGE;
		else if (child_result==0)
			for(i in 0...mObjs.length)
				if (mObjs[i] != mLastSetupObjs[i])
				{
				child_result |= DisplayObject.NON_TRANSLATE_CHANGE;
				break;
				}
		mLastSetupObjs = mObjs.copy();

		var result = 0;
		// TODO: case where all objects have moved together = TRANSLATE_CHANGE
		if ( child_result !=0 )
			result = DisplayObject.TRANSLATE_CHANGE | DisplayObject.NON_TRANSLATE_CHANGE;

		if ( (result & DisplayObject.NON_TRANSLATE_CHANGE) != 0 )
		{
			mCachedBitmap = null;
			mBoundsDirty = true;
		}


		if ( (result | super_result) !=0)
			mBoundsDirty = true;

		// See if we need cache, and that super call did not create one ...

		if (result!=0)
			mMaskHandle = null;

		return result | super_result;
	}

	#if js
	public function WalkChildren( func: DisplayObject -> Void )
	{
		for ( obj in mObjs )
		{
			func( obj );
		}
	}
	#end


	///////////////////////////// FLASH API ///////////////////////////////

	public function addChild(inObject:DisplayObject)
	{
		if (inObject == this) {
			throw "Adding to self";
		}
		if (inObject.mParent==this)
		{
			setChildIndex(inObject,mObjs.length-1);
			return;
		}

		#if debug
		for(i in 0...mObjs.length) {
			if(mObjs[i] == inObject) {
				throw "Internal error: child already existed at index " + i;
			}
		}
		#end

		mObjs.push(inObject);
		inObject.SetParent(this);
	}

	public function addChildAt( obj : DisplayObject, index : Int )
	{
		if(index > mObjs.length || index < 0) {
			throw "Invalid index position " + index;
		}

		if (obj.mParent == this)
		{
			setChildIndex(obj, index);
			return;
		}

		if(index == mObjs.length)
			mObjs.push(obj);
		else
			mObjs.insert(index, obj);
		obj.SetParent(this);
	}

	public function contains( obj : DisplayObject )
	{
		if ( obj == this ) return true;
		for ( i in mObjs )
		{
			if ( obj == i ) return true;
			if ( Std.is(i,DisplayObjectContainer) )
				if ( cast(i,DisplayObjectContainer).contains(obj) ) return true;
		}
		return false;
	}

	public function getChildAt( index : Int )
	{
		return mObjs[index];
	}

	public function getChildByName(inName:String):DisplayObject
	{
		for(i in 0...mObjs.length)
			if (mObjs[i].name==inName)
				return mObjs[i];
		return null;
	}

	public function getChildIndex( child : DisplayObject )
	{
		for ( i in 0...mObjs.length )
			if ( mObjs[i] == child )
				return i;
		return -1;
	}

	public function removeChild( child : DisplayObject )
	{
		for ( i in 0...mObjs.length )
		{
			if ( mObjs[i] == child )
			{
				child.SetParent( null );
				#if debug
				if (getChildIndex(child) >= 0) {
					throw "Not removed properly";
				}
				#end
				return;
			}
		}
		throw "removeChild : none found?";
	}

	public function removeChildAt(inI:Int)
	{
		mObjs[inI].SetParent(null);
	}

	public function __removeChild( child : DisplayObject )
	{
		var i = getChildIndex(child);
		if (i>=0)
		{
			mObjs.splice( i, 1 );
		}
	}

	public function setChildIndex( child : DisplayObject, index : Int )
	{
		if(index > mObjs.length) {
			throw "Invalid index position " + index;
		}

		var s : DisplayObject = null;
		var orig = getChildIndex(child);

		if (orig < 0) {
			var msg = "setChildIndex : object " + child.name + " not found.";
			if(child.parent == this) {
				var realindex = -1;
				for(i in 0...mObjs.length) {
					if(mObjs[i] == child) {
						realindex = i;
						break;
					}
				}
				if(realindex != -1)
					msg += "Internal error: Real child index was " + Std.string(realindex);
				else
					msg += "Internal error: Child was not in mObjs array!";
			}
			throw msg;
		}

		// move down ...
		if (index<orig)
		{
			var i = orig;
			while(i > index) {
				mObjs[i] = mObjs[i-1];
				i--;
			}
			mObjs[index] = child;
		}
		// move up ...
		else if (orig<index)
		{
			var i = orig;
			while(i < index) {
				mObjs[i] = mObjs[i+1];
				i++;
			}
			mObjs[index] = child;
		}

		#if debug
			for(i in 0...mObjs.length)
				if(mObjs[i] == null) {
					throw "Null element at index " + i + " length " + mObjs.length;
				}
		#end
	}

	public function swapChildren( child1 : DisplayObject, child2 : DisplayObject )
	{
		var c1 : Int = -1;
		var c2 : Int = -1;
		var swap : DisplayObject;
		for ( i in 0...mObjs.length )
		if ( mObjs[i] == child1 ) c1 = i;
		else if  ( mObjs[i] == child2 ) c2 = i;
		if ( c1 != -1 && c2 != -1 )
		{
			swap = mObjs[c1];
			mObjs[c1] = mObjs[c2];
			mObjs[c2] = swap;
			swap = null;
		}
	}

	public function swapChildrenAt( child1 : Int, child2 : Int )
	{
		var swap : DisplayObject = mObjs[child1];
		mObjs[child1] = mObjs[child2];
		mObjs[child2] = swap;
		swap = null;
	}

}

