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

