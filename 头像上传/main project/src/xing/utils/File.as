package xing.utils
{
	
	import flash.events.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.external.ExternalInterface;
	
	public class File extends EventDispatcher
	{

		private var file:FileReference;
		public var fName:String;
		private var data:ByteArray=new ByteArray;
		public function File()
		{
			data.length=0;
			file = new FileReference();
			configureListeners(file);
		}
		
		public function openFile():void{
			file.browse(getTypes());
		}
		
		public function loadFile():void{
			trace("-------------------");
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert","导图");
			}
			file.load();
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
		
		private function getTypes():Array {
			var allTypes:Array = new Array(getImageTypeFilter());
			return allTypes;
		}
		
		private function getImageTypeFilter():FileFilter {
			return new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png");   
		}
		
		private function getSwfTypeFilter():FileFilter {
			return new FileFilter("*","*") ;
		}
		
		private function getTextTypeFilter():FileFilter {
			return new FileFilter("Text Files (*.txt, *.rtf)", "*.txt;*.rtf");
		}
		
		private function cancelHandler(event:Event):void {
			 trace("cancelHandler: " + event);
		
		}
		
		private function completeHandler(event:Event):void {
			data=file.data;	
			//trace("completeHandler: " + data.length);
			this.dispatchEvent(new Event("LoadFileComplete"));
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert","导图成功");
			}
		}
		
		
		
		////////////////////////
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			//trace("uploadCompleteDataHandler: " + event);
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			// trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			 //trace("ioErrorHandler: " + event);
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert","导图ioErrorHandler");
			}
		}
		
		private function openHandler(event:Event):void {
			// trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			//var file:FileReference = FileReference(event.target);
		
			//trace("2progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			//trace("securityErrorHandler: " + event);
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert","导图securityErrorHandler");
			}
		}
		
		private function selectHandler(event:Event=null):void {
			fName=file.name;
			//trace("selectHandler:",file.name);
			this.dispatchEvent(new Event(Event.SELECT));
		}
		
		public function get getImgData():ByteArray{
			var d:ByteArray=new ByteArray();
			d.writeBytes(data,0,data.length);
			return d;
		}
		
		public function GC():void{
			data.length=0;
		}
		
	}
}