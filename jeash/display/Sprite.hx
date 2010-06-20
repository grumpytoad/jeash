package jeash.display;

import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;

class Sprite extends DisplayObjectContainer
{
	var mGraphics:Graphics;
	public var graphics(GetGraphics,null):Graphics;
	public var buttonMode:Bool;

	#if debug
	static var spriteIndex : Int = 0;
	#end

	public function new()
	{
		super();
		mGraphics = new Graphics();
		buttonMode = false;
		name = "Sprite " + DisplayObject.mNameID++;
	}

	public function startDrag(?lockCenter:Bool, ?bounds:Rectangle):Void
	{
		flash.Lib.SetDragged(this,lockCenter,bounds);
	}

	public function stopDrag():Void
	{
		flash.Lib.SetDragged(null);
	}

	public function getObjectsUnderPoint( pPoint:Point ):Array<DisplayObject> {
			// TODO
			return null;
	}

	override public function GetGraphics() { return mGraphics; }
}

