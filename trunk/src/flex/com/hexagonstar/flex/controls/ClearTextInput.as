package com.hexagonstar.flex.controls
{
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.events.FlexEvent;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	
	/**
	 * ClearTextInput Class
	 */
	public class ClearTextInput extends TextInput
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const CLEAR_BUTTON:String = "clearButton";
		
		[Embed(source="../assets/clearTextInput_closeButton1.gif")]
		protected static const WINDOW_CLOSE_BUTTON_1:Class;
		[Embed(source="../assets/clearTextInput_closeButton2.gif")]
		protected static const WINDOW_CLOSE_BUTTON_2:Class;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _clearButton:Button;
		protected var _defaultText:String = "";
		protected var _defaultTextColor:String = "#AAAAAA";
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ClearTextInput instance.
		 */
		public function ClearTextInput()
		{
			super();
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			addEventListener("textChanged", onTextChanged);
			addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		[Bindable]
		public function get defaultText():String
		{
			return _defaultText;
		}
		public function set defaultText(v:String):void
		{
			_defaultText = v;
		}
		
		[Bindable]
		public function get defaultTextColor():String
		{
			return _defaultTextColor;
		}
		public function set defaultTextColor(v:String):void
		{
			_defaultTextColor = v;
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
			if (text == "") setDefaultText();
		}
		
		
		/**
		 * @private
		 */
		protected function onFocusIn(e:FocusEvent):void
		{
			if (text == "")
			{
				text = "";
				textField.text = "";
				textField.textColor = getStyle("color");
				_clearButton.visible = false;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onFocusOut(e:FocusEvent):void
		{
			if (text == "")
			{
				setDefaultText();
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onTextChanged(e:Event):void
		{
			if (text != "")
			{
				_clearButton.visible = true;
				textField.textColor = getStyle("color");
			}
			else
			{
				if (focusManager.getFocus() is ClearTextInput
					&& ClearTextInput(focusManager.getFocus()) == this)
				{
					_clearButton.visible = false;
					textField.textColor = getStyle("color");
				}
				else
				{
					callLater(setDefaultText);
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onClearButtonClick(e:MouseEvent):void
		{
			text = "";
			_clearButton.visible = false;
			dispatchEvent(new Event(CLEAR_BUTTON));
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
			setStyle("paddingRight", 20);
			
			_clearButton = new Button();
			with (_clearButton)
			{
				width = 10;
				height = 10;
				y = (this.height - 10) / 2;
				x = this.width - 10 - (this.height - 10) / 2;
				focusEnabled = false;
				buttonMode = true;
				useHandCursor = true;
				mouseChildren = false;
				visible = false;
				setStyle("upSkin", WINDOW_CLOSE_BUTTON_1);
				setStyle("overSkin", WINDOW_CLOSE_BUTTON_2);
				setStyle("downSkin", WINDOW_CLOSE_BUTTON_2);
				addEventListener(MouseEvent.CLICK, onClearButtonClick);
			}
			
			addChild(_clearButton);
		}
		
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number,
			unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_clearButton)
			{
				_clearButton.x = width - 10 - (height - 10) / 2;
				_clearButton.y = (height - 10) / 2;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function setDefaultText():void
		{
			text = "";
			textField.textColor = convertColor(_defaultTextColor);
			textField.text = _defaultText;
			_clearButton.visible = false;
		}
		
		
		/**
		 * @private
		 */
		protected function convertColor(color:String):uint
		{
			if (color.length > 1 && color.substring(0, 1) == "#")
			{
				return uint("0x" + color.substring(1));
			}
			else
			{
				return uint(color);
			}
		}
	}
}
