/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.display.shapes{	import flash.display.JointStyle;	import flash.display.LineScaleMode;	import flash.display.Shape;		/**	 * LineShape Class	 */	public class LineShape extends Shape	{		//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new LineShape instance.		 * 		 * @param startX		 * @param startY		 * @param endX		 * @param endY		 * @param thickness		 * @param color		 * @param alpha		 */		public function LineShape(startX:int			= 0,									 startY:int			= 0,									 endX:int			= 0,									 endY:int			= 0,									 thickness:Number	= 1.0,									 color:uint			= 0xFF00FF,									 alpha:Number		= 1.0)		{			if (startX != endX || startY != endY)				draw(startX, startY, endX, endY, thickness, color, alpha);		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------				/**		 * Draws the line.		 * 		 * @param startX		 * @param startY		 * @param endX		 * @param endY		 * @param thickness		 * @param color		 * @param alpha		 */		public function draw(startX:int,								startY:int,								endX:int,								endY:int,								thickness:Number	= 1.0,								color:uint			= 0xFF00FF,								alpha:Number		= 1.0):void		{			graphics.clear();			graphics.lineStyle(thickness, color, alpha, true, LineScaleMode.NORMAL, null,				JointStyle.MITER);			graphics.moveTo(startX, startY);			graphics.lineTo(endX, endY);		}	}}