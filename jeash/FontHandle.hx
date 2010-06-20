package jeash;
import Type;


typedef FontMetrics =
{
   var height:Int;
   var ascent:Int;
   var descent:Int;
   var max_x_advance:Int;
}

typedef GlyphMetrics =
{
   var min_x: Int;
   var max_x: Int;
   var width: Int;
   var height : Int;
   var x_advance: Int;
}


class FontHandle
{
   public var handle(get_handle,null):Dynamic;
   var mHandle:Dynamic;

   public function new(inName:String, inSize:Int)
   {
					throw "Not implemented. new Fonthandle.";
   }

   public function GetGlyphMetrics(inChar:Dynamic) : GlyphMetrics
   {
      var c : Int = Type.typeof(inChar) == ValueType.TInt ? inChar :
                            inChar.charCodeAt(0) ;
					throw "Not implemented. GetGlyphMetrics.";
					return null;
   }

   public function GetFontMetrics() : FontMetrics
   {
					throw "Not implemented. GetFontMetrics.";
					return null;
   }

   public function get_handle() : Dynamic { return mHandle; }

}
