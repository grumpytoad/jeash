package jeash.filters;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

class BlurFilter extends flash.filters.BitmapFilter
{
   public function new(?inBlurX : Float, ?inBlurY : Float, ?inQuality : Int)
   {
      super("BlurFilter");
      blurX = inBlurX==null ? 4.0 : inBlurX;
      blurY = inBlurY==null ? 4.0 : inBlurY;
      quality = inQuality==null ? 1 : inQuality;
   }
   override public function clone() : flash.filters.BitmapFilter
   {
      return new BlurFilter(blurX,blurY,quality);
   }

   public function applyFilter(inBitmapData : BitmapData, inRect:Rectangle, inPoint:Point, inBitmapFilter:BitmapFilter):Void { }

   public var blurX : Float;
   public var blurY : Float;
   public var quality : Int;
}
