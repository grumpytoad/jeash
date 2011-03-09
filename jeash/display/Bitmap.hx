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

import flash.display.DisplayObject;
import flash.display.PixelSnapping;

class Bitmap extends jeash.display.DisplayObject {
	public var bitmapData(default,jeashSetBitmapData) : BitmapData;
	public var pixelSnapping : PixelSnapping;
	public var smoothing : Bool;

	var jeashGraphics:Graphics;

	public function new(?inBitmapData : BitmapData, ?inPixelSnapping : PixelSnapping, ?inSmoothing : Bool) : Void {
		super();
		pixelSnapping = inPixelSnapping;
		smoothing = inSmoothing;
		jeashSetBitmapData(inBitmapData);
	}

	public function jeashSetBitmapData(inBitmapData:BitmapData) : BitmapData
	{
		bitmapData = inBitmapData;
		jeashGraphics = inBitmapData.graphics;
		return inBitmapData;
	}


	override function jeashGetGraphics() { return jeashGraphics; }

}

