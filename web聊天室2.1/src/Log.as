package  
{
	import com.guagua.chat.model.RoomModel;
	import com.guagua.utils.ConstVal;
	import flash.utils.Timer;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;	
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class Log 
	{
		static private var local:LocalConnection;
		
		static private var isDebugTracer:Boolean = true;
		
		public function Log() 
		{
			throw new Error("Log是静态类,不允许实例化。*^_^*")
		}
		
		static public function out(...arg:Array):void {
			var outsz:String = "[" + ConstVal.date + "秒" + "] #" + arg.join(" ");
			
			if (ConstVal.DEBUG_MODE)trace(outsz);
			
			if (ExternalInterface.available) {
				try {
					//ExternalInterface.call("alertFlashMessage",outsz);
				}catch (e:Error) {
					trace("未定义js函数","alertFlashMessage")
				}				
			}
			//初始化本地连接
			if (local == null) {
				initLocal();				
			}
			
			if (isDebugTracer)
			{
				try {
					local.send("_guaguaClient", "log", outsz);	
				}catch (e:Error) {
					trace("Log Error:", e.message);
				}
			}		
			
			RoomModel.getRoomModel().showInfo(outsz+"\n");
		}		
		
		/**js传入数据错误*/
		static public function errorMsg(...arg:*):void {
			var sz:String = arg.join(" ")
			if (ExternalInterface.available) {					
				ExternalInterface.call("alert", sz);
			}
			if (ConstVal.DEBUG_MODE) trace("$$ERROR:", sz, "$$");
			
			RoomModel.getRoomModel().showInfo("$$ERROR: " + sz + "$$\n");
		}
		
		
		static private function initLocal():void {
			local = new LocalConnection();
			local.addEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		static private function statusHandler(e:StatusEvent):void 
		{
			//尝试一次失败以后不再发送数据
			if (e.level == "error")
			{
				isDebugTracer = false;
				//local.removeEventListener(StatusEvent.STATUS, statusHandler);
			}
		}
		
		
		
	}

}