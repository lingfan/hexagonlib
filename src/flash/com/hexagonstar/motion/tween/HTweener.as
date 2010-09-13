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
package com.hexagonstar.motion.tween
{
	import flash.utils.Dictionary;

	
	/**
	 * HTweener is an experimental class that provides a static interface and basic
	 * override management for HTween. It adds about 1kb to HTween. With HTweener, if
	 * you tween a value that is already being tweened, the new tween will override the
	 * old tween for only that value. The old tween will continue tweening other values
	 * uninterrupted. <br/>
	 * <br/>
	 * HTweener also serves as an interesting example for utilizing HTween's "*" plugin
	 * registration feature, where a plugin can be registered to run for every tween. <br/>
	 * <br/>
	 * HTweener introduces a small amount overhead to HTween, which may have a limited
	 * impact on performance critical scenarios with large numbers (thousands) of
	 * tweens.
	 */
	public class HTweener
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/* Used for access to dynamic plugIn data property */
		protected static const PLUGINDATA_PROP:String = "HTweener";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private **/
		protected static var _tweens:Dictionary;
		/** @private **/
		protected static var _instance:HTweener;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		staticInit();
		
		
		/**
		 * Tweens the target to the specified values.
		 * 
		 * @param target
		 * @param duration
		 * @param values
		 * @param properties
		 * @param pluginData
		 * @return HTween
		 */
		public static function to(target:Object = null,
									 duration:Number = 1,
									 values:Object = null,
									 properties:Object = null,
									 pluginData:Object = null):HTween
		{
			var tween:HTween = new HTween(target, duration, values, properties, pluginData);
			add(tween);
			return tween;
		}
		
		
		/**
		 * Tweens the target from the specified values to its current values.
		 * 
		 * @param target
		 * @param duration
		 * @param values
		 * @param properties
		 * @param pluginData
		 * @return HTween
		 */
		public static function from(target:Object = null,
										duration:Number = 1,
										values:Object = null,
										properties:Object = null,
										pluginData:Object = null):HTween
		{
			var tween:HTween = to(target, duration, values, properties, pluginData);
			tween.swapValues();
			return tween;
		}
		
		
		/**
		 * Adds a tween to be managed by HTweener.
		 * 
		 * @param tween
		 */
		public static function add(tween:HTween):void
		{
			var target:Object = tween.target;
			var list:Array = _tweens[target];
			
			if (list)
			{
				clearValues(target, tween.getValues());
			}
			else
			{
				list = _tweens[target] = [];
			}
			
			list.push(tween);
			tween.pluginData[PLUGINDATA_PROP] = true;
		}
		
		
		/**
		 * Gets the tween that is actively tweening the specified property of the target, or
		 * null if none.
		 * 
		 * @param target
		 * @param name
		 * @return HTween
		 */
		public static function getTween(target:Object, name:String):HTween
		{
			var list:Array = _tweens[target];
			if (list == null) 
			{ 
				return null; 
			}
			
			var l:int = list.length;
			for (var i:int = 0; i < l; i++)
			{
				var tween:HTween = list[i];
				if (!isNaN(tween.getValue(name)))
				{
					return tween;
				}
			}
			return null;
		}
		
		
		/**
		 * Returns an array of all tweens that HTweener is managing for the specified target.
		 * 
		 * @param target
		 * @return Array
		 */
		public static function getTweens(target:Object):Array
		{
			return _tweens[target] || [];
		}
		
		
		/**
		 * Pauses all tweens that HTweener is managing for the specified target.
		 * 
		 * @param target
		 * @param paused
		 */
		public static function pauseTweens(target:Object, paused:Boolean = true):void
		{
			var list:Array = _tweens[target];
			if (list == null)
			{
				return;
			}
			
			var l:int = list.length;
			for (var i:int = 0; i < l; i++)
			{
				HTween(list[i]).paused = paused;
			}
		}
		
		
		/**
		 * Resumes all tweens that HTweener is managing for the specified target.
		 * 
		 * @param target
		 */
		public static function resumeTweens(target:Object):void
		{
			pauseTweens(target, false);
		}
		
		
		/**
		 * Removes a tween from being managed by HTweener.
		 * 
		 * @param tween
		 */
		public static function remove(tween:HTween):void
		{
			delete(tween.pluginData[PLUGINDATA_PROP]);
			var list:Array = _tweens[tween.target];
			if (list == null)
			{
				return;
			}
			
			var l:int = list.length;
			for (var i:int = 0; i < l; i++)
			{
				if (list[i] == tween)
				{
					list.splice(i, 1);
					return;
				}
			}
		}
		
		
		/**
		 * Removes all tweens that HTweener is managing for the specified target.
		 * 
		 * @param target
		 */
		public static function removeTweens(target:Object):void
		{
			pauseTweens(target);
			
			var list:Array = _tweens[target];
			if (list == null)
			{
				return;
			}
			
			var l:int = list.length;
			for (var i:int = 0; i < l; i++)
			{
				delete(HTween(list[i]).pluginData[PLUGINDATA_PROP]);
			}
			delete(_tweens[target]);
		}
		
		
		/**
		 * @private
		 */
		public function init(tween:HTween, name:String, value:Number):Number
		{
			/* don't do anything. */
			return value;
		}
		
		
		/**
		 * @private
		 */
		public function tween(tween:HTween,
								 name:String,
								 value:Number,
								 initValue:Number,
								 rangeValue:Number,
								 ratio:Number,
								 end:Boolean):Number
		{
			/* if the tween has just completed and it is currently being
			 * managed by HTweener then remove it. */
			if (end && tween.pluginData[PLUGINDATA_PROP])
			{
				remove(tween);
			}
			return value;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected static function staticInit():void
		{
			_tweens = new Dictionary(true);
			_instance = new HTweener();
			
			/* register to be called any time a tween inits or tweens */
			HTween.installPlugin(_instance, ["*"]);
		}
		
		
		/**
		 * @private
		 */
		protected static function clearValues(target:Object, values:Object):void
		{
			for (var n:String in values)
			{
				var tween:HTween = getTween(target, n);
				if (tween)
				{
					tween.deleteValue(n);
				}
			}
		}
	}
}
