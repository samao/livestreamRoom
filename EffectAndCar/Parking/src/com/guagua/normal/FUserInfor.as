package com.guagua.normal
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	/**
	 *@Date:2012-11-1 下午05:45:06	
	 */
	
	public class FUserInfor extends EventDispatcher
	{
		/**皮肤是否准备好了*/
		private var isReady:Boolean;
		
		private var _texture:Sprite;			
		/**用户对于swf库内的映射id*/
		public var libMap:String="0";		
		/**车主id*/
		public var m_i64UserID:Number=0;
		/**车主昵称*/
		public var m_szUserName:String="";
		/**用户贵族*/
		public var m_szUserNobility:String="";
		/**用户贵族等级*/
		public var m_iUserNobilityLevel:Number=0;
		/**用户贵族图片*/
		public var m_szUserNobilityPic:String="";
		/**用户vip*/		
		public var m_szUserVip:String="";
		/**用户红钻等级*/
		public var m_iUserVipLevel:Number=0
		/**用户VIP图片*/
		public var m_szUserVipPic:String="";
		/**车辆价格等级*/
		public var m_wCarOrder:Number=0;
		/**车辆名称*/
		public var m_szCar:String="";
		/**车辆图片*/
		public var m_lCarID:String="19830202";
		/**加入公聊区信息*/
		public var m_szInserInfo:String="";
		
		public var m_i64UserComeinTime:Number=0;
		/**车辆图片地址*/
		public var m_szCarResPath:String=""
		
		/**
		 * 车主信息模型
		 * @param 
		 * <table><tr><td>obj.m_i64UserId:车主id</td><td>obj.m_szUserName:车主昵称</td></tr>
		 * <tr><td>obj.m_szUserNobility:用户贵族</td><td>obj.m_szUserNobilityPic:用户贵族图片</td></tr>
		 * <tr><td>obj.m_szUserVip:用户vip</td><td>obj.m_szUserVipPic:用户VIP图片:</td></tr>
		 * <tr><td>obj.m_fCarPrice:车辆价格等级</td><td>obj.m_szCar:车辆名称</td></tr>
		 * <tr><td>obj.m_lCarID:车辆图片id</td><td>obj.m_iUserNobilityLevel:贵族等级</td></tr>
		 * <tr><td>obj.m_iUserVipLevel:VIP等级</td></tr>
		 * </table>,
		 * */
		public function FUserInfor(obj:Object=null,target:IEventDispatcher=null)
		{
			super(target);			
			try{
				
				if(obj.hasOwnProperty(ConstVal.m_i64UserID)){
					this.m_i64UserID=obj[ConstVal.m_i64UserID];
				}
				
				if(obj.hasOwnProperty(ConstVal.m_szUserName)){
					this.m_szUserName=obj[ConstVal.m_szUserName];
				}
				
				if(obj.hasOwnProperty(ConstVal.m_szUserNobility)){
					this.m_szUserNobility=obj[ConstVal.m_szUserNobility];
				}
				
				if(obj.hasOwnProperty(ConstVal.m_szUserNobilityPic)){
					this.m_szUserNobilityPic=obj[ConstVal.m_szUserNobilityPic];
				}
				if(obj.hasOwnProperty(ConstVal.m_szUserVip)){
					this.m_szUserVip=obj[ConstVal.m_szUserVip];
				}
				if(obj.hasOwnProperty(ConstVal.m_szUserVipPic)){
					this.m_szUserVipPic=obj[ConstVal.m_szUserVipPic];
				}
				if(obj.hasOwnProperty(ConstVal.m_wCarOrder)){
					this.m_wCarOrder=obj[ConstVal.m_wCarOrder];
				}
				
				if(obj.hasOwnProperty(ConstVal.m_szCar)){
					this.m_szCar=obj[ConstVal.m_szCar];
				}
				if(obj.hasOwnProperty(ConstVal.m_lCarID)){
					this.m_lCarID=obj[ConstVal.m_lCarID];
				}
				
				if(obj.hasOwnProperty(ConstVal.m_szInserInfo)){
					this.m_szInserInfo=obj[ConstVal.m_szInserInfo];
				}
				if(obj.hasOwnProperty(ConstVal.m_iUserVipLevel)){
					this.m_iUserVipLevel=obj[ConstVal.m_iUserVipLevel];
				}
				if(obj.hasOwnProperty(ConstVal.m_iUserNobilityLevel)){
					this.m_iUserNobilityLevel=obj[ConstVal.m_iUserNobilityLevel];	
				}
				if(obj.hasOwnProperty(ConstVal.m_i64UserComeinTime)){
					this.m_i64UserComeinTime=obj[ConstVal.m_i64UserComeinTime];
				}
				if(obj.hasOwnProperty(ConstVal.m_szCarResPath)){
					this.m_szCarResPath=obj[ConstVal.m_szCarResPath];
				}
			}catch(e:Error){
				if(ExternalInterface.available){				
					ExternalInterface.call("onFlashError",e.message);
				}
			}	
		}		
		

		/**车辆皮肤*/
		public function get texture():Sprite
		{
			return _texture;
		}

		/**
		 * @private
		 */
		public function set texture(value:Sprite):void
		{
			isReady=true;
			_texture = value;
		}
		
		/**序列化用户模型*/
		public function toObject():Object{
			var o:Object=new Object();			
			o[ConstVal.m_i64UserID]=this.m_i64UserID;
			o[ConstVal.m_szUserName]=this.m_szUserName;
			o[ConstVal.m_szUserNobility]=this.m_szUserNobility;
			o[ConstVal.m_szUserNobilityPic]=this.m_szUserNobilityPic;
			o[ConstVal.m_szUserVip]=this.m_szUserVip;
			o[ConstVal.m_szUserVipPic]=this.m_szUserVipPic;
			o[ConstVal.m_wCarOrder]=this.m_wCarOrder;
			o[ConstVal.m_szCar]=this.m_szCar;
			o[ConstVal.m_lCarID]=this.m_lCarID;
			//trace(o[ConstVal.m_szCarPic])
			o[ConstVal.m_szInserInfo]=this.m_szInserInfo;
			o[ConstVal.m_iUserVipLevel]=this.m_iUserVipLevel;
			o[ConstVal.m_iUserNobilityLevel]=this.m_iUserNobilityLevel;
			o[ConstVal.m_i64UserComeinTime]=this.m_i64UserComeinTime;
			o[ConstVal.m_szCarResPath]=this.m_szCarResPath;
			return o;
		}
	}
}