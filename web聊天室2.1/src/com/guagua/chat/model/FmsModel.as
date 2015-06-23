package com.guagua.chat.model
{
	/**
	 *@Date:2012-11-12 上午10:03:10	
	 */
	
	public class FmsModel
	{
		
		public var rid:uint;
		public var ip:String;
		public var port:uint;
		public var sp:Number;
		
		/**fms质量，数值越高质量越差。最大值4294967295时网络不通*/
		private var _lag:Number = 1;
		
		public function FmsModel(roomid:Number,roomip:String,roomport:Number=0,_sp:Number=0)
		{
			rid=roomid;
			ip=roomip;
			port=roomport;
			sp=_sp;
			//trace("dizhi:",rid,ip,port)
		}	
		
		public function toString():String{
			return "FMS:RoomID>"+rid+" IP>"+ip+" Port>"+port+" SP>"+sp+" LAG>"+lag;
		}
		
		public function resetLAG():void {
			_lag = 1;
		}
		
		public function get lag():Number 
		{
			return _lag;
		}
		
		public function set lag(value:Number):void 
		{
			_lag = Number(Math.min(uint.MAX_VALUE, value));
			if (_lag == 0) {
				_lag = Number(uint.MAX_VALUE);
			}
		}
	}
}