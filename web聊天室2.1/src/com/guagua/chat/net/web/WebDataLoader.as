package com.guagua.chat.net.web
{
	import com.guagua.chat.model.RoomModel;
	
	//import com.adobe.serialization.json.JSON;
	
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.*;
	import flash.net.*;
	
	public class WebDataLoader extends EventDispatcher
	{
		private var loader:URLLoader=new URLLoader();
		private var _isLoad:Boolean=false;
		
		private static var _instance:WebDataLoader;
		
		private var loading:Boolean = false;;
		
		public function WebDataLoader()
		{
			
			loader.dataFormat=URLLoaderDataFormat.BINARY ;			
		}	
		
		static public function getInstance():WebDataLoader{
			logError("getInstance");
			if(_instance==null){
				_instance=new WebDataLoader();
			}
			return _instance;
		}		
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(Event.INIT, initHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR,ioErrorHandler);
			
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}
		public function load():void {	
			//if(RoomModel.getRoomModel().
			//return;
			if(isLoad||loading){
				return;
			}
			loading = true;
			configureListeners(loader);
			Log.out("重新加载了cas地址")
			isLoad=true;
			logError(RoomModel.getRoomModel().serverIpUrl)
			loader.load(new URLRequest(RoomModel.getRoomModel().serverIpUrl));
		}
		
		
		private function completeHandler(event:Event):void {
			
			loading = false;
			var obj:Object=JSON.parse(loader.data);
			var str:String = obj.result;
			
			RoomModel.getRoomModel().addCasIpList(str);
			
			logError(loader.data+">>"+RoomModel.getRoomModel().serverIpUrl)
			clearEventListener()
		}
		
		/**清除帧听事件*/
		private function clearEventListener():void{
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.removeEventListener(Event.INIT, initHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.removeEventListener(Event.OPEN, openHandler);
			loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.removeEventListener(Event.UNLOAD, unLoadHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,ioErrorHandler);
		}
		
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			logError("httpStatusHandler: " + event);
		}
		
		private function initHandler(event:Event):void {
			logError("initHandler: " + event);
		}
		
		private function ioErrorHandler(event:Event):void {
			isLoad = false;
			loading = false;
		}
		
		private function openHandler(event:Event):void {
			logError("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			logError("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function unLoadHandler(event:Event):void {
			logError("unLoadHandler: " + event);
		}
		
		static public function logError(value:String):void{
			//trace("WebDataLoader:",value);
		}
		
		public function set isLoad(value:Boolean):void 
		{
			_isLoad = value;
		}
		
		public function get isLoad():Boolean 
		{
			return _isLoad;
		}
	}
}