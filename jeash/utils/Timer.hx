package jeash.utils;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;

#if js
private typedef PTimer = haxe.Timer;
#else
private typedef PTimer = flash.Timer;
#end

/**
* @author Niel Drummond
* @author Russell Weir
**/
class Timer extends EventDispatcher {
	public var currentCount(default,null) : Int;
	public var delay(default,__setDelay) : Float;
	public var repeatCount(default,__setRepeatCount) : Int;
	public var running(default,null) : Bool;

	var proxy : PTimer;

	public function new(delay : Float, repeatCount : Int=0) : Void {
		super();
		this.running = false;
		this.delay = delay;
		this.repeatCount = repeatCount;
		this.currentCount = 0;
	}

	public function reset() : Void {
		stop();
		currentCount = 0;
	}

	public function start() : Void {
		if(running)
			return;
		running = true;
		proxy = new PTimer(Std.int(delay));
		proxy.run = __onInterval;
	}

	public function stop() : Void {
		proxy.stop();
		proxy = null;
		running = false;
	}

	private function __onInterval() : Void
	{
		var evtCom : TimerEvent = null;

		if( repeatCount != 0 && ++currentCount >= repeatCount ) {
			proxy.stop();
			stop();
			evtCom = new TimerEvent(TimerEvent.TIMER_COMPLETE);
			evtCom.target = this;
		}

		var evt = new TimerEvent(TimerEvent.TIMER);
		evt.target = this;
		dispatchEvent(evt);
		// dispatch complete if necessary
		if(evtCom != null)
			dispatchEvent(evtCom);
	}

	private function __setDelay(v:Float) : Float
	{
		if(v != delay) {
			var wasRunning = running;
			if(running)
				stop();
			this.delay = v;
			if(wasRunning)
				start();
		}
		return v;
	}

	private function __setRepeatCount(v : Int ) : Int
	{
		if(running && v != 0 && v <= currentCount)
			stop();
		repeatCount = v;
		return v;
	}
}
