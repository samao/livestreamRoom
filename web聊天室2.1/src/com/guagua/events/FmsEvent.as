package com.guagua.events
{
	import flash.events.Event;
	
	
	/**
	 *@Date:2012-11-12 上午10:25:52	
	 */
	
	public class FmsEvent extends Event
	{
		/**收到第一个fms*/
		static public const FMS_READY:String="fmsReady";
		/**请求fms*/
		static public const FMS_GETTING:String="fmsGetting";
		/**收到fms*/
		static public const FMS_RECEIVE:String="fmsReceive";
		
		public function FmsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}