package jeash.display;

import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.geom.Matrix;

class Shape extends DisplayObject
{
   var mGraphics:Graphics;

   public var graphics(GetGraphics,null):Graphics;


   public function new()
   {
      super();
      mGraphics = new Graphics();
      name = "Shape " + DisplayObject.mNameID++;
   }


   override public function GetGraphics() { return mGraphics; }
}



