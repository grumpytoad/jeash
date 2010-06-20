package jeash.display;

class BitmapDataRenderer
{
   var mData : flash.display.BitmapData;
   public var graphics(GetGraphics,null):flash.display.Graphics;

   #if flash
   var mShape : flash.display.Shape;
   #end

   public function new(inData:flash.display.BitmapData)
   {
      mData = inData;
   #if flash
      mShape = new flash.display.Shape();
   #end
   }

   public function GetGraphics()
   {
   #if flash
      return mShape.graphics;
   #else
      return mData.graphics;
   #end
   }

   public function close()
   {
   #if flash
      mData.draw(mShape);
      mShape = null;
   #end
   }
}
