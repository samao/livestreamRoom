package com.guagua.events
{
	import flash.events.Event;
	
	
	/**
	 *@Date:2012-11-13 下午03:58:32	
	 */
	
	public class CarEvent extends Event
	{
		
		static public const LIGHT:String="light";		
		
		public var isLight:Boolean
		
		public function CarEvent(type:String,_isLight:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			isLight=_isLight
		}
	}
}