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
package com.hexagonstar.motion.easing
{
	/**
	 * ElasticEasing class
	 */
	public class ElasticEasing implements IEasing
	{
		/** @private */
		private var p:Number = NaN;
		/** @private */
		private var a:Number = NaN;
		/** @private */
		private var s:Number = NaN;
		/** @private */
		private var mAbs:Function = Math.abs;
		/** @private */
		private var mAsin:Function = Math.asin;
		/** @private */
		private var mSin:Function = Math.sin;
		/** @private */
		private var mPow:Function = Math.pow;
		/** @private */
		private var mPI:Number = Math.PI;
		
		
		/**
		 * easeIn
		 */
		public function easeIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t == 0) return b;
			if ((t /= d) == 1) return b + c;
			if (isNaN(p)) p = d * .3;
			if (isNaN(a) || a < mAbs(c)) {a = c; s = p / 4;}
			else s = p / (2 * mPI) * mAsin(c / a);
			return -(a * mPow(2, 10 * (t -= 1)) * mSin((t * d - s) * (2 * mPI) / p)) + b;
		}
		
		
		/**
		 * easeOut
		 */
		public function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t == 0) return b;
			if ((t /= d) == 1) return b + c;
			if (isNaN(p)) p = d * .3;
			if (isNaN(a) || a < mAbs(c)) {a = c; s = p / 4;}
			else s = p / (2 * mPI) * mAsin(c / a);
			return (a * mPow(2, -10 * t) * mSin((t * d - s) * (2 * mPI) / p) + c + b);
		}
		
		
		/**
		 * easeInOut
		 */
		public function easeInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t == 0) return b;
			if ((t /= d / 2) == 2) return b + c;
			if (isNaN(p)) p = d * .465;
			if (isNaN(a) || a < mAbs(c)) {a = c; s = p / 4;}
			else s = p / (2 * mPI) * mAsin(c / a);
			if (t < 1) return -.5 * (a * mPow(2, 10 * (t -= 1)) * mSin((t * d - s) * (2 * mPI) / p)) + b;
			return a * mPow(2, -10 * (t -= 1)) * mSin((t * d - s) * (2 * mPI) / p) * .5 + c + b;
		}
	}
}
