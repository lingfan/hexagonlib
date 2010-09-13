/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.time{	import com.hexagonstar.exception.SingletonException;	import flash.events.Event;	import flash.utils.getTimer;		/**	 * Acts as a timer similar to flash.utils.Timer but only updates	 * it's time once every frame.	 * 	 * @example	 * <pre>	 *	package 	 *	{	 *		import com.hexagonstar.env.time.EnterFrame;	 *		import com.hexagonstar.env.time.FrameTimer;	 *		import flash.display.Sprite;	 *		import flash.events.Event;		 *			 *		public class Example extends Sprite	 *		{	 *			private var _frameTimer:FrameTimer;	 *			private var _enterFrame:EnterFrame;	 *			private var _count:int = 0;	 *				 *			public function Example()	 * 			{	 *				_enterFrame = EnterFrame.instance;	 *				_enterFrame.addEventListener(Event.ENTER_FRAME, onEnterFrame);	 *					 *				_frameTimer = FrameTimer.instance;	 *			}	 *				 *			private function onEnterFrame(e:Event):void	 *			{	 *				if (_count == 30)	 *				{	 *					_count = 0;	 *					trace(_frameTimer.milliseconds + "ms have passed.");	 *				}	 *				_count++;	 *			}	 *		}	 *	}	 * </pre>	 */	public class FrameTimer	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/** @private */		protected static var _instance:FrameTimer;		/** @private */		protected static var _singletonLock:Boolean = false;		/** @private */		protected var _enterFrame:EnterFrame;		/** @private */		protected var _ms:int;						//-----------------------------------------------------------------------------------------		// Constants		//-----------------------------------------------------------------------------------------				/**		 * Creates a new instance of the class.		 */		public function FrameTimer()		{			if (!_singletonLock) throw new SingletonException(this);						_enterFrame = EnterFrame.instance;			_enterFrame.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);			onEnterFrame(new Event(Event.ENTER_FRAME));		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * Returns the singleton instance of FrameTimer.		 */		public static function get instance():FrameTimer		{			if (_instance == null)			{				_singletonLock = true;				_instance = new FrameTimer();				_singletonLock = false;			}			return _instance;		}						/**		 * @return the number of milliseconds from when the SWF started playing		 * to the last enterFrame event.		 */		public function get milliseconds():int		{			return _ms;		}						//-----------------------------------------------------------------------------------------		// Event Handlers		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		protected function onEnterFrame(e:Event):void		{			_ms = getTimer();		}	}}