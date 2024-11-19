 export default  class friendListMode{
  //头像
  avatar:Resource
  //昵称
  name:string
  //最新消息
  newText:string
  //最新消息时间
  time:string

  constructor(avatar:Resource,name:string,newText:string,time:string) {
  this.avatar = avatar
    this.name =name
    this.newText = newText

    this.time = time
  }
}