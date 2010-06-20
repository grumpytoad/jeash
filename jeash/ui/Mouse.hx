package jeash.ui;

#if flash
typedef Mouse = flash.ui.Mouse;
#else

class Mouse
{
   public function new() { }

   public static function hide() { }
   public static function show() { }
}


#end
