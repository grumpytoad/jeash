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
