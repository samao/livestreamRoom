package xing.screenshot.com
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.text.*;
	import xing.screenshot.Config;
	public class TyImg extends Sprite
	{
		private var bit:Bitmap;
		private var id:Number=0;
		private var label:TextField ;
		public function TyImg(_id:Number)
		{
			id=_id;
			
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC,0.1);
			this.graphics.lineStyle(1, 0xCCCCCC,1,true);
			
			
			
			label = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			//label.width=170;
			label.textColor=0x999999;
			//label.background = true;
			//label.border = true;
			label.selectable=false;
			
			var format:TextFormat = new TextFormat();
			//format.font = "宋体";
			format.color = 0x999999;
			format.size = 16;
			
			addChild(label);
			
			/*if(id==170){
				label.text="大尺寸头像,170*170像素";
				label.y=175;
				this.graphics.drawRect(-1, -1, 172, 172);
			}
			if(id==50){
				label.text="中尺寸头像\n50*50像素";
				label.y=55;
				this.graphics.drawRect(-1, -1, 52, 52);
			}
			if(id==32){
				label.text="小尺寸头像\n32*32像素";
				label.y=37;
				this.graphics.drawRect(-1, -1, 34, 34);
			}*/
			label.y=Config.imgH+5+20;
			//label.text="尺寸大于"+Config.imgW+"*"+Config.imgH;
			label.htmlText="<font color='#FF0000'>尺寸大于"+Config.sizeAry[0][0]+"*"+Config.sizeAry[0][1]+"</font>";
			label.defaultTextFormat = format;
			
			this.graphics.endFill();	

		}
		
		public function initLabel():void{
			label.htmlText="<font color='#FF0000'>尺寸大于"+Config.sizeAry[0][0]+"*"+Config.sizeAry[0][1]+"</font>";
		}
		
		public function setBitData(b:BitmapData):void{
			if(bit!=null){
				bit.bitmapData.dispose();
				this.removeChild(bit);
				bit=null;
			}
			bit=new Bitmap(b);
			this.addChild(bit);
			this.graphics.drawRect(-1, -1, Config.imgW, Config.imgH);
			label.y=Config.imgH+3;
			if(bit.width>label.width){
				//label.x=bit.x+(bit.width-label.width)/2;
			}else{
				
			}
			bit.width=Config.imgW;
			bit.height=Config.imgH;
		}
		public function clear():void{
			if(bit!=null){
				if(bit.bitmapData)
				{
					bit.bitmapData.dispose();
				}
				this.removeChild(bit);
				bit=null;
			}
		}
		
		public function get getImgData():BitmapData{
			if(bit==null)return null;
			return bit.bitmapData.clone();
		}
	}
}