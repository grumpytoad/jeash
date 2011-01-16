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
import flash.geom.Point;


/**
* @author	Hugh Sanderson
* @author	Lee Sylvester
* @author	Niel Drummond
* @author	Russell Weir
*/
class DisplayObjectContainer extends InteractiveObject
{
	var jeashChildren : Array<DisplayObject>;
	var mLastSetupObjs : Array<DisplayObject>;
	public var numChildren(GetNumChildren,null):Int;
	public var mouseChildren:Bool;
	public var tabChildren:Bool;

	public function new()
	{
		jeashChildren = new Array<DisplayObject>();
		mLastSetupObjs = new Array<DisplayObject>();
		mouseChildren = true;
		tabChildren = true;
		super();
		name = "DisplayObjectContainer " +  flash.display.DisplayObject.mNameID++;
	}

	override public function AsContainer() { return this; }

	public function Broadcast(inEvent:flash.events.Event)
	{
		dispatchEvent(inEvent);
		for(obj in jeashChildren)
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
			for(obj in jeashChildren)
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
		for(child in jeashChildren)
			child.DoAdded(inObj);
	}

	override function DoRemoved(inObj:DisplayObject)
	{
		super.DoAdded(inObj);
		for(child in jeashChildren)
			child.DoRemoved(inObj);
	}

	override public function GetBackgroundRect()
	{
		var r = super.GetBackgroundRect();
		if (r!=null) r = r.clone();

		for(obj in jeashChildren)
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
		for(obj in jeashChildren)
			obj.GetFocusObjects(outObjs);
	}

   /*
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
   */


	public override function GetNumChildren() {
		return jeashChildren.length;
	}

	override public function __Render(?inMask:HTMLCanvasElement, inTX:Int = 0, inTY:Int = 0)
	{

		if (!visible || mMaskingObj!=null) return;

		super.__Render(inMask, inTX, inTY);
		for(obj in jeashChildren)
		{
			if (obj.visible && obj.mMaskingObj==null)
			{
				obj.__Render(inMask, inTX, inTY);
			}
		}

	}

	override function RenderContentsToCache(inCanvas:HTMLCanvasElement, inTX:Int, inTY:Int)
	{
		super.RenderContentsToCache(inCanvas,inTX,inTY);
		for(obj in jeashChildren)
			obj.RenderContentsToCache(inCanvas,inTX,inTY);
	}

	override public function SetupRender(inParentMatrix:Matrix) : Int
	{
		var super_result = super.SetupRender(inParentMatrix);

		var child_result = 0;

		for(obj in jeashChildren)
		{
			if (obj.visible)
				child_result |= obj.SetupRender(mFullMatrix);
		}
		if (mLastSetupObjs.length != jeashChildren.length)
			child_result |= DisplayObject.NON_TRANSLATE_CHANGE;
		else if (child_result==0)
			for(i in 0...jeashChildren.length)
				if (jeashChildren[i] != mLastSetupObjs[i])
				{
				child_result |= DisplayObject.NON_TRANSLATE_CHANGE;
				break;
				}
		mLastSetupObjs = jeashChildren.copy();

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
		for ( obj in jeashChildren )
		{
			func( obj );
		}
	}
	#end


	///////////////////////////// FLASH API ///////////////////////////////

	public function addChild(inObject:DisplayObject):DisplayObject
	{
		if (inObject == this) {
			throw "Adding to self";
		}
		if (inObject.jeashParent==this)
		{
			setChildIndex(inObject,jeashChildren.length-1);
			return inObject;
		}

		#if debug
		for(i in 0...jeashChildren.length) {
			if(jeashChildren[i] == inObject) {
				throw "Internal error: child already existed at index " + i;
			}
		}
		#end

		jeashChildren.push(inObject);
		inObject.jeashSetParent(this);

		var gfx = inObject.GetGraphics();
		if (gfx != null)
		{
			Lib.jeashAppendSurface(gfx.mSurface, 0, 0);
		}

		return inObject;
	}

	public function addChildAt( obj : DisplayObject, index : Int )
	{
		if(index > jeashChildren.length || index < 0) {
			throw "Invalid index position " + index;
		}

		if (obj.jeashParent == this)
		{
			setChildIndex(obj, index);
			return;
		}

		if(index == jeashChildren.length)
			jeashChildren.push(obj);
		else
			jeashChildren.insert(index, obj);
		obj.jeashSetParent(this);
	}

