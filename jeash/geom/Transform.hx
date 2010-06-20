package jeash.geom;

import flash.display.DisplayObject;
import flash.geom.Matrix;

class Transform
{
   public var colorTransform( GetColorTransform, SetColorTransform ) : ColorTransform;
   public var matrix(GetMatrix,SetMatrix):Matrix;

   var mObj:DisplayObject;

   public function new(inParent:DisplayObject)
   {
      mObj = inParent;
   }

   public function GetMatrix() : Matrix { return mObj.GetMatrix(); }
   public function SetMatrix(inMatrix:Matrix) : Matrix
       { return mObj.SetMatrix(inMatrix); }

   public function GetColorTransform() { 
#if silverlight
     var gfx = mObj.GetGraphics();
     return gfx.mColorTransform;
#else
     return new ColorTransform();
#end
   }

   public function SetColorTransform( inColorTransform : ColorTransform ) : ColorTransform
   {
#if silverlight
     mObj.GetGraphics().mColorTransform = colorTransform;
#end
     return inColorTransform;
   }
}
