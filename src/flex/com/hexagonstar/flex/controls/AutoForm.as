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
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.controls.Spacer;
	import mx.core.UIComponent;

	/**
	 * AutoForm Class
	 */
	public class AutoForm extends Form
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _alignment:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 * 
		 * @param alignment Alignment used for forum items, "left or "right".
		 */
		public function AutoForm(alignment:String = "left")
		{
			_alignment = alignment;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a new item to the form.
		 */
		public function addItem(label:String, item:UIComponent, itemWidth:Number = NaN):void
		{
			var formItem:FormItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.label = label;
			
			if (isNaN(itemWidth))
			{
				item.percentWidth = 100;
			}
			else
			{
				formItem.setStyle("horizontalAlign", _alignment);
				item.width = itemWidth;
			}
			
			addChild(formItem);
			formItem.addChild(item);
		}
		
		
		public function addSpacer(height:int = 0):void
		{
			var s:Spacer = new Spacer();
			s.percentWidth = 100;
			
			if (height > 0)
			{
				s.height = height;
			}
			else
			{
				s.percentHeight = 100;
			}
			
			addChild(s);
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
			
			percentWidth = 100;
			
			setStyle("paddingTop", 0);
			setStyle("paddingBottom", 0);
			setStyle("paddingLeft", 0);
			setStyle("paddingRight", 0);
		}
	}
}
