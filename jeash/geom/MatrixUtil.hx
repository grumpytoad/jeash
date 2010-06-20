package jeash.geom;

import flash.geom.Matrix;

class MatrixUtil
{
	
	public static inline var INVERT:String = "invert";
	
	
	
	/**
	 * 
	 * @deprecated use MatrixX that has convenience methods for concat and inverse concat
	 * 
	 * @param args
	 * @return 
	 * 
	 */		
	public static function concat( args : Array<Dynamic> ):Matrix
	{
		
		var thisMatrix:Matrix;
		var resultMatrix:Matrix = new Matrix( );
		
		var invertNext:Bool = false;
		
		for ( arg in args )
		{
			
			if ( arg == INVERT )
			{
				invertNext = true;
				continue;	
			}
			else
			{
var b : Matrix = arg;
				thisMatrix = b.clone( );
			}
			
			if ( invertNext )
			{
				thisMatrix.invert( );					
				invertNext = false;
			}
		
			resultMatrix.concat( thisMatrix );	
		
		}
		
		return resultMatrix;

	}
	
	
	


	public static function compare( m1:Matrix, m2:Matrix ):Bool
	{
		// is there a faster way to do this?
		// concat inverted perhaps?
		if ( m1.a != m2.a )		return false;
		if ( m1.b != m2.b )		return false;
		if ( m1.c != m2.c )		return false;
		if ( m1.d != m2.d )		return false;
		if ( m1.tx != m2.tx )	return false;
		if ( m1.ty != m2.ty )	return false;
		return true;		
	}


	
	
	
	
	
	
	
	public static function getScaleSign( matrix:Matrix ):Float
	{
		return ( matrix.a * matrix.d < 0 || matrix.b * matrix.c > 0 ) ? -1 : 1;
	}
	
	
	
	
	public static function transpose( matrix:Matrix ):Matrix
	{
		return new Matrix( matrix.a, matrix.c, matrix.b, matrix.d, 0, 0 );
	}
	
	
}


