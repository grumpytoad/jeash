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
		var h = new std.Http( request.url );
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

