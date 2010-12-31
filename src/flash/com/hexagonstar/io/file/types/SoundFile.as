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
	import com.hexagonstar.exception.IllegalArgumentException;
	import com.hexagonstar.exception.IllegalOperationException;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.ByteArray;

	
	/**
	 * Dispatched after the file's content has been loaded. This event is always
	 * broadcasted after the file finished loading, regardless whether it's content data
	 * could be parsed sucessfully or not. Use the <code>valid</code> property after the
	 * file has been loaded to check if the content is available.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	
	/**
	 * The SoundFile is a file type implementation that can be used to load sound file
	 * formats that are supported by Flash (MP3 only, wohoo!). It uses the AS3 Sound class
	 * to load the sound file after which the sound object can be directly obtained from
	 * the SoundFile.
	 * 
	 * @see com.hexagonstar.io.file.types.IFile
	 */
	public class SoundFile extends BinaryFile implements IFile
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _sound:Sound;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the sound file class.
		 * 
		 * @param path The path of the file that this file object is used for.
		 * @param id An optional ID for the file.
		 * @param priority An optional load priority for the file. Used for loading with the
		 *            BulkLoader class.
		 * @param weight An optional weight for the file. Used for weighted loading with the
		 *            BulkLoader class.
		 */
		public function SoundFile(path:String = null, id:String = null, priority:Number = NaN,
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
			return FileTypeIndex.SOUND_FILE_ID;
		}

		
		/**
		 * @inheritDoc
		 */
		override public function get content():*
		{
			return contentAsSound;
		}
		override public function set content(v:*):void
		{
			if (v is Sound)
			{
				_sound = v;
				_valid = true;
				_status = Status.OK;
			}
			else
			{
				_valid = false;
				_status = "SoundFile only accepts a Sound object as content.";
				throw new IllegalArgumentException(toString() + " " + _status);
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * The SoundFile content, as a Sound object.
		 */
		public function get contentAsSound():Sound
		{
			return _sound;
		}
		
		
		/**
		 * The sound file's content data, as a ByteArray. This simply writes the sound
		 * object into a ByteArray and returns it.
		 */
		override public function get contentAsBytes():ByteArray
		{
			if (!_sound) return null;
			var b:ByteArray = new ByteArray();
			b.writeObject(_sound);
			b.position = 0;
			return b;
		}
		
		
		/**
		 * Unsupported by the SoundFile class! The SoundFile only accepts a Sound object
		 * provided via <code>content</code>.
		 */
		override public function set contentAsBytes(v:ByteArray):void
		{
			throw new IllegalOperationException(toString()
					+ " SoundFile does no support setting contentAsBytes.");
		}
	}
}
