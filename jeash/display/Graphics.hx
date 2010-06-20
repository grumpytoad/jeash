/*


   Lines, fill styles and closing polygons.
   Flash allows the line stype to be changed withing one filled polygon.
   A single NME "DrawObject" has a point list, an optional solid fill style
   and a list of lines.  Each of these lines has a line style and a
   list of "point indices", which are indices into the DrawObject's point array.
   The solid does not need a point-index list because it uses all the
   points in order.

   When building up a filled polygon, eveytime the line style changes, the
   current "line fragment" is stored in the "mLineJobs" list and a new line
   is started, without affecting the solid fill bit.
 */


package jeash.display;

import Html5Dom;
import flash.geom.Matrix;
import flash.geom.Decompose;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.display.LineScaleMode;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.InterpolationMethod;
import flash.display.BitmapData;
import flash.Manager;

typedef DrawList = Array<Drawable>;

class GfxPoint
{
	public function new(inX:Float,inY:Float,inCX:Float,inCY:Float,inType:Int)
	{ x = inX; y=inY; cx=inCX; cy=inCY; type=inType; }

	public var x:Float;
	public var y:Float;
	public var cx:Float;
	public var cy:Float;
	public var type:Int;
}

typedef GfxPoints = Array<GfxPoint>;

typedef GradPoint = 
{
	var col:Int;
	var alpha:Float;
	var ratio:Int;
}

typedef GradPoints = Array<GradPoint>;

typedef Grad =
{
	var points:GradPoints;
	var matrix:Matrix;
	var flags:Int;
	var focal:Float;
}

class LineJob
{
	public function new( inGrad:Grad, inPoint_idx0:Int, inPoint_idx1:Int, inThickness:Float,
			inAlpha:Float, inColour:Int, inPixel_hinting:Int, inJoints:Int, inCaps:Int,
			inScale_mode:Int, inMiter_limit:Float)
	{
		grad = inGrad;
		point_idx0 = inPoint_idx0;
		point_idx1 = inPoint_idx1;
		thickness = inThickness;
		alpha = inAlpha;
		colour = inColour;
		pixel_hinting = inPixel_hinting;
		joints = inJoints;
		caps = inCaps;
		scale_mode = inScale_mode;
		miter_limit = inMiter_limit;
	}

	public var grad:Grad;
	public var point_idx0:Int;
	public var point_idx1:Int;
	public var thickness:Float;
	public var alpha:Float;
	public var colour:Int;
	public var pixel_hinting:Int;
	public var joints:Int;
	public var caps:Int;
	public var scale_mode:Int;
	public var miter_limit:Float;
}

typedef Drawable =
{
	var points:GfxPoints;
	var fillColour:Int;
	var fillAlpha:Float;
	var solidGradient:Grad;
	var bitmap:Texture;
	var lineJobs:LineJobs;
}

typedef Texture =
{
	var texture_buffer:HtmlCanvasElement;
	var matrix:Matrix;
	var flags:Int;
}

typedef LineJobs = Array<LineJob>;

class Graphics
{
	public static var defaultFontName = "ARIAL.TTF";
	public static var defaultFontSize = 12;
	public static var immediateMatrix = null;
	public static var immediateMask:Dynamic = null;

	public static var TOP = 0;
	public static var CENTER = 1;
	public static var BOTTOM = 2;

	public static var LEFT = 0;
	public static var RIGHT = 2;

	public static var RADIAL  = 0x0001;

	public static var REPEAT  = 0x0002;
	public static var REFLECT = 0x0004;


	private static var  EDGE_MASK        = 0x00f0;
	private static var  EDGE_CLAMP       = 0x0000;
	private static var  EDGE_REPEAT      = 0x0010;
	private static var  EDGE_UNCHECKED   = 0x0020;
	private static var  EDGE_REPEAT_POW2 = 0x0030;

	private static var  END_NONE         = 0x0000;
	private static var  END_ROUND        = 0x0100;
	private static var  END_SQUARE       = 0x0200;
	private static var  END_MASK         = 0x0300;
	private static var  END_SHIFT        = 8;

	private static var  CORNER_ROUND     = 0x0000;
	private static var  CORNER_MITER     = 0x1000;
	private static var  CORNER_BEVEL     = 0x2000;
	private static var  CORNER_MASK      = 0x3000;
	private static var  CORNER_SHIFT     = 12;

	private static var  PIXEL_HINTING    = 0x4000;

