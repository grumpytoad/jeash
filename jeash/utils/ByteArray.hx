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
import haxe.io.BytesBuffer;
import haxe.io.Eof;
import haxe.io.Error;

import Html5Dom;

class ByteArray {

	var data : Array<Int>;
	var bigEndian : Bool;

	public var bytesAvailable(default,null) : Int;
	public var endian(__GetEndian,__SetEndian) : Endian;
	public var objectEncoding : Int;

	public var position : Int;
	public var length(GetLength,null) : Int;

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

	function GetLength()
	{
		return data.length;
	}

	public function new() {
		this.position = 0;
		this.data = [];
	}

	public function readByte() : Int 
	{
		if( this.position >= this.length )
			throw new Eof();
		return data[this.position++];
	}

	public function readBytes(bytes : ByteArray, ?offset : UInt, ?length : UInt)
	{
		if( offset < 0 || length < 0 || offset + length > data.length )
			throw Error.OutsideBounds;

		if( data.length == 0 && length > 0 )
			throw new Eof();

		if( data.length < length )
			length = data.length;

		var b1 = data;
		var b2 = bytes;
		b2.position = offset;
		for( i in 0...length )
			b2.writeByte( b1[this.position+i] );
		b2.position = offset;

		this.position += length;
	}
	
	public function writeByte(value : Int)
	{
		data[this.position++] = value;
	}

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
		if( bigEndian ) {
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
		if( bigEndian ) 
		{
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
		var n = bigEndian ? ch2 | (ch1 << 8) : ch1 | (ch2 << 8);
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
		var len = readShort();

		var bytes = Bytes.ofData( data );
		return bytes.readString( 2, len );
	}

	public function writeUTF(value : String)
	{
		var bytes = Bytes.ofString( value );
		writeShort( bytes.length );
		for ( i in 0...bytes.length )
			data[this.position++] = bytes.get(i);
	}

	public function writeUTFBytes(value : String)
	{
		var bytes = Bytes.ofString( value );
		for ( i in 0...bytes.length )
			data[this.position++] = bytes.get(i);
	}

	public function readUTFBytes(len:Int)
	{
		var bytes = Bytes.ofData( data );
		return bytes.readString( 0, len );
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

/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir, based on code originally by Quanfei Wan
 * Contributors: Niel Drummond
 * All rights reserved.
 */

private enum Status {
	Normal;
	Overflow;
	Underflow;
	Denormalized;
	Quiet;
	Signalling;
}

private class IEEE754 {
	inline static var bias = 1024;
	inline static var cnst = 2102;

	var bigEndian(default,setEndian) : Bool;
	var input : Float;

	var rounding : Bool;
	var Size : Int;
	var BinaryPower : Int;
	var BinVal : Array<Int>;

	var ExpBias : Int;
	var MaxExp : Int;
	var MinExp : Int;
	var MinUnnormExp : Int;
	var Result : Array<Int>;

	var StatCond : Status;
	var StatCond64 : Status;

	function new(size : Int) {
		this.Size = size;
		this.BinaryPower = 0;

		this.StatCond = Normal;
		this.StatCond64 = Normal;
		if (this.Size == 32) {
			this.ExpBias = 127;
			this.MaxExp = 127;
			this.MinExp = -126;
			this.MinUnnormExp = -149;
		}
		else {
			this.Size = 64;
			this.ExpBias = 1023;
			this.MaxExp = 1023;
			this.MinExp = -1022;
			this.MinUnnormExp = -1074;
		}

	}

	function setEndian( b ) {
		bigEndian = b;
		return b;
	}

	function initBuffers() {
		this.BinVal = new Array();
		for(i in 0 ... cnst)
			this.BinVal[i] = 0;

		this.Result = new Array();
		for(i in 0...this.Size)
			this.Result[i] = 0;
	}

	function littleToBigEndian(inbuf : Bytes) {
		var c : Int = if(Size==32) 4; else 8;
		var nb = Bytes.alloc(c);
		var idx = c - 1;
		for(i in 0...c) {
			nb.set(idx, inbuf.get(i));
			idx--;
		}
		return nb;
	}

	function bufToEndian(inbuf : Bytes) {
		var rv = inbuf;
		if(!bigEndian)
			rv = littleToBigEndian(rv);
		return rv;
	}

	function infinity(negative:Bool) {
		if(negative) {
			var bb = new BytesBuffer();
			var cnt = 2;
			if(this.Size == 32) {
				bb.addByte(0xFF);
				bb.addByte(0x80);
			}
			else {
				bb.addByte(0xFF);
				bb.addByte(0xF0);
				cnt = 6;
			}
			for(i in 0...cnt)
				bb.addByte(0x00);
			return bufToEndian(bb.getBytes());
		}
		else {
			var bb = new BytesBuffer();
			var cnt = 2;
			if(this.Size == 32) {
				bb.addByte(0x7F);
				bb.addByte(0x80);
			}
			else {
				bb.addByte(0x7F);
				bb.addByte(0xF0);
				cnt = 6;
			}
			for(i in 0...cnt)
				bb.addByte(0x00);
			return bufToEndian(bb.getBytes());
		}
	}




	///////////////////////////////////////////
	//           BYTES -> Float              //
	///////////////////////////////////////////
	function convert(v : Float) : Bytes
	{
		this.input = v;
		this.StatCond = Normal;
		this.StatCond64 = Normal;
		if(input == Math.POSITIVE_INFINITY) {
			return infinity(false);
		}
		else if(input == Math.NEGATIVE_INFINITY) {
			return infinity(true);
		}
		else if(Math.isNaN(input)) {
			var bb = new BytesBuffer();
			var cnt = 2;
			if(this.Size == 32) {
				bb.addByte(0xFF);
				bb.addByte(0xC0);
			}
			else {
				bb.addByte(0xFF);
				bb.addByte(0xF8);
				cnt = 6;
			}
			for(i in 0...cnt)
				bb.addByte(0x00);
			return bufToEndian(bb.getBytes());
		}

		this.BinaryPower = 0;
		var binexpnt = 0;

		initBuffers();

		this.Result[0] = 0;
		if(input < 0)
			this.Result[0] = 1;


		//convert and seperate input to integer and decimal parts
		var value = Math.abs(input);
		var vp = splitFloat(value);
		var intpart = vp.integral;
		var decpart = vp.decimal;

		//convert integer part
		var index1 = bias;
		while ((intpart / 2.0 != 0.0) && (index1 >= 0))
		{
			var fip = intpart;
			while(fip > 2147483647.0)
				fip /= 10.0;
			var mod = Std.int(fip) % 2;
			this.BinVal[index1] = mod;
			if (mod == 0)
				intpart = intpart / 2.0;
			else
				intpart = intpart / 2.0 - 0.5;
			intpart = splitFloat(intpart * 10.0).integral/10.0;
			index1--;
		}

		//convert decimal part
		index1 = bias + 1;
		while ((decpart > 0.0) && (index1 < cnst))
		{
			decpart *= 2;
			if (decpart >= 1.0) {
				this.BinVal[index1] = 1;
				decpart--;
				index1++;
			}
			else { this.BinVal[index1] = 0; index1++; }
		}

		//obtain exponent value
		index1 = 0;
		while ((index1 < cnst) && (this.BinVal[index1] != 1))
			index1++;
		this.BinaryPower = bias - index1;

		if (this.BinaryPower < this.MinExp)
		{
			this.BinaryPower = this.MinExp - 1;
		}
		return Convert2Bin();

	}


	function Convert2Bin() {
		var power = this.BinaryPower;
		var lastbit = 0;
		var rounded = 0;
		var binexpnt : Int = 0;
		var binexpnt2 = 0;

		var index1 = 0;
		var index2 : Int = if (this.Size == 32) 9 else 12;
		var index3 = 0;

		if (rounding && StatCond64 == Normal)
		{
			while ((index1 < cnst) && (this.BinVal[index1] != 1))
				index1++;

			binexpnt = bias - index1;

			if (binexpnt >= this.MinExp)
				index1++;
			else {
				binexpnt = this.MinExp - 1;
				index1 = bias - binexpnt;
			}

			lastbit = this.Size - 1 - index2 + index1;

			if (this.BinVal[lastbit + 1] == 1)
			{
				rounded = 0;

				if (this.BinVal[lastbit] == 1)
					rounded = 1;
				else  
				{
					index3 = lastbit + 2;
					while ((rounded == 0) && (index3 < cnst))
					{
						rounded = this.BinVal[index3];
						index3++;
					}

				}

				index3 = lastbit;
				while ((rounded == 1) && (index3 >= 0))
				{
					if (this.BinVal[index3] == 0)
					{
						this.BinVal[index3] = 1;
						rounded = 0;
					}

					else
					{
						this.BinVal[index3] = 0;
					}
					index3--;
				}
			}
			index1 = index1 - 2;
			if (index1 < 0) index1 = 0;
		}

		while ((index1 < cnst) && (this.BinVal[index1] != 1))
			index1++;
		binexpnt2 = bias - index1;

		if(StatCond64 == Normal) {
			binexpnt = binexpnt2;
			if ((binexpnt >= this.MinExp) && (binexpnt <= this.MaxExp))
				index1++;
			else if (binexpnt < this.MinExp) {
				if (binexpnt2 == bias - cnst) {
					//value is truely zero
					this.StatCond = Normal;
				} else if (binexpnt2 < this.MinUnnormExp)
					this.StatCond = Underflow;
				else
					this.StatCond = Denormalized;
				binexpnt = this.MinExp - 1;
				index1 = bias - binexpnt;
			}
		}
		else
		{
			binexpnt = power;
			index1 = bias - binexpnt;
			if (binexpnt > this.MaxExp)
				binexpnt = this.MaxExp + 1;
			else if (binexpnt < this.MinExp)
				binexpnt = this.MinExp - 1;
		}

		while ((index2 < this.Size) && (index1 < cnst))
		{
			this.Result[index2] = this.BinVal[index1];
			index2++;
			index1++;
		}

		if (binexpnt > this.MaxExp || this.StatCond64 != Normal) {
			if(StatCond64 == Normal) {
				return infinity(this.Result[0] == 1);
			}
			else {
				this.StatCond = this.StatCond64;
			}
		}

		if (this.Size == 32) index1 = 8;
		else index1 = 11;
		this.BinaryPower = binexpnt;
		binexpnt += this.ExpBias;
		var fbxp : Float = binexpnt * 1.0;
		while ((fbxp / 2.0) != 0.0)
		{
			var mod = Std.int(fbxp) % 2;
			this.Result[index1] = mod;
			if (mod == 0)
				fbxp = fbxp / 2.0;
			else
				fbxp = fbxp / 2.0 - 0.5;
			index1--;
			fbxp = splitFloat(fbxp * 10.0).integral/10.0;
		}
		binexpnt = Std.int(fbxp);
		return toBytes();
	}

	public function toBytes() {
		var c : Int = if(Size==32) 4; else 8;
		var out = Bytes.alloc(c);
		var index = 0;
		var pos = 0;
		while(index < this.Size)
		{
			var temp = 0;
			var v = 0;
			for(i in 0...4)
				temp += Std.int(Math.pow(2, 3 - i)) * this.Result[index + i];
			v = temp << 4;
			temp = 0;
			index += 4;
			for(i in 0...4)
				temp += Std.int(Math.pow(2, 3 - i)) * this.Result[index + i];
			v = v | temp;
			out.set(pos++,v);
			index += 4;
		}
		if(!bigEndian) {
			var out2 = Bytes.alloc(c);
			var idx = c - 1;
			for(i in 0...c) {
				out2.set(idx, out.get(i));
				idx--;
			}
			out = out2;
		}
		return out;
	}


	///////////////////////////////////////////
	//           BYTES -> Float              //
	///////////////////////////////////////////
	/**
	  This method must receive a bigEndian buffer
	 **/
	function bytesToBin(b : Bytes) {
		initBuffers();
		var index1 = 0;
		var p = 0;

		var me = this;
		var store = function (temp : Float, idx) {
			for(i in 0...4) {
				temp *= 2.0;
				if (temp >= 1.0)
				{
					me.Result[idx + i] = 1;
					temp -= 1;
				}
				else
					me.Result[idx + i] = 0;
			}
		}
		while(index1 < this.Size)
		{
			var nibble = (b.get(p) & 0xF0) >> 4;
			store(nibble / 16, index1);
			index1 += 4;
			var nibble = (b.get(p) & 0x0F);
			store(nibble / 16, index1);
			index1 += 4;
			p++;
		}


		var binexpnt = 0;
		var index2 = if(this.Size == 32) { 9; } else { 12;}
		for( i in 1...index2)
			binexpnt += Std.int(this.Result[i] * Math.pow(2, index2 - i - 1));

		binexpnt -= this.ExpBias;
		this.BinaryPower = binexpnt;

		index1 = bias - binexpnt;

		if ((binexpnt >= this.MinExp) && (binexpnt <= this.MaxExp))
		{
			this.BinVal[index1] = 1;
			index1++;
		}

		var index3 = index1;

		var zeroFirst : Bool = false;
		if (this.Result[index2] == 0)
			zeroFirst = true;
		this.BinVal[index1] = this.Result[index2];
		index2++;
		index1++;

		var zeroRest : Bool = true;
		while ((index2 < this.Size) && (index1 < cnst))
		{
			if (this.Result[index2] == 1)
				zeroRest = false;
			this.BinVal[index1] = this.Result[index2];
			index2++;
			index1++;
		}

		while ((index3 < cnst) && (this.BinVal[index3] != 1))
			index3++;
		var binexpnt2 = bias - index3;

		if (binexpnt < this.MinExp)
		{
			if (binexpnt2 == bias - cnst)
				//value is truely zero
				this.StatCond = Normal;
			else if (binexpnt2 < this.MinUnnormExp)
				this.StatCond = Underflow;
			else
				this.StatCond = Denormalized;
		}

		else if (binexpnt > this.MaxExp)
		{
			if (zeroFirst && zeroRest)
			{
				//Infinity
				this.StatCond = Overflow;
				if(Result[0] == 1)
					return Math.NEGATIVE_INFINITY;
				else
					return Math.POSITIVE_INFINITY;
			}
			else if (!zeroFirst && zeroRest && (this.Result[0] == 1))
				this.StatCond = Quiet;
			else if (!zeroFirst)
				this.StatCond = Quiet;
			else
				this.StatCond = Signalling;
			return Math.NaN;
		}

		return Convert2Dec();
	}

	function Convert2Dec()
	{
		var LN10 = Math.log(10);
		var s = if (this.Size == 32) { 9; } else { 12; }
		var dp : Int = 0;
		var val : Float = 0.0;

		if ((this.BinaryPower < this.MinExp) || (this.BinaryPower > this.MaxExp))
		{
			dp = 0;
			val = 0;
		}
		else
		{
			dp = -1;
			val = 1;
		}

		var foo = [];
		for (i in s...this.Size)
		{
			val += Std.int(this.Result[i])*Math.pow(2, dp + s - i);
			foo.push( val );
		}

		var decValue : Float = val * Math.pow(2, this.BinaryPower);

		/* NOTE: commented out due to invalid results in TestIO.hx,
		   may need to revisit later.
		   if (this.Size == 32)
		   {
		   s = 8;
		   if (val > 0)
		   {
		   var power = Math.floor( Math.log(decValue) / LN10 );
		   decValue += 0.5 * Math.pow(10, power - s + 1);
		   val += 5E-8;
		   }
		   }
		   else s = 17;
		 */
		s = 17;

		if (this.Result[0] == 1)
		{
			decValue = - decValue;
		}
		decValue = Std.parseFloat(numStrClipOff(Std.string(decValue),s));
		return decValue;
	}

	function numStrClipOff(input : String, precision : Int)
	{
		var result = "";
		var numerals = "0123456789";
		var tempstr = input.toUpperCase();
		var expstr = "";
		var signstr = "";

		var stop : Int = 0;
		var expnum : Int = 0;

		var locE = tempstr.indexOf("E");
		if (locE != -1)
		{
			stop = locE;
			expstr = input.substr(locE + 1, input.length);
			expnum = Std.parseInt(expstr);
		}
		else
		{
			stop = input.length;
			expnum = 0;
		}

		if (input.indexOf(".") == -1)
		{
			tempstr = input.substr(0, stop);
			tempstr += ".";
			if (input.length != stop)
				tempstr += input.substr(locE, input.length);

			input = tempstr;

			locE = locE + 1;
			stop = stop + 1;
		}

		var locDP = input.indexOf(".");

		var start = 0;
		if (input.charAt(start) == "-")
		{
			start++;
			signstr = "-";
		}
		else
			signstr = "";

		var MSD = start;
		var MSDfound = false;
		while ((MSD < stop) && !MSDfound)
		{
			var index = 1;
			while (index < numerals.length)
			{
				if (input.charAt(MSD) == numerals.charAt(index))
				{
					MSDfound = true;
					break;
				}
				index++;
			}
			MSD++;
		}
		MSD--;

		var expdelta : Int = 0;
		if (MSDfound)
		{
			expdelta = locDP - MSD;
			if (expdelta > 0)
				expdelta = expdelta - 1;

			expnum = expnum + expdelta;

			expstr = "e" + expnum;
		}
		else  //No significant digits found, value is zero
			MSD = start;

		var digits = stop - MSD;

		tempstr = input.substr(MSD, stop);

		if (tempstr.indexOf(".") != -1)
			digits = digits - 1;

		var number = digits;
		if (precision < digits)
			number = precision;

		tempstr = input.substr(MSD, MSD + number + 1);

		if ( (MSD != start) || (tempstr.indexOf(".") == -1) )
		{
			result = signstr;
			result += input.substr(MSD, MSD + 1);
			result += ".";
			result += input.substr(MSD + 1, MSD + number);

			while (digits < precision)
			{
				result += "0";
				digits += 1;
			}

			result += expstr;
		}
		else
		{
			result = input.substr(0, start + number + 1);

			while (digits < precision)
			{
				result += "0";
				digits += 1;
			}

			if (input.length != stop)
				result += input.substr(locE, input.length);
		}

		return result;
	}


	///////////////////////////////////////////
	//           Static Methods              //
	///////////////////////////////////////////

	/**
	  Convert haxe Float to 4 byte float type
	 **/
	public static function floatToBytes(v : Float, ?bigEndian = false) : Bytes {
		var ieee = new IEEE754(32);
		ieee.bigEndian = bigEndian;
		ieee.rounding = true;
		return ieee.convert(v);
	}

	/**
	  Convert haxe Float to 8 byte double type
	 **/
	public static function doubleToBytes(v : Float, ?bigEndian = false) : Bytes {
		var ieee = new IEEE754(64);
		ieee.bigEndian = bigEndian;
		ieee.rounding = true;
		return ieee.convert(v);
	}

	/**
	  Read haxe Float from 4 or 8 byte buffer
	 **/
	public static function bytesToFloat(b : Bytes, ?bigEndian = false) {
		if(b.length != 4 && b.length != 8)
			throw "Bytes must be 4 or 8 bytes long";
		var size = if(b.length == 4) { 32; } else { 64; }
		var ieee = new IEEE754(size);
		ieee.bigEndian = bigEndian;
		ieee.rounding = true;
		if(!bigEndian)
			return ieee.bytesToBin(ieee.littleToBigEndian(b));
		else
			return ieee.bytesToBin(b);
	}

	/**
	  Splits a float into it's Math.floor and decimal portions. Loss of
	  precision results from using Std.string on the supplied value.
	 **/
	public static function splitFloat(v:Float) : { integral :Float, decimal : Float} {
		var rv = {
integral : 0.0,
	   decimal : 0.0
		};
		var val = Std.string(v).toLowerCase();
		var p = val.indexOf("e");
		var exp = 0;
		if(p >= 0) {
			exp = Std.parseInt(val.substr(p+1));
		} else {
			p = val.indexOf(".");
			if(p >= 0) {
				rv.integral = Std.parseFloat(val.substr(0, p));
				rv.decimal = Std.parseFloat("0." + val.substr(p+1));
			}
			else
				rv.integral = Std.parseFloat(val);
			return rv;
		}
		var fp : String = val.substr(0,p);
		p = fp.indexOf(".");
		fp = StringTools.replace(fp,".","");
		var dp : String = "0.";
		if(exp > 0) {
			p += exp;
			if(p == fp.length) {
				rv.integral = Std.parseFloat(fp);
			}
			else if(p > fp.length) {
				rv.integral = v;
			}
			else {
				rv.integral = Std.parseFloat(fp.substr(0,p));
				rv.decimal = Std.parseFloat("0." + fp.substr(p+1));
			}
		} else {
			exp += p;
			if(exp == 0) {
				rv.decimal = Std.parseFloat("0." + fp);
			}
			else if(exp < 0) {
				rv.decimal = Std.parseFloat("0." + fp + "e" + Std.string(exp));
			}
			else {
				rv.integral = Std.parseFloat(fp.substr(0,exp));
				rv.decimal = Std.parseFloat("0." + fp.substr(exp));
			}
		}
		return rv;
	}
}

