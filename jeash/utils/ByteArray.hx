/**
 * Copyright (c) 2010, Jeash contributors.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

package jeash.utils;

import haxe.io.Input;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Eof;
import haxe.io.Error;

import Html5Dom;
import std.math.IEEE754;

class ByteArray {

	var data : Array<Int>;
	var bigEndian : Bool;

	public var bytesAvailable(default,null) : Int;
	public var endian(__GetEndian,__SetEndian) : Endian;
	public var objectEncoding : Int;

	public var position : Int;
	public var length(default,null) : Int;

	function readString( len : Int ) : String {
		var bytes = Bytes.alloc(len);
		readFullBytes(bytes,0,len);
		return bytes.toString();
	}

	function readFullBytes( bytes : Bytes, pos : Int, len : Int ) {
		for ( i in pos...pos+len )
			data[this.position++] = bytes.get(i);
	}

	function read( nbytes : Int ) : Bytes 
	{
		var s = new ByteArray();
		readBytes(s,0,nbytes);
		return Bytes.ofData(s.data);
	}

	public function new() {
		this.position = 0;
		this.length = 0;
		this.data = [];
	}

	public function readByte() : Int 
	{
		if( this.position >= this.length )
			throw new Eof();
		return data[this.position++];
	}

	//public function readBytes( buf : Bytes, pos, len ) : Int 
	public function readBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt)
	{
		if( offset < 0 || length < 0 || offset + length > bytes.length )
			throw Error.OutsideBounds;

		if( this.length == 0 && length > 0 )
			throw new Eof();

		if( this.length < length )
			length = this.length;

		var b1 = data;
		var b2 = bytes;
		b2.position = offset;
		for( i in 0...length )
			b2.writeByte( b1[this.position+i] );

		this.position += length;
	}
	
	public function writeByte(value : Int)
	{
		data[this.position++] = value;
	}

	//override function writeBytes( buf : Bytes, pos, len ) : Int {
	public function writeBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt) 
	{
		if( offset < 0 || length < 0 || offset + length > bytes.length ) throw Error.OutsideBounds;
		var b2 = bytes;
		b2.position = offset;
		for( i in 0...length )
			data[this.position++] = b2.readByte();

	}

	public function readBoolean() 
	{
		return this.readByte() == 1 ? true : false;
	}

	public function writeBoolean(value : Bool) 
	{
		this.writeByte(value?1:0);
	}

	public function readDouble() : Float 
	{
		return IEEE754.bytesToFloat( read(8), endian == Endian.BIG_ENDIAN );
	}

	public function writeDouble(value : Float) 
	{
		var bytes = IEEE754.doubleToBytes( value, endian == Endian.BIG_ENDIAN );
		for ( i in 0...bytes.length )
			data[ this.position++ ] = bytes.get(i);
	}

	public function readFloat() : Float 
	{
		return IEEE754.bytesToFloat( read(4), endian == Endian.BIG_ENDIAN );
	}

	public function writeFloat( value : Float ) 
	{
		var bytes = IEEE754.floatToBytes( value, endian == Endian.BIG_ENDIAN );

		for ( i in 0...bytes.length )
			data[ this.position++ ] = bytes.get(i);
	}

	public function readInt()
	{
		var ch1,ch2,ch3,ch4;
		if( endian == Endian.BIG_ENDIAN ) {
			ch4 = readByte();
			ch3 = readByte();
			ch2 = readByte();
			ch1 = readByte();
		} else {
			ch1 = readByte();
			ch2 = readByte();
			ch3 = readByte();
			ch4 = readByte();
		}
		return ch1 | (ch2 << 8) | (ch3 << 16) | (ch4 << 24);
	}

	public function writeInt(value : Int)
	{
		if( endian == Endian.BIG_ENDIAN ) {
			writeByte(value >>> 24);
			writeByte((value >> 16) & 0xFF);
			writeByte((value >> 8) & 0xFF);
			writeByte(value & 0xFF);
		} else {
			writeByte(value & 0xFF);
			writeByte((value >> 8) & 0xFF);
			writeByte((value >> 16) & 0xFF);
			writeByte(value >>> 24);
		}
	}

	public function readShort()
	{
		var ch1 = readByte();
		var ch2 = readByte();
		var n = endian == Endian.BIG_ENDIAN ? ch2 | (ch1 << 8) : ch1 | (ch2 << 8);
		if( n & 0x8000 != 0 )
			return n - 0x10000;
		return n;
	}

	public function writeShort(value : Int)
	{
		if( value < -0x8000 || value >= 0x8000 ) throw Error.Overflow;
		writeUnsignedShort(value & 0xFFFF);
	}

	public function writeUnsignedShort( value : Int ) 
	{
		if( value < 0 || value >= 0x10000 ) throw Error.Overflow;
		if( endian == Endian.BIG_ENDIAN ) {
			writeByte(value >> 8);
			writeByte(value & 0xFF);
		} else {
			writeByte(value & 0xFF);
			writeByte(value >> 8);
		}
	}

	public function readUTF()
	{
		var bytes = Bytes.ofData( data );
		return bytes.toString();
	}

	public function writeUTF(value : String)
	{
		var bytes = Bytes.ofString( value );
		for ( i in 0...bytes.length )
			data[this.position++] = bytes.get(i);
	}

	public function writeUTFBytes(value : String)
	{
		writeUTF(value);
	}

	public function readUTFBytes(inLen:Int)
	{
		return readString(inLen);
	}

	public function readUnsignedByte():Int
	{
		return readByte();
	}

	public function readUnsignedShort():Int
	{
		return readShort();
	}

	public function readUnsignedInt():Int
	{
		return readInt();
	}

	public function writeUnsignedInt( value : Int )
	{
		writeInt( value );
	}

	public function __GetEndian() : Endian
	{
		if ( bigEndian == true )
		{
			return Endian.BIG_ENDIAN;
		} else {
			return Endian.LITTLE_ENDIAN;
		}
	}
	public function __SetEndian( endian : Endian ) : Endian
	{
		if ( endian == Endian.BIG_ENDIAN )
		{
			bigEndian = true;
		} else {
			bigEndian = false;
		}

		return endian;
	}
}
