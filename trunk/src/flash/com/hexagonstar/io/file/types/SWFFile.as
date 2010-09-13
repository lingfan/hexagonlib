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

	import com.hexagonstar.data.constants.Status;
	import com.hexagonstar.util.EnvUtil;

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	
	/**
	 * TODO Add better description!
	 */
	public class SWFFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _loader:Loader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ImageFile instance.
		 * @param path
		 * @param id
		 * @param priority
		 * @param weight
		 */
		public function SWFFile(path:String = null, id:String = null, priority:Number = NaN,
			weight:int = 1)
		{
			super(path, id, priority, weight);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get fileTypeID():int
		{
			return FileTypeIndex.SWF_FILE_ID;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsMovieClip;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			if (!_loader) _loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onComplete);
			
			var lc:LoaderContext = new LoaderContext(false,
				new ApplicationDomain(ApplicationDomain.currentDomain));
			
			/* allowCodeImport is only available for AIR and throws an exception if
			 * we don't check for AIR! TODO Is this check safe enough? */
			if (EnvUtil.isAIRApplication())
			{
				try
				{
					lc["allowLoadBytesCodeExecution"] = true;
				}
				catch (err1:Error)
				{
					/* TODO allowLoadBytesCodeExecution property changed in AIR runtime!
					 * Give an error message?  */
				}
				
				try
				{
					lc["allowCodeImport"] = true;
				}
				catch (err2:Error)
				{
					/* Same as above! allowCodeImport is deprecated! */
				}
			}
			
			try
			{
				_loader.loadBytes(v, lc);
				_valid = true;
				_status = Status.OK;
			}
			catch (err:Error)
			{
				_valid = false;
				_status = err.message;
			}
		}
		
		
		/**
		 * The SWFFile as a MovieClip.
		 */
		public function get contentAsMovieClip():MovieClip
		{
			if (_loader) return MovieClip(_loader.content);
			return null;
		}
		
		
		/**
		 * The Loader object that loaded the SWFFile internally.
		 */
		public function get loader():Loader
		{
			return _loader;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onComplete(e:Event):void 
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onComplete);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
