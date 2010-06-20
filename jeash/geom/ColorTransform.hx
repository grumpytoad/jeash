package jeash.geom;

class ColorTransform
{
   public var alphaMultiplier : Float;
   public var alphaOffset : Float;
   public var blueMultiplier : Float;
   public var blueOffset : Float;
   public var color : Int;
   public var greenMultiplier : Float;
   public var greenOffset : Float;
   public var redMultiplier : Float;
   public var redOffset : Float;

   public function new(
      ?inRedMultiplier : Float,
      ?inGreenMultiplier : Float,
      ?inBlueMultiplier : Float,
      ?inAlphaMultiplier : Float,
      ?inRedOffset : Float,
      ?inGreenOffset : Float,
      ?inBlueOffset : Float,
      ?inAlphaOffset : Float) : Void
   {
      redMultiplier = inRedMultiplier==null ? 1.0 : inRedMultiplier;
      greenMultiplier = inGreenMultiplier==null ? 1.0 : inGreenMultiplier;
      blueMultiplier = inBlueMultiplier==null ? 1.0 : inBlueMultiplier;
      alphaMultiplier = inAlphaMultiplier==null ? 1.0 : inAlphaMultiplier;
      redOffset = inRedOffset==null ? 0.0 : inRedOffset;
      greenOffset = inGreenOffset==null ? 0.0 : inGreenOffset;
      blueOffset = inBlueOffset==null ? 0.0 : inBlueOffset;
      alphaOffset = inAlphaOffset==null ? 0.0 : inAlphaOffset;
      color = 0;
   }

   function concat(second : flash.geom.ColorTransform) : Void
   {
      throw "Not implemented";
   }
}

