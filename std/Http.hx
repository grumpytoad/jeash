package std;

import haxe.Http;

import hsl.haxe.Signaler;
import hsl.haxe.direct.DirectSignaler;
#if flash
import flash.events.EventDispatcher;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import hsl.avm2.translation.AVM2TranslatingSignaler;
import hsl.avm2.translation.DatalessTranslator;
import hsl.js.translation.error.ErrorMessage;
import hsl.avm2.translation.error.ErrorMessageTranslator;
import hsl.avm2.translation.progress.LoadProgress;
import hsl.avm2.translation.progress.LoadProgressTranslator;
#elseif js
import js.Dom;
import js.Lib;
import js.XMLHttpRequest;
import hsl.js.translation.JSTranslatingSignaler;
import hsl.js.translation.DatalessTranslator;
import hsl.js.translation.error.ErrorMessage;
import hsl.js.translation.error.ErrorMessageTranslator;
import hsl.js.translation.progress.LoadProgress;
import hsl.js.translation.progress.LoadProgressTranslator;
#end

#if !(js || flash10)
#error
#end

enum HttpType
{
	IMAGE;
	VIDEO;
	AUDIO;
	STREAM( format:DataFormat );
}

enum DataFormat
{
	BINARY;
	TEXT;
}

class Http extends haxe.Http
{

	public var errorSignaler(default,null):Signaler<String>;
	public var completeSignaler(default,null):Signaler<Void>;
	public var progressSignaler(default,null):Signaler<LoadProgress>;

	public function new( url:String )
	{
		super(url);
	}

	function registerEvents( subject #if flash :EventDispatcher #end )
	{
#if js
		if ( Std.is( subject, XMLHttpRequest ) )
		{
			progressSignaler = new JSTranslatingSignaler<LoadProgress>(subject, subject, PROGRESS, new LoadProgressTranslator());
		}
		errorSignaler = new JSTranslatingSignaler<String>(subject, subject, ERROR, new ErrorMessageTranslator());
		completeSignaler = new JSTranslatingSignaler<Void>(subject, subject, LOAD, new DatalessTranslator<Void>());
#elseif flash
		progressSignaler = new AVM2TranslatingSignaler<LoadProgress>(subject, subject, "progress", new LoadProgressTranslator());
		errorSignaler = new AVM2TranslatingSignaler<String>(subject, subject, "ioError", new ErrorMessageTranslator());
		completeSignaler = new AVM2TranslatingSignaler<Void>(subject, subject, "complete", new DatalessTranslator<Void>());
#end
	}

	// Always GET, always async, uses HSL events
	public function requestUrl( type:HttpType ) : Void
	{
		var self = this;
#if js
		trace(type);
		switch (type) 
		{
			case STREAM( dataFormat ):
				var xmlHttpRequest = new XMLHttpRequest();

				switch (dataFormat) {
					case BINARY: untyped xmlHttpRequest.overrideMimeType('text/plain; charset=x-user-defined');
					default:
				}
				
				registerEvents(xmlHttpRequest);

				var uri = null;
				for( p in params.keys() )
					uri = StringTools.urlDecode(p)+"="+StringTools.urlEncode(params.get(p));

				try {
					if( uri != null ) {
						var question = url.split("?").length <= 1;
						xmlHttpRequest.open("GET",url+(if( question ) "?" else
									"&")+uri,true);
						uri = null;
					} else
						xmlHttpRequest.open("GET",url,true);
				} catch( e : Dynamic ) {
					errorSignaler.dispatch(new ErrorMessage(xmlHttpRequest.status,e.toString()));
					return;
				}

				xmlHttpRequest.send(uri);
				getData = function () { return xmlHttpRequest.responseText; };
			case IMAGE:
				var image : Image = untyped Lib.document.createElement("img");
				registerEvents(image);

				image.src = url;
				#if debug
				image.style.display = "none";
				Lib.document.body.appendChild(image);
				#end

				getData = function () { return image; };
				
			case AUDIO:
				var audio : {src:String, style:Style} = untyped Lib.document.createElement("audio");
				registerEvents(audio);

				audio.src = url;
				#if debug
				Lib.document.body.appendChild(untyped audio);
				#end

				getData = function () { return audio; }
				
			case VIDEO:
				var video : {src:String, style:Style} = untyped Lib.document.createElement("video");
				registerEvents(video);

				video.src = url;
				#if debug
				video.style.display = "none";
				Lib.document.body.appendChild(untyped video);
				#end
				
				getData = function () { return video; }
		}

#elseif flash9
		// request vars from haxe.Http
		var getRequestVars = function(url:String)
		{
				var param = false;
				var vars = new flash.net.URLVariables();
				for( k in self.params.keys() ){
					param = true;
					Reflect.setField(vars,k,self.params.get(k));
				}
				var small_url = url;
				if( param ){
					var k = url.split("?");
					if( k.length > 1 ) {
						small_url = k.shift();
						vars.decode(k.join("?"));
					}
				}
				var bug = small_url.split("xxx");

				var request = new URLRequest( small_url );

				request.data = vars;
				request.method = "GET";
				return request;
		}
		switch (type)
		{
			case STREAM( dataFormat ):
				var loader = new flash.net.URLLoader();
				loader.dataFormat = switch (dataFormat) {
					case TEXT: URLLoaderDataFormat.TEXT;
					case BINARY: URLLoaderDataFormat.BINARY;
				}

				registerEvents(loader);

				try {
					loader.load( getRequestVars(url) );
				}catch( e : Dynamic ){
					errorSignaler.dispatch(new ErrorMessage(502,"Exception: "+Std.string(e)));
				}
				getData = function () { return loader.data; }
			default:
				var display = new flash.display.Loader();

				registerEvents(display.contentLoaderInfo);

				try {
					display.load( getRequestVars(url) );
				}catch( e : Dynamic ){
					errorSignaler.dispatch("Exception: "+Std.string(e));
				}
				getData = function () { return display.content; }
		}
#end
	}
	dynamic function getData () : Dynamic { }
}
