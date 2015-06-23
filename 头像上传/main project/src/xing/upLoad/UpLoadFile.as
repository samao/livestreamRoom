package xing.upLoad
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.*;
	import flash.ui.Mouse;
	[SWF(width = "50", height = "30", backgroundColor = "0xFFFFFF", frameRate = "25")]
	public class UpLoadFile extends Sprite
	{
		private var file:FileItem;
		private var txtUpBtn:Btn;
		private var txtOpenBtn:Btn;
		private var isUpLoad:Boolean=false;
		private var ftypeAry:Array=[new FileFilter("*","*.*")];
		private var upLoadUrl:String="http://localhost:1108/upload_3.php";
		private var userUid:String="";
		public function UpLoadFile()
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
			txtUpBtn = new Btn("上传");
			//txtUpBtn.buttonMode=true;
			txtUpBtn.setColor(0xCCCCCC);
			txtUpBtn.addEventListener(MouseEvent.CLICK,btnClick);
			
			this.addChild(txtUpBtn);
			txtUpBtn.init();
			
			txtOpenBtn=new Btn("打开");
			txtOpenBtn.buttonMode=true;
			txtOpenBtn.addEventListener(MouseEvent.CLICK,btnOpenClick);
			this.addChild(txtOpenBtn);
			txtOpenBtn.init();
			txtOpenBtn.x=txtUpBtn.width+txtUpBtn.x+5;
			
			if(ExternalInterface.available){
				if(this.loaderInfo.parameters.url!=null){
					upLoadUrl=this.loaderInfo.parameters.url;
				}
				if(this.loaderInfo.parameters.uid!=null){
					userUid=this.loaderInfo.parameters.uid;
				}
			}
		}
		
		
		
		public function setFileType(ary:Array):void{
			if(ary.length%2!=0)return;
			ftypeAry=[];
			for(var i:int=0;i<ary.length;i++){
				var type:FileFilter=new FileFilter(ary[i],ary[i+1]);
				ftypeAry.push(type);
			}
			
			//file.upLoad("http://localhost:1108/upload_3.php");
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
			setUpBtnColor();
			trace("cancelHandler: " + event);
		}
		
		private function completeHandler(event:Event):void {
			trace("completeHandler: " + event);
			//if(ExternalInterface.available){
			//ExternalInterface.call("cHandler",uploadURL.data);
			//}
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			isUpLoad=false;
			setUpBtnColor();
			setOpenBtnColor(true);
			trace("uploadCompleteData: " + event.data);
			if(ExternalInterface.available){
				ExternalInterface.call("upLoadComplete",event.data.toString());
			}
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			isUpLoad=false;
			setUpBtnColor();
			setOpenBtnColor(true);
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler");
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
			isUpLoad=false;
			setUpBtnColor();
			setOpenBtnColor(true);
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler");
			}
		}
		
		private function selectHandler(event:Event):void {
			isUpLoad=true;
			setUpBtnColor();
			trace(file.fileName,file.fileSize);
			if(ExternalInterface.available){
				ExternalInterface.call("selectHandler",file.fileName,file.fileSize);
			}
	
			//file.upLoad("http://localhost:1108/upload_3.php");
		}
		
		private function btnClick(e:MouseEvent):void{
			if(isUpLoad){
				setOpenBtnColor(false);
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
				trace(variables.fuid,variables.fname);
				file.upLoad(upLoadUrl,"",variables);
			}
		}
		private function btnOpenClick(e:MouseEvent):void{
			file.setType(ftypeAry);
		}
		
		private function setUpBtnColor():void{
			if(isUpLoad){
				txtUpBtn.setColor(0x000000);
				txtUpBtn.buttonMode=true;
			}else{
				txtUpBtn.setColor(0xCCCCCC);
				txtUpBtn.buttonMode=false;
			}
		}
		
		private function setOpenBtnColor(b:Boolean):void{
			if(b){
				txtOpenBtn.setColor(0x0000000);
				txtOpenBtn.buttonMode=true;
			}else{
				txtOpenBtn.setColor(0xCCCCCC);
				txtOpenBtn.buttonMode=false;
			}
		}
	}
}