	public function contains( obj : DisplayObject )
	{
		if ( obj == this ) return true;
		for ( i in jeashChildren )
		{
			if ( obj == i ) return true;
			if ( Std.is(i,DisplayObjectContainer) )
				if ( cast(i,DisplayObjectContainer).contains(obj) ) return true;
		}
		return false;
	}

	public function getChildAt( index : Int )
	{
		return jeashChildren[index];
	}

	public function getChildByName(inName:String):DisplayObject
	{
		for(i in 0...jeashChildren.length)
			if (jeashChildren[i].name==inName)
				return jeashChildren[i];
		return null;
	}

	public function getChildIndex( child : DisplayObject )
	{
		for ( i in 0...jeashChildren.length )
			if ( jeashChildren[i] == child )
				return i;
		return -1;
	}

	public function removeChild( child : DisplayObject )
	{
		for ( i in 0...jeashChildren.length )
		{
			if ( jeashChildren[i] == child )
			{
				child.jeashSetParent( null );
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
		jeashChildren[inI].jeashSetParent(null);
	}

	public function __removeChild( child : DisplayObject )
	{
		var i = getChildIndex(child);
		if (i>=0)
		{
			jeashChildren.splice( i, 1 );
		}
	}

	public function setChildIndex( child : DisplayObject, index : Int )
	{
		if(index > jeashChildren.length) {
			throw "Invalid index position " + index;
		}

		var s : DisplayObject = null;
		var orig = getChildIndex(child);

		if (orig < 0) {
			var msg = "setChildIndex : object " + child.name + " not found.";
			if(child.parent == this) {
				var realindex = -1;
				for(i in 0...jeashChildren.length) {
					if(jeashChildren[i] == child) {
						realindex = i;
						break;
					}
				}
				if(realindex != -1)
					msg += "Internal error: Real child index was " + Std.string(realindex);
				else
					msg += "Internal error: Child was not in jeashChildren array!";
			}
			throw msg;
		}

		// move down ...
		if (index<orig)
		{
			var i = orig;
			while(i > index) {
				jeashChildren[i] = jeashChildren[i-1];
				i--;
			}
			jeashChildren[index] = child;
		}
		// move up ...
		else if (orig<index)
		{
			var i = orig;
			while(i < index) {
				jeashChildren[i] = jeashChildren[i+1];
				i++;
			}
			jeashChildren[index] = child;
		}

		#if debug
			for(i in 0...jeashChildren.length)
				if(jeashChildren[i] == null) {
					throw "Null element at index " + i + " length " + jeashChildren.length;
				}
		#end
	}

	public function swapChildren( child1 : DisplayObject, child2 : DisplayObject )
	{
		var c1 : Int = -1;
		var c2 : Int = -1;
		var swap : DisplayObject;
		for ( i in 0...jeashChildren.length )
		if ( jeashChildren[i] == child1 ) c1 = i;
		else if  ( jeashChildren[i] == child2 ) c2 = i;
		if ( c1 != -1 && c2 != -1 )
		{
			swap = jeashChildren[c1];
			jeashChildren[c1] = jeashChildren[c2];
			jeashChildren[c2] = swap;
			swap = null;
		}
	}

	public function swapChildrenAt( child1 : Int, child2 : Int )
	{
		var swap : DisplayObject = jeashChildren[child1];
		jeashChildren[child1] = jeashChildren[child2];
		jeashChildren[child2] = swap;
		swap = null;
	}

	override public function jeashGetObjectUnderPoint(point:Point)
	{
		var l = jeashChildren.length-1;
		for(i in 0...jeashChildren.length)
		{
			var result = jeashChildren[l-i].jeashGetObjectUnderPoint(point);
			if (result != null)
				return result;
		}

		return super.jeashGetObjectUnderPoint(point);
	}

	// @r551
	public function getObjectsUnderPoint(point:Point)
	{
		var result = new Array<DisplayObject>();
		jeashGetObjectsUnderPoint(point, result);
		return result;
	}

	function jeashGetObjectsUnderPoint(point:Point, stack:Array<DisplayObject>)
	{
		var l = jeashChildren.length-1;
		for(i in 0...jeashChildren.length)
		{
			var result = jeashChildren[l-i].jeashGetObjectUnderPoint(point);
			if (result != null)
				stack.push(result);
		}

		//return super.jeashGetObjectsUnderPoint(point);
	}
}

