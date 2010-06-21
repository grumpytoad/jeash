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

class TextFormat
{
   public var align : Null<String>;
   public var blockIndent : Dynamic;
   public var bold : Dynamic;
   public var bullet : Dynamic;
   public var color : Dynamic;
   public var display : Null<String>;
   public var font : Null<String>;
   public var indent : Dynamic;
   public var italic : Dynamic;
   public var kerning : Dynamic;
   public var leading : Dynamic;
   public var leftMargin : Dynamic;
   public var letterSpacing : Dynamic;
   public var rightMargin : Dynamic;
   public var size : Dynamic;
   public var tabStops : Array<Int>;
   public var target : String;
   public var underline : Dynamic;
   public var url : String;

  public function new(?in_font : String,
                      ?in_size : Dynamic,
                      ?in_color : Dynamic,
                      ?in_bold : Dynamic,
                      ?in_italic : Dynamic,
                      ?in_underline : Dynamic,
                      ?in_url : String,
                      ?in_target : String,
                      ?in_align : String,
                      ?in_leftMargin : Dynamic,
                      ?in_rightMargin : Dynamic,
                      ?in_indent : Dynamic,
                      ?in_leading : Dynamic)
   {
      font = in_font;
      size = in_size;
      color = in_color;
      bold = in_bold;
      italic = in_italic;
      underline = in_underline;
      url = in_url;
      target = in_target;
      align = in_align;
      leftMargin = in_leftMargin;
      rightMargin = in_rightMargin;
      indent = in_indent;
      leading = in_leading;
   }

}


