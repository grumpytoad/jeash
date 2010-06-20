package jeash.events;

import flash.events.IEventDispatcher;

class Callback
{
   var mDispatcher:IEventDispatcher;
   var mType:String;

#if flash
   var mFunc:Function;
   var mCapture:Null<Bool>;
#else true
   var mID:Int;
#end

   public function new(inDispatcher:IEventDispatcher,
       type:String, listener:Function,
       ?useCapture:Bool /*= false*/, ?priority:Int /*= 0*/)
   {
      mDispatcher = inDispatcher;
      mType = type;

      #if flash
      mFunc = listener;
      mCapture = useCapture;
      #else true
      mID =
      #end
      inDispatcher.addEventListener(type,listener,useCapture,priority);
   }

   public function Remove()
   {
      #if flash
      mDispatcher.removeEventListener(mType,mFunc,mCapture);
      #else true
      mDispatcher.RemoveByID(mType,mID);
      #end
      mDispatcher = null;
   }

}

