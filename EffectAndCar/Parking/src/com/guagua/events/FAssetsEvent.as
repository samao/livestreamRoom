package com.guagua.events
{
	import flash.events.Event;
	
	
	/**
	 *@Date:2012-12-11 上午10:38:19	
	 */
	
	public class FAssetsEvent extends Event
	{
		static public const ASSETS_READY:String="assetsReady";
		public var isReady:Boolean=false;
		
		public function FAssetsEvent(type:String,isok:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			isReady=isok;
		}
	}
}