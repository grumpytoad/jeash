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

package jeash.system;

class System
{

   public static var vmVersion(getVersion,null) : String;

   public static function getVersion()
   {
      #if neko
      return "NekoVM";
      #elseif cpp
      return "CPP";
      #else
      return "Unknown";
      #end
   }

   public static var totalMemory(getMemory,null) : Int;

   public static var useCodePage : Bool = false;

   public static function exit( code : Int ) : Void
   {
      flash.Lib.close();
   }
   public static function gc() : Void
   {
      #if neko
      neko.vm.Gc.run(true);
      #end
   }
   public static function pause() : Void
   {
     // TODO
   }
   public static function resume() : Void
   {
     // TODO
   }
   public static function getMemory() : Int
   {
   #if neko
      return neko.vm.Gc.stats().heap;
   #else
      // TODO;
      return 0x100000;
   #end
   }
   public static function setClipboard( string : String ) : Void
   {
      nme.Manager.setClipboardString(string);
   }

}
