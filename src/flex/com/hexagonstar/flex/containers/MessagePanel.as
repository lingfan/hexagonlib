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
package com.hexagonstar.flex.containers
{
	import com.hexagonstar.flex.controls.FlexButton;
	import com.hexagonstar.flex.event.FlexPanelEvent;

	import mx.containers.ControlBar;
	import mx.controls.Label;
	import mx.controls.Text;

	import flash.events.MouseEvent;
	
	
	/**
	 * A panel that contains a title, a message and an OK button.
	 */
	public class MessagePanel extends FlexPanel
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _controlBar:ControlBar;
		protected var _okButton:FlexButton;
		protected var _messageTitle:Label;
		protected var _messageText:Text;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		[Bindable]
		public function set messageTitle(v:String):void
		{
			_messageTitle.htmlText = v;
		}
		public function get messageTitle():String
		{
			return _messageTitle.htmlText;
		}
		
		[Bindable]
		public function set messageText(v:String):void
		{
			_messageText.htmlText = v;
		}
		public function get messageText():String
		{
			return _messageText.htmlText;
		}
		
		
		/**
		 * Sets the alignment of the window's button. Allowed values
		 * are "left", "center" and "right".
		 */
		public function set buttonAlignment(v:String):void
		{
			_controlBar.setStyle("horizontalAlign", v);
		}
		public function get buttonAlignment():String
		{
			return _controlBar.getStyle("horizontalAlign");
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onOKButtonClick(e:MouseEvent):void
		{
			dispatchEvent(new FlexPanelEvent(FlexPanelEvent.OK_BUTTON, this));
			close();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function createChildren():void
		{
			_controlBar = new ControlBar();
			addChild(_controlBar);
			
			_okButton = new FlexButton();
			_okButton.label = "OK";
			_controlBar.addChild(_okButton);
			
			super.createChildren();
			
			layout = "vertical";
			
			_messageTitle = new Label();
			_messageTitle.styleName = "messagePanelTitle";
			_messageTitle.percentWidth = 100;
			_messageTitle.selectable = false;
			addChild(_messageTitle);
			
			_messageText = new Text();
			_messageText.styleName = "messagePanelText";
			_messageText.percentWidth = 100;
			_messageText.percentHeight = 100;
			_messageText.selectable = false;
			addChild(_messageText);
		}
		
		
		/**
		 * @private
		 */
		override protected function addEventListeners():void
		{
			super.addEventListeners();
			_okButton.addEventListener(MouseEvent.CLICK, onOKButtonClick);
		}
		
		
		/**
		 * @private
		 */
		override protected function removeEventListeners():void
		{
			super.removeEventListeners();
			_okButton.removeEventListener(MouseEvent.CLICK, onOKButtonClick);
		}
	}
}
