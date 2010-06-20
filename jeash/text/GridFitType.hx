package jeash.text;

#if flash
typedef GridFitType = flash.text.GridFitType
#else true

class GridFitType
{
   public function new() { }

   public static var NONE = "ADVANCED";
   public static var PIXEL = "PIXEL";
   public static var SUBPIXEL = "SUBPIXEL";
}

#end
