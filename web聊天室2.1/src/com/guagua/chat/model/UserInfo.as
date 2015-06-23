package com.guagua.chat.model 
{
	import com.guagua.chat.util.Operation;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Wen
	 */
	public class UserInfo extends EventDispatcher
	{
		public var uid:Number=0;
		public var name:String = "";
		public var mesk:String = "4D2EE2ADF46FBB147A65A99BCB040B63";
		public var m_wPhotoNum:Number=0;//头像
		public var m_byUserRule:Number=0;//用户权限
		public var m_i64EquipState:Number=0;//装备情况
		public var m_i64EquipState2:Number=0;//明星数据
		public var m_userState:Number=0;//
		public var m_wTuyaImage:Number = 0;//涂鸦的图�?
		public var m_Media:Array = [19];//媒体状态[19]
		public var isLongUser:Boolean = false;//游客false
		public var isLogin:int = 0;//是否登录
		//等级
		public var level:int=-1;
		//下面为用户列表排�?
		public var sortIndex:Number=0;
		public var next:Number;
		public var prev:Number; 
		
		/**处理缓存时，默认true用户进入，false用户离开*/
		public var COMEIN:Boolean = true;
		
		public function UserInfo() 
		{
			
		}
		
		/**歌手等级*/
		public function  get starLevel():Number{
			return (m_i64EquipState2>>18)&31
		}
		
		/***职业等级*/
		public function get jobLevel():Number {
			return (m_i64EquipState2>>7) & 31;
		}
		
		/**用户等级*/
		public function get userLevel():Number {
			//return (m_i64EquipState & (Math.pow(2,6)-1));
			return (m_i64EquipState2) & (Math.pow(2,7)-1);
		}
		
		public function get nobility():Boolean{
			var gz:Number=(m_i64EquipState/Math.pow(2,60))&0xf;
			var hz:Number=(m_i64EquipState/Math.pow(2,44))&0xf;
			var huz:Number=(m_i64EquipState/Math.pow(2,35))&0x7;
			return Boolean((gz>0)||(hz>0)||(huz>0));
		}
		/**用户vip等级*/
		public function get byVipGrade():Number {
			return (m_i64EquipState >> 48) & 0xF; 
			//return (m_i64EquipState / Math.pow(2, 48)) & 0xf;
		}			
		
		//1053 用户资料变化通知
		
		public function getJsObj():Object{
			var obj:Object = new Object();
			obj.uid=uid;
			obj.nickName = name;
			obj.photoNum = m_wPhotoNum;
			obj.userRule =m_byUserRule;
			obj.userState = m_userState;
			obj.equipState = m_i64EquipState;
			obj.equipState2 = m_i64EquipState2;
			obj.tuyaImg = m_wTuyaImage;
			obj.sortIndex =sortIndex;
			obj.level=level;
			obj.next = next;
			obj.prev = prev;
			obj.starLevel=starLevel;
			//trace(sortIndex,this.name,this.uid);
			return obj;
		}
		
		/**
		 * 用户是否是游客
		 * */
		public function get isGuest():Boolean
		{
			return uid >= RoomModel.getRoomModel().maxUid;
		}
		
		public function toPropertyString():String {
			return this.name + " " + this.uid;
		}
	}

}