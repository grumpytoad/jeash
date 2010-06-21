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

import flash.text.FontInstance;
import flash.text.Font;
import flash.swf.ScaledFont;
import flash.geom.Matrix;

class FontManager
{
   static var mFontMap = new Hash<flash.text.Font>();
   static var mSWFFonts = new Hash<flash.swf.Font>();
   
   static public function GetFont(inFace:String,inHeight:Int) : Font
   {
      var id = inFace+":"+inHeight;
      var font:Font = mFontMap.get(inFace);
      if (font==null)
      {
         // Look for swf font ...
         var swf_font = mSWFFonts.get(inFace);
         if (swf_font!=null)
         {
            font = new ScaledFont(swf_font,inHeight);
         }
         else
         {
            var native_font = new NativeFont(inFace,inHeight);
            if (native_font.Ok())
               font = native_font;
         }

         if (font!=null)
           mFontMap.set(id,font);
      }

      return font;
   }

   static public function RegisterFont(inFont:flash.swf.Font)
   {
      // trace("Register :" + inFont.GetName() + "<");
      mSWFFonts.set(inFont.GetName(), inFont);
   }

}
