package xing.upLoad
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.*;
	import flash.ui.Mouse;
	
	[SWF(width = "50", height = "20", backgroundColor = "0xFFFFFF", frameRate = "25")]
	public class UpLoadFile3 extends MovieClip
	{

		private var file:FileItem;
		public var btnMc:SimpleButton;
		private var isUpLoad:Boolean=true;
		private var ftypeAry:Array=[new FileFilter("jpg gif","*.jpg;*.gif")];
		private var upLoadUrl:String="http://localhost:1108/upload_3.php";
		private var userUid:String="";
		private var size:Number=2257577;
	
		
		
		public function UpLoadFile3()
		{
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			Security.exactSettings=false;
			Security.allowDomain("*");
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			file=new FileItem();
			configureListeners(file);
			file.setItemId(1);
			file.setFileId(1);
			if(ExternalInterface.available){
				ExternalInterface.addCallback("setFileType",setFileType);
				ExternalInterface.call("upLoadSwfInit");
			}
			
			if(ExternalInterface.available){
				if(this.loaderInfo.parameters.url!=null){
					upLoadUrl=this.loaderInfo.parameters.url;
				}
				if(this.loaderInfo.parameters.size!=null){
					size=Number(this.loaderInfo.parameters.size);
				}
				if(this.loaderInfo.parameters.uid!=null){
					userUid=this.loaderInfo.parameters.uid;
				}
			}
			
			btnMc.addEventListener(MouseEvent.CLICK,click);
			
			
		}
		
		
		
		
		/*public function setFileType(ary:Array):void{
			if(ary.length%2!=0)return;
			ftypeAry=[];
			for(var i:int=0;i<ary.length;i++){
				var type:FileFilter=new FileFilter(ary[i],ary[i+1]);
				ftypeAry.push(type);
			}
			
			//file.upLoad("http://localhost:1108/upload_3.php");
		}*/
		public function setFileType(_n:String,_t:String):void{
			trace(_n,_t);
			ftypeAry=[];
			//for(var i:int=0;i<ary.length;i++){
				var type:FileFilter=new FileFilter("Images", "*.jpg;*.gif");
				ftypeAry.push(type);
			//}
			
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
			//isUpLoad=false;

			trace("cancelHandler: " + event);
		}
		
		private function completeHandler(event:Event):void {
			trace("completeHandler: " + event);
			
			
			//if(ExternalInterface.available){
			//ExternalInterface.call("cHandler",uploadURL.data);
			//}
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			isUpLoad=true;
		
			trace("uploadCompleteData: " + event.data);
		
			if(ExternalInterface.available){
				ExternalInterface.call("upLoadComplete",event.data.toString());
			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			isUpLoad=true;
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler","网络出错!");
			}
		}
		
		private function openHandler(event:Event):void {
			//trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			if(ExternalInterface.available){
				ExternalInterface.call("progressHandler",Math.floor(100*(event.bytesLoaded/event.bytesTotal)));
			}
			//trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			isUpLoad=true;
			
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler","网络出错!");
			}
		}
		
		private function selectHandler(event:Event):void {
			isUpLoad=false;
			trace(file.fileName,file.fileSize,file.type,file.type.length);
		     if(file.fileSize>size){
				 if(ExternalInterface.available)ExternalInterface.call("sizeErr",file.fileSize);
			 }else{
				 if(file.type.toLowerCase()==".jpg" || file.type.toLowerCase()==".jpeg" || file.type.toLowerCase()==".gif"){
					 upLoadFile();
				 }else{
					 if(ExternalInterface.available){
						 ExternalInterface.call("errorHandler","不支持文件格式:"+file.type);
					 }
				 }
			 }
			//file.loadFile();
			
			//if(ExternalInterface.available){
			//ExternalInterface.call("selectHandler",file.fileName,file.fileSize);
			//}
			
			//file.upLoad("http://localhost:1108/upload_3.php");
		}
		
		private function upLoadFile():void{
			
			var obj:Object=new Object();
			var variables:URLVariables=new URLVariables();
			if(ExternalInterface.available){
				obj=ExternalInterface.call("selectPrame");
			}
			for(var i:* in obj){
				variables[i]=obj[i];
				trace(i,obj[i]);
			}	
			variables.fuid=userUid;
			variables.fname=file.fileName;
			file.upLoad(upLoadUrl,"",variables);
		}
		private function click(e:MouseEvent):void{
		    if(isUpLoad){
				//file.setType(ftypeAry);
				file.setType([new FileFilter("Images", "*.jpg;*.jpeg;*.gif")]);
			}
		}
		
		
		
		
	}
}