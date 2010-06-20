package jeash.display;

import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;

#if flash
typedef ColorInt = UInt;
#else
typedef ColorInt = Int;
#end

typedef GraphicsLike = 
{
   public function lineTo(x:Float,y:Float) : Void;
   public function moveTo(x:Float,y:Float) : Void;
   public function endFill() : Void;
   public function beginFill(inColour:ColorInt,?inAlpha:Float) : Void;
   public function lineStyle(?thickness:Null<Float>,
                             ?color:Null<ColorInt> /* = 0 */,
                             ?alpha:Null<Float> /* = 1.0 */,
                             ?pixelHinting:Null<Bool> /* = false */,
                             ?scaleMode:Null<LineScaleMode> /* = "normal" */,
                             ?caps:Null<CapsStyle>,
                             ?joints:Null<JointStyle>,
                             ?miterLimit:Null<Float> /*= 3*/) : Void;
   public function lineGradientStyle(type : GradientType,
                 colors : Array<Dynamic>,
                 alphas : Array<Dynamic>,
                 ratios : Array<Dynamic>,
                 ?matrix : Matrix,
                 ?spreadMethod : SpreadMethod,
                 ?interpolationMethod : InterpolationMethod,
                 ?focalPointRatio : Null<Float>) : Void;

   public function beginGradientFill(type : flash.display.GradientType,
                 colors : Array<Dynamic>,
                 alphas : Array<Dynamic>,
                 ratios : Array<Dynamic>,
                 ?matrix : Matrix,
                 ?spreadMethod : Null<SpreadMethod>,
                 ?interpolationMethod : Null<InterpolationMethod>,
                 ?focalPointRatio : Null<Float>) : Void;
   public function beginBitmapFill(bitmap:BitmapData, ?matrix:Matrix,
                  ?in_repeat:Null<Bool>, ?in_smooth:Null<Bool>) : Void;

   public function curveTo(inX:Float,inY:Float,inX1:Float,inY1:Float):Void;

#if (neko||cpp)
   public function RenderGlyph(inFont:nme.FontHandle,inGlyph:Int,inX:Float, inY:Float,
                               ?inUseFreeType:Bool):Void;
#elseif js
   public function RenderGlyph(inFont:flash.FontHandle,inGlyph:Int,inX:Float, inY:Float,
                               ?inUseFreeType:Bool):Void;
#end

}


