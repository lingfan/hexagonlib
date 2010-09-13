/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.geom{	import flash.geom.Point;		/**	 * Represents an ellipse (circlular or oval) by storing it's position and size.	 */	public class Ellipse	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/**		 * The horizontal position of the ellipse.		 */		public var x:Number;				/**		 * The vertical position of the ellipse.		 */		public var y:Number;				/**		 * The width of the ellipse at its widest horizontal point.		 */		public var width:Number;				/**		 * The height of the ellipse at its tallest point.		 */		public var height:Number;						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates new Ellipse object.		 * 		 * @param x The horizontal position of the ellipse.		 * @param y The vertical position of the ellipse.		 * @param width Width of the ellipse at its widest horizontal point.		 * @param height Height of the ellipse at its tallest point.		 */		public function Ellipse(x:Number, y:Number, width:Number, height:Number)		{			this.x = x;			this.y = y;			this.width = width;			this.height = height;		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * Finds the x and y position of the degree along the circumference of the ellipse.		 * degree can be over 360 or even negitive numbers; minding 0 = 360 = 720, 540 = 180,		 * -90 = 270, etc.		 * 		 * @param degree Number representing a degree on the ellipse.		 * @return a Point object.		 */		public function getPointOfDegree(degree:Number):Point		{			var r:Number = (degree - 90) * (Math.PI / 180);			var xRad:Number = width * 0.5;			var yRad:Number = height * 0.5;			return new Point(x + xRad + Math.cos(r) * xRad, y + yRad + Math.sin(r) * yRad);		}						/**		 * Finds if the specified point is contained inside the ellipse perimeter.		 * 		 * @param point A Point object.		 * @return true if shape's area contains point; otherwise false.		 */		public function containsPoint(point:Point):Boolean		{			var xRad:Number = width * 0.5;			var yRad:Number = height * 0.5;			var xt:Number = point.x - x - xRad;			var yt:Number = point.y - y - yRad;			return Math.pow(xt / xRad, 2) + Math.pow(yt / yRad, 2) <= 1;		}						/**		 * Determines if the Ellipse specified in the ellipse parameter is equal		 * to this Ellipse object.		 * 		 * @param ellipse An Ellipse object.		 * @return true if object is equal to this Ellipse; otherwise false.		 */		public function equals(ellipse:Ellipse):Boolean		{			return x == ellipse.x && y == ellipse.y && width == ellipse.width				&& height == ellipse.height;		}						/**		 * Returns a new Ellipse object with the same values as this Ellipse.		 * 		 * @return a new Ellipse object with the same values as this Ellipse.		 */		public function clone():Ellipse		{			return new Ellipse(x, y, width, height);		}						/**		 * Returns a String Representation of Ellipse.		 * 		 * @return A String Representation of Ellipse.		 */		public function toString():String		{			return "[Ellipse x=" + x + ", y=" + y + ", width=" + width + ", height=" + height + "]";		}						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------				/**		 * The center of the ellipse.		 */		public function get center():Point		{			return new Point(x + width * 0.5, y + height * 0.5);		}		public function set center(v:Point):void		{			x = v.x - width * 0.5;			y = v.y - height * 0.5;		}						/**		 * The size of the ellipse, expressed as a Point object with		 * the values of the width and height properties.		 */		public function get size():Point		{			return new Point(width, height);		}				/**		 * The circumference of the ellipse. Calculating the circumference of		 * an ellipse is difficult; this is an approximation but should be fine		 * for most cases.		 */		public function get perimeter():Number		{			return (Math.sqrt(.5 * (Math.pow(width, 2)				+ Math.pow(height, 2))) * Math.PI * 2) * 0.5;		}				/**		 * The area of the ellipse.		 */		public function get area():Number		{			return Math.PI * (width * 0.5) * (height * 0.5);		}	}}