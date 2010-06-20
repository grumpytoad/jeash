package jeash.events;

class IOErrorEvent extends flash.events.Event
{
   public var text : String;

   public function new(type : String, ?bubbles : Bool, ?cancelable : Bool,
         ?inText : String = "")
   {
      super(type,bubbles,cancelable);

      text = inText;
   }

   public static var IO_ERROR = "IO_ERROR";

}


