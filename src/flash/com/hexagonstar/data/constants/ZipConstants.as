/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.data.constants{	/**	 * Contains constants used for working with Zip files.	 */	public class ZipConstants	{		//-----------------------------------------------------------------------------------------		// Constants		//-----------------------------------------------------------------------------------------				/* Compression methods */		public static const STORE:uint		= 0;		public static const DEFLATE:uint	= 8;				/* The local file header */		public static const LOCSIG:uint = 0x04034b50;	// "PK\003\004"		public static const LOCHDR:uint = 30;			// LOC header size		//public static const LOCVER:uint = 4;			// version needed to extract		//public static const LOCNAM:uint = 26;			// filename length				/* The Data descriptor */		public static const EXTSIG:uint = 0x08074b50;	// "PK\007\008"		//public static const EXTHDR:uint = 16;			// EXT header size				/* The central directory file header */		public static const CENSIG:uint = 0x02014b50;	// "PK\001\002"		public static const CENHDR:uint = 46;			// CEN header size		public static const CENVER:uint = 6;			// version needed to extract		public static const CENNAM:uint = 28;			// filename length		public static const CENOFF:uint = 42;			// LOC header offset				/* The entries in the end of central directory */		public static const ENDSIG:uint = 0x06054b50;	// "PK\005\006"		public static const ENDHDR:uint = 22;			// END header size		public static const ENDTOT:uint = 10;			// total number of entries		public static const ENDSIZ:uint = 12;			// size if the cen directory		public static const ENDOFF:uint = 16;			// offset of first CEN header				public static const MAXCMT:uint = 0xFFFF;		// Max. zip file comment length	}}