	public static var BMP_REPEAT  = 0x0010;
	public static var BMP_SMOOTH  = 0x10000;


	private static var  SCALE_NONE       = 0;
	private static var  SCALE_VERTICAL   = 1;
	private static var  SCALE_HORIZONTAL = 2;
	private static var  SCALE_NORMAL     = 3;

	static var MOVE = 0;
	static var LINE = 1;
	static var CURVE = 2;

	public static var BLEND_ADD = 0;
	public static var BLEND_ALPHA = 1;
	public static var BLEND_DARKEN = 2;
	public static var BLEND_DIFFERENCE = 3;
	public static var BLEND_ERASE = 4;
	public static var BLEND_HARDLIGHT = 5;
	public static var BLEND_INVERT = 6;
	public static var BLEND_LAYER = 7;
	public static var BLEND_LIGHTEN = 8;
	public static var BLEND_MULTIPLY = 9;
	public static var BLEND_NORMAL = 10;
	public static var BLEND_OVERLAY = 11;
	public static var BLEND_SCREEN = 12;
	public static var BLEND_SUBTRACT = 13;
	public static var BLEND_SHADER = 14;

	public var mSurface(default,null):HtmlCanvasElement;
	public var mChanged:Bool;

	// Current set of points
	private var mPoints:GfxPoints;

	// Solids ...
	private var mSolid:Bool;
	private var mFilling:Bool;
	private var mFillColour:Int;
	private var mFillAlpha:Float;
	private var mSolidGradient:Grad;
	private var mBitmap:Texture;

	// Lines ...
	private var mCurrentLine:LineJob;
	private var mLineJobs:LineJobs;

	// List of drawing commands ...
	private var mDrawList:DrawList;
	private var mLineDraws:DrawList;

	// Current position ...
	private var mPenX:Float;
	private var mPenY:Float;
	private var mLastMoveID:Int;

	public function new(?inSurface:HtmlCanvasElement)
	{
		mChanged = false;

		if ( inSurface == null ) {
			mSurface = cast js.Lib.document.createElement("canvas");

		} else {
			mSurface = inSurface;
		}

		mLastMoveID = 0;
		clear();
	}

	public function SetSurface(inSurface:Dynamic)
	{
		mSurface = inSurface;
	}

	// FIXME: needed by neash, but somehow unecessary in js so far
	public static function setBlendMode(inBlendMode:Int) {}

	private function createCanvasColor(color : Int, alpha : Float) {
		var r:Float;
		var g:Float;
		var b:Float;
		r = (0xFF0000 & color) >> 16;
		g = (0x00FF00 & color) >> 8;
		b = (0x0000FF & color);
		return 'rgba' + '(' + r + ',' + g + ',' + b + ',' + alpha + ')';

	}
	private function createCanvasGradient(ctx : CanvasRenderingContext2D, g : Grad) : CanvasGradient{
		var gradient : CanvasGradient;
		//TODO handle spreadMethod flags REPEAT and REFLECT (defaults to PAD behavior)

		var matrix = g.matrix;
		if ((g.flags & RADIAL) == 0) {
			var p1 = matrix.transformPoint(new Point( -819.2, 0));
			var p2 = matrix.transformPoint(new Point(819.2, 0));
			gradient = ctx.createLinearGradient(p1.x, p1.y, p2.x, p2.y);
		} else {
			//TODO not quite right (no ellipses when width != height)
			var p1 = matrix.transformPoint(new Point(g.focal*819.2, 0));
			var p2 = matrix.transformPoint(new Point(0, 819.2));
			gradient = ctx.createRadialGradient(p1.x, p1.y, 0, p2.x, p1.y, p2.y);
		}

		for (point in g.points) {
			var color = createCanvasColor(point.col, point.alpha);
			var pos = point.ratio / 255;
			gradient.addColorStop(pos, color);
		}
		return gradient;
	}

	public function __Render(?inMatrix:Matrix,inSurface:HtmlCanvasElement,?inMaskHandle:HtmlCanvasElement,?inScrollRect:Rectangle)
	{
		ClosePolygon(true);

		var ctx : CanvasRenderingContext2D = inSurface.getContext('2d');
		//var ctx = jeash.Lib.canvas.getContext('2d');

		ctx.save();
		ctx.transform(inMatrix.a, inMatrix.b, inMatrix.c, inMatrix.d, inMatrix.tx, inMatrix.ty);

		//var len : Int = mDrawList.length;
		//for ( i in 0...len ) {
		//}

		// merge into parent canvas context
		if (inMaskHandle != null)
		{
			var maskCtx = inMaskHandle.getContext('2d');
			maskCtx.drawImage(inSurface, 0, 0);
		}

		ctx.restore();

	}

