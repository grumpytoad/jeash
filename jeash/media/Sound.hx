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

package jeash.media;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.net.URLLoader;


private typedef NmeSound = nme.Sound;

/**
* @author	Russell Weir
* @todo Possibly implement streaming
* @todo Review events match flash
**/
class Sound extends flash.events.EventDispatcher {
	public var bytesLoaded(default,null) : Int;
	public var bytesTotal(default,null) : Int;
	public var id3(default,null) : ID3Info;
	public var isBuffering(default,null) : Bool;
	public var length(default,null) : Float;
	public var url(default,null) : String;


	private static var s_channels : IntHash<SoundChannel>;
	private static var s_channelsToStart : List<SoundChannel>;

	private var m_sound : NmeSound;
	private var m_loaded : Bool;
	private var m_loader : URLLoader;

	public function new(?stream : URLRequest, ?context : SoundLoaderContext) : Void {
		super( this );
		bytesLoaded = 0;
		bytesTotal = 0;
		id3 = null;
		isBuffering = false;
		length = 0;
		url = null;
		m_sound = new NmeSound();
		m_loaded = false;
		if(stream != null)
			load(stream, context);
	}

	/////////////////// Neash API /////////////////////////////
	/**
	* Internal notification from SoundChannel that stop()
	* has been called
	**/
	public function OnChannelStopped(v:Int) : Void
	{
		if(v >= 0)
			CleanupSoundChannel(v);
	}

	/////////////////// Flash API /////////////////////////////

	public function close() : Void	{	}

	/**
	* @todo JS target just dispatches COMPLETE.
	**/
	public function load(stream : URLRequest, ?context : SoundLoaderContext) : Void
	{
		if(m_loader != null)
			throw "Already loading";
		#if js
		DispatchCompleteEvent();
		#else
		m_loader = new URLLoader();
		m_loader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
		m_loader.addEventListener(Event.COMPLETE, __onSoundLoaded);
		m_loader.addEventListener(IOErrorEvent.IO_ERROR, __onSoundLoadError);
		m_loader.load( stream );
		#end
	}

	public function play(startTime : Float=0.0, loops : Int=0, sndTransform : SoundTransform=null) : SoundChannel {
		var sc = SoundChannel.Create(this, m_sound, startTime, loops, sndTransform);

		if(m_loaded)
		{
			StartSoundChannel(sc);
		}
		else
		{
			s_channelsToStart.add(sc);
		}

		return sc;
	}


	////////////////////// Privates //////////////////////////

	private static function StartSoundChannel(sc : SoundChannel) : Void
	{
		var idx = sc.Start();
		if( idx >= 0 )
		{
			s_channels.set(idx, sc);
		}
	}

	private static function CleanupSoundChannel(v : Int) : SoundChannel
	{
		var chan = s_channels.get(v);
		if(chan != null)
			s_channelsToStart.remove(chan);
		s_channels.remove(v);
		return chan;
	}

	private function __onSoundLoaded(evt : Event)
	{
		m_loader.removeEventListener(Event.COMPLETE, __onSoundLoaded);
		m_loader.removeEventListener(IOErrorEvent.IO_ERROR, __onSoundLoadError);
		m_loaded = true;

		if(!Std.is(m_loader.data,nme.utils.ByteArray))
			throw "Improper data in loader";
		// mutex acquired here and in StartSoundChannel
		m_sound.loadFromByteArray(m_loader.data);

		// start up any channels which were queued to play
		for(sc in s_channelsToStart)
			StartSoundChannel( sc );

		s_channelsToStart = new List();
		DispatchCompleteEvent();
	}

	private function __onSoundLoadError(evt : IOErrorEvent)
	{
		m_loader.removeEventListener(Event.COMPLETE, __onSoundLoaded);
		m_loader.removeEventListener(IOErrorEvent.IO_ERROR, __onSoundLoadError);
		DispatchIOErrorEvent();
	}

	private static function __onSoundChannelFinished( channel : Int ) : Void
	{
		var sc = CleanupSoundChannel( channel );
		if(sc != null) {
			var evt = new Event(Event.SOUND_COMPLETE);
			evt.target = sc;
			sc.dispatchEvent(evt);
		}
	}

	private static function __init__()
	{
		nme.Sound.onChannelFinished = __onSoundChannelFinished;
		nme.Sound.maxChannels = 32;
		s_channels = new IntHash();
		s_channelsToStart = new List();
	}

}
