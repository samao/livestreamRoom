package xing.screenshot
{
	import com.adobe.images.PNGEncoder;
	import com.guagua.iplugs.IBitmap;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import xing.screenshot.com.GetImgDataView;
	import xing.screenshot.com.LoadIngView;
	import xing.utils.File;

    /**图片截图上传组件  国英 管理后台**/
	[SWF(width = "560", height = "300", backgroundColor = "0xFFFFFF", frameRate = "25")]
	public class SMain extends Sprite
	{
		/**放大按钮**/
		public var btnBig:SimpleButton;
		/**缩小按钮**/
		public var smallBtn:SimpleButton;
		/**选择图片**/
		public var loadBtn:SimpleButton;
		/**上传按钮**/
		public var upLoadBtn:SimpleButton;
		/**摄像头*/
		public var camBtn:SimpleButton;
		/**重置按钮**/
		public var czhiBtn:SimpleButton;
		/**背景**/
		public var baskImgMc:MovieClip;
		/**图片文件**/
		private var file:File;
		/**显示**/
		private var imgDataView:GetImgDataView
		/**图片显示屏宽**/
		public static var imgContainerW:Number=250;
		/**图片显示屏高**/
		public static var imgContainerH:Number=250;
		/**图片显示屏高宽比例**/
		public static var imgContainerHW:Number=imgContainerH/imgContainerW;
		public static var loadIngView:LoadIngView=new LoadIngView();
		
		/**是否开启视频抓图*/
		public static const useCamera:Boolean=true;
		
		/**摄像头组件*/
		[Embed(source="../../../plugs/CameraScreenShot.swf",mimeType="application/octet-stream")]
		static public const CameraShot:Class;
		
		public function SMain()
		{
			stage.scaleMode="noScale";
			stage.align = "TL";
			file=new File();
			file.addEventListener(Event.SELECT,selectHandel);
			file.addEventListener("LoadFileComplete",fileComplethanedel);
			
			camBtn.visible=useCamera;
			
			imgDataView=new GetImgDataView();
			this.addChild(imgDataView);
			
			this.addChild(loadIngView);
			loadIngView.init();
			baskImgMc.gotoAndStop(1);
			if(!btnBig.hasEventListener(MouseEvent.CLICK)){
				btnBig.addEventListener(MouseEvent.CLICK,btnClickHandler);
				smallBtn.addEventListener(MouseEvent.CLICK,btnClickHandler);
				loadBtn.addEventListener(MouseEvent.CLICK,btnClickHandler);
				upLoadBtn.addEventListener(MouseEvent.CLICK,btnClickHandler);
				czhiBtn.addEventListener(MouseEvent.CLICK,btnClickHandler);
				camBtn.addEventListener(MouseEvent.CLICK,camClick);
			}
			if(ExternalInterface.available){
				if(this.loaderInfo.parameters.url!=null){
					Config.upLoadUrl=this.loaderInfo.parameters.url;
				}
				if(this.loaderInfo.parameters.uid!=null){
					imgDataView.uid=this.loaderInfo.parameters.uid;
				}
				if(this.loaderInfo.parameters.sizeAry!=null){
					Config.sizeAry=[];
					var strAry:Array=this.loaderInfo.parameters.sizeAry.split("_");
					for(var i:int=1;i<strAry.length;i++){
						Config.sizeAry.push(strAry[i].split("*"));
					}
				//trace(Config.sizeAry,"lll",this.loaderInfo.parameters.sizeAry);
					Config.rectW=Number(strAry[0].split("*")[0]);
					Config.rectH=Number(strAry[0].split("*")[1]);
					imgDataView.init();
				}
				if(this.loaderInfo.parameters.index!=null){
					Config.index=this.loaderInfo.parameters.index;
					Config.imgW=Number(Config.sizeAry[Config.index][0]);
					Config.imgH=Number(Config.sizeAry[Config.index][1]);
				}
				if(this.loaderInfo.parameters.bjImg!=null){
					Config.bjImgUrl="http://"+this.loaderInfo.parameters.bjImg;
				}
				
			}
			
			/*var m:Monitor=new Monitor();
			m.x=300;
			this.addChild(m);*/
		}
		
		protected function camClick(event:MouseEvent):void
		{
			if(camPlug)
			{
				if(this.contains(camPlug))
				{
					this.removeChild(camPlug);		
				}
				imgDataView.clear();				
				camPlug=null;
			}
			
			var loaderCamPlug:Loader=new Loader();
			loaderCamPlug.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void
			{
				camPlug=e.target.content as DisplayObject;				
				var ibitmap:IBitmap=e.target.content as IBitmap
				ibitmap.setWH(250,250);
				addChild(camPlug);
				ibitmap.shotComplete(getBitmapData);
			});
			loaderCamPlug.loadBytes(new CameraShot());
		}
		
		public function getBitmapData(b:BitmapData):void
		{
			this.removeChild(camPlug);
			baskImgMc.gotoAndStop(2);
			imgDataView.setImg=PNGEncoder.encode(b);
		}
		
		private var isGetFile:Boolean=false;

		private var camPlug:DisplayObject;
		private function selectHandel(e:Event):void{
			
			isGetFile=true;
			file.loadFile();
			
			if(ExternalInterface.available){
				ExternalInterface.call("openFile",file.fName);
			}
			
		}
		
		private function fileComplethanedel(e:Event):void{
			baskImgMc.gotoAndStop(2);
			imgDataView.setImg=file.getImgData;			
		}
		
		private function btnClickHandler(e:MouseEvent):void{
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert",e.target["name"]);
			}
			//trace(e.target["name"]);
			if(e.target["name"]=="btnBig"){
				imgDataView.bigSmallImg();
			}
			if(e.target["name"]=="smallBtn"){
				imgDataView.bigSmallImg(-1);
			}
			if(e.target["name"]=="loadBtn"){
				if(camPlug&&this.contains(camPlug))
				{
					this.removeChild(camPlug);
				}
				file.openFile();	
			}
			if(e.target["name"]=="upLoadBtn"){
				if(isGetFile){
					if(Config.isUpload){
						imgDataView.upload();
					}else{
						trace("SMain btnClickHandler fileWHerr");
						if(ExternalInterface.available){
							ExternalInterface.call("fileWHerr");
						}
					}
				}else{
					if(ExternalInterface.available){
						ExternalInterface.call("noSelectFile");
					}
				}
			}
			if(e.target["name"]=="czhiBtn"){
				imgDataView.reset();	
			}
		}
			
	}
}