	public function HitTest(inX:Int,inY:Int) : Bool
	{
		var ctx : CanvasRenderingContext2D = Manager.getScreen();
		ctx.save();
		for(d in mDrawList)
		{
			ctx.beginPath();
			for ( p in d.points ) {
				switch (p.type) {
					case MOVE:
						ctx.moveTo(p.x , p.y);
					case CURVE:
						ctx.quadraticCurveTo(p.cx, p.cy, p.x, p.y);
					default:
						ctx.lineTo(p.x, p.y);
				}
			}
			if ( ctx.isPointInPath(inX, inY) ) return true;
			ctx.closePath();
		}
		ctx.restore();
		return false;
	}


	public function blit(inTexture:BitmapData)
	{
		ClosePolygon(true);

		var ctx = mSurface.getContext('2d');
		untyped ctx.drawImage(inTexture.handle(),mPenX,mPenY);
	}



	public function lineStyle(?thickness:Null<Float>,
			?color:Null<Int>,
			?alpha:Null<Float> ,
			?pixelHinting:Null<Bool> ,
			?scaleMode:Null<LineScaleMode> ,
			?caps:Null<CapsStyle>,
			?joints:Null<JointStyle>,
			?miterLimit:Null<Float> )
	{
		// Finish off old line before starting a new one
		AddLineSegment();

		//with no parameters it clears the current line (to draw nothing)
		if( thickness == null )
		{
			ClearLine();
			return;
		}
		else
		{
			mCurrentLine.grad = null;
			mCurrentLine.thickness = Math.round(thickness);
			mCurrentLine.colour = color==null ? 0 : color;
			mCurrentLine.alpha = alpha==null ? 1.0 : alpha;
			mCurrentLine.miter_limit = miterLimit==null ? 3.0 : miterLimit;
			mCurrentLine.pixel_hinting = (pixelHinting==null || !pixelHinting)?
				0 : PIXEL_HINTING;
		}

		//mCurrentLine.caps = END_ROUND;
		if (caps!=null)
		{
			switch(caps)
			{
				case CapsStyle.ROUND:
					mCurrentLine.caps = END_ROUND;
				case CapsStyle.SQUARE:
					mCurrentLine.caps = END_SQUARE;
				case CapsStyle.NONE:
					mCurrentLine.caps = END_NONE;
			}
		}

		mCurrentLine.scale_mode = SCALE_NORMAL;
		if (scaleMode!=null)
		{
			switch(scaleMode)
			{
				case LineScaleMode.NORMAL:
					mCurrentLine.scale_mode = SCALE_NORMAL;
				case LineScaleMode.VERTICAL:
					mCurrentLine.scale_mode = SCALE_VERTICAL;
				case LineScaleMode.HORIZONTAL:
					mCurrentLine.scale_mode = SCALE_HORIZONTAL;
				case LineScaleMode.NONE:
					mCurrentLine.scale_mode = SCALE_NONE;
			}
		}


		mCurrentLine.joints = CORNER_ROUND;
		if (joints!=null)
		{
			switch(joints)
			{
				case JointStyle.ROUND:
					mCurrentLine.joints = CORNER_ROUND;
				case JointStyle.MITER:
					mCurrentLine.joints = CORNER_MITER;
				case JointStyle.BEVEL:
					mCurrentLine.joints = CORNER_BEVEL;
			}
		}
	}

	public function lineGradientStyle(type : GradientType,
			colors : Array<Dynamic>,
			alphas : Array<Dynamic>,
			ratios : Array<Dynamic>,
			?matrix : Matrix,
			?spreadMethod : SpreadMethod,
			?interpolationMethod : InterpolationMethod,
			?focalPointRatio : Null<Float>) : Void
	{
		mCurrentLine.grad = CreateGradient(type,colors,alphas,ratios,
				matrix,spreadMethod,
				interpolationMethod,
				focalPointRatio);
	}



	public function beginFill(color:Int, ?alpha:Null<Float>)
	{
		ClosePolygon(true);

		mFillColour =  color;
		mFillAlpha = alpha==null ? 1.0 : alpha;
		mFilling=true;
		mSolidGradient = null;
		mBitmap = null;
	}

	public function endFill()
	{
		ClosePolygon(true);
	}

