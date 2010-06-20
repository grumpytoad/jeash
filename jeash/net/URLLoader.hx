package jeash.net;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;

/**
* @author	Hugh Sanderson
* @author	Niel Drummond
* @author	Russell Weir
* @todo open and progress events
* @todo Complete Variables type
**/
class URLLoader extends flash.events.EventDispatcher
{
	public var bytesLoaded:Int;
	public var bytesTotal:Int;
	public var data:Dynamic;
	public var dataFormat:URLLoaderDataFormat;

	public function new(?request:URLRequest)
	{
		super();
		bytesLoaded = 0;
		bytesTotal = 0;
		dataFormat = URLLoaderDataFormat.TEXT;
		if(request != null)
			load(request);
	}

	public function close() { }

	public function load(request:URLRequest)
	{
		#if (neko || cpp)
			var ereg = ~/^(http:\/\/)/;

			if(!ereg.match(request.url)) { // local file
				#if neko
				if(!neko.FileSystem.exists(request.url)) {
				#else
				if(!cpp.FileSystem.exists(request.url)) {
				#end
					onError("File not found");
					return;
				}
				#if neko
				switch(neko.FileSystem.kind(request.url)) {
				#else
				switch(cpp.FileSystem.kind(request.url)) {
				#end
				case kdir:
					onError("File " + request.url + " is a directory");
				default:
				}

				try {
					switch(dataFormat) {
					case BINARY:
						this.data = ByteArray.readFile(request.url);
					case TEXT, VARIABLES:
						#if neko
						this.data = neko.io.File.getContent(request.url);
						#else
						this.data = cpp.io.File.getContent(request.url);
						#end
					}
				} catch(e:Dynamic) {
					onError(e);
					return;
				}
				DispatchCompleteEvent();
				return;
			}
		#end
		var h = new haxe.Http( request.url );
		h.onData = onData;
		h.onError = onError;
		h.request( false );

	}

	function onData (data:String) {
		switch(dataFormat) {
		case BINARY:
			this.data = new ByteArray( haxe.io.Bytes.ofString( data ) );
		case TEXT:
			this.data = data;
		case VARIABLES:
			throw "Not complete";
		}

		DispatchCompleteEvent();
	}

	function onError (msg) {
		trace(msg);
		DispatchIOErrorEvent();
	}

}

