package jeash.events;

class FocusEvent extends flash.events.Event
{
   public var keyCode : Int;
   public var shiftKey : Bool;
   public var relatedObject : flash.display.InteractiveObject;

   public function new(type : String, ?bubbles : Bool, ?cancelable : Bool,
         ?inObject : flash.display.InteractiveObject,
         ?inShiftKey : Bool,
         ?inKeyCode : Int)
   {
      super(type,bubbles,cancelable);

      keyCode = inKeyCode;
      shiftKey = inShiftKey==null ? false : inShiftKey;
      target = inObject;
   }

   public static var FOCUS_IN = "FOCUS_IN";
   public static var FOCUS_OUT = "FOCUS_OUT";
   public static var KEY_FOCUS_CHANGE = "KEY_FOCUS_CHANGE";
   public static var MOUSE_FOCUS_CHANGE = "MOUSE_FOCUS_CHANGE";

}

