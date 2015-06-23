package xing.upLoad
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.*;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	
	
	
	public class FileItem extends EventDispatcher {

		public var type:String;
		private var file:FileReference;
		//自带ID
	    private var itemId:int=-1;
		//用户生成id
		private var fileId:int=-1;

		public var fileName:String="";
		public var fileSize:Number=0;
		
		
		
		private var data:ByteArray=new ByteArray;
		
		public function FileItem() {
			file=new FileReference();
			
			
			configureListeners(file);
		}
		
		public function setItemId(id:int):void{
			if(itemId==-1)itemId=id;
		}
		
		public function setFileId(id:int):void{
			fileId=id;
		}
		
		public function loadFile():void{
			file.load();
		}
		
		public function setType(fType:Array):void{
			file.browse(fType);	
		}		
		public function upLoad(url:String,fName:String="",variables:URLVariables=null):void{
			trace("FileItem upLoad",url,variables);
			var uploadURL:URLRequest = new URLRequest(url);
			if(variables!=null)uploadURL.data=variables;
			if(fName==""){
				file.upload(uploadURL);
			}else{
				file.upload(uploadURL,fName);
			}
		}
		
		private function init(e:Event = null):void {
			
			
			file = new FileReference();
			configureListeners(file);
		}
		
		
		
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CANCEL, cancelHandler);
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.addEventListener(Event.SELECT, selectHandler);
			dispatcher.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler);
		}
		
		
		
		private function cancelHandler(event:Event):void {
			fileName="";
			fileSize=0;
			this.dispatchEvent(event);
			trace("cancelHandler: " + event);
			
		}
		
		private function completeHandler(event:Event):void {
			data=file.data;	
			this.dispatchEvent(event);
			trace("completeHandler: " + event);
			//if(ExternalInterface.available){
			//ExternalInterface.call("cHandler",uploadURL.data);
			//}
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			trace("uploadCompleteData: " + event.data);
			this.dispatchEvent(event);
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event);
			this.dispatchEvent(event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			this.dispatchEvent(event);
		}
		
		private function openHandler(event:Event):void {
			this.dispatchEvent(event);
			trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			this.dispatchEvent(event);
			trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			this.dispatchEvent(event);
		}

		private function selectHandler(event:Event):void {
			trace("selectHandler");
			type=file.type;
			fileName=file.name;
			fileSize=file.size;
			
			this.dispatchEvent(event);
			
		}
		
		public function getFileData():ByteArray{
			var d:ByteArray=new ByteArray();
			d.writeBytes(data,0,data.length);
			return d;
		}
		
	}
}