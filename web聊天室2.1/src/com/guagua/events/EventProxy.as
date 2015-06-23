package com.guagua.events
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	/**
	 * 事件代理
	 */
	public class EventProxy extends EventDispatcher
	{
		private static var _instance:EventProxy;
		
		
		
		public function EventProxy(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function instance():EventProxy{
			if(_instance==null){
				_instance=new EventProxy();
				
			}
			return _instance;
		}
	}
}