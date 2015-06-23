package xing.upLoad
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.*;

	
	public class UpLoadMp3 extends Sprite
	{
		private var file:FileItem;
		public var xzBtn:MovieClip;
		public var upBtn:MovieClip;
		public var loadMc:MovieClip;
		public var nameTxt:TextField;
		public var loadIngTxt:TextField;
		public var messageTxt:TextField;
		//是否允许上传
		private var isUpLoad:Boolean=false;
		private var ftypeAry:Array=[new FileFilter("*","*.*")];
		private var upLoadUrl:String="http://localhost:1108/upload_3.php";
		private var userUid:String="";
		private var size:Number=7*1024*1024;
		public function UpLoadMp3()
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
			
			//loadMc.gotoAndStop(1);
			//loadMc.visible=false;
			nameTxt.selectable=false;
			nameTxt.text="";
			loadIngTxt.selectable=false;
			loadIngTxt.text="";
			messageTxt.selectable=false;
			messageTxt.text="";
			
			upBtn.addEventListener(MouseEvent.CLICK,btnClick);
			xzBtn.addEventListener(MouseEvent.CLICK,btnOpenClick);
			upBtn.buttonMode=true;
			xzBtn.buttonMode=true;
			
			setUpBtnColor();
			
			
			
			if(ExternalInterface.available){
				if(this.loaderInfo.parameters.url!=null){
					upLoadUrl=this.loaderInfo.parameters.url;
				}
				if(this.loaderInfo.parameters.uid!=null){
					userUid=this.loaderInfo.parameters.uid;
				}
				if(this.loaderInfo.parameters.size!=null){
					size=this.loaderInfo.parameters.size;
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
			messageTxt.text="上传成功";
			nameTxt.text="";
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
			messageTxt.text="上传失败!";
			nameTxt.text="";
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
			var progre:Number=Math.floor(100*(event.bytesLoaded/event.bytesTotal))
			//loadMc.gotoAndStop(progre);
			loadMc["loadMc"].width=450*progre/100;
			loadIngTxt.text=progre.toString()+"%";
			//if(ExternalInterface.available){
				//ExternalInterface.call("progressHandler",Math.floor(100*(event.bytesLoaded/event.bytesTotal)));
			//}
			//trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			isUpLoad=false;
			messageTxt.text="上传失败!";
			nameTxt.text="";
			setUpBtnColor();
			setOpenBtnColor(true);
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler");
			}
		}
		
		private function selectHandler(event:Event):void {
			messageTxt.text="";
			loadIngTxt.text="";
			nameTxt.text="";
			//loadMc.gotoAndStop(1);
			loadMc["loadMc"].width=1;
			if(file.fileSize>size){
				isUpLoad=false;
				nameTxt.text="文件大小超过限制,请重新选择";
			}else{
				isUpLoad=true;
			}
			
			setUpBtnColor();
			//nameTxt.text=file.fileName;
			//trace(file.fileName,file.fileSize);
			if(ExternalInterface.available){
				ExternalInterface.call("selectHandler",file.fileName,file.fileSize);
			}
			
			//file.upLoad("http://localhost:1108/upload_3.php");
		}
		
		private function btnClick(e:MouseEvent):void{
			if(isUpLoad){
				loadMc.visible=true;
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
				nameTxt.text="正在上传，请不要关闭页面...";
			}
		}
		private function btnOpenClick(e:MouseEvent):void{
			file.setType(ftypeAry);
		}
		
		private function setUpBtnColor():void{
			if(isUpLoad){
				upBtn.mouseEnabled=true;
			}else{
				upBtn.mouseEnabled=false;
			}
		}
		
		private function setOpenBtnColor(b:Boolean):void{
			if(b){
				xzBtn.mouseEnabled=true;
			}else{
				xzBtn.mouseEnabled=false;
			}
		}
	}
}