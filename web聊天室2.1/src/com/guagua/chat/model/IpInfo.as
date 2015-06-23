package com.guagua.chat.model
{
	public class IpInfo
	{
		/**IP**/
		public var ip:String="";
		/**端口**/
		public var port:uint=0;
		/**是否正常**/
		public var isNormal:Boolean=true;
		/**服务器类型**/
		public var type:String="";
		public function IpInfo()
		{
			
		}
		
		public function toString():String {
			return type + ":" + ip + ":" + port + " " + isNormal;
		}
	}
}