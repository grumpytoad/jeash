package jeash.text;

#if flash
typedef AntiAliasType = flash.text.AntiAliasType
#else true

class AntiAliasType
{
   public function new() { }

   public static var ADVANCED = "ADVANCED";
   public static var NORMAL = "NORMAL";
}

#end
