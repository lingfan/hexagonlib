/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.io.file
{
	import com.hexagonstar.data.constants.Status;
	import com.hexagonstar.data.constants.ZipConstants;
	import com.hexagonstar.debug.HLog;
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.IFile;
	import com.hexagonstar.io.file.types.ZipEntry;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;			/**	 * Dispatched after the zip file used by the ZipLoader has been opened and is ready	 * for use.	 * 	 * @eventType flash.events.Event.OPEN	 */	[Event(name="open", type="flash.events.Event.OPEN")]			/**	 * Dispatched after the ZipLoader has been closed.	 * 	 * @eventType flash.events.Event.CLOSE	 */	[Event(name="close", type="flash.events.Event.CLOSE")]			/**	 * Dispatched if any error happens while trying to open the zip file.	 * 	 * @eventType flash.events.IOErrorEvent.IO_ERROR	 */	[Event(name="ioError", type="flash.events.IOErrorEvent.IO_ERROR")]			/**	 * Dispatched after a bulk file has been opened.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.OPEN	 */	[Event(name="fileIOOpen", type="com.hexagonstar.event.FileIOEvent.OPEN")]			/**	 * Dispatched everytime a file progresses loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.PROGRESS	 */	[Event(name="fileIOProgress", type="com.hexagonstar.event.FileIOEvent.PROGRESS")]			/**	 * Dispatched if a bulk file has completed loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.FILE_COMPLETE	 */	[Event(name="fileIOFileComplete", type="com.hexagonstar.event.FileIOEvent.FILE_COMPLETE")]			/**	 * Dispatched if the load progress has been aborted.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.ABORT	 */	[Event(name="fileIOAbort", type="com.hexagonstar.event.FileIOEvent.ABORT")]			/**	 * Dispatched if a HTTP Status event is broadcasted.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.HTTP_STATUS	 */	[Event(name="fileIOHTTPStatus", type="com.hexagonstar.event.FileIOEvent.HTTP_STATUS")]			/**	 * Dispatched if an IO error occurs during the load operation.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.IO_ERROR	 */	[Event(name="fileIOIOError", type="com.hexagonstar.event.FileIOEvent.IO_ERROR")]			/**	 * Dispatched if a security error occurs during the load operation.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.SECURITY_ERROR	 */	[Event(name="fileIOSecurityError", type="com.hexagonstar.event.FileIOEvent.SECURITY_ERROR")]			/**	 * Dispatched after all bulk files haven been completed loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.COMPLETE	 */	[Event(name="fileIOComplete", type="com.hexagonstar.event.FileIOEvent.COMPLETE")]			/**	 * The ZipLoader works like the BulkLoader with the difference that it opens a zip	 * file and can load packed data from the zip file using random access. This allows to	 * pack a large amount of files together into one zip file and extract artbitrary	 * files from it without the need to load it completely into memory first.<br>	 * 	 * <p>To use the zip loader you first have to open it using the <code>open()</code>	 * method. The zip loader then reads the central directory from the zip file which	 * contains a list of all packed files and their offsets.</p><br>	 * 	 * <p>After the zip file has been opened file objects can be added to the loader	 * using <code>addFile()</code> or <code>addFileQueue()</code>. These file	 * objects need to have their paths set so that they reflect their associated	 * file entry in the zip file.</p><br>	 * 	 * <p><b>Limitations:</b> The same limitations apply as with the ZipFile class.</p>	 * 	 * @see com.hexagonstar.io.file.BulkLoader	 * @see com.hexagonstar.event.BulkFileIOEvent	 * @see com.hexagonstar.io.file.types.IFile	 * @see com.hexagonstar.io.file.types.ZipFile	 * 	 * @playerversion AIR 1.0	 */	public class ZipLoader extends BulkLoader
	{
		//-----------------------------------------------------------------------------------------		// Constants		//-----------------------------------------------------------------------------------------				/** @private */		protected static const READ_END:int	= 0;		/** @private */		protected static const READ_CEN:int	= 1;		/** @private */		protected static const OPEN:int		= 2;		/** @private */		protected static const OPENED:int	= 3;		/** @private */		protected static const CLOSE:int	= 4;						//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/** @private */		protected static var _bufferSize:uint = 8192;				/** @private */		protected var _zipFile:File;		/** @private */		protected var _stream:FileStream;		/** @private */		protected var _buffer:ByteArray;				/** @private */		protected var _entriesCount:uint;		/** @private */		protected var _entriesList:Array;		/** @private */		protected var _entriesTable:Dictionary;		/** @private */		protected var _locOffsetTable:Dictionary;				/** @private */		protected var _zipFileSize:Number;		/** @private */		protected var _readAhead:Number;				/** @private */		protected var _state:int;				/** @private */		protected var _cenStart:Number;				/** @private */		protected var _opened:Boolean;		/** @private */		protected var _streamStarted:Boolean;				/** @private */		protected var _valid:Boolean;
		/** @private */		protected var _status:String;
						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new instance of ZipLoader. Before using this class you have to create a		 * File object which points to the zip file that you want to use with the ZipLoader.		 * 		 * @param zipFile A File object that points to a zip file.		 */		public function ZipLoader(zipFile:File)		{			_zipFile = zipFile;			reset();		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		override public function reset():void		{			super.reset();			
			_opened = false;
			_streamStarted = false;			_valid = false;			_state = ZipLoader.READ_END;			_status = Status.INIT;						_entriesList = [];			_entriesTable = new Dictionary();			_locOffsetTable = new Dictionary();		}						/**		 * Opens the zip file which is used with the ZipLoader. This readies the ZipLoader for		 * random access to be able to extract data from the zip file. Call this method before		 * using <code>addFile()</code> or <code>addFileQueue()</code> and listen to the OPEN		 * event that ZipLoader broadcasts after it is ready.		 * 		 * @return true if the zip loader is opening successfully, false if not which only		 *         happens if the loader is already opened or the zip file size is 0. Note		 *         that returning true does not mean that the zip loader has been opened but		 *         only that everything went OK while starting to open the loader. To make		 *         sure that the loader is opened and ready for use listen to the Event.OPEN		 *         event.		 */		public function open():Boolean		{			if (_opened || !_zipFile.exists || _zipFile.size < 1) return false;						_zipFileSize = _zipFile.size;						_buffer = new ByteArray();			_buffer.endian = Endian.LITTLE_ENDIAN;						_stream = new FileStream();			_stream.endian = Endian.LITTLE_ENDIAN;			_stream.addEventListener(ProgressEvent.PROGRESS, onStreamProgress);			_stream.addEventListener(Event.COMPLETE, onStreamComplete);			_stream.addEventListener(IOErrorEvent.IO_ERROR, onStreamError);			_stream.addEventListener(Event.CLOSE, onStreamClose);						/* Stream buffer read ahead. If the file is smaller than ~64Kb (the size			 * of the zip END header + max. zip comment length) we read in the whole			 * file at once, otherwise we want the last 64Kb at the end of the file! */			var endChunkSize:int = ZipConstants.ENDHDR + ZipConstants.MAXCMT;			_readAhead = _zipFileSize < endChunkSize ? _zipFileSize : endChunkSize;			_stream.readAhead = _readAhead;						_stream.openAsync(_zipFile, FileMode.READ);			return true;		}						/**		 * Closes the zip loader. Call this method after you are finished using the loader.		 */		public function close():void		{			if (!_opened) return;			_state = ZipLoader.CLOSE;			_stream.position = _zipFileSize;		}						/**		 * Adds a file to the zip loader for which data can be extracted from the zip file.		 * <p>		 * If the file has no priority defined (i.e. it's priority is <code>NaN</code>) the		 * zip loader will automatically assign a priority to the file starting from 0 and		 * counting minus. For example adding three files without priority means that the		 * first gets a priority of 0, the second a priority of -1, the third a priority of -2		 * and so on (down to <code>int.MIN_VALUE</code>). This guarantees that priority-less		 * files are loaded in the same order they were added.		 * </p>		 * 		 * @see com.hexagonstar.io.file.types.IFile		 * 		 * @param file A file object to add to the zip loader.		 * @return <code>true</code> if the file was added successfully or <code>false</code>		 *         if not which only happens if a file with the same path was already added to		 *         the zip loader of if it refers to an empty directory in the zip file.		 */		override public function addFile(file:IFile):Boolean
		{
			if (!_opened || _state != ZipLoader.OPENED) return false;						var id:String = file.path;			var e:ZipEntry = getEntry(id);						if (!e || e.isDirectory || isNaN(e.compressedSize)) return false;						/* If file was already added to this bulk, don't add it again! */			if (isAlreadyAdded(id))			{				HLog.warn(toString() + " The file <" + id +					"> has already been added to the load queue.");				return false;			}						/* Check if compression method is supported */
			if (e.compressionMethod != ZipConstants.DEFLATE				&& e.compressionMethod != ZipConstants.STORE)			{				error("The compression method used by the zipped file <" + e.path					+ "> in zip file <" + _zipFile.nativePath + "> is not supported."					+ " The ZipLoader only supports STORE and DEFLATE compression methods.");				return false;			}						/* If no file priority was defined, assign automatic priority. */			if (isNaN(file.priority))			{				file.priority = _priorityCount;				if (_priorityCount > int.MIN_VALUE) _priorityCount--;			}						/* Extra field for local file header may not match one in central directory header			 * so we subtract the two bytes here which are later read in from the file chunk			 * in the ZippedFile class. */			var offset:Number = _locOffsetTable[id] + ZipConstants.LOCHDR - 2;						// TODO Add ZippedSoundFile!			var zf:ZippedFile = new ZippedFile(file, e, offset, _stream, _buffer, _zipFile);			var vo:BulkFileVO = new BulkFileVO(id, file.priority, zf);						zf.addEventListener(FileIOEvent.OPEN, onFileOpen, false, 0, true);			zf.addEventListener(FileIOEvent.PROGRESS, onFileProgress, false, 0, true);			zf.addEventListener(FileIOEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);			zf.addEventListener(FileIOEvent.IO_ERROR, onFileError, false, 0, true);			zf.addEventListener(FileIOEvent.SECURITY_ERROR, onFileError, false, 0, true);			zf.addEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete, false, 0, true);						_files.push(vo);			_fileCount = _filesTotal += 1;						return true;		}						/**		 * Returns the zip entry that belongs to the specified path.		 * 		 * @see com.hexagonstar.io.file.types.ZipEntry		 * 		 * @return The zip entry that belongs to the specified path or <code>null</code> if no		 *         zip entry with that path exists in the zip file.		 */		public function getEntry(path:String):ZipEntry		{			return _entriesTable[path];		}						/**		 * Returns a String Representation of the zip loader.		 * 		 * @return A String Representation of the zip loader.		 */		override public function toString():String		{			return "[ZipLoader]";		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * The load buffer size (in bytes) used to load files from a zip file, a value between		 * 8192 and 8388608 (8 MB). The default value is 8192. This buffer size is used by all		 * ZipLoader instances.		 */		static public function get bufferSize():uint		{			return _bufferSize;		}		static public function set bufferSize(v:uint):void		{			_bufferSize = (v < 8192) ? 8192 : (v > 8388608) ? 8388608 : v;		}						/**		 * An array of ZipEntry objects that contains all zip entries of the zip file that is		 * used with the zip loader.		 * 		 * @see com.hexagonstar.io.file.types.ZipEntry		 */		public function get entries():Array		{			return _entriesList;		}						/**		 * Not used by the ZipLoader class! Maximum connections has no effect on a zip loader.		 * A zip loader always uses one connection for loading files.		 */		override public function set maxConnections(v:int):void		{			_maxConnections = 1;		}						/**		 * The path of the zip file that is used with the ZipLoader.		 */		public function get path():String
		{
			return _zipFile.nativePath;		}						/**		 * The file name of the zip file that is used with the ZipLoader.		 */		public function get filename():String		{			return _zipFile.name;		}						/**		 * Deternmines if the zip loader is opened for random access (true) or not (false).		 */		public function get opened():Boolean		{			return _opened;		}						/**		 * Setting load retries has no effect on a zip loader! Any added file is ever only		 * tried to be loaded once from a zip file and is not being tried to load again in		 * case it fails.		 */		override public function set loadRetries(v:int):void		{		}						/**		 * Not used for zip loaders since absolute file paths have no effect on file paths		 * inside a zip file. Setting this property has no effect!		 */		override public function set useAbsoluteFilePath(v:Boolean):void		{		}						/**		 * Not used for zip loaders! Setting this property has no effect!		 */		override public function set preventCaching(v:Boolean):void		{		}						//-----------------------------------------------------------------------------------------		// Event Handlers		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		protected function onStreamProgress(e:ProgressEvent):void		{			/* As soon as the stream started we set it's position to the offset			 * of the end chunk from the end of the file. */			if (!_streamStarted)			{				_streamStarted = true;				if (_state == ZipLoader.READ_END)					_stream.position = _zipFileSize - _readAhead;				if (_state == ZipLoader.READ_CEN)					_stream.position = _cenStart;			}						/* If enough bytes are read in, find and read the END chunk */			if (_stream.bytesAvailable >= _readAhead)			{				_stream.readBytes(_buffer, 0, _readAhead);				if (_state == ZipLoader.READ_END)					readEND();				else if (_state == ZipLoader.READ_CEN)					readCEN();			}		}						/**		 * @private		 */		protected function onStreamComplete(e:Event):void
		{
			if (_state != ZipLoader.OPENED)			{				_stream.close();			}		}						/**		 * @private		 */		protected function onStreamError(e:IOErrorEvent):void		{			error("Stream Error while opening zip file <" + _zipFile.nativePath + ">: " + e.text);		}						/**		 * @private		 */		protected function onStreamClose(e:Event):void		{			if (_state == ZipLoader.OPEN)			{				/* If loader was opening, it's now opened! */
				_state = ZipLoader.OPENED;
				_opened = true;				dispatchEvent(new Event(Event.OPEN));			}			else if (_state == ZipLoader.CLOSE)			{				/* Loader was closed, time to cleanup! */				_stream.removeEventListener(Event.COMPLETE, onStreamComplete);				_stream.removeEventListener(Event.CLOSE, onStreamClose);				_stream.removeEventListener(ProgressEvent.PROGRESS, onStreamProgress);				_stream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamError);				_stream = null;				_buffer = null;				reset();				_opened = false;				dispatchEvent(new Event(Event.CLOSE));			}		}						//-----------------------------------------------------------------------------------------		// Private Methods		//-----------------------------------------------------------------------------------------				/**		 * Finds and reads the END header of the zip file.		 * @private		 */		protected function readEND():void		{			var i:uint = _buffer.length - ZipConstants.ENDHDR;			var n:uint = Math.max(1, i - ZipConstants.MAXCMT);			var end:uint = 0;						/* Loop from end on through the buffer to find END header. */			for (i; i >= n; i--)			{				/* Quick check that the byte is 'P'. */				if (_buffer[i] != 0x50)				{					continue;				}				_buffer.position = i;				if (_buffer.readUnsignedInt() == ZipConstants.ENDSIG)				{					end = i;					break;				}			}						if (end > 0)			{				/* Read the total number of zip entries in the central dir and				 * position the buffer at the start of the central directory. */				var b:ByteArray = new ByteArray();				b.endian = Endian.LITTLE_ENDIAN;				_buffer.position = end;				_buffer.readBytes(b, 0, ZipConstants.ENDHDR);				b.position = ZipConstants.ENDTOT;				_entriesCount = b.readUnsignedShort();				b.position = ZipConstants.ENDSIZ;				/* Set readAhead to CEN length. */				_readAhead = b.readUnsignedInt();				b.position = ZipConstants.ENDOFF;				_cenStart = b.readUnsignedInt();								/* Prepare for reading in CEN dir. */				_buffer.clear();				_state = ZipLoader.READ_CEN;				_streamStarted = false;				_stream.readAhead = _readAhead;				_stream.openAsync(_zipFile, FileMode.READ);			}			else			{
				error("Could not find END header of zip file <" + _zipFile.nativePath + ">.");				close();			}		}						/**		 * Reads the central directory of the zip file and fills the zippedFiles array. This		 * is called exactly once when first needed.		 * 		 * @private		 */		protected function readCEN():void		{			/* Remove event listeners that are not necessary anymore! */			_stream.removeEventListener(ProgressEvent.PROGRESS, onStreamProgress);			_stream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamError);						/* Loop through CEN entries. */			for (var i:uint = 0; i < _entriesCount; i++)			{				var tmp:ByteArray = new ByteArray();				tmp.endian = Endian.LITTLE_ENDIAN;				_buffer.readBytes(tmp, 0, ZipConstants.CENHDR);								var sig:uint = tmp.readUnsignedInt();				if (sig != ZipConstants.CENSIG)				{					error("Invalid CEN header in zip file <" + _zipFile.nativePath						+ "> (bad signature: 0x" + sig.toString(16) + ").");					close();					return;				}								/* Handle filename */				tmp.position = ZipConstants.CENNAM;								var len:uint = tmp.readUnsignedShort();				if (len == 0)
				{
					error("Missing zip entry file path in zip file <" + _zipFile.nativePath + ">.");					close();					return;				}								var f:ZipEntry = new ZipEntry(_buffer.readUTFBytes(len), null);								/* Handle extra field */				len = tmp.readUnsignedShort();				f.extra = new ByteArray();								/* Handle file comment */				if (len > 0) _buffer.readBytes(f.extra, 0, len);				_buffer.position += tmp.readUnsignedShort();								/* Now get the remaining fields for the entry */				tmp.position = ZipConstants.CENVER;				f.version = tmp.readUnsignedShort();				f.flag = tmp.readUnsignedShort();				if ((f.flag & 1) == 1)				{					error("Encrypted zip entry not supported in zip file <" + _zipFile.nativePath						+ ">.");					close();					return;				}				f.compressionMethod = tmp.readUnsignedShort();				f.dostime = tmp.readUnsignedInt();				f.crc32 = tmp.readUnsignedInt();				f.compressedSize = tmp.readUnsignedInt();				f.size = tmp.readUnsignedInt();				f.offset = tmp.readUnsignedInt();								/* Add to file list and table */				_entriesList.push(f);				_entriesTable[f.path] = f;								/* Store loc offset */				tmp.position = ZipConstants.CENOFF;				_locOffsetTable[f.path] = tmp.readUnsignedInt();			}						/* Ready for fetching files from the zip. */			_buffer.clear();			_state = ZipLoader.OPEN;			_stream.position = _zipFileSize;		}						/**		 * @private		 */		protected function error(msg:String):void		{			var e:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);			_valid = false;			_status = e.text = msg;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
	}}