package com.guagua.events
{
	import flash.events.Event;
	
	public class RoomEvent extends Event
	{
		/**
		 * 登陆cas 
		 */
		public static const Event_Socket_Cas_Login:String = "Event_Socket_Cas_Login";	
		/**cas ip连接断开**/
		public static const Event_Socket_Cas_Ip_Err:String = "Event_Socket_Cas_Ip_Err";
		
		public var cmd:String;
		public var data:*;
		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
		
	}
}