	public function drawEllipse(x:Float,y:Float,rx:Float,ry:Float)
	{
		ClosePolygon(false);

		moveTo(x+rx, y);
		curveTo(rx+x        ,-0.4142*ry+y,0.7071*rx+x ,-0.7071*ry+y);
		curveTo(0.4142*rx+x ,-ry+y       ,x           ,-ry+y);
		curveTo(-0.4142*rx+x,-ry+y       ,-0.7071*rx+x,-0.7071*ry+y);
		curveTo(-rx+x       ,-0.4142*ry+y,-rx+x       , y);
		curveTo(-rx+x       ,0.4142*ry+y ,-0.7071*rx+x,0.7071*ry+y);
		curveTo(-0.4142*rx+x,ry+y        ,x           ,ry+y);
		curveTo(0.4142*rx+x ,ry+y        ,0.7071*rx+x ,0.7071*ry+y) ;
		curveTo(rx+x        ,0.4142*ry+y ,rx+x        ,y);

		ClosePolygon(false);
	}

	public function drawCircle(x:Float,y:Float,rad:Float)
	{
		drawEllipse(x,y,rad,rad);
	}

	public function drawRect(x:Float,y:Float,width:Float,height:Float)
	{
		ClosePolygon(false);

		moveTo(x,y);
		lineTo(x+width,y);
		lineTo(x+width,y+height);
		lineTo(x,y+height);
		lineTo(x,y);

		ClosePolygon(false);
	}



	public function drawRoundRect(x:Float,y:Float,width:Float,height:Float,
			ellipseWidth:Float, ellipseHeight:Float)
	{
		if (ellipseHeight<1 || ellipseHeight<1)
		{
			drawRect(x,y,width,height);
			return;
		}

		ClosePolygon(false);

		moveTo(x,y+ellipseHeight);
		// top-left
		curveTo(x,y,x+ellipseWidth,y);

		lineTo(x+width-ellipseWidth,y);
		// top-right
		curveTo(x+width,y,x+width,y+ellipseWidth);

		lineTo(x+width,y+height-ellipseHeight);

		// bottom-right
		curveTo(x+width,y+height,x+width-ellipseWidth,y+height);

		lineTo(x+ellipseWidth,y+height);

		// bottom-left
		curveTo(x,y+height,x,y+height-ellipseHeight);

		lineTo(x,y+ellipseHeight);

		ClosePolygon(false);
	}

	function CreateGradient(type : GradientType,
			colors : Array<Dynamic>,
			alphas : Array<Dynamic>,
			ratios : Array<Dynamic>,
			matrix : Null<Matrix>,
			spreadMethod : Null<SpreadMethod>,
			interpolationMethod : Null<InterpolationMethod>,
			focalPointRatio : Null<Float>)
	{

		var points = new GradPoints();
		for(i in 0...colors.length)
			points.push({col:colors[i], alpha:alphas[i], ratio:ratios[i]});


		var flags = 0;

		if (type==GradientType.RADIAL)
			flags |= RADIAL;

		if (spreadMethod==SpreadMethod.REPEAT)
			flags |= REPEAT;
		else if (spreadMethod==SpreadMethod.REFLECT)
			flags |= REFLECT;


		if (matrix==null)
		{
			matrix = new Matrix();
			matrix.createGradientBox(25,25);
		}
		else
			matrix = matrix.clone();

		var focal : Float = focalPointRatio ==null ? 0 : focalPointRatio;
		return  { points : points, matrix : matrix, flags : flags, focal:focal };
	}


	public function beginGradientFill(type : GradientType,
			colors : Array<Dynamic>,
			alphas : Array<Dynamic>,
			ratios : Array<Dynamic>,
			?matrix : Matrix,
			?spreadMethod : Null<SpreadMethod>,
			?interpolationMethod : Null<InterpolationMethod>,
			?focalPointRatio : Null<Float>) : Void
	{
		ClosePolygon(true);

		mFilling = true;
		mBitmap = null;
		mSolidGradient = CreateGradient(type,colors,alphas,ratios,
				matrix,spreadMethod,
				interpolationMethod,
				focalPointRatio);
	}




	public function beginBitmapFill(bitmap:BitmapData, ?matrix:Matrix,
			?in_repeat:Bool, ?in_smooth:Bool)
	{
		ClosePolygon(true);

		var repeat:Bool = in_repeat==null ? true : in_repeat;
		var smooth:Bool = in_smooth==null ? false : in_smooth;

		mFilling = true;

		mSolidGradient = null;

		mBitmap  = { texture_buffer: bitmap.handle(),
			matrix: matrix==null ? matrix : matrix.clone(),
			flags : (repeat ? BMP_REPEAT : 0) |
				(smooth ? BMP_SMOOTH : 0) };

	}


