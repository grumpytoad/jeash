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

import flash.net.URLRequest;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.events.Event;
import flash.events.IOErrorEvent;

/**
* @author	Hugh Sanderson
* @author	Niel Drummond
* @author	Russell Weir
* @todo init, open, progress, unload (?) events
* @todo Complete LoaderInfo initialization
**/
class Loader extends flash.display.DisplayObjectContainer
{
	public var content(default,null) : DisplayObject;
	public var contentLoaderInfo(default,null) : LoaderInfo;
	var mImage:BitmapData;
	var mShape:Shape;

	public function new()
	{
		super();
		contentLoaderInfo = LoaderInfo.create(this);
	}

	// No "loader context" in neash
	public function load(request:URLRequest)
	{
		// get the file extension for the content type
		var parts = request.url.split(".");
		var extension : String = if(parts.length == 0) "" else parts[parts.length-1].toLowerCase();

		var transparent = true;
		// set properties on the LoaderInfo object
		untyped {
			contentLoaderInfo.url = request.url;
			contentLoaderInfo.contentType = switch(extension) {
			case "swf": "application/x-shockwave-flash";
			case "jpg","jpeg": transparent = false; "image/jpeg";
			case "png": "image/gif";
			case "gif": "image/png";
			default:
				throw "Unrecognized file " + request.url;
			}
		}

		mImage = new BitmapData(0,0,transparent);

		try {
			#if !js
				mImage.LoadFromFile(request.url);
			#else
				mImage.LoadFromFile(request.url, contentLoaderInfo);
			#end
			content = new Bitmap(mImage);
			untyped contentLoaderInfo.content = this.content;
		} catch(e:Dynamic) {
			trace("Error " + e);
			contentLoaderInfo.DispatchIOErrorEvent();
			return;
		}

		if (mShape==null)
		{
			mShape = new Shape();
			addChild(mShape);
		}
		else
			mShape.graphics.clear();

		#if !js
			mShape.graphics.blit(mImage);
		#end

		contentLoaderInfo.DispatchCompleteEvent();
	}

}

