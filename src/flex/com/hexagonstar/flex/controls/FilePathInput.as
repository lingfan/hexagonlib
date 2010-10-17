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
package com.hexagonstar.flex.controls
{
	import mx.containers.HBox;
	import mx.controls.TextInput;
	import mx.events.FlexEvent;

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	[Event(name="click", type="flash.events.MouseEvent")]
	[Event(name="change", type="flash.events.Event")]
	
	
	/**
	 * FilePathInput Class
	 */
	public class FilePathInput extends HBox
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		[Embed(source="../assets/icon_filePathInput.png")]
		protected static const BROWSE_ICON:Class;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _textInput:TextInput;
		protected var _browseButton:FlexButton;
		protected var _path:String = "";
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new FilePathInput instance.
		 */
		public function FilePathInput()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * dispose
		 */
		public function dispose():void
		{
			removeEventListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		[Bindable]
		[Inspectable(type="String", category="Common")]
		public function set path(v:String):void
		{
			_path = v;
			if (_textInput) updateFilePath();
		}
		public function get path():String
		{
			return _path;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onCreationComplete(e:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			updateFilePath();
			addEventListeners();
		}
		
		
		/**
		 * @private
		 */
		protected function onChange(e:Event):void
		{
			_path = _textInput.text;
			dispatchEvent(e);
		}
		
		
		/**
		 * @private
		 */
		protected function onClick(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			setStyle("horizontalGap", 4);
			
			_textInput = new TextInput();
			_textInput.percentWidth = 100;
			_textInput.maxChars = 2048;
			addChild(_textInput);
			
			_browseButton = new FlexButton();
			_browseButton.width = 22;
			_browseButton.setStyle("icon", BROWSE_ICON);
			addChild(_browseButton);
		}
		
		
		/**
		 * @private
		 */
		protected function addEventListeners():void
		{
			_textInput.addEventListener(Event.CHANGE, onChange);
			_browseButton.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		/**
		 * @private
		 */
		protected function removeEventListeners():void
		{
			_textInput.removeEventListener(Event.CHANGE, onChange);
			_browseButton.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		/**
		 * @private
		 */
		protected function updateFilePath():void
		{
			_textInput.text = _path;
			_textInput.toolTip = _path;
		}
	}
}