	public function ClearLine()
	{
		mCurrentLine = new LineJob( null,-1,-1,  0.0,
				0.0, 0x000, 1, CORNER_ROUND, END_ROUND,
				SCALE_NORMAL, 3.0);
	}

	public function clear()
	{
		mChanged = true;
		mPenX = 0.0;
		mPenY = 0.0;

		mDrawList = new DrawList();

		mPoints = [];

		mSolidGradient = null;
		//mBitmap = null;
		mFilling = false;
		mFillColour = 0x000000;
		mFillAlpha = 0.0;
		mLastMoveID = 0;

		ClearLine();

		mLineJobs = [];
	}

	public function GetExtent(inMatrix:Matrix) : Rectangle
	{
		flush();

		if (mDrawList.length == 0)
			return new Rectangle();

		//TODO build this as points are added, and store in var
		var maxX, minX, maxY, minY;
		maxX = minX = mDrawList[0].points[0].x;
		maxY = minY = mDrawList[0].points[0].y;
		for (dl in mDrawList) {
			for (p in dl.points) {
				var t = inMatrix.transformPoint(new Point(p.x, p.y));
				if (t.x > maxX) {
					maxX = t.x;
				}
				if (t.x < minX) {
					minX = t.x;
				}
				if (t.y > maxY) {
					maxY = t.y;
				}
				if (t.y < minY) {
					minY = t.y;
				}
			}
		}
		return new Rectangle(minX, minY, maxX-minX, maxY-minY);
	}

	public function moveTo(inX:Float,inY:Float)
	{
		mPenX = inX;
		mPenY = inY;

		if (!mFilling)
		{
			ClosePolygon(false);
		}
		else
		{
			AddLineSegment();
			mLastMoveID = mPoints.length;
			mPoints.push( new GfxPoint( mPenX, mPenY, 0.0, 0.0, MOVE ) );
		}
	}

	public function lineTo(inX:Float,inY:Float)
	{
		var pid = mPoints.length;
		if (pid==0)
		{
			mPoints.push( new GfxPoint( mPenX, mPenY, 0.0, 0.0, MOVE ) );
			pid++;
		}

		mPenX = inX;
		mPenY = inY;
		mPoints.push( new GfxPoint( mPenX, mPenY, 0.0, 0.0, LINE ) );

		if (mCurrentLine.grad!=null || mCurrentLine.alpha>0)
		{
			if (mCurrentLine.point_idx0<0)
				mCurrentLine.point_idx0 = pid-1;
			mCurrentLine.point_idx1 = pid;
		}

		if ( !mFilling ) ClosePolygon(false);

	}

	public function curveTo(inCX:Float,inCY:Float,inX:Float,inY:Float)
	{
		var pid = mPoints.length;
		if (pid==0)
		{
			mPoints.push( new GfxPoint( mPenX, mPenY, 0.0, 0.0, MOVE ) );
			pid++;
		}

		mPenX = inX;
		mPenY = inY;
		mPoints.push( new GfxPoint( inX, inY, inCX, inCY, CURVE ) );

		if (mCurrentLine.grad!=null || mCurrentLine.alpha>0)
		{
			if (mCurrentLine.point_idx0<0)
				mCurrentLine.point_idx0 = pid-1;
			mCurrentLine.point_idx1 = pid;
		}

	}


	public function flush() { ClosePolygon(true); }

	public function CheckChanged() : Bool
	{
		ClosePolygon(true);
		var result = mChanged;
		mChanged = false;
		return result;
	}

