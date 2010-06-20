package jeash.events;

import flash.events.Event;

class TimerEvent extends Event {
	public function new(type : String, ?bubbles : Bool, ?cancelable : Bool) : Void {
      super(type,bubbles,cancelable);
	}

	public function updateAfterEvent() : Void {
	}

	public static inline var TIMER : String = "timer";
	public static inline var TIMER_COMPLETE : String = "timerComplete";
}
