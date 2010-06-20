package jeash.events;

import flash.events.Event;

typedef Function = Dynamic->Void;

interface IEventDispatcher
{
   public function addEventListener(type:String, listener:Function,
       ?useCapture:Bool /*= false*/, ?priority:Int /*= 0*/,
       ?useWeakReference:Bool /*= false*/):Int;

   public function dispatchEvent(event : Event) : Bool;
   public function hasEventListener(type : String) : Bool;
   public function removeEventListener(type : String, listener : Function,
              ?useCapture : Bool) : Void;
   public function willTrigger(type : String) : Bool;

   // Neko can't compare functions - so it should use this ...
   public function RemoveByID(inType:String,inID:Int) : Void;
}



