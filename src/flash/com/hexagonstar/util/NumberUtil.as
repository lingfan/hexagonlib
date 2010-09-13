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
package com.hexagonstar.util
{
	/**
	 * Provides utility methods for nummeric operations.
	 */
	public class NumberUtil
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the specified number is even.
		 *
		 * @param value aA number to determine if it is divisible by 2.
		 * @return true if the number is even; otherwise false.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.isEven(7)); // Traces false
		 *     trace(NumberUtil.isEven(12)); // Traces true
		 * </pre>
		 */
		public static function isEven(value:Number):Boolean 
		{
			return (value & 1) == 0;
		}
		
		
		/**
		 * Determines if the specified number is odd.
		 * 
		 * @param value a number to determine if it is not divisible by 2.
		 * @return Returns true if the number is odd; otherwise false.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.isOdd(7)); // Traces true
		 *     trace(NumberUtil.isOdd(12)); // Traces false
		 * </pre>
		 */
		public static function isOdd(value:Number):Boolean 
		{
			return !isEven(value);
		}
		
		
		/**
		 * Determines if the specified number is an integer.
		 * 
		 * @param value a number to determine if it contains no decimal values.
		 * @return Returns true if the number is an integer; otherwise false.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.isInteger(13)); // Traces true
		 *     trace(NumberUtil.isInteger(1.2345)); // Traces false
		 * </pre>
		 */
		public static function isInteger(value:Number):Boolean 
		{
			return (value % 1) == 0;
		}
		
		
		/**
		 * Checks if the specified number is an unsigned integer, i.e. a
		 * number that is 0 or positive and has no decimal places.
		 *
		 * @param number the number to check.
		 * @return true if the number is unsigned otherwise false.
		 */	
		public static function isUnsignedInteger(value:Number):Boolean
		{
			return (value >= 0 && value % 1 == 0);
		}
		
		
		/**
		 * Checks if the specified number is a prime. A prime number is a positive
		 * integer that has no positive integer divisors other than 1 and itself.
		 * 
		 * @param value a number to determine if it is only divisible by 1 and itself.
		 * @return true if the number is prime; otherwise false.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.isPrime(13)); // Traces true
		 *     trace(NumberUtil.isPrime(4)); // Traces false
		 * </pre>
		 */
		public static function isPrime(value:Number):Boolean 
		{
			if (value == 1 || value == 2) return true;
			if (isEven(value)) return false;
			
			var s:Number = Math.sqrt(value);
			for (var i:int = 3; i <= s; i++)
			{
				if (value % i == 0) return false;
			}
			
			return true;
		}
		
		
		/**
		 * Calculates the factorial of the specified value. A factorial is the
		 * total of an integer when multiplied by all lower positive integers.
		 *
		 * @param value the number to calculate the factorial of.
		 * @return the factorial of the number.
		 */
		public static function getFactorialOf(value:int):Number
		{
			if (value == 0) return 1;
			var d:Number = value.valueOf();
			var i:Number = d - 1;
			while (i)
			{
				d = d * i;
				i--;
			}
			return d;
		}
		
		
		/**
		 * Returns a Vector with all divisors of the specified value.
		 * 
		 * @param value the number from which to return the divisors of.
		 * @return a Vector that contains the divisors of number.
		 */
		public static function getDivisorsOf(value:int):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			var e:Number = value / 2;
			for (var i:uint = 1; i <= e; i++)
			{
				if (value % i == 0) v.push(i);
			}
			if (value != 0) v.push(value.valueOf());
			return v;
		}
		
		
		
		
		/**
		 * Determines if the specified value is included within a range. The range
		 * values do not need to be in order.
		 *
		 * @param value Number to determine if it is included in the range.
		 * @param start First value of the range.
		 * @param end Second value of the range.
		 * @return true if the number falls within the range; otherwise false.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.isBetween(3, 0, 5)); // Traces true
		 *     trace(NumberUtil.isBetween(7, 0, 5)); // Traces false
		 * </pre>
		 */
		public static function isBetween(value:Number, start:Number, end:Number):Boolean 
		{
			return !(value < Math.min(start, end) || value > Math.max(start, end));
		}
		
		
		/**
		 * Determines if the specified value falls within a range; if not it is snapped
		 * to the nearest range value. The constraint values do not need to be in order.
		 * 
		 * @param value Number to determine if it is included in the range.
		 * @param start First value of the range.
		 * @param end Second value of the range.
		 * @return Returns either the number as passed, or its value once snapped to
		 *          the nearest range value.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.constrain(3, 0, 5)); // Traces 3
		 *     trace(NumberUtil.constrain(7, 0, 5)); // Traces 5
		 * </pre>
		 */
		public static function constrain(value:Number, start:Number, end:Number):Number 
		{
			return Math.min(Math.max(value, Math.min(start, end)), Math.max(start, end));
		}
		
		
		/**
		 * Creates a Vector of evenly spaced numerical increments between two numbers.
		 * 
		 * @param start The starting value.
		 * @param end The ending value.
		 * @param steps The number of increments between the starting and ending values.
		 * @return Returns a Vector composed of the increments between the two values.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.createStepsBetween(0, 5, 4)); // Traces 1,2,3,4
		 *     trace(NumberUtil.createStepsBetween(1, 3, 3)); // Traces 1.5,2,2.5
		 * </pre>
		 */
		public static function createStepsBetween(start:Number, end:Number,
			steps:Number):Vector.<Number>
		{
			steps++;
			
			var i:int = 0;
			var v:Vector.<Number> = new Vector.<Number>();
			var increment:Number = (end - start) / steps;
			
			while (++i < steps)
			{
				v.push((i * increment) + start);
			}
			
			return v;
		}
		
		
		/**
		 * Formats a number.
		 * 
		 * @param value The number you wish to format.
		 * @param minLength The minimum length of the number.
		 * @param delimChar The character used to seperate thousands.
		 * @param fillChar The leading character used to make the number the minimum length.
		 * @return Returns the formated number as a String.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.format(1234567, 8, ",")); // Traces 01,234,567
		 * </pre>
		 */
		public static function format(value:Number, minLength:int,
			delimChar:String = null, fillChar:String = null):String
		{
			var n:String = value.toString();
			var l:int = n.length;
			
			if (delimChar != null)
			{
				var numSplit:Array = n.split("");
				var c:int = 3;
				var i:int = numSplit.length;
				
				while (--i > 0)
				{
					c--;
					if (c == 0) 
					{
						c = 3;
						numSplit.splice(i, 0, delimChar);
					}
				}
				
				n = numSplit.join("");
			}
			
			if (minLength != 0)
			{
				if (l < minLength) 
				{
					minLength -= l;
					var addChar:String = (fillChar == null) ? "0" : fillChar;
					
					while (minLength--)
					{
						n = addChar + n;
					}
				}
			}
			
			return n;
		}
		
		
		/**
		 * Finds the English ordinal suffix for the number given.
		 * 
		 * @param value Number to find the ordinal suffix of.
		 * @return Returns the suffix for the number, 2 characters.
		 * 
		 * @example
		 * <pre>
		 *     trace(32 + NumberUtil.getOrdinalSuffix(32)); // Traces 32nd
		 * </pre>
		 */
		public static function getOrdinalSuffix(value:int):String 
		{
			if (value >= 10 && value <= 20) return "th";
			switch (value % 10)
			{
				case 0:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
					return "th";
				case 3:
					return "rd";
				case 2:
					return "nd";
				case 1:
					return "st";
				default:
					return "";
			}
		}
		
		
		/**
		 * Adds leading zeroes in front of the specified value up the amount specified
		 * by the digits parameter.
		 * 
		 * @param value Number to add leading zeroes.
		 * @param digits determines the amount of digits that the number must have to still
		 *         get leading zeroes.
		 * @return the Number as a String.
		 * 
		 * @example
		 * <pre>
		 *     trace(NumberUtil.addLeadingZeroes(7, 3)); // Traces 007
		 *     trace(NumberUtil.addLeadingZeroes(10, 4)); // Traces 0010
		 * </pre>
		 */
		public static function addLeadingZeroes(value:Number, digits:int = 4):String 
		{
			var s:String = value.toString();
			var l:int = s.length;
			var z:String = "";
			
			if (l >= digits) return s;
			
			digits -= l;
			for (var i:int = 0; i < digits; i++)
			{
				z += "0";
			}
			
			return z + s;
		}
	}
}
