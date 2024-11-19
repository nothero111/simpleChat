interface userMessage{
  name:string,
  account:string,
  password:string,
}//定义用户信息的接口


interface dialog{
  postUserAccount:number,
  getUserAccount:number,
  text:string
}//定义用户对话的接口


class diagLog implements dialog{
  postUserAccount:number;

  getUserAccount:number;

  text:string

  constructor(postUserAccount:number,getUserAccount:number,text:string) {
    this.postUserAccount = postUserAccount

    this.getUserAccount = getUserAccount

    this.text = text
  }

}//定义用户对话的类

class  myFriend{
  name:string;
  account:string;
  avatar: string|Resource;
  timing:number;
  newMessage:string;

  constructor(name: string, account: string, avatar: string|Resource, timing: number, newMessage: string) {
    this.name = name;
    this.account = account;
    this.avatar = avatar;
    this.timing = timing;
    this.newMessage = newMessage;
  }

}

class UserMessage{
  name:string;
  account:string;
  password:string;
timing:string;
  constructor(name:string,account:string,password:string,timing:string) {
    this.name = name
    this.account = account
    this.password = password
    this.timing = timing
  }
}

class returnLink{
  firstCharacter:string;
  friendList:queryFriend[]

  constructor(firstCharacter: string, friendList: queryFriend[]) {
    this.firstCharacter = firstCharacter;
    this.friendList = friendList;
  }


}




class queryFriend{
  id:number;
  first:string;
  password:string;
  verify:string;
  touxianglj:string|Resource;
  name:string;
  account:string;
  timing:string;
  constructor(id: number, first: string, password: string, verify: string, touxianglj: string|Resource, name: string,
    account: string, timing: string) {
    this.id = id;
    this.first = first;
    this.password = password;
    this.verify = verify;
    this.touxianglj = touxianglj;
    this.name = name;
    this.account = account;
    this.timing = timing;
  }
}

class queryFriend1{
  name:string;
  account:string;
  avatar:string|Resource;

  constructor(name: string, account: string, avatar: string|Resource) {
    this.name = name;
    this.account = account;
    this.avatar = avatar;
  }

}
class newest1{
  id:number;
  sender:string;
  message:string;
  timestamp:string

  constructor(id: number, sender: string, message: string, timestamp: string) {
    this.id = id;
    this.sender = sender;
    this.message = message;
    this.timestamp = timestamp;
  }

}
class newest{
  id:number;
  sender:string;
  message:string;
  isread:boolean;
  timestamp:string;
  constructor(id:number,sender_id: string, message_new: string, isread: boolean,timestamp:string) {
    this.id = id
    this.sender = sender_id;
    this.message = message_new;
    this.isread = isread;
    this.timestamp = timestamp
  }
}//定义一个最新消息的



class talk{
    sender:string;
    receiver:string;
    message:string;
    timestamp:string

  constructor(sender: string, receiver: string, message: string, timestamp: string) {
    this.sender = sender;
    this.receiver = receiver;
    this.message = message;
    this.timestamp = timestamp;
  }



}//为聊天列表创建的类
export {newest1,newest,myFriend,userMessage,dialog,UserMessage,diagLog,queryFriend,queryFriend1,talk,returnLink}