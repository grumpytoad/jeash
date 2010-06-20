package jeash.display;

import flash.geom.Matrix;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

class DebugGfx
{
#if neko
  static var print = neko.Lib.println;
#else true
  static var print = DoTrace;
#end

   public function new() { }

   static function DoTrace(inString:String)
   {
      trace(inString);
   }

   public function lineTo(x:Float,y:Float) : Void
   {
      print("gfx.lineTo(" + x + "," + y + ");");
   }
   public function moveTo(x:Float,y:Float) : Void
   {
      print("gfx.moveTo(" + x + "," + y + ");");
   }
   public function endFill() : Void
   {
      print("gfx.endFill();");
   }
   public function beginFill(inColour:Int,?inAlpha:Null<Float>) : Void
   {
      print("gfx.beginFill(" + StringTools.hex(inColour,6) +"," + inAlpha + ");");
   }
   public function lineStyle(?thickness:Null<Float>,
                             ?color:Null<Int> /* = 0 */,
                             ?alpha:Null<Float> /* = 1.0 */,
                             ?pixelHinting:Null<Bool> /* = false */,
                             ?scaleMode:LineScaleMode /* = "normal" */,
                             ?caps:CapsStyle,
                             ?joints:JointStyle,
                             ?miterLimit:Null<Float> /*= 3*/) : Void
   {
      print("gfx.lineStyle " + thickness + ", #" + color);
   }

   public function lineGradientStyle(type : GradientType,
                 colors : Array<Dynamic>,
                 alphas : Array<Dynamic>,
                 ratios : Array<Dynamic>,
                 ?matrix : Matrix,
                 ?spreadMethod : SpreadMethod,
                 ?interpolationMethod : InterpolationMethod,
                 ?focalPointRatio : Null<Float>) : Void
   {
      print("lineGradientStyle(" + type + "," + 
        colors + "," + alphas + "," + ratios + "," +
        matrix + "," + spreadMethod + "," + interpolationMethod + "," +
        focalPointRatio );
   }



   public function beginGradientFill(type : flash.display.GradientType,
                 colors : Array<Dynamic>,
                 alphas : Array<Dynamic>,
                 ratios : Array<Dynamic>,
                 ?matrix : Matrix,
                 ?spreadMethod : Null<SpreadMethod>,
                 ?interpolationMethod : Null<InterpolationMethod>,
                 ?focalPointRatio : Null<Float>) : Void
   {
      print("beginGradientFill(" + type + "," + 
        colors + "," + alphas + "," + ratios + "," +
        matrix + "," + spreadMethod + "," + interpolationMethod + "," +
        focalPointRatio );


   }

   public function beginBitmapFill(bitmap:BitmapData, ?matrix:Matrix,
                  ?in_repeat:Null<Bool>, ?in_smooth:Null<Bool>) : Void
   {
      print("beginBitmapFill(" + bitmap + "," + matrix + "," + in_repeat +
                   "," + in_smooth + ")");
   }



   public function curveTo(inX:Float,inY:Float,inX1:Float,inY1:Float):Void
   {
      print("gfx.curveTo( " + inX + "," + inY + "," + inX1 + "," + inY1 + ")");
   }

#if neko
   public function RenderGlyph(inFont:nme.FontHandle,inChar:Int,
            inX:Float,inY:Float,?inUseFreeType:Bool):Void
   {
      print("gfx.RenderGlyph( " + inChar + ")");
   }
#elseif js
   public function RenderGlyph(inFont:flash.FontHandle,inChar:Int,
            inX:Float,inY:Float,?inUseFreeType:Bool):Void
   {
      print("gfx.RenderGlyph( " + inChar + ")");
   }
#end

}

