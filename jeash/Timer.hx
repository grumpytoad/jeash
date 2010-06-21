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

#if flash
typedef Timer = haxe.Timer;
#else

typedef TimerList = Array<Timer>

class Timer
{
   static var sRunningTimers:TimerList = [];
	static var sInitTime:Float = haxe.Timer.stamp();        //traacks time since VM instantion (approximately)

   var mTime:Int;
   var mFireAt:Int;
   var mRunning:Bool;

   public function new(time:Int)
   {
      mTime = time;
      sRunningTimers.push(this);
      mFireAt = GetMS()+mTime;
      mRunning = true;
   }

   // Set this with "run=..."
   dynamic public function run(){ }

   public function stop() : Void
   {
      if (mRunning)
      {
         mRunning = false;
         sRunningTimers.remove(this);
      }
   }

   function Check(inTime:Int)
   {
      if (inTime>=mFireAt)
      {
         mFireAt += mTime;
         run();
      }
   }

   public static function CheckTimers()
   {
      var now = GetMS();
      for(timer in sRunningTimers)
         timer.Check(now);
   }

   static function GetMS() 
   { 
   	return Std.int(stamp()*1000.0); 
   }


   // From std/haxe/Timer.hx
	public static function delay( f : Void -> Void, time : Int ) {
		var t = new flash.Timer(time);
		t.run = function() {
			t.stop();
			f();
		};
	}


   static public function stamp() : Float
   {
       //subtraction is needed to get a VM time offset within the 31-bit Int range
       //since on Linux/neko the normal timestamp is since 1970 (which *1000
       //in GetMS overflows)
       return haxe.Timer.stamp() - sInitTime;
   }

}


#end
