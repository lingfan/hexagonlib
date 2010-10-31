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
	import com.hexagonstar.display.StageReference;
	import com.hexagonstar.flex.controls.FlexButton;
	import com.hexagonstar.flex.event.FlexPanelEvent;

	import mx.containers.Panel;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.managers.PopUpManager;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	/**
	 * A resizeable and maximizeable panel.
	 */
	public class FlexPanel extends Panel
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private static const SIDE_OTHER:Number	= 0;
		private static const SIDE_TOP:Number	= 1;
		private static const SIDE_BOTTOM:Number	= 2;
		private static const SIDE_LEFT:Number	= 4;
		private static const SIDE_RIGHT:Number	= 8;
		
		private static const _shadowFilter:GlowFilter =
			new GlowFilter(0x000000, 1.0, 12, 12, 1, BitmapFilterQuality.MEDIUM);
		
		[Embed(source="../assets/cursor_verticalResize.png")]
		private static const VERTICAL:Class;
		[Embed(source="../assets/cursor_horizontalResize.png")]
		private static const HORIZONTAL:Class;
		[Embed(source="../assets/cursor_leftObliqueResize.png")]
		private static const LEFT_OBLIQUE:Class;
		[Embed(source="../assets/cursor_rightObliqueResize.png")]
		private static const RIGHT_OBLIQUE:Class;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected static var _resizeObj:FlexPanel;
		protected static var _resizeMargin:Number = 6;
		protected static var _mouseState:Number = 0;
		protected static var _cursorType:Class = null;
		
		protected var _stage:Stage;
		protected var _titleBar:UIComponent;
		protected var _maxButton:FlexButton;
		protected var _closeButton:FlexButton;
		
		protected var _minWidth:int = 300;
		protected var _minHeight:int = 160;
		protected var _boundTop:int = 0;
		protected var _boundBottom:int = 0;
		protected var _boundLeft:int = 0;
		protected var _boundRight:int = 0;
		
		protected var _op:Point;
		protected var _ow:Number = 0;
		protected var _oh:Number = 0;
		protected var _ox:Number = 0;
		protected var _oy:Number = 0;
		
		protected var _resizable:Boolean = true;
		protected var _dragable:Boolean = true;
		protected var _maximized:Boolean = false;
		protected var _resizing:Boolean = false;
		protected var _preventDragging:Boolean = false;
		protected var _showShadow:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function FlexPanel()
		{
			_stage = StageReference.stage;
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			width = _minWidth;
			height = _minHeight;
			
			super();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function bringToFront():void
		{
			if (parent)
			{
				parent.setChildIndex(this, parent.numChildren - 1);
			}
		}
		
		
		public function close():void
		{
			dispose();
			
			try
			{
				PopUpManager.removePopUp(this);
			}
			catch (err:Error)
			{
				parent.removeChild(this);
			}
			
			dispatchEvent(new FlexPanelEvent(FlexPanelEvent.CLOSE, this));
		}
		
		
		/**
		 * Disposes the class.
		 */
		public function dispose():void
		{
			removeEventListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		[Bindable]
		public function get resizable():Boolean
		{
			return _resizable;
		}
		public function set resizable(v:Boolean):void
		{
			_resizable = v;
		}
		
		
		[Bindable]
		public function get dragable():Boolean
		{
			return _dragable;
		}
		public function set dragable(v:Boolean):void
		{
			_dragable = v;
		}
		
		
		[Bindable]
		public function set closeButtonEnabled(v:Boolean):void
		{
			_closeButton.enabled = v;
		}
		public function get closeButtonEnabled():Boolean
		{
			return _closeButton.enabled;
		}
		
		
		[Bindable]
		public function set maximizable(v:Boolean):void
		{
			_maxButton.enabled = v;
		}
		public function get maximizable():Boolean
		{
			return _maxButton.enabled;
		}
		
		
		[Bindable]
		public function set maximized(v:Boolean):void
		{
			_maximized = v;
		}
		public function get maximized():Boolean
		{
			return _maximized;
		}
		
		
		[Bindable]
		public function set minimumWidth(v:int):void
		{
			_minWidth = (v < 0) ? 0 : v;
		}
		public function get minimumWidth():int
		{
			return _minWidth;
		}
		
		
		[Bindable]
		public function set minimumHeight(v:int):void
		{
			_minHeight = (v < 0) ? 0 : v;
		}
		public function get minimumHeight():int
		{
			return _minHeight;
		}
		
		
		[Bindable]
		public function set boundTop(v:int):void
		{
			_boundTop = v;
		}
		public function get boundTop():int
		{
			return _boundTop;
		}
		
		
		[Bindable]
		public function set boundBottom(v:int):void
		{
			_boundBottom = v;
		}
		public function get boundBottom():int
		{
			return _boundBottom;
		}
		
		
		[Bindable]
		public function set boundLeft(v:int):void
		{
			_boundLeft = v;
		}
		public function get boundLeft():int
		{
			return _boundLeft;
		}
		
		
		[Bindable]
		public function set boundRight(v:int):void
		{
			_boundRight = v;
		}
		public function get boundRight():int
		{
			return _boundRight;
		}
		
		
		[Bindable]
		public function get showShadow():Boolean
		{
			return _showShadow;
		}
		public function set showShadow(v:Boolean):void
		{
			_showShadow = v;
		}
		
		
		public static function set resizeMargin(v:int):void
		{
			_resizeMargin = v;
		}
		public static function get resizeMargin():int
		{
			return _resizeMargin;
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
			checkBoundaries();
			initPosition(this);
			addEventListeners();
		}
		
		
		/**
		 * @private
		 */
		protected function onWindowClick(e:MouseEvent):void
		{
			_titleBar.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			//bringToFront();
		}
		
		
		/**
		 * @private
		 */
		protected function onDragStart(e:MouseEvent):void
		{
			if (!_dragable || _preventDragging) return;
			_titleBar.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
		}
		
		
		/**
		 * @private
		 */
		protected function onDragMove(e:MouseEvent):void
		{
			if (!_resizing && width < _stage.stageWidth)
			{
				_stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
				_titleBar.addEventListener(DragEvent.DRAG_DROP,onDragStop);
				bringToFront();
				startDrag(false, new Rectangle(_boundLeft, _boundTop,
					(_stage.stageWidth - _boundRight - _boundLeft) - width,
					(_stage.stageHeight - _boundBottom - _boundTop) - height));
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onDragStop(e:MouseEvent):void
		{
			_titleBar.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			stopDrag();
			dispatchEvent(new FlexPanelEvent(FlexPanelEvent.MOVE, this));
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseMove(e:MouseEvent):void
		{
			if (!_resizable) return;
			/* No resizing allowed if window is maximized */
			if (!_maximized)
			{
				if (!_resizeObj)
				{
					var xp:Number = _stage.mouseX;
					var yp:Number = _stage.mouseY;
					
					if (xp >= (x + width - _resizeMargin) && yp >= (y + height - _resizeMargin))
					{
						changeCursor(LEFT_OBLIQUE, -6, -6);
						_mouseState = SIDE_RIGHT | SIDE_BOTTOM;
					}
					else if (xp <= (x + _resizeMargin) && yp <= (y + _resizeMargin))
					{
						changeCursor(LEFT_OBLIQUE, -6, -6);
						_mouseState = SIDE_LEFT | SIDE_TOP;
					}
					else if (xp <= (x + _resizeMargin) && yp >= (y + height - _resizeMargin))
					{
						changeCursor(RIGHT_OBLIQUE, -6, -6);
						_mouseState = SIDE_LEFT | SIDE_BOTTOM;
					}
					else if (xp >= (x + width - _resizeMargin) && yp <= (y + _resizeMargin))
					{
						changeCursor(RIGHT_OBLIQUE, -6, -6);
						_mouseState = SIDE_RIGHT | SIDE_TOP;
					}
					else if (xp >= (x + width - _resizeMargin))
					{
						changeCursor(HORIZONTAL, -9, -9);
						_mouseState = SIDE_RIGHT;	
					}
					else if (xp <= (x + _resizeMargin))
					{
						changeCursor(HORIZONTAL, -9, -9);
						_mouseState = SIDE_LEFT;
					}
					else if (yp >= (y + height - _resizeMargin))
					{
						changeCursor(VERTICAL, -9, -9);
						_mouseState = SIDE_BOTTOM;
					}
					else if (yp <= (y + _resizeMargin))
					{
						changeCursor(VERTICAL, -11, -11);
						_mouseState = SIDE_TOP;
					}
					else
					{
						_mouseState = SIDE_OTHER;
						changeCursor(null, 0, 0);
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseOut(e:MouseEvent):void
		{
			if (!_resizable) return;
			if (!_resizeObj)
			{
				changeCursor(null, 0, 0);
				_resizing = false;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseDown(e:MouseEvent):void
		{
			if (_resizable && _mouseState != SIDE_OTHER)
			{
				onWindowClick(e);
				_resizeObj = FlexPanel(e.currentTarget);
				initPosition(_resizeObj);
				_op.x = _resizeObj.mouseX;
				_op.y = _resizeObj.mouseY;
				_op = this.localToGlobal(_op);
				_resizing = true;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function onMouseUp(e:MouseEvent):void
		{
			if (!_resizable) return;
			if (_resizeObj)
			{
				initPosition(_resizeObj);
				_resizing = false;
				dispatchEvent(new FlexPanelEvent(FlexPanelEvent.RESIZE, this));
			}
			_resizeObj = null;
		}
		
		
		/**
		 * @private
		 */
		protected function onResize(e:MouseEvent):void
		{
			if (!_resizable) return;
			// TODO Add condition to not allow dragging over the bounds (right & bottom)!
			if (_resizeObj)
			{
				_resizeObj.stopDragging();
				
				var ro:FlexPanel = _resizeObj;
				var xpl:Number = _stage.mouseX - _resizeObj._op.x;
				var ypl:Number = _stage.mouseY - _resizeObj._op.y;
				var mw:int = _minWidth;
				var mh:int = _minHeight;
				
				switch (_mouseState)
				{
					case SIDE_RIGHT:
						ro.width = ro._ow + xpl > mw ? ro._ow + xpl : mw;
						break;
					case SIDE_LEFT:
						ro.x = xpl < ro._ow - mw ? ro._ox + xpl : ro.x;
						ro.width = ro._ow - xpl > mw ? ro._ow - xpl : mw;
						break;
					case SIDE_BOTTOM:
						ro.height = ro._oh + ypl > mh ? ro._oh + ypl : mh;
						break;
					case SIDE_TOP:
						ro.y = ypl < ro._oh - mh ? ro._oy + ypl : ro.y;
						ro.height = ro._oh - ypl > mh ? ro._oh - ypl : mh;
						break;
					case SIDE_RIGHT | SIDE_BOTTOM:
						ro.width = ro._ow + xpl > mw ? ro._ow + xpl : mw;
						ro.height = ro._oh + ypl > mh ? ro._oh + ypl : mh;
						break;
					case SIDE_LEFT | SIDE_TOP:
						ro.x = xpl < ro._ow - mw ? ro._ox + xpl : ro.x;
						ro.y = ypl < ro._oh - mh ? ro._oy + ypl : ro.y;
						ro.width = ro._ow - xpl > mw ? ro._ow - xpl : mw;
						ro.height = ro._oh - ypl > mh ? ro._oh - ypl : mh;
						break;
					case SIDE_LEFT | SIDE_BOTTOM:
						ro.x = xpl < ro._ow - mw ? ro._ox + xpl : ro.x;
						ro.width = ro._ow - xpl > mw ? ro._ow - xpl : mw;
						ro.height = ro._oh + ypl > mh ? ro._oh + ypl : mh;
						break;
					case SIDE_RIGHT | SIDE_TOP:
						ro.y = ypl < ro._oh - mh ? ro._oy + ypl : ro.y;
						ro.width = ro._ow + xpl > mw ? ro._ow + xpl : mw;
						ro.height = ro._oh - ypl > mh ? ro._oh - ypl : mh;
						break;
				}
			}
			positionChildren();
		}
		
		
		/**
		 * @private
		 */
		protected function onTitleBarDoubleClick(e:MouseEvent):void
		{
			if (!_maxButton.enabled || _preventDragging) return;
			onMaximize(null);
		}
		
		
		/**
		 * @private
		 */
		protected function onMaximize(e:MouseEvent):void
		{
			if (!_maxButton.enabled) return;
			if (!_maximized)
			{
				initPosition(this);
				x = _boundLeft;
				y = _boundTop;
				width = _stage.stageWidth - _boundRight - _boundLeft;
				height = _stage.stageHeight - _boundBottom - _boundTop;
				_maxButton.styleName = "restoreButton";
				_maximized = true;
				dispatchEvent(new FlexPanelEvent(FlexPanelEvent.MAXIMIZE, this));
			}
			else
			{
				x = _ox;
				y = _oy;
				width = _ow;
				height = _oh;
				_maxButton.styleName = "maximizeButton";
				_maximized = false;
				dispatchEvent(new FlexPanelEvent(FlexPanelEvent.RESTORE, this));
			}
			checkBoundaries();
		}
		
		
		/**
		 * @private
		 */
		protected function onButtonOver(e:MouseEvent):void
		{
			_preventDragging = true;
		}
		
		
		/**
		 * @private
		 */
		protected function onButtonOut(e:MouseEvent):void
		{
			_preventDragging = false;
		}
		
		
		/**
		 * @private
		 */
		protected function onClose(e:MouseEvent):void
		{
			close();
		}
		
		
		/**
		 * @private
		 */
		protected function onStageResize(e:Event):void
		{
			checkBoundaries();
			
			if (_maximized)
			{
				x = _boundLeft;
				y = _boundTop;
				width = _stage.stageWidth - _boundRight - _boundLeft;
				height = _stage.stageHeight - _boundBottom - _boundTop;
				positionChildren();
			}
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
			
			doubleClickEnabled = true;
			
			_titleBar = super.titleBar;
			_op = new Point();
			
			_maxButton = new FlexButton();
			_maxButton.width = 16;
			_maxButton.height = 16;
			_maxButton.styleName = "maximizeButton";
			_titleBar.addChild(_maxButton);
			
			_closeButton = new FlexButton();
			_closeButton.width = 16;
			_closeButton.height = 16;
			_closeButton.styleName = "closeButton";
			_closeButton.enabled = false;
			_titleBar.addChild(_closeButton);
			
			if (_showShadow)
			{
				filters = [_shadowFilter];
			}
		}
		
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			checkBoundaries();
		}
		
		
		/**
		 * @private
		 */
		protected function checkBoundaries():void
		{
			if (_resizable)
			{
				/* Check that the minimum size is not out of bounds */
				var bw:int = _stage.stageWidth - _boundRight - _boundLeft;
				var bh:int = _stage.stageHeight - _boundBottom - _boundTop;
				
				/* Check that the window size is not overlapping the boundaries */
				if (width < _minWidth) width = _minWidth;
				else if (width > bw) width = bw;
				if (height < _minHeight) height = _minHeight;
				else if (height > bh) height = bh;
				
				/* Check that the window position is inside the boundaries */
				var px:int = _stage.stageWidth - _boundRight - width;
				var py:int = _stage.stageHeight - _boundBottom - height;
				
				if (x < _boundLeft) x = _boundLeft;
				else if (x > px) x = px;
				if (y < _boundTop) y = _boundTop;
				else if (y > py) y = py;
			}
			
			positionChildren();
		}
		
		
		/**
		 * @private
		 */
		protected function positionChildren():void
		{
			_maxButton.y = 6;
			_maxButton.x = unscaledWidth - (_maxButton.width * 2) - 10;
			_closeButton.y = 6;
			_closeButton.x = unscaledWidth - _closeButton.width - 8;
		}
		
		
		/**
		 * @private
		 */
		protected function addEventListeners():void
		{
			addEventListener(MouseEvent.CLICK, onWindowClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_titleBar.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			_titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, onTitleBarDoubleClick);
			
			_maxButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			_maxButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			_maxButton.addEventListener(MouseEvent.CLICK, onMaximize);

			_closeButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			_closeButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			_closeButton.addEventListener(MouseEvent.CLICK, onClose);
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onResize);
			_stage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		
		/**
		 * @private
		 */
		protected function removeEventListeners():void
		{
			removeEventListener(MouseEvent.CLICK, onWindowClick);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			_titleBar.removeEventListener(MouseEvent.DOUBLE_CLICK, onTitleBarDoubleClick);
			
			_maxButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			_maxButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			_maxButton.removeEventListener(MouseEvent.CLICK, onMaximize);

			_closeButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			_closeButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			_closeButton.removeEventListener(MouseEvent.CLICK, onClose);
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResize);
			_stage.removeEventListener(Event.RESIZE, onStageResize);
			
		}
		
		
		/**
		 * @private
		 */
		protected static function initPosition(w:FlexPanel):void
		{
			w._oh = w.height;
			w._ow = w.width;
			w._ox = w.x;
			w._oy = w.y;
		}
		
		
		/**
		 * @private
		 * 
		 * @param type The image class
		 * @param xOffset The xOffset of the cursorimage
		 * @param yOffset The yOffset of the cursor image
		 */
		protected static function changeCursor(type:Class, xOffset:Number = 0, yOffset:Number = 0):void
		{
			if (_cursorType != type)
			{
				_cursorType = type;
				CursorManager.removeCursor(CursorManager.currentCursorID);
				
				if (type != null)
				{
					CursorManager.setCursor(type, CursorManagerPriority.MEDIUM, xOffset, yOffset);
				}
			}
		}
	}
}
