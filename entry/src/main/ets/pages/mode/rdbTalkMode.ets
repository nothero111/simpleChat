  class talkList{
  postAccount:string
  acceptAccount:string
  message:string
postName:string
  acceptName:string
  postAvatar:string|Resource
  acceptAvatar:string|Resource
  timing:number

  constructor(postAccount: string, acceptAccount: string, message: string, postName: string, acceptName: string,
    postAvatar: string|Resource, acceptAvatar: string|Resource, timing: number) {
    this.postAccount = postAccount
    this.acceptAccount = acceptAccount
    this.message = message
    this.postName = postName
    this.acceptName = acceptName
    this.postAvatar = postAvatar
    this.acceptAvatar = acceptAvatar
    this.timing = timing
  }
}//定义单条聊天记录的数据模型

  class talk1{
      sender:string;
      receiver:string;
      message:string;
      timestamp:string

    constructor(sender: string, receiver: string, message: string, timestamp: string) {
      this.sender = sender
      this.receiver = receiver
      this.message = message
      this.timestamp = timestamp
    }

  }
  class talkReturn{
      id:string;
      sender:string;
      receiver:string;
      message:string;
      timestamp:string

    constructor(id:string,sender: string, receiver: string, message: string, timestamp: string) {
      this.id  = id
        this.sender = sender
      this.receiver = receiver
      this.message = message
      this.timestamp = timestamp
    }

  }

export {talkList,talk1,talkReturn}
  //储存有关聊天记录的类