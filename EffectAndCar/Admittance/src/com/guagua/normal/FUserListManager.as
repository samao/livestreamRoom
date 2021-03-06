package com.guagua.normal
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	/**
	 * 用户管理类
	 *@Date:2012-11-1 下午05:45:52	
	 */
	
	public class FUserListManager extends EventDispatcher
	{
		/**客户端用户id*/
		public var client_uid:Number;
		
		/**进入用户队列*/
		public var userEntryVector:Vector.<FUserInfor>=new Vector.<FUserInfor>();
		
		/**离开用户队列*/
		private var userLeaveVector:Vector.<FUserInfor>=new Vector.<FUserInfor>();
		
		static private var instance:FUserListManager;
		
		public function FUserListManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		static public function getInstance():FUserListManager{
			if(instance==null){
				instance=new FUserListManager();
			}
			return instance;
		}
		
		/**检查进入队列是否为空*/
		public function hasNext():Boolean{
			return (userEntryVector.length>0)
		}
		
		/**
		 * 按id删除进入队列的用户
		 * @param id:需要删除的用户id
		 * @param 成功返回被删除用户，失败返回null
		 * */
		public function removeUserById(id:uint):FUserInfor{
			for each(var i:FUserInfor in userEntryVector){
				if(i.m_i64UserID==id){
					return i;
				}
			}
			return null;
		}
		
		/**
		 * 按用户模型删除进入队列的用户
		 * @param user:需要删除的用户
		 * @param 成功返回被删除用户，失败返回null
		 * */
		public function removeUser(user:FUserInfor):FUserInfor{
			for(var i:uint=0;i<userEntryVector.length;i++){
				if(userEntryVector[i].m_i64UserID==user.m_i64UserID){
					return userEntryVector.splice(i,1)[0];
				}
			}
			return null;
		}
		
		/**
		 * 将用户从离开列表移到进入列表
		 * @param id被操作用户id
		 * @return 移动成功返回true，失败返回false
		 * */
		public function moveUserToEntryList(id:uint):Boolean{
			
			for(var i:uint=0;i<userLeaveVector.length;i++){
				if(userLeaveVector[i].m_i64UserID==id){
					var user:FUserInfor=userLeaveVector.splice(i,1)[0];
					userEntryVector.push(user);
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 添加用户到进入队列
		 * @param user:用户模型
		 * @return 添加结果，失败返回false成功返回true
		 * */
		public function addUser(user:FUserInfor):Boolean{	
			if(findUser(user)){
				trace("用户已在队列")
				return false;
			}
			userEntryVector.push(user);
			return true;
		}
		
		/**
		 * 添加用户到离开列表
		 * @param user:用户模型
		 * */
		public function addToLeave(user:FUserInfor):String{
			for each(var i:FUserInfor in userLeaveVector){
				if(i.m_i64UserID==user.m_i64UserID){
					return "用户已经在离开队列"
				}
			}						
			userLeaveVector.push(user);
			return "离开成功";
		}
		
		/**
		 * 从离开列表删除用户
		 * @param id:用户id；
		 * */
		public function removeUserFromLeave(id:uint):FUserInfor{
			for (var i:uint=0;i<userLeaveVector.length;i++){
				if(userLeaveVector[i].m_i64UserID==id){
					return userLeaveVector.splice(i,1)[0];
				}
			}
			return null
		}
		
		/**
		 * 查看用户在不在进入队列中
		 * @param user:需要查找才用户模型
		 * @return 在队列中返回true，不在返回false
		 * */
		private function findUser(user:FUserInfor):Boolean{
			for each(var i:FUserInfor in this.userEntryVector){
				if(i.m_i64UserID==user.m_i64UserID){
					return true
				}
			}
			return false
		}
		
		
		
		/**获取队列中第一个用户*/
		public function getNextUser():FUserInfor{			
			return (userEntryVector[0]);
		}
		
		/**
		 * 检查用户是否在离开队列
		 * @param id:用户id
		 * @return 返回检查结果
		 * */
		public function isLeave(id:uint):Boolean{
			for each(var i:FUserInfor in userLeaveVector){
				if(i.m_i64UserID==id){
					return true;
				}
			}
			
			return false;
		}
	}
}