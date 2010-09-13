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
package com.hexagonstar.display.bitmaps
{
	import com.hexagonstar.core.IDisposable;
	import com.hexagonstar.display.IAnimatedDisplayObject;
	import com.hexagonstar.display.PlayMode;
	import com.hexagonstar.event.FrameEvent;
	import com.hexagonstar.time.FrameRateInterval;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	/**
	 * Dispatched everytime a frame is entered.
	 * @eventType com.hexagonstar.event.FrameEvent
	 */
	[Event(name="enterFrame", type="com.hexagonstar.event.FrameEvent")]
	
	
	/**
	 * Represents an animateable bitmap. When creating the AnimatedBitmap a bitmapData
	 * object has to be specified that consists of horizonally layed out, same-sized
	 * single frames that the AnimatedBitmap uses as frames for it's animation.
	 */
	public class AnimatedBitmap extends Bitmap implements IAnimatedDisplayObject, IDisposable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The global interval is used for all animated bitmaps that do not use their
		 * own dedicated interval. The framerate of this interval can be changed with
		 * the globalFrameRate property.
		 * @private
		 */
		protected static var _globalInterval:FrameRateInterval;
		
		/**
		 * The framrate used with the global interval.
		 * @private
		 */
		protected static var _globalFrameRate:int = 12;
		
		/**
		 * The buffer that contains all single frames of the animation.
		 * @private
		 */
		protected var _buffer:BitmapData;
		
		/**
		 * Interval that is used to make the animation 'run'.
		 * @private
		 */
		protected var _interval:FrameRateInterval;
		
		/**
		 * Point used to position frame window on the buffer.
		 * @private
		 */
		protected var _point:Point;
		
		/**
		 * Rectangle used as the frame window.
		 * @private
		 */
		protected var _rect:Rectangle;
		
		/**
		 * Storage object for frame coords on the buffer image.
		 * @private
		 */
		protected var _frameCoords:Vector.<Point>;
		
		/**
		 * Storage object for defined animation sequences.
		 * @private
		 */
		protected var _sequences:Object;
		
		/**
		 * The currently playing animation sequence.
		 * @private
		 */
		protected var _sequence:Sequence;
		
		/**
		 * Frame number from which to start playing.
		 * @private
		 */
		protected var _startFrame:int;
		
		/**
		 * Frame number at which playback ends.
		 * @private
		 */
		protected var _endFrame:int;
		
		/**
		 * The width of a single animation frame.
		 * @private
		 */
		protected var _frameWidth:int;
		
		/**
		 * The height of a single animation frame.
		 * @private
		 */
		protected var _frameHeight:int;
		
		/**
		 * The number of total frames of the animated bitmap.
		 * @private
		 */
		protected var _totalFrames:int;
		
		/**
		 * The frame number on that the playhead currently is.
		 * @private
		 */
		protected var _currentFrame:int;
		
		/**
		 * Frame count property used for ping pong mode playback.
		 * @private
		 */
		protected var _addFrame:int = 1;
		
		/**
		 * @private
		 */
		protected var _loopCount:int = 0;
		
		/**
		 * Determines if the animated bitmap is currently playing.
		 * @private
		 */
		protected var _playing:Boolean = false;
		
		/**
		 * Determines if the animated bitmap is flipped in x direction.
		 * @private
		 */
		protected var _flipX:Boolean = false;
		
		/**
		 * Determines if the animated bitmap is flipped in y direction.
		 * @private
		 */
		protected var _flipY:Boolean = false;
		
		/**
		 * Determines if the animated bitmap uses the global interval.
		 * @private
		 */
		protected var _useGlobalInterval:Boolean = false;
		
		/**
		 * Determines if the animated bitmap has been disposed.
		 * @private
		 */
		protected var _disposed:Boolean = false;
		
		protected var _stopAtNextLoop:Boolean = false;
		
		private var _frameRate:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AnimatedBitmap instance. Required parameters are bitmap,
		 * frameWidth and frameHeight.
		 * 
		 * @param bitmapData
		 * @param frameWidth
		 * @param frameHeight
		 * @param totalFrames
		 * @param playMode
		 * @param interval
		 * @param transparent
		 * @param pixelSnapping
		 * @param smoothing
		 */
		public function AnimatedBitmap(bitmapData:BitmapData,
										   frameWidth:int,
										   frameHeight:int,
										   totalFrames:int = 0,
										   playMode:int = 0,
										   interval:FrameRateInterval = null,
										   transparent:Boolean = true,
										   pixelSnapping:String = "auto",
										   smoothing:Boolean = false)
		{
			super(new BitmapData(frameWidth, frameHeight, transparent, 0x00000000),
				pixelSnapping, smoothing);
			
			_buffer = bitmapData.clone();
			_point = new Point(0, 0);
			_sequences = {};
			
			_frameWidth = frameWidth;
			_frameHeight = frameHeight;
			_startFrame = _currentFrame = 1;
			
			_endFrame = _totalFrames = (totalFrames > 0)
				? totalFrames 
				: (_buffer.width / _frameWidth) * (_buffer.height / _frameHeight);
			
			if (!interval)
			{
				if (!_globalInterval)
				{
					_globalInterval = new FrameRateInterval(_globalFrameRate);
				}
				_interval = _globalInterval;
				_useGlobalInterval = true;
			}
			else
			{
				_interval = interval;
			}
			
			_frameRate = _interval.frameRate;
			
			calculateFrameCoords();
			defineSequence("all", _startFrame, _endFrame, playMode);
			sequence = "all";
			draw();
		}
		
		
		/**
		 * Starts the playback of the animated bitmap. If the animated bitmap is already
		 * playing while calling this method, it calls stop() and then play again instantly
		 * to allow for framerate changes during playback.
		 */
		public function play():void
		{
			_stopAtNextLoop = false;
			if (!_playing)
			{
				if (_loopCount == _sequence.loops)
				{
					// TODO This is bad! Needs to be fixed differently!
					/* Temp fix! needs testing! Causes anims with only one loop to play
					 * again after they are stopped and play() is called again. */
					//_currentFrame = 1;
					
					_loopCount = 0;
				}
				
				_playing = true;
				_interval.addEventListener(TimerEvent.TIMER, onInterval, false, 0, true);
				_interval.start();
			}
			else
			{
				stop();
				play();
			}
		}
		
		
		/**
		 * Stops the playback of the animated bitmap.
		 */
		public function stop():void
		{
			if (_playing)
			{
				_interval.removeEventListener(TimerEvent.TIMER, onInterval);
				_playing = false;
			}
		}
		
		
		/**
		 * stopAtNextLoop
		 */
		public function stopAtNextLoop():void
		{
			_stopAtNextLoop = true;
		}
		
		
		/**
		 * Jumps to the specified frame nr. and plays the animated bitmap from that
		 * position. Note that the frames of an animated bitmap start at 1 just like
		 * a MovieClip.
		 * 
		 * @param frame an Integer that designates the frame from which to start play.
		 * @param scene unused in animated bitmaps.
		 */
		public function gotoAndPlay(frameOrSequence:Object, scene:String = null):void
		{
			_currentFrame = resolveFrame(frameOrSequence) - 1;
			play();
		}

		
		/**
		 * Jumps to the specified frame nr. and stops the animated bitmap at that position.
		 * Note that the frames of an animated bitmap start at 1 just like a MovieClip.
		 * 
		 * @param frame an Integer that designates the frame to which to jump.
		 * @param scene unused in animated bitmaps.
		 */
		public function gotoAndStop(frameOrSequence:Object, scene:String = null):void
		{
			var f:int = resolveFrame(frameOrSequence);
			if (f >= _currentFrame)
			{
				_currentFrame = f - 1;
				nextFrame();
			}
			else
			{
				_currentFrame = f + 1;
				prevFrame();
			}
		}
		
		
		/**
		 * Moves the animation to the next of the current frame. If the animated bitmap is
		 * playing, the playback is stopped by this operation.
		 */
		public function nextFrame():void
		{
			if (_playing) stop();
			_currentFrame++;
			if (_currentFrame > _totalFrames) _currentFrame = _totalFrames;
			draw();
		}
		
		
		/**
		 * Moves the animation to the previous of the current frame. If the animated bitmap
		 * is playing, the playback is stopped by this operation.
		 */
		public function prevFrame():void
		{
			if (_playing) stop();
			_currentFrame--;
			if (_currentFrame < 1) _currentFrame = 1;
			draw();
		}
		
		
		/**
		 * Defines a new animation sequence to the animated bitmap.
		 * 
		 * @param name The name of the sequence.
		 * @param startFrame Starting frame number of the range.
		 * @param endFrame Ending frame number of the range.
		 * @param loops Nr of loops that the sequence should play.
		 * @param playMode
		 * @param followSequence Optional sequence name that follows after this sequence
		 *         reached its end.
		 * @param followDelay Delay in ms after that the followSequence should play.
		 */
		public function defineSequence(name:String,
										   startFrame:int,
										   endFrame:int,
										   loops:int = 0,
										   playMode:int = 0,
										   followSequence:String = null,
										   followDelay:int = 0
										   ):void
		{
			_sequences[name] = new Sequence(name, startFrame, endFrame, playMode, loops,
				followSequence, followDelay);
		}
		
		
		/**
		 * removeRange
		 */
		public function removeSequence(name:String):void
		{
			delete(_sequences[name]);
		}
		
		
		/**
		 * Disposes the animated bitmap.
		 */
		public function dispose():void
		{
			stop();
			_disposed = true;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the frame rate timer object used for the animated bitmap. This method is
		 * useful when it is desired to change the framerate at a later timer.
		 * 
		 * @param timer The frame rate timer used for the animated bitmap.
		 */
		public function set frameRateInterval(v:FrameRateInterval):void
		{
			if (_playing)
			{
				stop();
				_interval = v;
				play();
			}
			else
			{
				_interval = v;
			}
		}
		
		
		/**
		 * Indicates the framerate of the global framerate Interval that can be used
		 * as a default interval for all animated objects. The valid range is
		 * between 1 and 1000.
		 */
		public static function get globalFrameRate():int
		{
			return _globalFrameRate;
		}
		public static function set globalFrameRate(v:int):void
		{
			if (v < 1) v = 1;
			else if (v > 1000) v = 1000;
			_globalFrameRate = v;
			if (_globalInterval) _globalInterval.frameRate = _globalFrameRate;
		}
		
		
		/**
		 * The framerate with that the animated bitmap is playing.
		 */
		public function get frameRate():int
		{
			if (_useGlobalInterval) return AnimatedBitmap.globalFrameRate;
			return _frameRate;
		}
		public function set frameRate(v:int):void
		{
			if (v < 1) v = 1;
			else if (v > 1000) v = 1000;
			_frameRate = v;
			if (_useGlobalInterval)
			{
				AnimatedBitmap.globalFrameRate = _frameRate;
			}
			else
			{
				_interval.frameRate = _frameRate;
			}
		}
		
		
		/**
		 * The current frame position of the animated bitmap.
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		
		/**
		 * The total amount of frames that the animated bitmap has.
		 */
		public function get totalFrames():int
		{
			return _totalFrames;
		}
		
		
		/**
		 * Returns the play mode of the currently played sequence.
		 */
		public function get playMode():int
		{
			return _sequence.playMode;
		}
		
		
		/**
		 * Sets the name of the animation sequence that should be played or returns the name
		 * of the animation sequence that the play header is currently in.
		 * 
		 * @see defineSequence
		 * @see removeSequence
		 */
		public function get sequence():String
		{
			if (!_sequence) return null;
			return _sequence.name;
		}
		public function set sequence(v:String):void
		{
			var s:Sequence = _sequences[v];
			if (s)
			{
				_sequence = s;
				_startFrame = _currentFrame = _sequence.start;
				_endFrame = _sequence.end;
				_loopCount = 0;
				
				// TODO Temp Off! Not needed?
				// This is indeed required!
				draw();
			}
		}
		
		
		/**
		 * Shortcut property to set horizontal and vertical scaling equally.
		 */
		public function get scale():Number
		{
			return scaleX;
		}
		public function set scale(v:Number):void
		{
			scaleX = scaleY = v;
		}
		
		
		/**
		 * A 'workaround' property that always returns the top-left x position of the
		 * animated bitmap, regardless if it has been flipped in x direction. If an animated
		 * bitmap is flipped with flipX it's x coordinate changes to the opposite side of
		 * it's original position. For example an animated bitmap with a width of 200 and
		 * whose x coordinate is at 200 will change it's x coordinate to 400 if it is
		 * flipped on the x axis. To circumvent the changed x position use xPos which would
		 * still return 200 in the above example, no matter if it is flipped or not.
		 */
		public function get xPos():int
		{
			if (_flipX) return x - width;
			return x;
		}
		public function set xPos(v:int):void
		{
			x = v;
		}
		
		
		/**
		 * A 'workaround' property that always returns the top-left y position of the
		 * animated bitmap, regardless if it has been flipped in y direction. If an animated
		 * bitmap is flipped with flipY it's y coordinate changes to the opposite side of
		 * it's original position. For example an animated bitmap with a height of 200 and
		 * whose y coordinate is at 200 will change it's y coordinate to 400 if it is
		 * flipped on the y axis. To circumvent the changed y position use yPos which would
		 * still return 200 in the above example, no matter if it is flipped or not.
		 */
		public function get yPos():int
		{
			if (_flipY) return y - height;
			return y;
		}
		public function set yPos(v:int):void
		{
			y = v;
		}
		
		
		/**
		 * Indicates if the animated bitmap is flipped in the x direction.
		 */
		public function get flipX():Boolean
		{
			return _flipX;
		}
		public function set flipX(v:Boolean):void
		{
			if (v == _flipX) return;
			
			_flipX = v;
			var m:Matrix = transform.matrix;
			m.transformPoint(new Point(width / 2, height / 2));
			m.a = -1 * m.a;
			
			if (_flipX) m.tx = width + x;
			else m.tx = x - width;
			
			transform.matrix = m;
		}
		
		
		/**
		 * Indicates if the animated bitmap is flipped in the y direction.
		 */
		public function get flipY():Boolean
		{
			return _flipY;
		}
		public function set flipY(v:Boolean):void
		{
			if (v == _flipY) return;
			
			_flipY = v;
			var m:Matrix = transform.matrix;
			m.transformPoint(new Point(width / 2, height / 2));
			m.d = -1 * m.d;
			
			if (_flipY) m.ty = y + height;
			else m.ty = y - height;
			
			transform.matrix = m;
		}
		
		
		/**
		 * Returns whether the animated bitmap is playing or not.
		 */
		public function get playing():Boolean
		{
			return _playing;
		}
		
		
		/**
		 * Determines if the object has been disposed (true), or is still available
		 * for use (false).
		 */
		public function get disposed():Boolean
		{
			return _disposed;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onInterval(e:TimerEvent):void
		{
			if (_sequence.playMode == PlayMode.FORWARD)
			{
				_currentFrame++;
				if (_currentFrame > _endFrame)
				{
					_loopCount++;
					if (_stopAtNextLoop || _loopCount == _sequence.loops)
					{
						_stopAtNextLoop = false;
						stop();
						_currentFrame--;
						checkFollowSequence();
						return;
					}
					_currentFrame = _startFrame;
				}
			}
			else if (_sequence.playMode == PlayMode.BACKWARD)
			{
				_currentFrame--;
				
				if (_currentFrame < _startFrame)
				{
					_loopCount++;
					if (_stopAtNextLoop || _loopCount == _sequence.loops)
					{
						_stopAtNextLoop = false;
						stop();
						_currentFrame++;
						checkFollowSequence();
						return;
					}
					_currentFrame = _endFrame;
				}
			}
			else if (_sequence.playMode == PlayMode.PINGPONG)
			{
				_currentFrame += _addFrame;
				if (_currentFrame == _endFrame)
				{
					_addFrame = -_addFrame;
				}
				else if (_currentFrame == _startFrame)
				{
					_loopCount++;
					_addFrame = -_addFrame;
					if (_stopAtNextLoop || _loopCount == _sequence.loops)
					{
						_stopAtNextLoop = false;
						stop();
						draw();
						checkFollowSequence();
						return;
					}
				}
			}
			
			draw();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Draws the next bitmap frame from the buffer to the visible area.
		 * 
		 * @private
		 */
		protected function draw():void
		{
			dispatchEvent(new FrameEvent(FrameEvent.ENTER_FRAME, _currentFrame));
			var p:Point = _frameCoords[_currentFrame - 1];
			_rect = new Rectangle(p.x, p.y, _frameWidth, _frameHeight);
			bitmapData.copyPixels(_buffer, _rect, _point);
		}
		
		
		/**
		 * Prepares coordinates for frames on the buffer.
		 * 
		 * @private
		 */
		protected function calculateFrameCoords():void
		{
			_frameCoords = new Vector.<Point>(_totalFrames, true);
			
			var x:int = 0;
			var y:int = 0;
			
			/* Iterate through frames on the buffer */
			for (var i:int = 0; i < _totalFrames; i++)
			{
				_frameCoords[i] = new Point(x, y);
				
				/* Increase x position */
				x += _frameWidth;
				
				/* Reset x and increase y after reaching the last frame per row */
				if (x > (_buffer.width - _frameWidth))
				{
					x = 0;
					y += _frameHeight;
				}
			}
		}
		
		
		/**
		 * Resolves the frame number of the specified value. If v is a number it is returned
		 * directly. If v is not a number it is seen as the name of a sequence and the start
		 * frame number of the sequence is tried to be returned.
		 * 
		 * @private
		 */
		protected function resolveFrame(v:*):int
		{
			if (isNaN(v))
			{
				var s:Sequence = _sequences[String(v)];
				if (s) return s.start;
			}
			return v;
		}
		
		
		/**
		 * @private
		 */
		protected function checkFollowSequence():void
		{
			if (_sequence.followSeq)
			{
				if (_sequence.followDelay < 1)
				{
					sequence = _sequence.followSeq;
					play();
				}
				else
				{
					setTimeout(function():void 
					{
						sequence = _sequence.followSeq;
						play();
					}, _sequence.followDelay);
				}
			}
		}
	}
}


// ------------------------------------------------------------------------------------------------

/**
 * Sequence Data Object
 * @private
 */
class Sequence
{
	public var name:String;
	public var start:int;
	public var end:int;
	public var playMode:int;
	public var loops:int;
	public var followSeq:String;
	public var followDelay:int;
	
	public function Sequence(n:String, s:int, e:int, pm:int, l:int, fs:String, fd:int)
	{
		name = n;
		start = s;
		end = e;
		playMode = pm;
		loops = l;
		followSeq = fs;
		followDelay = fd;
	}
}
