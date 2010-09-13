/*
 * hexagonlib - Multi-Purpose ActionScript 3 Library.
 *       __    __
 *    __/  \__/  \__    __
 *   /  \__/HEXAGON \__/  \
 *   \__/  \__/  LIBRARY _/
 *            \__/  \__/
 *
 * Licensed under the MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.hexagonstar.io.file.types
{

	import com.hexagonstar.util.MathUtil;

	import flash.utils.ByteArray;
	
	/**
	 * A zip entry represents a file that is contained inside a zip file. It is not
	 * loaded manually by adding it to a BulkLoader. Instead a zip file can be loaded
	 * with a BulkLoader and then zip entry objects can be obtained from the loaded
	 * zip file.
	 */
	public class ZipEntry
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _path:String;
		private var _data:ByteArray;
		private var _zipFile:ZipFile;
		
		private var _size:uint;
		private var _compressedSize:uint;
		private var _crc:uint;
		private var _method:int;
		private var _extra:ByteArray;
		private var _comment:String;
		
		/* The following flags are used only by Zip Generator */
		public var dostime:uint;
		public var flag:uint;			// bit flags
		public var version:uint;		// version needed to extract
		public var offset:uint;			// offset of loc header
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance.
		 * 
		 * @param path The path of the zip entry.
		 * @param data Content data of the zip entry. Only needs to be set if this
		 *        file is created manually. For any zip entry that is fetched from a
		 *        loaded zip file the zip file will care about providing the data.
		 * @param zipFile A reference to the zip file to which this file belongs.
		 */
		public function ZipEntry(path:String, data:ByteArray = null, zipFile:ZipFile = null)
		{
			_path = path;
			_data = data;
			_zipFile = zipFile;
			
			_size = NaN;
			_compressedSize = NaN;
			_method = -1;
			dostime = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Path of the zipped file.
		 */
		public function get path():String
		{
			return _path;
		}
		
		
		/**
		 * The time of last modification of the entry, or -1 if unknown.
		 */
		public function get time():Number
		{
			var d:Date = new Date(((dostime >> 25) & 0x7f) + 1980, ((dostime >> 21) & 0x0f) - 1,
				(dostime >> 16) & 0x1f, (dostime >> 11) & 0x1f, (dostime >> 5) & 0x3f,
				(dostime & 0x1f) << 1);
			return d.time;
		}
		public function set time(v:Number):void
		{
			var d:Date = new Date(v);
			dostime = (d.fullYear - 1980 & 0x7f) << 25 | (d.month + 1) << 21 | d.day << 16
				| d.hours << 11 | d.minutes << 5 | d.seconds >> 1;
		}
		
		
		/**
		 * Size of the uncompressed data.
		 */
		public function get size():uint
		{
			return _size;
		}
		public function set size(v:uint):void
		{
			_size = v;
		}
		
		
		/**
		 * The size of the compressed data.
		 */
		public function get compressedSize():uint
		{
			return _compressedSize;
		}
		public function set compressedSize(v:uint):void
		{
			_compressedSize = v;
		}
		
		
		/**
		 * The compression ratio in percent.
		 * TODO change ratio to return the inverted % value.
		 */
		public function get ratio():Number
		{
			if (isDirectory) return 0;
			if (_compressedSize + _size == 0) return 0;
			return MathUtil.round((_compressedSize / _size) * 100, 1);
		}
		
		
		/**
		 * The CRC of the uncompressed data.
		 */
		public function get crc32():uint
		{
			return _crc;
		}
		public function set crc32(v:uint):void
		{
			_crc = v;
		}
		
		
		/**
		 * Convenience getter to return the CRC checksum as a hexadecimal string.
		 */
		public function get crc32hex():String
		{
			return _crc.toString(16).toUpperCase();
		}
		
		
		/**
		 * The compression method. Only DEFLATED and STORED are supported.
		 */
		public function get compressionMethod():int
		{
			return _method;
		}
		public function set compressionMethod(v:int):void
		{
			_method = v;
		}
		
		
		/**
		 * The extra data.
		 */
		public function get extra():ByteArray
		{
			return _extra;
		}
		public function set extra(v:ByteArray):void
		{
			_extra = v;
		}
		
		
		/**
		 * The comment data.
		 */
		public function get comment():String
		{
			return _comment;
		}
		public function set comment(v:String):void
		{
			_comment = v;
		}
		
		
		/**
		 * The content of the zipped file.
		 */
		public function get data():ByteArray
		{
			/* ZippedFile has it's own data */
			if (_data) return _data;
			/* ZippedFile is loaded from zip file and it's data is stored in ZipFile */
			if (_zipFile) return _zipFile.getData(_path);
			return null;
		}
		
		
		/**
		 * True, if the entry is a directory. This is solely determined by the name,
		 * a trailing slash '/' marks a directory.
		 */
		public function get isDirectory():Boolean
		{
			return _path.charAt(_path.length - 1) == "/";
		}
	}
}
