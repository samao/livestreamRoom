package com.guagua.debug 
{
	//import com.adobe.serialization.json.JSON;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class Debuger extends EventDispatcher 
	{
		private var loadURL:URLRequest=new URLRequest();
		
		private const webServerURL:String = "http://v.guagua.cn/chatroom/client/";
		
		private const roomTxtURL:String = "config.ini";
		
		private var urlloader:URLLoader=new URLLoader();
		
		private var webData:String = "";
		
		public var roomId:String = "";
		
		private var _webObj:Object = null;
		
		public function Debuger() 
		{			
			urlloader.addEventListener(Event.COMPLETE, loaderHandler);
			urlloader.addEventListener(IOErrorEvent.IO_ERROR, ioHandler);						
		}
		
		public function loadRoomId():void {
			loadURL.url = roomTxtURL;
			
			urlloader.load(loadURL);
		}
		
		public function loadWebData(rid:String = ""):void {
			if (rid != "") roomId = rid;
			
			loadURL.url = webServerURL + roomId;
			
			urlloader.load(loadURL);
		}
		
		private function ioHandler(e:IOErrorEvent):void 
		{
			Log.out("加载房间id错误：", loadURL.url);
			this.dispatchEvent(new Event(Event.COMPLETE));
			destryEventListener();
		}
		
		private function loaderHandler(e:Event):void 
		{
			if (roomId == "") {
				roomId = e.target.data;
				trace("roomId",roomId);
				loadURL.url = webServerURL + roomId;				
				urlloader.load(loadURL);
				return;
			}
			webData = (e.target.data);
			
			paseWebData();
		}
		
		private function paseWebData():void 
		{
			var startIndex:int = webData.indexOf("{");
			var endIndex:int = webData.lastIndexOf(")");
			Log.out("WEB_DATA:", webData,endIndex,"\n初始数据完成，开始登录。");
			try {
				_webObj = JSON.parse(webData.substring(startIndex, endIndex));
				//com.adobe.serialization.json.JSON.decode;
				//_webObj=com.adobe.serialization.json.JSON.decode
			}catch(e:Error) {
				Log.out("paseWebData is Error:",e.message);
			}
		
			
			
			this.dispatchEvent(new Event(Event.COMPLETE));
			destryEventListener();
		}
		
		public function get webObj():Object 
		{
			return _webObj;
		}
		
		public function destryEventListener():void {
			urlloader.removeEventListener(Event.COMPLETE, loaderHandler);
			urlloader.removeEventListener(IOErrorEvent.IO_ERROR, ioHandler);
		}
		
	}

}