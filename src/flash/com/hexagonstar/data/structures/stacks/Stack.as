/* * hexagonlib - Multi-Purpose ActionScript 3 Library. *       __    __ *    __/  \__/  \__    __ *   /  \__/HEXAGON \__/  \ *   \__/  \__/  LIBRARY _/ *            \__/  \__/ * * Licensed under the MIT License *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package com.hexagonstar.data.structures.stacks{	import com.hexagonstar.data.structures.ICollection;	import com.hexagonstar.data.structures.IIterator;	import com.hexagonstar.data.structures.ProtectedIterator;	import com.hexagonstar.data.structures.arrays.ArrayIterator;		/**	 * An array-based Stack class. A stack is a LIFO (last-in first-out) data structure	 * where only the top element can be removed. New elements are added with push() and	 * are placed at the top of the stack. The top element can then be removed with	 * pop() or peeked at with peek(). It is also possible to peek at any other element	 * in the stack by specifying it's index with the peekAt() method. The remove()	 * method is not supported as elements may only be removed from the top of the	 * stack.	 */	public class Stack extends AbstractStack implements IStack	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				/** @private */		protected var _elements:Array;						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new Stack instance.		 * 		 * @param elements An optional number of elements that are added to the new		 *         stack.		 */		public function Stack(...elements)		{			clear();						if (elements.length > 0)			{				var l:int = elements.length;				for (var i:int = 0; i < l; i++)				{					push(elements[i]);				}			}					}						//-----------------------------------------------------------------------------------------		// Query Operations		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		public function peek():*		{			if (_size > 0) return _elements[_elements.length - 1];			return null;		}						/**		 * Returns the element from the stack that is at the specified index without		 * removing it.		 * 		 * @return The element or null if the stack is empty.		 * @throws com.hexagonstar.exception.IndexOutOfBoundsException if the specified		 *             index is lower than 0 or higher than the stack's current size.		 */		public function peekAt(index:int):*		{			if (_size > 0)			{				if (index < 0 || index >= _size)				{					return throwIndexOutOfBoundsException(index);				}				else				{					return _elements[index];				}			}						return null;		}						/**		 * @inheritDoc		 */		override public function contains(element:*):Boolean		{			return _elements.indexOf(element) > -1;		}						/**		 * @inheritDoc		 */		public function equals(collection:ICollection):Boolean		{			if (collection is Stack)			{				var s:Stack = Stack(collection);				var i:int = s.size;								if (i != _size)				{					return false;				}								while (i--)				{					if (s.peekAt(i) != _elements[i])					{						return false;					}				}								return true;			}						return false;		}						/**		 * @inheritDoc		 */		public function clone():*		{			var stack:Stack = new Stack();			stack.addAll(this);			return stack;		}						/**		 * Returns an Iterator over the elements of the stack. The Iterator returned is a		 * protected Itertator so that no elements from the stack can be removed with it.		 * 		 * @return an Iterator over the elements in the stack.		 */		public function iterator():IIterator		{			return (new ProtectedIterator(new ArrayIterator(_elements)));		}						/**		 * @inheritDoc		 */		public function toArray():Array		{			return _elements.concat();		}						/**		 * @inheritDoc		 */		public function dump():String		{			var s:String = "\n" + toString();			for (var i:int = 0; i < _size; i++)			{				s += "\n[" + i + ": " + _elements[i] + "]";			}			return s;		}				//-----------------------------------------------------------------------------------------		// Modification Operations		//-----------------------------------------------------------------------------------------				/**		 * Adds the specified element to the Stack. This does the same like calling push().		 * 		 * @param element The element to be added to the Stack.		 * @return true if the element was added to the Stack successfully otherwise false.		 */		public function add(element:*):Boolean		{			return push(element);		}						/**		 * @inheritDoc		 */		public function push(element:*):Boolean		{			_elements.push(element);			_size++;			return true;		}						/**		 * @inheritDoc		 */		public function pop():*		{			if (_size > 0)			{				_size--;				return _elements.pop();			}			else			{				return null;			}		}						/**		 * Operation not supported by the Stack! Use pop() to retrieve abd remove elements!		 * 		 * Throws an unsupported Operation Exceptions as the removal of elements is not		 * allowed in this Stack.		 * 		 * @return null.		 * @throws com.hexagonstar.exception.UnsupportedOperationException		 */		public function remove(element:*):*		{			throwRemoveNotSupported();			return null;		}						//-----------------------------------------------------------------------------------------		// Bulk Operations		//-----------------------------------------------------------------------------------------				/**		 * @inheritDoc		 */		public function addAll(collection:ICollection):Boolean		{			if (collection)			{				if (collection.size < 1)				{					return false;				}								var a:Array = collection.toArray();				var l:int = a.length;								for (var i:int = 0; i < l; i++)				{					push(a[i]);				}								return true;			}			else			{				return throwNullReferenceException();			}		}						/**		 * Operation not supported by the Stack!		 * 		 * Throws an unsupported Operation Exceptions as the removal of elements is not		 * allowed in the Stack.		 * 		 * @return false.		 * @throws com.hexagonstar.exception.UnsupportedOperationException		 */		public function removeAll(collection:ICollection):Boolean		{			return throwRemoveNotSupported();		}						/**		 * Operation not supported by the Stack!		 * 		 * Throws an unsupported Operation Exceptions as the removal of elements is not		 * allowed in the Stack.		 * 		 * @return false.		 * @throws com.hexagonstar.exception.UnsupportedOperationException		 */		public function retainAll(collection:ICollection):Boolean		{			return throwRemoveNotSupported();		}						/**		 * @inheritDoc		 */		public function clear():void		{			_elements = [];			_size = 0;		}	}}