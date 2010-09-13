/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.io.net{	/**	 * NetStatus Class	 */	public class NetStreamStatus	{		//-----------------------------------------------------------------------------------------		// Constants		//-----------------------------------------------------------------------------------------				public static const BUFFER_EMPTY:String	= "NetStream.Buffer.Empty";		public static const BUFFER_FULL:String	= "NetStream.Buffer.Full";		public static const BUFFER_FLUSH:String	= "NetStream.Buffer.Flush";				public static const FAILED:String		= "NetStream.Failed";				public static const PUBLISH_START:String		= "NetStream.Publish.Start";		public static const PUBLISH_BADNAME:String		= "NetStream.Publish.BadName";		public static const PUBLISH_IDLE:String			= "NetStream.Publish.Idle";		public static const UNPUBLISH_SUCCESS:String	= "NetStream.Unpublish.Success";				public static const PLAY_START:String					= "NetStream.Play.Start";		public static const PLAY_STOP:String					= "NetStream.Play.Stop";		public static const PLAY_FAILED:String					= "NetStream.Play.Failed";		public static const PLAY_STREAMNOTFOUND:String			= "NetStream.Play.StreamNotFound";		public static const PLAY_RESET:String					= "NetStream.Play.Reset";		public static const PLAY_PUBLISHNOTIFY:String			= "NetStream.Play.PublishNotify";		public static const PLAY_UNPUBLISHNOTIFY:String			= "NetStream.Play.UnpublishNotify";		public static const PLAY_INSUFFICIENTBW:String			= "NetStream.Play.InsufficientBW";		public static const PLAY_FILESTRUCTUREINVALID:String	= "NetStream.Play.FileStructureInvalid";		public static const PLAY_NOSUPPORTEDTRACKFOUND:String	= "NetStream.Play.NoSupportedTrackFound";		public static const PLAY_TRANSITION:String				= "NetStream.Play.Transition";				public static const PAUSE_NOTIFY:String		= "NetStream.Pause.Notify";		public static const UNPAUSE_NOTIFY:String	= "NetStream.Unpause.Notify";				public static const RECORD_START:String		= "NetStream.Record.Start";		public static const RECORD_NOACCESS:String	= "NetStream.Record.NoAccess";		public static const RECORD_STOP:String		= "NetStream.Record.Stop";		public static const RECORD_FAILED:String	= "NetStream.Record.Failed";				public static const SEEK_FAILED:String		= "NetStream.Seek.Failed";		public static const SEEK_INVALIDTIME:String	= "NetStream.Seek.InvalidTime";		public static const SEEK_NOTIFY:String		= "NetStream.Seek.Notify";				public static const CONNECT_CLOSED:String	= "NetStream.Connect.Closed";		public static const CONNECT_FAILED:String	= "NetStream.Connect.Failed";		public static const CONNECT_SUCCESS:String	= "NetStream.Connect.Success";		public static const CONNECT_REJECTED:String	= "NetStream.Connect.Rejected";	}}