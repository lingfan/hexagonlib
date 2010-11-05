/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.io.file{	import com.hexagonstar.data.structures.IIterator;	import com.hexagonstar.data.structures.queues.Queue;	import com.hexagonstar.debug.HLog;	import com.hexagonstar.event.BulkFileIOEvent;	import com.hexagonstar.event.FileIOEvent;	import com.hexagonstar.io.file.types.IFile;	import com.hexagonstar.io.file.types.SoundFile;		import flash.events.EventDispatcher;			/**	 * Dispatched after a bulk file has been opened.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.OPEN	 */	[Event(name="fileIOOpen", type="com.hexagonstar.event.FileIOEvent.OPEN")]			/**	 * Dispatched everytime a file progresses loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.PROGRESS	 */	[Event(name="fileIOProgress", type="com.hexagonstar.event.FileIOEvent.PROGRESS")]			/**	 * Dispatched if a bulk file has completed loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.FILE_COMPLETE	 */	[Event(name="fileIOFileComplete", type="com.hexagonstar.event.FileIOEvent.FILE_COMPLETE")]			/**	 * Dispatched if the load progress has been aborted.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.ABORT	 */	[Event(name="fileIOAbort", type="com.hexagonstar.event.FileIOEvent.ABORT")]			/**	 * Dispatched if a HTTP Status event is broadcasted.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.HTTP_STATUS	 */	[Event(name="fileIOHTTPStatus", type="com.hexagonstar.event.FileIOEvent.HTTP_STATUS")]			/**	 * Dispatched if an IO error occurs during the load operation.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.IO_ERROR	 */	[Event(name="fileIOIOError", type="com.hexagonstar.event.FileIOEvent.IO_ERROR")]			/**	 * Dispatched if a security error occurs during the load operation.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.SECURITY_ERROR	 */	[Event(name="fileIOSecurityError", type="com.hexagonstar.event.FileIOEvent.SECURITY_ERROR")]			/**	 * Dispatched after all bulk files haven been completed loading.	 * 	 * @eventType com.hexagonstar.event.FileIOEvent.COMPLETE	 */	[Event(name="fileIOComplete", type="com.hexagonstar.event.FileIOEvent.COMPLETE")]			/**	 * The BulkLoader offers comfortable loading of multiple files.<br>	 * 	 * <p>To use the bulk loader you first have to add file objects to it by using the	 * <code>addFile()</code> method to add single files or the	 * <code>addFileQueue()</code> method to add a queue of files. After that	 * <code>load()</code> is called to start the loading process.</p><br>	 * 	 * <p>Files are loaded one by one unless you increase the amount of concurrent load	 * connections by using the <code>maxConnections</code> property. For example setting	 * <code>maxConnections</code> to 4 will tell the bulk loader to load a maximum of	 * four files at the same time. This can speed up loading of files on a fast network	 * connection.</p><br>	 * 	 * <p>By default any file that failed loading will not tried to be loaded again in the	 * same operation unless the <code>loadRetries</code> property is raised. This	 * property is only meaningful for loading files over a network.</p><br>	 * 	 * <p>If you only need to a load a single file you can opt to use the FileLoader class	 * instead which is more light-weight than the BulkLoader.</p>	 * 	 * @see com.hexagonstar.io.file.BulkFile	 * @see com.hexagonstar.io.file.BulkSoundFile	 * @see com.hexagonstar.io.file.FileLoader	 * @see com.hexagonstar.data.structures.queues.Queue	 */	public class BulkLoader extends EventDispatcher	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/** @private */		protected var _files:Vector.<BulkFileVO>;		/** @private */		protected var _loadedFileQueue:Queue;		/** @private */		protected var _usedConnections:Object;		/** @private */		protected var _maxConnections:int;		/** @private */		protected var _loadRetries:int;		/** @private */		protected var _priorityCount:int;		/** @private */		protected var _fileCount:int;		/** @private */		protected var _filesTotal:int;		/** @private */		protected var _filesProcessed:int;		/** @private */		protected var _loading:Boolean;		/** @private */		protected var _aborted:Boolean;		/** @private */		protected var _useAbsoluteFilePath:Boolean;		/** @private */		protected var _preventCaching:Boolean;						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new bulk loader instance.		 * 		 * @param maxConnections Maximum concurrent load connections.		 * @param loadRetries How often a failed file should be retried to be loaded.		 * @param useAbsoluteFilePath If true absolute file paths are used.		 * @param preventCaching If true the loader adds a timestamp to the file path to		 *            prevent file caching by server caches or proxies.		 */		public function BulkLoader(maxConnections:int = 1,									loadRetries:int = 0,									useAbsoluteFilePath:Boolean = false,									preventCaching:Boolean = false)		{			this.maxConnections = maxConnections;			this.loadRetries = loadRetries;			_useAbsoluteFilePath = useAbsoluteFilePath;			_preventCaching = preventCaching;						reset();		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * Resets the loader. You only need to call this method if you want to use the same		 * loader instance more than once. You cannot reset the loader while it's performing		 * a load operation.		 */		public function reset():void		{			if (_loading)			{				HLog.warn(toString() + " Tried to reset loader during a load operation.");				return;			}						_files = new Vector.<BulkFileVO>();			_loadedFileQueue = new Queue();			_usedConnections = {};			_priorityCount = _fileCount = _filesTotal = 0;			_loading = false;			_aborted = false;		}						/**		 * Adds a file to the loader.<br>		 * 		 * <p>If the file has no priority defined (i.e. it's priority is <code>NaN</code>) the		 * loader will automatically assign a priority to the file starting from 0 and		 * counting minus. For example adding three files without priority results in that the		 * first file receives a priority of 0, the second a priority of -1, the third a		 * priority of -2 and so on (down to <code>int.MIN_VALUE</code>). This guarantees that		 * priority-less files are loaded in the same order they were added.</p>		 * 		 * @see #addFileQueue		 * 		 * @param file The file to add to the loader.		 * @return true if the file was added successfully or false if not, e.g. if a file		 *         with the same path has already been already added to the loader.		 */		public function addFile(file:IFile):Boolean		{			/* We use the file path as the ID to map file objects. */			var id:String = file.path;						/* If file was already added to this bulk, don't add it again! */			if (isAlreadyAdded(id))			{				HLog.warn(toString() + " The file <" + id + "> has already been added.");				return false;			}						/* If no file priority was defined, assign automatic priority. */			if (isNaN(file.priority))			{				file.priority = _priorityCount;				if (_priorityCount > int.MIN_VALUE) _priorityCount--;			}						var bf:IBulkFile = (file is SoundFile) ? new BulkSoundFile(file) : new BulkFile(file);			var vo:BulkFileVO = new BulkFileVO(id, file.priority, bf);						bf.addEventListener(FileIOEvent.OPEN, onFileOpen, false, 0, true);			bf.addEventListener(FileIOEvent.PROGRESS, onFileProgress, false, 0, true);			bf.addEventListener(FileIOEvent.HTTP_STATUS, onHTTPStatus, false, 0, true);			bf.addEventListener(FileIOEvent.IO_ERROR, onFileError, false, 0, true);			bf.addEventListener(FileIOEvent.SECURITY_ERROR, onFileError, false, 0, true);			bf.addEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete, false, 0, true);						_files.push(vo);			_fileCount = _filesTotal += 1;						return true;		}						/**		 * Allows adding a queue of files at once to the loader. The enqueued files must be of		 * type IFile. Any non-IFile objects in the queue are ignored. It is possible to add		 * several queues to the loader.		 * 		 * @see #addFile		 * @see com.hexagonstar.data.structures.queues.Queue		 * 		 * @param queue The queue with files to load.		 */		public function addFileQueue(queue:Queue):void		{			if (!queue) return;			var i:IIterator = queue.iterator();			while (i.hasNext)			{				var n:* = i.next;				if (n is IFile)				{					addFile(n);				}				else				{					HLog.warn(toString()						+ " File queue contains item which is not of type IFile: " + n);				}			}		}						/**		 * Starts loading the files which were added to the loader with <code>addFile()</code>		 * or <code>addFileQueue()</code>.		 * 		 * @see #addFile		 * @see #addFileQueue		 * 		 * @return <code>true</code> if the load process started or <code>false</code> if the		 *         loader is already loading or the file count is zero.		 */		public function load():Boolean		{			if (_loading || fileCount < 1) return false;						_filesProcessed = 0;			_aborted = false;			_loading = true;						sort();			loadNext();						return true;		}						/**		 * Aborts the bulk load process. Aborting only takes effect between files in the bulk		 * and never while a file is loaded. I.e. if you call abort while a file in the bulk		 * is currently being loaded the loader will finish loading the current file in		 * progress and aborts once the file is loaded but before the next file in the load		 * queue. Calling abort before the first file is loaded or after the last file started		 * loading has no effect.		 */		public function abort():void		{			if (!_loading || fileCount < 1) return;			_aborted = true;		}						/**		 * Provides a shortcut method for adding IO event listeners quickly. The class which		 * should listen to events fired by this loader needs to implement the		 * IFileIOEventListener interface if it is used with this method.		 * 		 * @see com.hexagonstar.io.file.IFileIOEventListener		 * @see #removeEventListenersFor		 * 		 * @param l The listener which should listen for IO events fired by the loader.		 */		public function addEventListenersFor(l:IFileIOEventListener):void		{			addEventListener(FileIOEvent.OPEN, l.onFileOpen, false, 0, true);			addEventListener(FileIOEvent.PROGRESS, l.onFileProgress, false, 0, true);			addEventListener(FileIOEvent.FILE_COMPLETE, l.onFileComplete, false, 0, true);			addEventListener(FileIOEvent.ABORT, l.onFileAbort, false, 0, true);			addEventListener(FileIOEvent.HTTP_STATUS, l.onFileHTTPStatus, false, 0, true);			addEventListener(FileIOEvent.IO_ERROR, l.onFileIOError, false, 0, true);			addEventListener(FileIOEvent.SECURITY_ERROR, l.onFileSecurityError, false,				0, true);			addEventListener(FileIOEvent.COMPLETE, l.onAllFilesComplete, false, 0, true);		}						/**		 * Provides a shortcut method for removing all event listeners that were added before		 * with <code>addEventListenersFor()</code>.		 * 		 * @see com.hexagonstar.io.file.IFileIOEventListener		 * @see #addEventListenersFor		 * 		 * @param l The listener which should stop listen for IO events fired by the loader.		 */		public function removeEventListenersFor(l:IFileIOEventListener):void		{			removeEventListener(FileIOEvent.OPEN, l.onFileOpen);			removeEventListener(FileIOEvent.PROGRESS, l.onFileProgress);			removeEventListener(FileIOEvent.FILE_COMPLETE, l.onFileComplete);			removeEventListener(FileIOEvent.ABORT, l.onFileAbort);			removeEventListener(FileIOEvent.HTTP_STATUS, l.onFileHTTPStatus);			removeEventListener(FileIOEvent.IO_ERROR, l.onFileIOError);			removeEventListener(FileIOEvent.SECURITY_ERROR, l.onFileSecurityError);			removeEventListener(FileIOEvent.COMPLETE, l.onAllFilesComplete);		}						/**		 * Disposes the loader to free up system resources. The loader instance cannot ber		 * used anymore after calling this method unless <code>reset()</code> is called		 * afterwards. Note that you cannot dispose the loader while it performs a load		 * operation. You first need to make sure that all loading stopped.		 */		public function dispose():void		{			if (_loading) return;						for (var i:int = 0; i < fileCount; i++)			{				removeEventListenersFrom(_files[i].bulkfile);				_files[i].bulkfile.dispose();			}						_files = null;			_usedConnections = null;			_priorityCount = _fileCount = _filesTotal = 0;		}						/**		 * Returns a string representation of the loader.		 * 		 * @return A string representation of the loader.		 */		override public function toString():String		{			return "[BulkLoader]";		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * The maximum concurrent load connections. The maximum value is 1000, the minimum		 * value is 1. The default value is 1. Raising this value can increase loading speed		 * of files when loaded over a fast network connection.		 */		public function get maxConnections():int		{			return _maxConnections;		}		public function set maxConnections(v:int):void		{			_maxConnections = (v < 1) ? 1 : (v > 1000) ? 1000 : v;		}						/**		 * Determines how often a file that failed loading should be tried to load again. The		 * default value is 0. This property is only meaningful for loading files over a		 * network connection where file loading might fail due to network problems. The		 * maximum value for this is 1000, the minimum value is 0.		 */		public function get loadRetries():int		{			return _loadRetries;		}		public function set loadRetries(v:int):void		{			_loadRetries = (v < 0) ? 0 : (v > 1000) ? 1000 : v;		}						/**		 * Indicates whether the loader is currently in a load operation or not.		 */		public function get loading():Boolean		{			return _loading;		}						/**		 * Indicates whether the loader was aborted (i.e. <code>abort()</code> was called).		 */		public function get aborted():Boolean		{			return _aborted;		}						/**		 * Determines how many files are left that need to be loaded.		 */		public function get fileCount():int		{			return _fileCount;		}						/**		 * A Queue that contains all files. This can be used to obtain all files		 * at once after loading of all files has completed. The queue contains		 * both successfully and failed to load files. The queue becomes unavailable		 * after a call to reset().		 */		public function get fileQueue():Queue		{			return _loadedFileQueue;		}						/**		 * Determines whether the loader is using absolute file paths for loading or not.<br>		 * 		 * <p>By default the loader uses the relative file path of any files added for		 * loading. This means the path is relative from the path in that the loading SWF file		 * resides. If <code>useAbsoluteFilePath</code> is set to true the loader will load		 * files by using their full paths. It is recommended to leave this property set to		 * false (the default) unless the server or environment requires absolute file		 * paths.</p>		 */		public function get useAbsoluteFilePath():Boolean		{			return _useAbsoluteFilePath;		}		public function set useAbsoluteFilePath(v:Boolean):void		{			_useAbsoluteFilePath = v;		}						/**		 * Determines whether the loader is preventing file caching (true) or not (false). If		 * set to true the loader will not re-use files cached by a browser or proxy but		 * instead request the files again from the server. The default value is false.		 */		public function get preventCaching():Boolean		{			return _preventCaching;		}		public function set preventCaching(v:Boolean):void		{			_preventCaching = v;		}						/**		 * Determines if a free load connection is currently available.		 * 		 * @private		 */		protected function get connectionAvailable():Boolean		{			return currentlyUsedConnections < _maxConnections;		}						/**		 * The amount of load connections that are currently in use.		 * 		 * @private		 */		protected function get currentlyUsedConnections():int		{			var v:int = 0;			for (var c:String in _usedConnections)			{				v++;			}			return v;		}						/**		 * Determines if all files in the bulk were processed, i.e. if they are loaded		 * successfully or failed because of a load error.		 * 		 * @private		 */		protected function get allFilesProcessed():Boolean
		{			return _filesProcessed == _filesTotal;		}						/**		 * Checks if abort was called.		 * 		 * @private		 */		protected function get isAbort():Boolean		{			if (_aborted && fileCount > 0)			{				_loading = false;				dispatchEvent(new FileIOEvent(FileIOEvent.ABORT));				return true;			}			return false;		}						//-----------------------------------------------------------------------------------------		// Event Handlers		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		protected function onFileOpen(e:BulkFileIOEvent):void		{			dispatchEvent(e);		}						/**		 * @private		 */		protected function onFileProgress(e:BulkFileIOEvent):void		{			dispatchEvent(createProgressEvent(e.bulkFile));		}						/**		 * @private		 */		protected function onHTTPStatus(e:BulkFileIOEvent):void		{			dispatchEvent(e);		}						/**		 * @private		 */		protected function onFileError(e:BulkFileIOEvent):void		{			var bf:IBulkFile = e.bulkFile;			removeConnectionFrom(bf);						//HLog.warn(toString() + " error loading: " + bf.toString()			//	+ " (" + (_loadRetries - bf.retryCount) + " retries left). Error was: "			//	+ e.text);						/* We dispatch an error event here only after all load retries are used up! */			if (bf.retryCount >= _loadRetries)			{				removeEventListenersFrom(bf);				_loadedFileQueue.enqueue(e.file);				dispatchEvent(e);				if (!isAbort)				{					_filesProcessed++;					next(e);				}			}			else			{				if (!isAbort)				{					_filesProcessed++;					next(e);				}				else				{					removeEventListenersFrom(bf);				}			}			e.stopPropagation();		}						/**		 * @private		 */		protected function onFileComplete(e:BulkFileIOEvent):void		{			var bf:IBulkFile = e.bulkFile;			removeConnectionFrom(bf);			removeEventListenersFrom(bf);						_loadedFileQueue.enqueue(e.file);						dispatchEvent(e);			if (!isAbort)			{				_filesProcessed++;				next(e);			}			e.stopPropagation();		}						/**		 * @private		 */		protected function onAllFilesComplete(e:BulkFileIOEvent):void		{			e.stopPropagation();						_loading = false;						/* The COMPLETE event still sends the last loaded file. Like this we			 * can access the file in case only one file is loaded and should be			 * accessed inside the listener's onAllFilesComplete handler. */			dispatchEvent(new FileIOEvent(FileIOEvent.COMPLETE, e.file));		}						//-----------------------------------------------------------------------------------------		// Private Methods		//-----------------------------------------------------------------------------------------				/**		 * Checks if the file with the specified ID was already added to the bulk.		 * 		 * @private		 */		protected function isAlreadyAdded(id:String):Boolean 		{			for (var i:int = 0; i < fileCount; i++)			{				if (_files[i].id == id) return true;			}			return false;		}						/**		 * Sorts the collection of files by priority.		 * 		 * @private		 */		protected function sort():void		{			/* Use nested sort function */			_files.sort(function (o1:BulkFileVO, o2:BulkFileVO):Number			{				if (o1.priority < o2.priority) return 1;				else if (o1.priority > o2.priority) return -1;				return 0;			});		}						/**		 * @private		 */		protected function removeEventListenersFrom(bf:IBulkFile):void		{			bf.removeEventListener(FileIOEvent.OPEN, onFileOpen);			bf.removeEventListener(FileIOEvent.PROGRESS, onFileProgress);			bf.removeEventListener(FileIOEvent.HTTP_STATUS, onHTTPStatus);			bf.removeEventListener(FileIOEvent.IO_ERROR, onFileError);			bf.removeEventListener(FileIOEvent.SECURITY_ERROR, onFileError);			bf.removeEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete);		}						/**		 * @private		 */		protected function next(e:BulkFileIOEvent):void		{			loadNext();						if (allFilesProcessed)			{				/* Send an additional progress event after all files are finished!				 * Without this the last load stats would not be accurate. */				onFileProgress(e);				onAllFilesComplete(e);			}		}						/**		 * @private		 */		protected function loadNext():Boolean		{			var hasNext:Boolean = false;			var next:IBulkFile = getNextBulkFile();						if (next)			{				hasNext = true;				_usedConnections[next.file.path] = true;				next.load(_useAbsoluteFilePath, _preventCaching);								/* If we got any more connections available, go on and load the next item. */				if (getNextBulkFile())				{					loadNext();				}			}						return hasNext;		}						/**		 * @private		 */		protected function getNextBulkFile():IBulkFile		{			for (var i:int = 0; i < fileCount; i++)			{				var bf:IBulkFile = _files[i].bulkfile;				if (!bf.loading && bf.status != BulkFile.STATUS_LOADED && connectionAvailable)				{					/* No error status so just load the file. */					if (bf.status != BulkFile.STATUS_ERROR)					{						return bf;					}					else					{						/* There was an error before so check if we still have retries left. */						if (bf.retryCount < _loadRetries)						{							bf.retryCount++;							return bf;						}					}				}			}			return null;		}						/**		 * @private		 */		protected function removeConnectionFrom(bf:IBulkFile):void		{			var id:String = bf.file.path;			for (var i:String in _usedConnections)			{				if (i == id)				{					_usedConnections[i] = false;					delete _usedConnections[i];					return;				}			}		}						/**		 * @private		 */		protected function createProgressEvent(cf:IBulkFile):FileIOEvent		{			var weightPercent:Number = 0;			var weightLoaded:Number = 0;			var weightTotal:uint = 0;			var filesStarted:uint = 0;			var filesLoaded:uint = 0;			var bytesLoaded:Number = 0;			var bytesTotal:Number = Number.POSITIVE_INFINITY;			var bytesTotalCurrent:Number = 0;						for (var i:int = 0; i < fileCount; i++)			{				var bf:IBulkFile = _files[i].bulkfile;								weightTotal += bf.weight;								if (bf.status == BulkFile.STATUS_PROGRESSING					|| bf.status == BulkFile.STATUS_LOADED)				{					bytesLoaded += bf.bytesLoaded;					bytesTotalCurrent += bf.bytesTotal;										if (bf.bytesTotal > 0)					{						weightLoaded += (bf.bytesLoaded / bf.bytesTotal) * bf.weight;					}										if (bf.status == BulkFile.STATUS_LOADED)					{						filesLoaded++;					}										filesStarted++;				}			}						/* only set bytes total if all items have begun loading */			if (filesStarted == _filesTotal)			{				bytesTotal += bytesTotalCurrent;			}						weightPercent = weightLoaded / weightTotal;			if (weightTotal == 0) weightPercent = 0;						return new BulkFileIOEvent(FileIOEvent.PROGRESS, cf, null, 0, bytesLoaded, bytesTotal, bytesTotalCurrent, filesLoaded, _filesTotal, weightPercent);
		}
	}}