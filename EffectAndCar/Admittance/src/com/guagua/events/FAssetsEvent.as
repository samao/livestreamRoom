package com.guagua.events
{
	import flash.events.Event;
	
	
	/**
	 *@Date:2012-12-10 下午04:53:03	
	 */
	
	public class FAssetsEvent extends Event
	{
		static public const START:String="start";
		
		static public const FINISH:String="finish";
		
		static public const READY:String="ready";
		
		public var isReady:Boolean=false;
		
		public function FAssetsEvent(type:String,isLoaded:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			isReady=isLoaded;			
		}
	}
}