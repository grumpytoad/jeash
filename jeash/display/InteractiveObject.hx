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

import jeash.geom.Point;

class InteractiveObject extends DisplayObject {
	public var doubleClickEnabled:Bool;
	public var focusRect:Dynamic;
	public var mouseEnabled:Bool;
	public var tabEnabled:Bool;
	public var tabIndex(jeashGetTabIndex,jeashSetTabIndex):Int;
	var jeashDoubleClickEnabled:Bool;
	var jeashTabIndex:Int;

	public function new() {
		super();
		tabEnabled = false;
		mouseEnabled = true;
		doubleClickEnabled = true;
		tabIndex = 0;
		name = "InteractiveObject";
	}

	override public function toString() { return name; }

	public function OnKey(inKey:jeash.events.KeyboardEvent):Void { }

	override public function jeashAsInteractiveObject() return this

	public function jeashGetTabIndex() { return jeashTabIndex; }
	public function jeashSetTabIndex(inIndex:Int) {
		jeashTabIndex = inIndex;
		return inIndex;
	}

	override public function jeashGetObjectUnderPoint(point:Point):DisplayObject 
		 if (!mouseEnabled) return null;
		 else return super.jeashGetObjectUnderPoint(point)

}
