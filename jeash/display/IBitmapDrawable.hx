package jeash.display;

import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

#if !silverlight
interface IBitmapDrawable 
{
    public function drawToSurface(inSurface : Dynamic,
                        matrix:Matrix,
                        colorTransform:ColorTransform,
                        blendMode:String,
                        clipRect:Rectangle,
                        smoothing:Bool):Void;
}
#end
