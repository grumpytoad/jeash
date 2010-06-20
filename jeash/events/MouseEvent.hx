package jeash.events;

#if !js
import nme.Manager;
#else
import flash.Manager;
#end

class MouseEvent extends Event
{
   public var altKey : Bool;
   public var buttonDown : Bool;
   public var ctrlKey : Bool;
   public var delta : Int;
   public var localX : Float;
   public var localY : Float;
   public var relatedObject : flash.display.InteractiveObject;
   public var shiftKey : Bool;
   public var stageX : Float;
   public var stageY : Float;

   public function new(type : String, ?bubbles : Bool, ?cancelable : Bool,
            ?in_localX : Float,
            ?in_localY : Float,
            ?in_relatedObject : flash.display.InteractiveObject,
            ?in_ctrlKey : Bool,
            ?in_altKey : Bool,
            ?in_shiftKey : Bool,
            ?in_buttonDown : Bool,
            ?in_delta : Int)
   {
      super(type,bubbles,cancelable);

      shiftKey = in_shiftKey==null ? false : in_shiftKey;
      altKey = in_altKey==null ? false : in_altKey;
      ctrlKey = in_ctrlKey==null ? false : in_ctrlKey;
      bubbles = in_buttonDown==null ? false : in_buttonDown;
      relatedObject = in_relatedObject;
      delta = in_delta==null ? 0 : in_delta;
      localX = in_localX==null ? 0 : in_localX;
      localY = in_localY==null ? 0 : in_localY;
      buttonDown = in_buttonDown==null ? false : in_buttonDown;
   }

   public function updateAfterEvent()
   {
   }

   public static var CLICK : String = "click";
   public static var DOUBLE_CLICK : String = "doubleClick";
   public static var MOUSE_DOWN : String = "mouseDown";
   public static var MOUSE_MOVE : String = "mouseMove";
   public static var MOUSE_OUT : String = "mouseOut";
   public static var MOUSE_OVER : String = "mouseOver";
   public static var MOUSE_UP : String = "mouseUp";
   public static var MOUSE_WHEEL : String = "mouseWheel";
   public static var ROLL_OUT : String = "rollOut";
   public static var ROLL_OVER : String = "rollOver";
}

