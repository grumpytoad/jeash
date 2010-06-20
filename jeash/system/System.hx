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
