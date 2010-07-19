package std.io;

import std.math.IEEE754;
import haxe.io.Error;

class BytesInput extends haxe.io.BytesInput
{
	function read_( nbytes : Int ) : Bytes {
		var s = Bytes.alloc(nbytes);
		var p = 0;
		while( nbytes > 0 ) {
			var k = readBytes(s,p,nbytes);
			if( k == 0 ) throw Error.Blocked;
			p += k;
			nbytes -= k;
		}
		return s;
	}

	override public function readString( len : Int ) : String {
		var b = Bytes.alloc(len);
		readFullBytes(b,0,len);
		return b.toString();
	}


	override public function readDouble() : Float {
		return IEEE754.bytesToFloat( read_(8), bigEndian );
	}

	override public function readFloat() : Float {
		return IEEE754.bytesToFloat( read_(4), bigEndian );
	}
}

