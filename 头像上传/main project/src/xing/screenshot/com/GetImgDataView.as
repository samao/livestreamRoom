package xing.screenshot.com
{

	
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.JSON;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import xing.screenshot.Config;
	import xing.screenshot.SMain;

	public class GetImgDataView extends Sprite
	{
		private var imgView:ImgView=new ImgView();
		/**四角**/
		private var rectView:RectView=new RectView();
		private var tyImg:TyImg=new TyImg(170);
		//private var tyImg2:TyImg=new TyImg(50);
		//private var tyImg3:TyImg=new TyImg(32);
		/**背景**/
		private var bjloader:Loader=new Loader();
		private var imgW:Number=100;
		private var imgH:Number=100;
		private var ImgBtyAry:Vector.<BitmapData>
		private var upLoadId:int=0;
		private var isUpLoad:Boolean=false;
		private var loader:URLLoader=new URLLoader();
		//public var upLoadUrl:String="zone.17guagua.com/2004069/site/portrait";//"127.0.0.1:8080/Xing/index.jsp";
		public var uid:String="";

		private var jsDataAry:Array=[];
		public function GetImgDataView()
		{
			this.addChild(imgView);
			this.addChild(rectView);
			this.addChild(tyImg);
			this.addChild(bjloader);
			//this.addChild(tyImg3);
			imgView.imgRectV=rectView;
			tyImg.y=8
			tyImg.x=300;
			bjloader.x=tyImg.x;
			bjloader.y=tyImg.y;
			bjloader.addEventListener(Event.COMPLETE, bjuploadCompleteHandler);
			bjloader.load(new URLRequest(Config.bjImgUrl));
			//tyImg2.y=35;
			//tyImg2.x=tyImg.x+170+20;
		//	tyImg3.x=tyImg2.x;
			//tyImg3.y=tyImg2.y+50+55;
			//trace(tyImg2.x,tyImg2.y);
			imgView.addEventListener("Event_Img_Complete",imgCompleteHandel);
			rectView.addEventListener("Event_ImgRect_Complete",imgRectComplete);
		}
		
		public function init():void{
			tyImg.initLabel();
		}
		
		public function set setImg(b:ByteArray):void{
			imgView.LoadBty(b);
			
		}
		
		public function clear():void{
			imgView.clear();
			tyImg.clear();
			this.rectView.clear();
		}
		
		private function imgCompleteHandel(e:Event):void{
			//trace("GetImgDataView imgCompleteHandel",imgView.imgW,imgView.imgH);
			
			var w:Number=Config.rectW;
			var h:Number=Config.rectH;
			if(imgView.width>=Config.rectW && imgView.height>=Config.rectH){
				//trace(imgView.width>=Config.rectW && imgView.height>=Config.rectH);
			}else{
				if(imgView.imgH>imgView.imgW){
					if(imgView.imgW<w){
						w=imgView.imgW;
						h=(Config.rectH/Config.rectW)*w;
					}
				}else{
					if(imgView.imgH<h){
						h=imgView.imgH;
						w=h/(Config.rectH/Config.rectW);
					}
				}
			}
			imgView.bigSmallImg();//add by yanlong 默认原始大小
			rectView.setWH(Config.rectW,Config.rectH,imgView.imgData);
		}
		
		private function imgRectComplete(e:Event):void{
			if(bjloader!=null){
				bjloader.unload();
				bjloader.removeEventListener(Event.COMPLETE, bjuploadCompleteHandler);
				this.removeChild(bjloader);
				bjloader=null;
			}
			//trace("imgRectComplete ImgBtyAry=getImgRectDataAry");
			ImgBtyAry=imgView.getImgRectDataAry(rectView.rect);
			tyImg.setBitData(ImgBtyAry[Config.index]);
			
		}
		
		public function upload():void{
			
			if(isUpLoad)return;
			if(ImgBtyAry==null)return;
			jsDataAry=[];
			isUpLoad=true;
			doUpLoad();
		}
		private function doUpLoad():void{
			if(ExternalInterface.available){
				ExternalInterface.call("swfAlert","上传");
			}
			var jpg:JPGEncoder=new JPGEncoder(100);
			var bty:ByteArray=jpg.encode(ImgBtyAry[upLoadId]);
			
			//var bty:ByteArray=PNGEncoder.encode(tyImg.getImgData);
			var req:URLRequest = new URLRequest("http://"+Config.upLoadUrl+"?icon="+uid+"_"+Config.sizeAry[upLoadId][0]+"&size="+Config.sizeAry[upLoadId][0]);
			var obj:Object=new Object();
			obj.size=Config.sizeAry[upLoadId][0];
			req.data = bty;
			req.method = URLRequestMethod.POST;
			req.contentType = "application/octet-stream";
			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(req); 
			loader.addEventListener(Event.COMPLETE, uploadCompleteHandler);
			loader.addEventListener(ProgressEvent.PROGRESS,proEventHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ioErrorHandler);
			
		}
		
		public function reset():void{
			
			imgView.reset();
		}
		
		public function bigSmallImg(i:int=1):void{
			imgView.bigSmallImg(i);
		}
		
		private function uploadCompleteHandler(e:Event):void{
			//JSON.decode(loader.data);
			jsDataAry[upLoadId]=loader.data.toString();
			//trace("GetImgDataView uploadCompleteHandler",jsDataAry[upLoadId],loader.data,upLoadId,Config.sizeAry.length);
			upLoadId++;
			if(upLoadId<Config.sizeAry.length){
				
				doUpLoad();
			}else{
			
				ImgBtyAry=null;
				isUpLoad=false;
				upLoadId=0;
				SMain.loadIngView.close();
				if(ExternalInterface.available){
					ExternalInterface.call("upLoadComplete",jsDataAry);
				}
			}
		}
		
		private function proEventHandler(e:ProgressEvent):void{
			trace("proEventHandler ImgBtyAry=null");
			var i:Number=Math.floor((e.bytesLoaded/e.bytesTotal)/3*(upLoadId+1)*100);
			//trace(e.bytesLoaded,e.bytesTotal);
			//var i:Number=(upLoadId+1)*30;
			SMain.loadIngView.show("已经上传"+i.toString()+"%",i);
		}
		
		private function ioErrorHandler(e:Event):void{
			//SMain.loadIngView.show("上传失败",(upLoadId+1)*30,true);
			isUpLoad=false;
			upLoadId=0;
			SMain.loadIngView.close();
			if(ExternalInterface.available){
				ExternalInterface.call("errHandler","上传失败");
			}
		}
		
		private function bjuploadCompleteHandler(e:Event):void{
			bjloader.width=Config.rectW;
			bjloader.height=Config.rectH;
		}
		
	}
}