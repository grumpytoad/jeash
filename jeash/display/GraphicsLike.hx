/**
 * Copyright (c) 2010, Jeash contributors.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

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


