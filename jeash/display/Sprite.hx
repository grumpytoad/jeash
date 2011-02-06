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

import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;

class Sprite extends DisplayObjectContainer
{
	var mGraphics:Graphics;
	public var graphics(GetGraphics,null):Graphics;
	public var buttonMode:Bool;

	#if debug
	static var spriteIndex : Int = 0;
	#end

	public function new()
	{
		Lib.canvas;
		mGraphics = new Graphics();
		super();
		buttonMode = false;
		name = "Sprite " + DisplayObject.mNameID++;
	}

	public function startDrag(?lockCenter:Bool, ?bounds:Rectangle):Void
	{
		if (stage != null)
			stage.jeashStartDrag(this, lockCenter, bounds);
	}

	public function stopDrag():Void
	{
		if (stage != null)
			stage.jeashStopDrag(this);
	}

	override public function GetGraphics() 
	{ 
		return mGraphics; 
	}
}

