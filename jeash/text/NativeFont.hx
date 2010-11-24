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

package jeash.text;

import flash.geom.Matrix;
import flash.display.GraphicsLike;


#if (neko||cpp)

import nme.FontHandle;

typedef GlyphMetricArray = Array<GlyphMetrics>;

class NativeFont implements flash.text.Font
{
   var mName : String;
   var mFont : FontHandle;
   var mHeight : Int;
   var mToEm:Float;
   var mFontMetrics:FontMetrics;
   var mMetrics : GlyphMetricArray;

   public function new(inFace:String,inHeight:Int)
   {
      mName = inFace;
      mFont = new FontHandle(inFace,inHeight);
      mHeight = inHeight;
      if (mFont!=null)
      {
         mFontMetrics = mFont.GetFontMetrics();
         mMetrics = new GlyphMetricArray();
      }
   }

   public function toString() : String
   {
       return "NativeFont:" + mName + "/" + mHeight;
   }


   public function GetName() : String { return mName; }
   public function Ok() : Bool { return mFont!=null; }

   public function CanRenderSolid():Bool { return true; }
   public function CanRenderOutline():Bool { return false; }
   public function GetHeight():Int { return mHeight; }
   public function Render(inGraphics:GraphicsLike,inChar:Int,inX:Int,inY:Int,inFreeType:Bool) : Int
   {
      //trace("   char " + String.fromCharCode(inChar) );
      inGraphics.RenderGlyph(mFont,inChar,inX,inY,inFreeType);
      return GetAdvance(inChar);
   }


   public function GetAdvance(inGlyph:Int) : Int
   {
      var m = mMetrics[inGlyph];
      if (m==null)
         mMetrics[inGlyph] = m = mFont.GetGlyphMetrics(inGlyph);
      if (m==null)
         return 0;
      return m.x_advance;
   }

   public function GetAscent() : Int { return mFontMetrics.ascent; }
   public function GetDescent() : Int { return mFontMetrics.descent; }
   public function GetLeading() : Int { return 0; }
}

#else


class NativeFont implements flash.text.Font
{
   var mName : String;
   var mHeight : Int;

   public function new(inFace:String,inHeight:Int)
      { mName = inFace; mHeight = inHeight; }

   // GlyphRenderer Interface
   public function GetName() : String { return mName; }
   public function Ok() : Bool { return false; }

   public function CanRenderSolid():Bool { return true; }
   public function CanRenderOutline():Bool { return false; }
   public function Render(inGfx:GraphicsLike,inChar:Int,inX:Int,inY:Int,inOutline:Bool):Int
   {
      return 0;
   }

   public function GetHeight():Int { return mHeight; }
   public function GetAdvance(inGlyph:Int) : Int { return mHeight; }
   public function GetAscent() : Int { return Std.int(mHeight*0.8); }
   public function GetDescent() : Int { return Std.int(mHeight*0.1); }
   public function GetLeading() : Int { return 0; }
}


#end
