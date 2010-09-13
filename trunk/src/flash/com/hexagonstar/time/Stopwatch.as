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
package com.hexagonstar.time
{
	import com.hexagonstar.core.IResumable;

	import flash.utils.getTimer;

	
	/**
	 * Simple stopwatch class that records elapsed time in milliseconds.
	 * 
	 * @example
	 * <pre>
	 *	package
	 *	{
	 *		import flash.display.Sprite;
	 *		import com.hexagonstar.env.time.Stopwatch;
	 *		
	 *		public class Example extends Sprite
	 *		{
	 *			public function Example()
	 *			{
	 *				var stopwatch:Stopwatch = new Stopwatch();
	 *				stopwatch.start();
	 *				
	 *				var t:int = 1000000;
	 *				while (t--)
	 *				{
	 *					doSomething();
	 *				}
	 *				
	 *				trace(stopwatch.time);
	 *			}
	 *			
	 *			public function doSomething():void
	 *			{
	 *			}
	 *		}
	 *	}
	 * </pre>
	 */
	public class Stopwatch implements IResumable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _elapsedTime:int;
		/** @private */
		protected var _startTime:int;
		/** @private */
		protected var _isStopped:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Stopwatch instance.
		 */
		public function Stopwatch()
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the Stopwatch and resets any previous elapsed time.
		 */
		public function start():void
		{
			_elapsedTime = 0;
			_startTime = timer;
			_isStopped = false;
		}
		
		
		/**
		 * Stops the Stopwatch.
		 */
		public function stop():void 
		{
			_elapsedTime = time;
			_startTime = 0;
			_isStopped = true;
		}
		
		
		/**
		 * Resumes the Stopwatch after it has been stopped.
		 */
		public function resume():void
		{
			if (_isStopped) _startTime = timer;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the time elapsed since start() or until stop() was called.
		 * Can be called before or after calling stop().
		 * 
		 * @return the elapsed time in milliseconds.
		 */
		public function get time():int
		{
			return (_startTime != 0) ? timer - _startTime + _elapsedTime : _elapsedTime;
		}
		
		
		/**
		 * @private
		 */
		protected function get timer():int
		{
			return getTimer();
		}
	}
}
