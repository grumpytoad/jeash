package jeash.text;

#if !js
import flash.geom.Matrix;
import flash.display.Graphics;
import flash.display.BitmapData;
#else
import flash.geom.Matrix;
import flash.display.Graphics;
#end


typedef GlyphArray = Array<BitmapData>;

enum FontInstanceMode
{
   fimSolid;
}

class FontInstance
{
   static var mSolidFonts = new Hash<FontInstance>();

   var mMode : FontInstanceMode;
   var mColour : Int;
   var mAlpha : Float;
   var mFont : Font;
   var mHeight: Int;
   var mGlyphs: GlyphArray;
   var mCacheAsBitmap:Bool;
   public var mTryFreeType:Bool;

   public var height(GetHeight,null):Int;


   function new(inFont:Font,inHeight:Int)
   {
      mFont = inFont;
      mHeight = inHeight;
      mTryFreeType = true;
      mGlyphs = [];
      #if flash
      mCacheAsBitmap = false;
      #else
      mCacheAsBitmap = flash.Lib.IsOpenGL();
      #end
   }


   public function toString() : String
   {
       return "FontInstance:" + mFont + ":" + mColour + "(" + mGlyphs.length + ")";
   }



   public function GetFace()
   {
      return mFont.GetName();
   }

   static public function CreateSolid(inFace:String,inHeight:Int,inColour:Int, inAlpha:Float)
   {
      var id = "SOLID:" + inFace+ ":" + inHeight + ":" + inColour + ":" + inAlpha;
      var f:FontInstance =  mSolidFonts.get(id);
      if (f!=null)
         return f;

      var font = FontManager.GetFont(inFace,inHeight);
      if (font==null)
         return null;

      f = new FontInstance(font,inHeight);
      f.SetSolid(inColour,inAlpha);
      mSolidFonts.set(id,f);
      return f;
   }

   function GetHeight():Int { return mHeight; }

   function SetSolid(inCol:Int, inAlpha:Float)
   {
      mColour = inCol;
      mAlpha = inAlpha;
      mMode = fimSolid;
   }

   public function RenderChar(inGraphics:Graphics,inGlyph:Int,inX:Int, inY:Int) : Int
   {
      inGraphics.lineStyle();
      if (mCacheAsBitmap)
      {
         var glyph = mGlyphs[inGlyph];
         if (glyph==null)
         {
            var shape = new flash.display.Shape();
            var gfx = shape.graphics;
            // Make sure 0,0 is part of bounds ...
            gfx.lineStyle(1,1);
            gfx.moveTo(1,1);
            gfx.lineTo(0,0);
            mFont.Render(gfx,inGlyph,0,0,mTryFreeType);
            var w = Math.ceil(shape.width + 10);
            var h = Math.ceil(shape.height + 10);
            #if flash
            var bmp = new BitmapData(w,h,true,0);
            gfx.clear();
            gfx.beginFill(mColour,mAlpha);
            mFont.Render(gfx,inGlyph,0,0,mTryFreeType);
            bmp.draw(shape);
            #else
            var bmp = new BitmapData(w,h,true, flash.RGB.CLEAR );
            var gfx = bmp.graphics;
            gfx.beginFill(mColour,mAlpha);
            mFont.Render(gfx,inGlyph,0,0,false);
            #end

            mGlyphs[inGlyph] = glyph = bmp;
         }

         var m = new Matrix();
         m.tx = inX;
         m.ty = inY;
         inGraphics.beginBitmapFill(glyph,m,false,true);
         inGraphics.drawRect(inX,inY,glyph.width,glyph.height);

         return mFont.GetAdvance(inGlyph);
      }
      else
      {
         inGraphics.beginFill(mColour,mAlpha);
         return mFont.Render(inGraphics,inGlyph,inX,inY,mTryFreeType);
      }
   }

   public function GetAdvance(inChar:Int) : Int
   {
     if (mFont==null) return 0;
     return mFont.GetAdvance(inChar);
   }
}
