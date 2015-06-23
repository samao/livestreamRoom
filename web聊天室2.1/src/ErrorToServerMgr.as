package  
{
	import flash.net.sendToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class ErrorToServerMgr 
	{
		static private var instance:ErrorToServerMgr;
		//报错缓存列表
		private var errorVec:Vector.<Object> = new Vector.<Object>();
		//定时器标记
		private var timerTag:int;
		
		private var url:URLRequest;
		//接收错误消息服务器地址
		private const SERVER:String = "http://123.150.168.42/chatroom/webChatLog/addLog.do";
		//管理器激活状态
		private var enabled:Boolean;
		//统计时间
		private var countTimeVec:Vector.<String> = new Vector.<String>();
		//错误信息表
		private const errorXML:XML =<node>
									<error id="100" type="" info="初始化数据错误"/>
									<error id="101" type="CAS" info="连接843端失败"/>
									<error id="102" type="CAS" info="cas连接失败"/>
									<error id="103" type="CAS" info="cas请求FMS地址失败"/>
									<error id="104" type="CAS" info="cas服务器程序未响应"/>
									<error id="105" type="FMS" info="fms建立通道失败"/>
									<error id="106" type="FMS" info="fms无流数据"/>
									<error id="107" type="FMS" info="fms连接网速差"/>
									<error id="108" type="BSP" info="bsp连接失败"/>
									<error id="109" type="RES" info="res连接失败"/>
									<error id="110" type="CQS" info="cqs连接房间服务器失败"/>
									<error id="111" type="ACS" info="acs连接计费服务器失败"/>
									<error id="112" type="TIME" info="视频统计时间"/>
								</node>
		/**
		 * 单例模式禁止实例化
		 * */
		public function ErrorToServerMgr(arg:InterErrorArg) 
		{
			url = new URLRequest(SERVER);	
			url.method = URLRequestMethod.POST;
			enabled = true;
			//10分钟以后清理缓存信息，关闭管理器
			setTimeout(function():void { sendJSON(); enabled = false }, 600000);
		}
		
		public function addCountStr(value:String):void
		{
			countTimeVec.push(value);
		}
		
		/**
		 *单例模式，获取单例 
		 * */
		static public function getLocal():ErrorToServerMgr
		{
			if (!instance)
			{
				instance = new ErrorToServerMgr(new InterErrorArg());
			}
			return instance;
		}
		
		/**
		 * 向缓存中加入一条错误信息
		 * @param info:Object 例如：{errorID:101,serverIp:"192.168.0.1",serverPort:8888,col1:"其它描述"}，errorID是错误信息表中定义的id。
		 * @return 返回列表的JSON串
		 * */
		public function add(info:Object):String
		{
			if (!enabled) return "";
			var xml:XMLList = errorXML.error.(@id == String(info.errorID));
			info.type = String(xml.@type);
			info.errorCode = info.errorID;
			info.reason = String(xml.@info);
			if (info.errorID == 112) info.col2 = countTimeVec.join(",");
			
			errorVec.push(info);			
			if (errorVec.length >= 10)
			{
				sendJSON();
			}else if (errorVec.length == 1) {				
				timerTag = setTimeout(sendJSON, 60000);
			}
			
			return JSON.stringify(errorVec);
		}
		
		/**
		 * 向服务器提交错误信息，清理定时器
		 * */
		private function sendJSON():void 
		{
			if (timerTag != 0) clearTimeout(timerTag);		
			
			//发送数据
			if (errorVec.length > 0)
			{		
				var urlVars:URLVariables = new URLVariables();
				urlVars.logInfo = JSON.stringify(errorVec);
				url.data = urlVars;
				errorVec = new Vector.<Object>();
				trace(urlVars.logInfo);
				sendToURL(url);
			}
			
			timerTag = 0;
		}
		
		
	}
	
}
/**
 * 单例内置参数
 * */
class InterErrorArg{}