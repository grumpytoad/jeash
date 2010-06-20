package jeash.swf;

import flash.swf.Character;
import flash.swf.DepthSlot;
import flash.swf.DisplayAttributes;
import flash.geom.Matrix;
import flash.geom.ColorTransform;


typedef DepthObjects = IntHash<DepthSlot>;


class Frame
{
   var mObjects : DepthObjects;
   var mFrame : Int;

   public function new(?inPrev:Frame)
   {
      mObjects = new DepthObjects();
      if (inPrev!=null)
      {
         var objs = inPrev.mObjects;
         for(depth in objs.keys())
            mObjects.set( depth, objs.get(depth) );
         mFrame = inPrev.mFrame + 1;
      }
      else
         mFrame = 1;
   }

   public function CopyObjectSet()
   {
      var c = new DepthObjects();
      for(d in mObjects.keys())
         c.set(d,mObjects.get(d));
      return c;
   }

   public function Remove(inDepth:Int)
   {
      mObjects.remove(inDepth);
   }

   public function Place(inCharID:Int, inChar:Character, inDepth:Int,
                  inMatrix:Matrix, inColTx:ColorTransform,
                  inRatio:Null<Int>)
   {
      var old = mObjects.get(inDepth);
      if (old!=null)
         throw("Overwriting non-empty depth");
      var attrib = new DisplayAttributes( );
      attrib.mFrame = mFrame;
      attrib.mMatrix = inMatrix;
      attrib.mColorTransform = inColTx;
      attrib.mRatio = inRatio;
      attrib.mName = "";
      attrib.mCharacterID = inCharID;
      var obj = new DepthSlot(inChar,inCharID,attrib);
      mObjects.set(inDepth,obj);
   }

   public function Move(inDepth:Int,
                  inMatrix:Matrix, inColTx:ColorTransform,
                  inRatio:Null<Int>)
   {
      var obj = mObjects.get(inDepth);
      if (obj==null)
         throw("depth has no object");

      obj.Move(mFrame, inMatrix, inColTx, inRatio);
   }

   public function GetFrame() { return mFrame; }

}

typedef Frames = Array<Frame>;
