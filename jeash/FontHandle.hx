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

package jeash;
import Type;


typedef FontMetrics =
{
   var height:Int;
   var ascent:Int;
   var descent:Int;
   var max_x_advance:Int;
}

typedef GlyphMetrics =
{
   var min_x: Int;
   var max_x: Int;
   var width: Int;
   var height : Int;
   var x_advance: Int;
}


class FontHandle
{
   public var handle(get_handle,null):Dynamic;
   var mHandle:Dynamic;

   public function new(inName:String, inSize:Int)
   {
					throw "Not implemented. new Fonthandle.";
   }

   public function GetGlyphMetrics(inChar:Dynamic) : GlyphMetrics
   {
      var c : Int = Type.typeof(inChar) == ValueType.TInt ? inChar :
                            inChar.charCodeAt(0) ;
					throw "Not implemented. GetGlyphMetrics.";
					return null;
   }

   public function GetFontMetrics() : FontMetrics
   {
					throw "Not implemented. GetFontMetrics.";
					return null;
   }

   public function get_handle() : Dynamic { return mHandle; }

}
