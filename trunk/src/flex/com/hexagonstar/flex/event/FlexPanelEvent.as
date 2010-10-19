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
package com.hexagonstar.flex.event
{
	import com.hexagonstar.flex.containers.FlexPanel;

	import flash.events.Event;
	/**	 * FlexPanelEvent Class	 */	public class FlexPanelEvent extends Event	{		//-----------------------------------------------------------------------------------------		// Constants		//-----------------------------------------------------------------------------------------				public static const MOVE:String					= "flexWindowMove";		public static const MAXIMIZE:String				= "flexWindowMaximize";		public static const RESTORE:String				= "flexWindowRestore";		public static const RESIZE:String				= "flexWindowResize";		public static const OK_BUTTON:String			= "flexWindowOKButton";		public static const CANCEL_BUTTON:String		= "flexWindowCancelButton";		public static const CLOSE_BUTTON:String			= "flexWindowCloseButton";		public static const CLOSE:String				= "flexWindowClose";				
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------				public var window:FlexPanel;				
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------				/**		 * Creates a new FlexWindowEvent instance.		 */		public function FlexPanelEvent(type:String, window:FlexPanel = null,			bubbles:Boolean = false, cancelable:Boolean = false)		{			this.window = window;
			super(type, bubbles, cancelable);		}		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------		
		/**
		 * @inheritDoc
		 */		override public function clone():Event		{			return new FlexPanelEvent(type, window, bubbles, cancelable);		}	}}