	private function AddDrawable(inDrawable:Drawable)
	{
		if (inDrawable==null)
			return; // throw ?

		mChanged = true;
		mDrawList.unshift( inDrawable );

		var d = inDrawable;

		var ctx : CanvasRenderingContext2D = mSurface.getContext('2d');

		ctx.save();
		ctx.beginPath();

		if (d.lineJobs.length > 0) {
			//TODO lj.pixel_hinting and lj.scale_mode
			for (lj in d.lineJobs) {
				ctx.lineWidth = lj.thickness;

				switch(lj.joints)
				{
					case CORNER_ROUND:
						ctx.lineJoin = "round";
					case CORNER_MITER:
						ctx.lineJoin = "miter";
					case CORNER_BEVEL:
						ctx.lineJoin = "bevel";
				}

				switch(lj.caps) {
					case END_ROUND:
						ctx.lineCap = "round";
					case END_SQUARE:
						ctx.lineCap = "square";
					case END_NONE:
						ctx.lineCap = "butt";
				}

				ctx.miterLimit = lj.miter_limit;

				if (lj.grad != null) {
					ctx.strokeStyle = createCanvasGradient(ctx, lj.grad);
				} else {
					ctx.strokeStyle = createCanvasColor(lj.colour, lj.alpha);
				}

				ctx.beginPath();
				for (i in lj.point_idx0...lj.point_idx1 + 1) {
					var p = d.points[i];
					switch (p.type) {
						case MOVE:
							ctx.moveTo(p.x , p.y);
						case CURVE:
							ctx.quadraticCurveTo(p.cx, p.cy, p.x, p.y);
						default:
							ctx.lineTo(p.x, p.y);
					}

				}
				ctx.stroke();
			}
		} else {
			for ( p in d.points ) {
				switch (p.type) {
					case MOVE:
						ctx.moveTo(p.x , p.y);
					case CURVE:
						ctx.quadraticCurveTo(p.cx, p.cy, p.x, p.y);
					default:
						ctx.lineTo(p.x, p.y);
				}
			}
		}

		var fillColour = d.fillColour;
		var fillAlpha = d.fillAlpha;
		if (  fillAlpha >= 0. && fillAlpha <= 1.) {
			var g = d.solidGradient;
			if (g != null)
				ctx.fillStyle = createCanvasGradient(ctx, g);
			else 
				ctx.fillStyle = createCanvasColor(fillColour, fillAlpha);
		}
		ctx.fill();

		ctx.restore();

		var bitmap = d.bitmap;
		if ( bitmap != null) {
			ctx.save();
			ctx.clip();
			var img = bitmap.texture_buffer;
			var matrix = bitmap.matrix;

			try {
				if(matrix != null) {
					ctx.transform( matrix.a,  matrix.b,  matrix.c,  matrix.d,  matrix.tx,  matrix.ty );
				}
				ctx.drawImage( img, 0, 0 );

				ctx.restore();
			} catch (e:Dynamic) {
				try {
					// fallback - should work for most canvas-browsers

					var svd = Decompose.singularValueDecomposition( matrix );   
					ctx.translate( svd.dx , svd.dy  );
					ctx.rotate( -svd.angle1 );
					ctx.scale( svd.sx, svd.sy );
					ctx.rotate( -svd.angle2 );

					ctx.drawImage( img, 0,0 );
					ctx.restore();
				} catch (e2:Dynamic) {
					ctx.restore();
				}
			}
		}

	}

	private function AddLineSegment()
	{
		if (mCurrentLine.point_idx1>0)
		{
			mLineJobs.push(
					new LineJob(
						mCurrentLine.grad,
						mCurrentLine.point_idx0,
						mCurrentLine.point_idx1,
						mCurrentLine.thickness,
						mCurrentLine.alpha,
						mCurrentLine.pixel_hinting,
						mCurrentLine.colour,
						mCurrentLine.joints,
						mCurrentLine.caps,
						mCurrentLine.scale_mode,
						mCurrentLine.miter_limit
						) );
		}
		mCurrentLine.point_idx0 = mCurrentLine.point_idx1 = -1;
	}

	static var drawableCount;
	private function ClosePolygon(inCancelFill)
	{
		var l =  mPoints.length;
		if (l>0)
		{
			if (l>1)
			{
				if (mFilling && l>2)
				{
					// Make implicit closing line
					if (mPoints[mLastMoveID].x!=mPoints[l-1].x || mPoints[mLastMoveID].y!=mPoints[l-1].y)
					{
						lineTo(mPoints[mLastMoveID].x, mPoints[mLastMoveID].y);

					}
				}

				AddLineSegment();

				var drawable : Drawable = { 
					points: mPoints, 
					fillColour: mFillColour, 
					fillAlpha: mFillAlpha,
					solidGradient: mSolidGradient, 
					bitmap: mBitmap,
					lineJobs: mLineJobs 
				};

				AddDrawable( drawable );

			}

			mLineJobs = [];
			mPoints = [];
		}

		if (inCancelFill)
		{
			mFillAlpha = 0;
			mSolidGradient = null;
			mBitmap = null;
			mFilling = false;
		}
	}

}

