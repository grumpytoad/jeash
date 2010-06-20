package jeash.text;

import flash.geom.Matrix;
import flash.display.GraphicsLike;


#if neko

import nme.FontHandle;

typedef GlyphMetricArray = Array<GlyphMetrics>;

class NativeGlyphRenderer implements flash.text.GlyphRenderer
{
   var mName : String;
   var mFont : FontHandle;
   var mFontMetrics:FontMetrics;
   var mMetrics : GlyphMetricArray;

   public function new(inFace:String)
   {
      mName = inFace;
      mFont = new FontHandle(inFace,1024);
      if (mFont!=null)
      {
         mFontMetrics = mFont.GetFontMetrics();
         mMetrics = new GlyphMetricArray();
      }
   }


   // GlyphRenderer Interface
   public function GetName() : String { return mName; }
   public function Ok() : Bool { return mFont!=null; }
   public function RenderGlyph(inGraphics:GraphicsLike,inGlyph:Int,m:Matrix) : Void
   {
      inGraphics.RenderGlyph(mFont,inGlyph,m, false);
   }

   public function RenderChar(inGraphics:GraphicsLike,inChar:Int,m:Matrix) : Void
      { RenderGlyph(inGraphics,inChar,m); }



   public function GetAdvance(inGlyph:Int, ?inNext:Null<Int>) : Float
   {
      var m = mMetrics[inGlyph];
      if (m==null)
         mMetrics[inGlyph] = m = mFont.GetGlyphMetrics(inGlyph);
      return m.x_advance;
   }

   public function GetAscent() : Float { return mFontMetrics.ascent; }
   public function GetDescent() : Float { return mFontMetrics.descent; }
   public function GetLeading() : Float { return 0; }
}

#else true


class NativeGlyphRenderer implements flash.text.GlyphRenderer
{
   var mName : String;

   public function new(inFace:String) { mName = inFace; }

   // GlyphRenderer Interface
   public function GetName() : String { return mName; }
   public function Ok() : Bool { return false; }
   public function RenderGlyph(inGraphics:GraphicsLike,inGlyph:Int,m:Matrix) : Void { }
   public function RenderChar(inGraphics:GraphicsLike,inChar:Int,m:Matrix) : Void
      { RenderGlyph(inGraphics,inChar,m); }

   public function GetAdvance(inGlyph:Int, ?inNext:Null<Int>) : Float { return 1024; }
   public function GetAscent() : Float { return 800; }
   public function GetDescent() : Float { return 224; }
   public function GetLeading() : Float { return 0; }
}


#end
