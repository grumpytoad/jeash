package jeash.media;

import flash.events.Event;

private typedef NmeSound = nme.Sound;

/**
* @author	Russell Weir
* @author	Niel Drummond
* @todo Implement soundTransform
**/
class SoundChannel extends flash.events.EventDispatcher {
	public var ChannelId(default,null) : Int;
	public var leftPeak(default,null) : Float;
	public var position(default,null) : Float;
	public var rightPeak(default,null) : Float;
	public var soundTransform(default,__setSoundTransform) : SoundTransform;

	private var m_started : Bool;
	private var m_sound : NmeSound;
	private var m_parentSound : Sound;
	private var m_startTime : Int;
	private var m_loops : Int;

	private function new() : Void {
		super( this );
		ChannelId = -1;
		leftPeak = 0.;
		position = 0.;
		rightPeak = 0.;

		m_started = false;
		m_startTime = 0;
		m_loops = 0;
	}

	/////////////////// Neash API /////////////////////////////
	/**
	* Internal call from Sound class to start a clip. This is
	* used since the call to Sound.play() could potentially
	* occur before the sound has loaded from a network resource
	*
	* @return Channel index that sound started playing on, -1 on error
	*/
	public function Start() : Int {
		if(m_started)
			throw "Can not restart a SoundChannel";
		m_started = true;
		ChannelId = m_sound.play( m_loops );
		if( m_startTime != 0 )
			nme.Sound.setChannelPosition(ChannelId, m_startTime);
		return ChannelId;
	}

	public static function Create(parent:Sound, nmeSoundObj:NmeSound, startTime : Float=0.0, loops : Int=0, sndTransform : SoundTransform=null) : SoundChannel
	{
		var snd = new SoundChannel();
		snd.m_parentSound = parent;
		snd.m_sound = nmeSoundObj;
		snd.m_startTime = Std.int(startTime);
		snd.m_loops = loops;
		snd.soundTransform = sndTransform;
		return snd;
	}


	/////////////////// Flash API /////////////////////////////
	public function stop() : Void {
		if(m_parentSound != null) {
			m_parentSound.OnChannelStopped(this.ChannelId);
			// this effectively destroys this channel
			// reduce GC load
			m_parentSound = null;
		}
	}


	////////////////////// Privates //////////////////////////
	private function __setSoundTransform( v : SoundTransform ) : SoundTransform
	{
		return this.soundTransform = v;
	}
}

