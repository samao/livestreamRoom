package xing.screenshot
{
	public class Config
	{
		//public static var upLoadUrl:String="zone.17guagua.com/2004069/site/portrait";//"127.0.0.1:8080/Xing/index.jsp";
		/**上传网址**/
		public static var upLoadUrl:String="127.0.0.1:1108/upload_1.php";
		/**图片大小**/
		public static var sizeAry:Array=[["432","202"]];
		//public static var sizeAry:Array=["216","101"];
		/**方框宽**/
		public static var rectW:Number=216;
		/**方框高**/
		public static var rectH:Number=101;
		/**预览宽高**/
		public static var imgW:Number=216;
		public static var imgH:Number=101;
		/**预览在图片数组中的index**/
		public static var index:int=0;
		
		public static var isUpload:Boolean=false;
		
		public static var bjImgUrl:String="http://zy.17guagua.com/images/Head.jpg";
		public function Config()
		{
		}
		
		public static function isUpLoadHandler(w:Number,h:Number):void{
			trace(w,Number(Config.sizeAry[0][0]),h,Number(Config.sizeAry[0][1]));
			if(w>=Number(Config.sizeAry[0][0]) && h>=Number(Config.sizeAry[0][1])){
				isUpload=true;
			}else{
				isUpload=false;
			}
		}
	}
}