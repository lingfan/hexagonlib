/*
{
	import com.hexagonstar.algo.compr.Inflate;
	import com.hexagonstar.data.constants.ZipConstants;
	import com.hexagonstar.event.BulkFileIOEvent;
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.IFile;
	import com.hexagonstar.io.file.types.ZipEntry;
	import com.hexagonstar.io.file.types.ZipFile;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
			_bytesTotal = _fileSize;
		//-----------------------------------------------------------------------------------------
			_over = (_offset + _bufferSize) - _zipFile.size;
			_stream.readAhead = _bufferSize;
		/**
			removeLoaderListenersFrom();
			ZippedFile._inflate = null;
		{
			_bytesLoaded = _buffer.length > _fileSize ? _fileSize : _buffer.length;
			if (_extraLength == -1)
			{
					_extraLength += _entry.path.length + 2;
					_stream.readBytes(_buffer, _stream.position - _offset - _extraLength, _bufferSize); 
		}
		/**
			removeLoaderListenersFrom();
			relayEvent(FileIOEvent.IO_ERROR, e.text);
			/* If _over is larger than 0 it means that the file chunk is within the end area
				_stream.readBytes(_buffer, _stream.position - _offset - _extraLength,
			_bytesLoaded = _fileSize;
			if (_entry.compressionMethod == ZipConstants.DEFLATE)