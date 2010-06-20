package jeash.text;

import flash.display.GraphicsLike;

interface Font
{
   public function GetName():String;
      public function GetHeight():Int;
   public function CanRenderSolid():Bool;
   public function CanRenderOutline():Bool;
   public function Render(inGfx:GraphicsLike,inChar:Int,inX:Int,inY:Int,inOutline:Bool):Int;

   public function GetAdvance(inChar:Int):Int;
   public function GetAscent() : Int;
   public function GetDescent() : Int;
   public function GetLeading() : Int;

}
