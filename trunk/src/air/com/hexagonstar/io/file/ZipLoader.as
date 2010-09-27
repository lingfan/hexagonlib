/*
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
	import flash.utils.Endian;
	{
		//-----------------------------------------------------------------------------------------
		/** @private */
		
			_opened = false;
			_streamStarted = false;
		{
			if (!_opened || _state != ZipLoader.OPENED) return false;
			if (e.compressionMethod != ZipConstants.DEFLATE
		{
			return _zipFile.nativePath;
		{
			if (_state != ZipLoader.OPENED)
				_state = ZipLoader.OPENED;
				_opened = true;
				error("Could not find END header of zip file <" + _zipFile.nativePath + ">.");
				{
					error("Missing zip entry file path in zip file <" + _zipFile.nativePath + ">.");
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
	}