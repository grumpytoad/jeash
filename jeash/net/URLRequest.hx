package jeash.net;

class URLRequest
{
   public var url:String;

   public function new(?inURL:String)
   {
      if (inURL!=null)
         url = inURL;
   }
}


