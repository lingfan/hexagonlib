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

	import com.hexagonstar.algo.compr.Inflate;
	import com.hexagonstar.data.constants.Status;
	import com.hexagonstar.data.constants.ZipConstants;
	import com.hexagonstar.display.text.ColumnText;
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.FileTypes;
	import com.hexagonstar.util.MathUtil;
	import com.hexagonstar.util.NumberUtil;

	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	/**
	 * The ZipFile represents an archive of compressed files. It can be used to
	 * load a Zip file into memory and unpack it's contents or to create a Zip
	 * file object to which data is added and compressed so it can later be stored
	 * to disk.
	 * 
	 * However this class does not allow to use the same instance for both loading
	 * and creation of Zip files, i.e. you cannot load a Zip file from disk and
	 * then add new data to it. You have to use two different ZipFile instances
	 * for this.
	 * 
	 * Limitations:
	 * - No Encyption support
	 * - Standard character file paths only
	 * - Deflate and Store methods only
	 */
	public class ZipFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _fileList:Array;
		private var _fileTable:Dictionary;
		private var _locOffsetTable:Dictionary;
		private var _fileCount:uint;
		private var _hasLoadedData:Boolean;
		
		private var _generator:ZipGenerator;
		private var _autoCompression:Boolean;
		private var _comment:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param path The path of the file that this File object is used for.
		 * @param id An optional ID for the file.
		 * @param priority Optional load priority for the file. Used for loading
		 *        with the BulkLoader class.
		 * @param weight Optional weight for the file. Used for weighted loading
		 *        with the BulkLoader class.
		 * @param comment Optional text used as the Zip file's comment, only used
		 *        for zip generation.
		 */
		public function ZipFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1, comment:String = null)
		{
			super(path, id, priority, weight);
			
			_comment = comment;
			
			_content = new ByteArray();
			_content.endian = Endian.LITTLE_ENDIAN;
			
			_fileList = [];
			_fileTable = new Dictionary();
			_locOffsetTable = new Dictionary();
			_hasLoadedData = false;
			
			_autoCompression = true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * <p>Gets the file that is contained in the zip file under the specified path
		 * as an instance of IFile. Use this method to quickly obtain a resource
		 * from the zip file in it's correctly typed IFile implementing class.</p>
		 * 
		 * The type of the resulting file is determined by the file extension of
		 * the file's path (see FileTypes class for a list of default extensions).
		 * The resulting file contains the unpacked data from the zipped file that
		 * is stored under the path in the zip file.
		 * 
		 * If the specified path is not found in the zip file or the specified path's
		 * entry is a directory then false is returned. If the path was found in the
		 * zip file but it's extension is not known a BinaryFile is created by default.
		 * 
		 * This method returns an instance of type IFile. However as it cannot be
		 * assured that the file's data is fully loaded after the method returns you
		 * should instead listen to the FileIOEvent.COMPLETE event broadcasted by this
		 * class which is fired after the file has been fully loaded. The event then
		 * contains a reference to the loaded file.
		 * 
		 * @see com.hexagonstar.io.file.FileTypes
		 * 
		 * @param path The path of a file stored inside the zip file of which a
		 *        new instance of type IFile should be loaded.
		 * @return An instance of type IFile or null.
		 */
		public function getFile(path:String):IFile
		{
			var e:ZipEntry = getEntry(path);
			if (!e || e.isDirectory) return null;
			
			var f:IFile;
			var ext:String = path.substring(path.lastIndexOf(".") + 1).toLowerCase();
			var clazz:Class = FileTypes.getFileClass(ext);
			if (!clazz) clazz = BinaryFile;
			
			try
			{
				f = new clazz(path);
			}
			catch (err:Error)
			{
				error("getFile: Error trying to instantiate file class (" + err.message + ").");
				return null;
			}
			
			if (f)
			{
				f.size = e.size;
				f.addEventListener(Event.COMPLETE, onFileReady);
				f.contentAsBytes = getData(path);
			}
			
			return f;
		}
		
		
		/**
		 * Gets a ByteArray with the uncompressed data from the file that is stored
		 * in the ZipFile under the specified path.
		 * 
		 * @param path The path of a file stored inside the zip file from which the
		 *        uncompressed data should be obtained.
		 * @return A byte array, or null if the requested file does not exist.
		 */
		public function getData(path:String):ByteArray
		{
			var e:ZipEntry = getEntry(path);
			if (!e || e.isDirectory) return null;
			
			/* Extra field for local file header may not match one in central directory header */
			_content.position = _locOffsetTable[e.path] + ZipConstants.LOCHDR - 2;
			
			/* Extra length */
			var len:uint = _content.readShort();
			_content.position += e.path.length + len;
			var b1:ByteArray = new ByteArray();
			
			/* Read compressed data */
			if (e.compressedSize > 0)
			{
				_content.readBytes(b1, 0, e.compressedSize);
			}
			
			switch (e.compressionMethod)
			{
				case ZipConstants.STORE:
					return b1;
					break;
				case ZipConstants.DEFLATE:
					var b2:ByteArray = new ByteArray();
					new Inflate().process(b1, b2);
					return b2;
					break;
				default:
					error("getData: The compression method used by the zip entry <"
						+ e.path + "> is not supported. The zip file class only"
						+ " supports STORE and DEFLATE compression methods.");
			}
			
			return null;
		}
		
		
		/**
		 * Returns the zip entry that is stored in the zip file under the specified
		 * path. If there is no entry stored under the path null is returned instead.
		 * 
		 * @see com.hexagonstar.io.file.types.ZipEntry
		 * 
		 * @param path The path of the zip entry. May contain directory components
		 *        separated by slashes ("/").
		 * @return The zip entry, or null if no entry with that path exists in the zip.
		 */
		public function getEntry(path:String):ZipEntry
		{
			return _fileTable[path];
		}
		
		
		/**
		 * Adds a new file entry for storing inside the ZipFile. This operation adds
		 * a newly created ZippedFile instance with the specified path and data to
		 * the ZipFile. Note that this operation only works on a fresh ZipFile instance
		 * into that no data has been loaded before.
		 * 
		 * @param path The path under which to store the file data inside the ZipFile.
		 * @param data The file data to be compressed and/or stored.
		 * @return true if file entry was added successful, false if not.
		 */
		public function addFile(path:String, data:ByteArray):Boolean
		{
			return addEntry(new ZipEntry(path, data, this));
		}
		
		
		/**
		 * Adds an empty folder to the ZipFile.
		 */
		public function addFolder(path:String):Boolean
		{
			if (path.charAt(_path.length - 1) != "/") path += "/";
			return addEntry(new ZipEntry(path, null, this));
		}
		
		
		/**
		 * Adds a new file entry for storing inside the zip file provided by the
		 * specified file. This operation should be used to quickly copy a zip entry
		 * object from one zip file to a new zip file since no data is contained
		 * in a zip entry object which was not obtained from a zip file. For creating
		 * completely fresh zip files with new data use the addFile method.
		 * 
		 * @param file The ZippedFile to add to the ZipFile.
		 * @return true if file entry was added successful, false if not.
		 */
		public function addEntry(file:ZipEntry):Boolean
		{
			/* No go if we already got content loaded from a file (would mean we
			 * have to store the central dir buffer separately and attach it back
			 * on anytime a file is added which is possible but I don't feel like
			 * that today! */
			if (_hasLoadedData || (_generator && _generator.finalized))
			{
				return false;
			}
			
			/* Only instantiate when first needed */
			if (!_generator)
			{
				_generator = new ZipGenerator(this, _content, _fileList, _autoCompression);
			}
			
			return _generator.addEntry(file);
		}
		
		
		/**
		 * Finalizes the ZipFile if file entries were added manually. Call this
		 * method after all file entries were added to generate the Zip's central
		 * directory. After calling this method yuo cannot add any more entries.
		 */
		public function finalize():void
		{
			if (_hasLoadedData || _fileList.length < 1) return;
			if (!_generator) return;
			if (_generator.finalized) return;

			_generator.finalize(_comment);
		}
		
		
		/**
		 * Generates a formatted string output of the zip file's content list.
		 * 
		 * @param colMaxLength Max. length of a text column in the resulting string.
		 * @return A string dump of the zip's contents.
		 */
		public function dump(colMaxLength:int = 40):String
		{
			var ct:ColumnText = new ColumnText(5, false, null, null, null, colMaxLength,
				["PATH", "SIZE", "PACKED", "RATIO", "CRC32"]);
			for (var i:int = 0; i < _fileList.length; i++)
			{
				var f:ZipEntry = _fileList[i];
				var r:Number = f.ratio;
				var p:String = r + (NumberUtil.isInteger(r) ? ".0" : "") + "%";
				ct.add([f.path, f.size, f.compressedSize, p, f.crc32hex]);
			}
			return ct.toString();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.ZIP_FILE_ID;
		}
		
		
		/**
		 * An array of ZipEntry objects with all zip entries contained in this zip file.
		 */
		public function get entries():Array
		{
			return _fileList;
		}
		
		
		/**
		 * The number of zipped files in this zip file. This does not include folders,
		 * Use folderCount to get the amount of folders in the ZipFile.
		 */
		public function get fileCount():int
		{
			var c:int = 0;
			for each (var f:ZipEntry in _fileList)
			{
				if (!f.isDirectory) c++;
			}
			return c;
		}
		
		
		/**
		 * The number of zipped folders in this zip file.
		 */
		public function get folderCount():int
		{
			var c:int = 0;
			for each (var f:ZipEntry in _fileList)
			{
				if (f.isDirectory) c++;
			}
			return c;
		}
		
		
		/**
		 * The uncompressed size of the Zip file.
		 */
		override public function get size():uint
		{
			var s:uint = 0;
			for (var i:int = 0; i < _fileList.length; i++)
			{
				s += ZipEntry(_fileList[i]).size;
			}
			return s;
		}
		override public function set size(v:uint):void
		{
			/* should not be able to set the size, which is
			 * calculated from the zipped files inside it! */
		}
		
		
		/**
		 * The size of the compressed zip file.
		 */
		public function get compressedSize():uint
		{
			return _size;
		}
		public function set compressedSize(v:uint):void
		{
			_size = v;
		}
		
		
		/**
		 * The compression ratio in percent.
		 */
		public function get ratio():Number
		{
			return MathUtil.round((compressedSize / size) * 100, 1);
		}
		
		
		public function get autoCompression():Boolean
		{
			return _autoCompression;
		}
		public function set autoCompression(v:Boolean):void
		{
			_autoCompression = v;
		}
		
		
		/**
		 * @inheritDoc
		 * Used only by Loader to set loaded zip data!
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			try
			{
				_content.writeBytes(v);
				_content.position = 0;
				_valid = true;
				_status = Status.OK;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
			
			if (_valid)
			{
				/* Process compressed content */
				_hasLoadedData = true;
				readCEN();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onFileReady(e:Event):void
		{
			var f:IFile = IFile(e.target);
			f.removeEventListener(Event.COMPLETE, onFileReady);
			dispatchEvent(new FileIOEvent(FileIOEvent.COMPLETE, f));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Reads the central directory of a zip file and fills the zippedFiles array.
		 * This is called exactly once when first needed.
		 * 
		 * @private
		 * @return true if successful, false if errors occured.
		 */
		private function readCEN():Boolean
		{
			readEND();
			
			/* Debug */
			//var pos:Number = _content.position;
			//var t:ByteArray = new ByteArray();
			//t.endian = Endian.LITTLE_ENDIAN;
			//_content.readBytes(t, 0, ZipFile.CENHDR);
			//_content.position = pos;
			//Debug.hexDump(t);
			
			for (var i:int = 0; i < _fileCount; i++)
			{
				var tmp:ByteArray = new ByteArray();
				tmp.endian = Endian.LITTLE_ENDIAN;
				_content.readBytes(tmp, 0, ZipConstants.CENHDR);
				
				var sig:uint = tmp.readUnsignedInt();
				if (sig != ZipConstants.CENSIG)
				{
					error("readCENEntries: Invalid CEN header (bad signature: 0x"
						+ sig.toString(16) + ").");
					return false;
				}
				
				/* Handle filename */
				tmp.position = ZipConstants.CENNAM;
				
				var len:uint = tmp.readUnsignedShort();
				if (len == 0)
				{
					error("readCENEntries: Missing zipped file path.");
					return false;
				}
				
				var e:ZipEntry = new ZipEntry(_content.readUTFBytes(len), null, this);
				
				/* Handle extra field */
				len = tmp.readUnsignedShort();
				e.extra = new ByteArray();
				
				/* Handle file comment */
				if (len > 0) _content.readBytes(e.extra, 0, len);
				_content.position += tmp.readUnsignedShort();
				
				/* Now get the remaining fields for the entry */
				tmp.position = ZipConstants.CENVER;
				e.version = tmp.readUnsignedShort();
				e.flag = tmp.readUnsignedShort();
				if ((e.flag & 1) == 1)
				{
					error("readCENEntries: Encrypted zip entry not supported.");
					return false;
				}
				e.compressionMethod = tmp.readUnsignedShort();
				e.dostime = tmp.readUnsignedInt();
				e.crc32 = tmp.readUnsignedInt();
				e.compressedSize = tmp.readUnsignedInt();
				e.size = tmp.readUnsignedInt();
				
				/* Add to file list and table */
				_fileList.push(e);
				_fileTable[e.path] = e;
				
				/* Loc offset */
				tmp.position = ZipConstants.CENOFF;
				_locOffsetTable[e.path] = tmp.readUnsignedInt();
			}
			return true;
		}
		
		
		/**
		 * Reads the total number of zipped files in the central dir and positions
		 * the buffer at the start of the central directory.
		 * 
		 * @private
		 */
		private function readEND():void
		{
			var end:uint = findEND();
			if (end > 0)
			{
				var b:ByteArray = new ByteArray();
				b.endian = Endian.LITTLE_ENDIAN;
				
				_content.position = end;
				_content.readBytes(b, 0, ZipConstants.ENDHDR);
				b.position = ZipConstants.ENDTOT;
				_fileCount = b.readUnsignedShort();
				b.position = ZipConstants.ENDOFF;
				_content.position = b.readUnsignedInt();
			}
		}
		
		
		/**
		 * Find the end of central directory record.
		 * -----------------------------------------------------
		 * end of central dir signature    4 bytes  (0x06054b50)
		 * number of this disk             2 bytes
		 * number of the disk with the
		 * start of the central directory  2 bytes
		 * total number of entries in the
		 * central directory on this disk  2 bytes
		 * total number of entries in
		 * the central directory           2 bytes
		 * size of the central directory   4 bytes
		 * offset of start of central
		 * directory with respect to
		 * the starting disk number        4 bytes
		 * .ZIP file comment length        2 bytes
		 * .ZIP file comment       (variable size)
		 * 
		 * @private
		 */
		private function findEND():uint
		{
			var i:uint = _content.length - ZipConstants.ENDHDR;
			var n:uint = Math.max(0, i - ZipConstants.MAXCMT);
			
			for (i; i >= n; i--)
			{
				if (i < 1) break;
				/* Quick check that the byte is 'P' */
				if (_content[i] != 0x50) continue;
				_content.position = i;
				if (_content.readUnsignedInt() == ZipConstants.ENDSIG)
				{
					return i;
				}
			}
			
			error("findEND: Could not find the end header.");
			return 0;
		}
		
		
		/**
		 * Used by ZipGenerator.
		 * @private
		 */
		internal function setStatus(valid:Boolean, status:String):void
		{
			_valid = valid;
			_status = status;
		}
		
		
		/**
		 * @private
		 */
		internal function error(msg:String):void
		{
			_valid = false;
			_status = "ERROR - " + msg;
		}
	}
}
