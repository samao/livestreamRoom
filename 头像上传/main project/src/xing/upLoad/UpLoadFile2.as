package xing.upLoad
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.*;
	import flash.ui.Mouse;

	[SWF(width = "105", height = "125", backgroundColor = "0xFFFFFF", frameRate = "25")]
	public class UpLoadFile2 extends MovieClip
	{
		
		public static var imgWidth:Number=105;
		public static var imgHeight:Number=105;
		private var file:FileItem;
		private var txtUpBtn:Btn;
		private var txtOpenBtn:Btn;
		private var isUpLoad:Boolean=false;
		private var ftypeAry:Array=[new FileFilter("*","*.*")];
		private var upLoadUrl:String="http://localhost:1108/upload_3.php";
		private var userUid:String="";
		
		private var imgView:ImgView=new ImgView();
		
		private var loadIngView:Sprite=new Sprite;
		
		private var completeSp:Sprite=new Sprite;
		
		private var messTxt:TextField=new TextField();
		
		
		public function UpLoadFile2()
		{
		
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			Security.exactSettings=false;
			Security.allowDomain("*");
			//stage.scaleMode="noScale";
			//stage.align = "TL";
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC,0.5);
			this.graphics.lineStyle(1, 0x999999);
			this.graphics.drawRect(0, 0, UpLoadFile2.imgWidth-1,UpLoadFile2.imgHeight-1);
			this.graphics.endFill();
			
			file=new FileItem();
			configureListeners(file);
			file.setItemId(1);
			file.setFileId(1);
			if(ExternalInterface.available){
				ExternalInterface.addCallback("setFileType",setFileType);
				ExternalInterface.call("upLoadSwfInit");
			}
			
			this.addChild(imgView);
			
			txtUpBtn = new Btn("上传");
			txtUpBtn.buttonMode=true;
			txtUpBtn.setColor(0xCCCCCC);
			txtUpBtn.addEventListener(MouseEvent.CLICK,btnClick);
			txtUpBtn.y=105;
			txtUpBtn.x=25;
			
			this.addChild(txtUpBtn);
			txtUpBtn.init();
			
			txtOpenBtn=new Btn("打开");
			txtOpenBtn.buttonMode=true;
			txtOpenBtn.addEventListener(MouseEvent.CLICK,btnOpenClick);
			this.addChild(txtOpenBtn);
			txtOpenBtn.init();
			txtOpenBtn.x=(stage.stageWidth-txtOpenBtn.width)-25;
			txtOpenBtn.y=105;
			
			if(ExternalInterface.available){
				if(this.loaderInfo.parameters.url!=null){
					upLoadUrl=this.loaderInfo.parameters.url;
				}
				if(this.loaderInfo.parameters.uid!=null){
					userUid=this.loaderInfo.parameters.uid;
				}
			}
			
			this.addChild(loadIngView);
			loadIngView.graphics.beginFill(0x999999,0.5);
			loadIngView.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			loadIngView.graphics.endFill();
			var loadmc:LoadMc=new LoadMc();
			loadIngView.addChild(loadmc);
			loadmc.x=(loadIngView.width-loadmc.width)/2;
			loadmc.y=(loadIngView.height-loadmc.height)/2;
			loadIngView.visible=false;
			
			this.addChild(completeSp);
		
			completeSp.addChild(messTxt);
			messTxt.textColor=0xFFFFFF;
			messTxt.selectable=false;
			messTxt.height=20;
			messTxt.width=imgWidth;
			messTxt.autoSize=TextFieldAutoSize.CENTER; 
			messTxt.text="成功!";
			completeSp.y=(imgHeight-completeSp.height);
			completeSp.visible=false;
		}
		
		private function messAge(b:Boolean):void{
			completeSp.graphics.clear();
		
			completeSp.graphics.beginFill(0x66FF33,0.5);
			completeSp.graphics.drawRect(0,0,stage.stageWidth,20);
			completeSp.graphics.endFill();
			if(b){
				messTxt.text="成功!";
			}else{
				messTxt.text="失败!";
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
			imgView.LoadBty(file.getFileData());
			
			//if(ExternalInterface.available){
			//ExternalInterface.call("cHandler",uploadURL.data);
			//}
		}
		
		private function uploadCompleteDataHandler(event:DataEvent):void {
			isUpLoad=false;
			setUpBtnColor();
			setOpenBtnColor(true);
			trace("uploadCompleteData: " + event.data);
			
			loadIngView.visible=false;
			completeSp.visible=true;
			messAge(true);
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
			
			loadIngView.visible=false;
			completeSp.visible=true;
			messAge(false);
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
			loadIngView.visible=false;
			if(ExternalInterface.available){
				ExternalInterface.call("errorHandler");
			}
		}
		
		private function selectHandler(event:Event):void {
			isUpLoad=true;
			setUpBtnColor();
			trace(file.fileName,file.fileSize);
			completeSp.visible=false;
			file.loadFile();
			//btnClick();
			//if(ExternalInterface.available){
				//ExternalInterface.call("selectHandler",file.fileName,file.fileSize);
			//}
			
			//file.upLoad("http://localhost:1108/upload_3.php");
		}
		
		private function btnClick(e:MouseEvent=null):void{
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
				file.upLoad(upLoadUrl,"",variables);
				loadIngView.visible=true;
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