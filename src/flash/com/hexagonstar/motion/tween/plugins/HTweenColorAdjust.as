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
package com.hexagonstar.motion.tween.plugins 
{
	import com.hexagonstar.geom.ColorMatrix;
	import com.hexagonstar.motion.tween.HTween;

	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;

	
	/**
	 * Plugin for HTween. Applies a color matrix filter to the target based on the
	 * "brightness", "contrast", "hue", and/or "hue" tween values. <br/>
	 * <br/>
	 * If a color matrix filter does not already exist on the tween target, the plugin
	 * will create one. Note that this may conflict with other plugins that use filters.
	 * If you experience problems, try applying a color matrix filter to the target in
	 * advance to avoid this behaviour. <br/>
	 * <br/>
	 * Supports the following <code>pluginData</code> properties:
	 * <UL>
	 * <LI>colorAdjustEnabled: overrides the enabled property for the plugin on a per</LI>
	 * tween basis.
	 * <LI>colorAdjustData: Used internally.</LI>
	 * </UL>
	 **/
	public class HTweenColorAdjust implements IHTweenPlugin
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/* Used for access to dynamic plugIn data properties */
		protected static const PLUGINDATA_COLORADJUSTENABLED:String	= "colorAdjustEnabled";
		protected static const PLUGINDATA_COLORADJUSTDATA:String	= "colorAdjustData";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Specifies whether this plugin is enabled for all tweens by default.
		 */
		public static var enabled:Boolean = true;
		
		/** @private **/
		protected static var _instance:HTweenColorAdjust;
		
		/** @private **/
		protected static var tweenProperties:Array =
			["brightness", "contrast", "hue", "saturation"];
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Installs this plugin for use with all HTween instances.
		 */
		public static function install():void
		{
			if (_instance) return; 
			_instance = new HTweenColorAdjust();
			HTween.installPlugin(_instance, tweenProperties);
		}
		
		
		/**
		 * @private
		 * 
		 * @param tween
		 * @param name
		 * @param value
		 * @return Number
		 */
		public function init(tween:HTween, name:String, value:Number):Number
		{
			if (!((tween.pluginData[PLUGINDATA_COLORADJUSTENABLED] == null && enabled)
				|| tween.pluginData[PLUGINDATA_COLORADJUSTENABLED])) 
			{ 
				return value;
			}
			
			if (tween.pluginData[PLUGINDATA_COLORADJUSTDATA] == null)
			{
				/* try to find an existing color matrix filter on the target */
				var f:Array = DisplayObject(tween.target).filters;
				for (var i:int = 0; i < f.length; i++)
				{
					if (f[i] is ColorMatrixFilter)
					{
						var cmF:ColorMatrixFilter = f[i];
						var o:ColorAdjustDO = new ColorAdjustDO(i, NaN, cmF.matrix,
							getMatrix(tween));
						
						/* store in pluginData for this tween for retrieval later */
						tween.pluginData[PLUGINDATA_COLORADJUSTDATA] = o;
					}
				}
			}
			
			/* make up an initial value that will let us get a 0-1 ratio back later */
			return tween.getValue(name) - 1;
		}
		
		
		/**
		 * @private
		 * 
		 * @param tween
		 * @param name
		 * @param value
		 * @param initValue
		 * @param rangeValue
		 * @param ratio
		 * @param end
		 * @return Number
		 */
		public function tween(tween:HTween,
								 name:String,
								 value:Number,
								 initValue:Number,
								 rangeValue:Number,
								 ratio:Number,
								 end:Boolean):Number
		{
			/* don't run if we're not enabled */
			if (!((tween.pluginData[PLUGINDATA_COLORADJUSTENABLED] == null && enabled)
				|| tween.pluginData[PLUGINDATA_COLORADJUSTENABLED]))
			{ 
				return value; 
			}
			
			/* grab the tween specific data from pluginData */
			var data:ColorAdjustDO = tween.pluginData[PLUGINDATA_COLORADJUSTDATA];
			if (data == null)
			{
				data = initTarget(tween); 
			}
			
			/* only run once per tween tick, regardless of how many properties we're
			 * dealing with ex. don't run twice if both contrast and hue are specified,
			 * because we deal with them at the same time */
			if (ratio == data.ratio)
			{ 
				return value; 
			}
			
			data.ratio = ratio;
			
			/* use the "magic" ratio we set up in init */
			ratio = value - initValue;
			
			/* grab the filter */
			var d:DisplayObject = DisplayObject(tween.target);
			var f:Array = d.filters;
			var cmF:ColorMatrixFilter = f[data.index] as ColorMatrixFilter;
			
			if (cmF == null)
			{ 
				return value; 
			}
			
			/* grab our init and target color matrixes */
			var initMatrix:Array = data.initMatrix;
			var targMatrix:Array = data.matrix;
			
			/* check if we're running backwards */
			if (rangeValue < 0)
			{
				/* values were swapped */
				initMatrix = targMatrix;
				targMatrix = data.initMatrix;
				ratio *= -1;
			}
			
			/* grab the current color matrix, and tween it's values */
			var matrix:Array = cmF.matrix;
			var l:int = matrix.length;
			for (var i:int = 0; i < l; i++)
			{
				matrix[i] = initMatrix[i] + (targMatrix[i] - initMatrix[i]) * ratio;
			}
			
			/* set the matrix back to the filter, and set the filters on the target */
			cmF.matrix = matrix;
			d.filters = f;
			
			/* clean up if it's the end of the tween */
			if (end)
			{
				delete(tween.pluginData[PLUGINDATA_COLORADJUSTDATA]);
			}
			
			/* tell HTween not to use the default assignment behaviour */
			return NaN;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function getMatrix(tween:HTween):ColorMatrix
		{
			var brightness:Number = fixValue(tween.getValue("brightness"));
			var contrast:Number = fixValue(tween.getValue("contrast"));
			var saturation:Number = fixValue(tween.getValue("saturation"));
			var hue:Number = fixValue(tween.getValue("hue"));
			var mtx:ColorMatrix = new ColorMatrix();
			mtx.adjustColor(brightness, contrast, saturation, hue);
			return mtx;
		}
		
		
		/**
		 * @private
		 */
		protected function initTarget(tween:HTween):ColorAdjustDO 
		{
			var d:DisplayObject = DisplayObject(tween.target);
			var f:Array = d.filters;
			var mtx:ColorMatrix = new ColorMatrix();
			f.push(new ColorMatrixFilter(mtx));
			d.filters = f;
			
			var o:ColorAdjustDO = new ColorAdjustDO(f.length - 1, NaN, mtx, getMatrix(tween));
			return tween.pluginData[PLUGINDATA_COLORADJUSTDATA] = o;
		}
		
		
		/**
		 * @private
		 */
		protected function fixValue(value:Number):Number 
		{
			return isNaN(value) ? 0 : value;
		}
	}
}


// -------------------------------------------------------------------------------------------------

import com.hexagonstar.geom.ColorMatrix;

/**
 * @private
 */
class ColorAdjustDO
{
	public var index:int;
	public var ratio:Number;
	public var initMatrix:Array;
	public var matrix:ColorMatrix;
	
	public function ColorAdjustDO(i:int, r:Number, im:Array, m:ColorMatrix)
	{
		index = i;
		ratio = r;
		initMatrix = im;
		matrix = m;
	}
}
