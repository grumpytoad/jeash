package jeash.swf;

import flash.swf.Shape;
import flash.swf.MorphShape;
import flash.swf.Sprite;
import flash.swf.Bitmap;
import flash.swf.Font;
import flash.swf.StaticText;
import flash.swf.EditText;

enum Character
{
   charShape(inShape:Shape);
   charMorphShape(inMorphShape:MorphShape);
   charSprite(inSprite:Sprite);
   charBitmap(inBitmap:Bitmap);
   charFont(inFont:Font);
   charStaticText(inText:StaticText);
   charEditText(inText:EditText);
}
