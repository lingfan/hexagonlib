**Contents**



---


# hexagonlib File API Introduction #

hexagonlib provides a collection of file classes to comfortably load and manage any number of files. The file API resides in the **com.hexagonstar.io.file** package and allows you to create file objects that contain the filesystem path to their physical files and then load these files with any of the hexagonlib file loader classes like the _BulkLoader_ or the _ZipLoader_.

To create a file object you choose any of the classes in the **com.hexagonstar.io.file.types** package that reflect the base data type of the physical file you want to load like in the following example which creates instances of _XMLFile_ and _ImageFile_:

```
var xmlFile:XMLFile = new XMLFile("path/to/the/example.xml");
var imageFile:ImageFile = new ImageFile("path/to/the/example.png");
```

File type classes provide a unified interface to access information about the file and the loaded content. You can use the _content_ property to access the loaded file content in untyped form or use any of the accessors which are specific to the file type class but provide the content data strong-typed as for example the _contentAsString_ property of the _TextFile_ class.


---


# Using the BulkLoader #

The _BulkLoader_ class allows you to load a bulk of files. To use the loader you first create file objects and add these to the bulk loader. You then listen for the events fired by the bulk loader and call load() to start loading the files. Your files become available via the FileIOEvent broadcasted by the loader, consider the following example:

```
package 
{
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.*;
	import com.hexagonstar.io.file.BulkLoader;
	
	import flash.display.Sprite;
	
	
	public class Main extends Sprite
	{
		private var _bulkLoader:BulkLoader;
		
		
		public function Main()
		{
			_bulkLoader = new BulkLoader();
			_bulkLoader.addEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete);
			_bulkLoader.addEventListener(FileIOEvent.COMPLETE, onComplete);
			
			_bulkLoader.addFile(new XMLFile("path/to/example.xml"));
			_bulkLoader.addFile(new ImageFile("path/to/example.png"));
			_bulkLoader.addFile(new ImageFile("path/to/another.jpg"));
			_bulkLoader.addFile(new BinaryFile("path/to/shader.pbj"));
			
			_bulkLoader.load();
		}
		
		
		private function onFileComplete(e:FileIOEvent):void
		{
			trace("Loaded file: " + e.file.path);
		}
		
		
		private function onComplete(e:FileIOEvent):void
		{
			trace("All files loaded.");
		}
	}
}
```

It is also possible to use the _Queue_ class to create a **queue of file objects** and add these quickly to the bulk loader:

```
package 
{
	import com.hexagonstar.data.structures.queues.Queue;
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.*;
	import com.hexagonstar.io.file.BulkLoader;
	
	import flash.display.Sprite;
	
	public class Main extends Sprite
	{
		private var _bulkLoader:BulkLoader;
		
		
		public function Main()
		{
			_bulkLoader = new BulkLoader();
			_bulkLoader.addEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete);
			_bulkLoader.addEventListener(FileIOEvent.COMPLETE, onComplete);
			_bulkLoader.addEventListener(FileIOEvent.IO_ERROR, onFileError);
			
			var queue:Queue = new Queue();
			for (var i:int = 0; i < 20; i++)
			{
				queue.add(new ImageFile("images/image" + i + ".jpg"));
			}
			
			_bulkLoader.addFileQueue(queue);
			_bulkLoader.load();
		}
		
		
		private function onFileComplete(e:FileIOEvent):void
		{
			trace("Loaded file: " + e.file.path);
		}
		
		
		private function onComplete(e:FileIOEvent):void
		{
			trace("All files loaded.");
		}
		
		
		private function onFileError(e:FileIOEvent):void
		{
			trace("Failed loading file: " + e.file.path + " (Error was: " + e.text + ")");
		}
	}
}
```

## Load Priorities ##

Files are loaded in the same order they were added to the bulk loader unless you set the load priority on files. A file with a higher priority value is loaded before one with a lower value. In the following example file2 would be loaded before file1:

```
var file1:TextFile = new TextFile("example.txt", null, 0);
var file2:TextFile = new TextFile("another.txt");
file2.priority = 1;
```

## Load Connections ##

By default the bulk loader loads one file at a time and then continues with the next. However if files are loaded over a network (e.g. from a server) it can be beneficial to raise the amount of load connections so that more than one file is loaded at (nearly) the same time. You can use the _maxConnections_ property of the _BulkLoader_ class for this. E.g. setting this property to 4 like ...

```
_bulkLoader.maxConnections = 4;
```

... will let the bulk loader load up to four files simultaneously. Anytime a file is done loading the next one in the file bulk will be loaded until no more are left. NOTE: loading more than one file at the same time will still sort and start loading files by priority but it cannot be assured which file has been finished loading first and is therefore first available for the application.


---


# Using the ZipLoader #

The _ZipLoader_ class is available for AIR development and allows you to open a standard zip file and extract packed files from it using [Random Access](http://en.wikipedia.org/wiki/Random_access). This makes it possible to create large zip archives which contain many resources and access these in an AIR application without ever needing to load the whole zip file into memory.

To use the ZipLoader you first have to open a zip file with it by providing a _flash.filesystem.File_ object and listen for the _Event.OPEN_ event which is broadcasted once the zip loader is ready for accessing the zip file's contents. Once the ZipLoader is ready you can add file objects to it in the same fashion as with the BulkLoader that can then be 'loaded' from the zip file. The following example opens a zip file named _resources.zip_ which is located in the application folder and then 'loads' three resource files from it:

```
package 
{
	import com.hexagonstar.event.FileIOEvent;
	import com.hexagonstar.io.file.types.XMLFile;
	import com.hexagonstar.io.file.types.ImageFile;
	import com.hexagonstar.io.file.types.IFile;
	import com.hexagonstar.io.file.ZipLoader;
	
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	
	public class Main extends Sprite
	{
		private var _zipFile:File;
		private var _zipLoader:ZipLoader;
		
		
		public function Main()
		{
			_zipFile = File.applicationDirectory.resolvePath("resources.zip");
			_zipLoader = new ZipLoader(_zipFile);
			_zipLoader.addEventListener(Event.OPEN, onZipLoaderOpen);
			_zipLoader.addEventListener(Event.CLOSE, onZipLoaderClose);
			_zipLoader.addEventListener(IOErrorEvent.IO_ERROR, onZipLoaderError);
			_zipLoader.open();
		}
		
		
		private function onZipLoaderOpen(e:Event):void
		{
			/* ZipLoader has been opened, let's extract some files from it */
			_zipLoader.addEventListener(FileIOEvent.FILE_COMPLETE, onFileComplete);
			_zipLoader.addEventListener(FileIOEvent.IO_ERROR, onFileError);
			_zipLoader.addFile(new ImageFile("images/texture_115.png"));
			_zipLoader.addFile(new ImageFile("images/tileset_level2.png"));
			_zipLoader.addFile(new XMLFile("maps/level2_map.xml"));
			_zipLoader.load();
		}
		
		
		private function onZipLoaderClose(e:Event):void
		{
			trace("ZipLoader closed.");
			_zipLoader.dispose();
		}
		
		
		private function onZipLoaderError(e:IOErrorEvent):void
		{
			trace("Error trying to open the zip file (Error was: " + e.text + ").");
		}
		
		
		private function onFileComplete(e:FileIOEvent):void
		{
			var file:IFile = e.file;
			trace("Loaded file from zip: " + file.path);
			if (file.valid)
			{
				// Do something with the file.
			}
			else
			{
				trace("File invalid: " + file.status);
			}
		}
		
		
		private function onFileError(e:FileIOEvent):void
		{
			trace("Error trying to load file from zip: " + e.text);
		}
	}
}
```