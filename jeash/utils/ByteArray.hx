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

package jeash.utils;

import haxe.io.Input;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Eof;

class ByteArray extends Input, implements ArrayAccess<Int> {
   public  var position:Int;
   public var bytesAvailable(default,null) : Int;
   public var endian(__GetEndian,__SetEndian) : Endian;
   public var objectEncoding : Int;

   public var length(get_length,null):Int;

   public var b : BytesData;
   public var pos : Int;
   public var len : Int;

   public function new( b : Bytes, ?pos : Int, ?len : Int ) {
     if( pos == null ) pos = 0; if( len == null ) len = b.length - pos;
     if( pos < 0 || len < 0 || pos + len > b.length ) throw "Out of Bounds.";
     this.b = b.getData();
     this.pos = pos;
     this.len = len;
   }

   public override function readByte() : Int {
     //trace( this.len );
     if( this.len == 0 )
       throw new Eof();
     len--;
     //trace( b[pos] );
     return b[pos++];
   }

   override public function readInt31() {
     var ch1,ch2,ch3,ch4;
     if( bigEndian ) {
       ch4 = readByte();
       ch3 = readByte();
       ch2 = readByte();
       ch1 = readByte();
     } else {
       ch1 = readByte();
       ch2 = readByte();
       ch3 = readByte();
       ch4 = readByte();
     }
     return ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
   }

   public function get_length():Int
   {
      return readAll().toString().length;
   }

   public function readUTFBytes(inLen:Int)
   {
      return readString(inLen);
   }
   public function readInt():Int
   {
     var x = readInt31();
     if( (((cast x) >> 30) & 1) != ((cast x) >>> 31) ) 
     { 
       trace(x); 
       trace((cast x) & 0xFF); 
       /*
       trace(pos); 
       trace (b); 
       trace( b[pos-1] ); 
       trace( b[pos-2] ); 
       trace( b[pos-3] ); 
       trace( b[pos-4] ); 
       trace( b[pos-1] << 24 );
       trace( b[pos-2] << 16 );
       trace( b[pos-3] << 8 );
       trace( b[pos-4] | (b[pos-3] << 8) );
       trace( b[pos-1] & 128 );
       trace( b[pos-1] & 64 );
       */
     //return (cast x) & 0xFF;
     }
#if neko
     return try untyped __i32__to_int(x) catch( e : Dynamic ) throw "Overflow"+x;
#elseif flash9
     return cast x;
#else
     return (cast x) & 0xFFFFFFFF;
#end
   }
   public function readUnsignedByte():Int
   {
     trace( b[pos] );
     return readByte();
   }
   public function readShort():Int
   {
     return readInt16();
   }
   public function readUnsignedShort():Int
   {
     //trace ( b[pos] );
     //trace ( b[pos + 1] );

     return readInt8();
   }
   public function readUnsignedInt():Int
   {
     return haxe.Int32.toInt( readInt32() );
   }

   public function __GetEndian() : Endian
   {
     if ( bigEndian == true )
     {
       return Endian.BIG_ENDIAN;
     } else {
       return Endian.LITTLE_ENDIAN;
     }
   }
   public function __SetEndian( endian : Endian ) : Endian
   {
     if ( endian == Endian.BIG_ENDIAN )
     {
       bigEndian = true;
     } else {
       bigEndian = false;
     }

     return endian;
   }
}
