package jeash.filters;

import flash.geom.Point;
import flash.display.BitmapData;

class FilterSet
{
   var mHandle:Void;
   var mOffset:Point;

   public function new(inFilters:Array<Dynamic>)
   {
      mOffset = new Point();
   }

   public function FilterImage(inImage:BitmapData) : BitmapData
   {
					throw "Not implemented. FilterImage.";
					return null;
   }

   public function GetOffsetX() : Int { return Std.int(mOffset.x); }
   public function GetOffsetY() : Int { return Std.int(mOffset.y); }

}
