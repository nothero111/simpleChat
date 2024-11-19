import { router } from '@kit.ArkUI'
import { postNewMessage } from '../../httpMode/newhttp'
import MyPre from '../../Util/preference'
import myRdb from '../../Util/rdbUtil'
import {  newest, newest1, queryFriend } from '../../mode/httpMode'
import { PublicUtils } from '../../time/timeConvert'
import { BusinessError } from '@kit.BasicServicesKit'

class  myFriend0{
  name:string;
  account:string;
  avatar: string|Resource;
  timing:string;
  newMessage:string;
  isRead:boolean;
  constructor(name: string, account: string, avatar: string|Resource, timing: string, newMessage: string,
  isRead:boolean) {
    this.name = name;
    this.account = account;
    this.avatar = avatar;
    this.timing = timing;
    this.newMessage = newMessage;
    this.isRead = isRead
  }
}

@Component
export default  struct friendList {
  @State myAccount:string = ''
  @State news:newest1[] =[]//创建一个空数组，储存所有的最新消息
  @State i:number = 0
  @State myFriends:queryFriend[] = []//准备一个空的数组，来存储所有的信息
  @State accounts:newest[] =[]//定义一个数组，储存所有需要更新最新消息的
  //账号
@State lastList:myFriend0[] = []//定义一个最终的数组用来渲染信息
  async aboutToAppear() {

   let ID = setInterval(async  ()=>{
     this.myAccount = await MyPre.getPre('myCount','') as string

     postNewMessage<newest1[]>('',this.myAccount,'',0,'','newMessage1')
       .then(async (resp)=>{
         this.lastList.splice(0,this.lastList.length)
         let aaa = await myRdb.queryNews()//从库里取出所有的最新消息1
         this.myFriends = await myRdb.queryLinkRecord()//取出所有的好友信息
         if (aaa.length == 0) {
           for (let index = 0; index < resp.length; index++) {
             const element = resp[index];
             this.myFriends.find((value)=>{
               if (value.account == element.sender) {
                 this.lastList.push(new myFriend0(element.sender,value.account,value.touxianglj,
                   element.timestamp,element.message,true))
                 myRdb.addNews(value.account,element.message,element.timestamp,true)
               }
             })
           }
         }else {
           //this.lastList.splice(this.lastList.length)
           for (let index = 0; index < resp.length; index++) {
             const element = resp[index];
             aaa.find(value=>{
               if (element.sender == value.sender && element.timestamp != value.timestamp) {
                 myRdb.updateNew(element.sender,element.message,element.timestamp,false)
               }
             })
           }
           for (let index = 0; index < resp.length; index++) {
             const element = resp[index];
             for (let index = 0; index < this.myFriends.length; index++) {
               const elemen = this.myFriends[index];
               for (let index = 0; index < aaa.length; index++) {
                 const elem = aaa[index];
                 if (element.sender == elemen.account&& element.sender == elem.sender) {
                   this.lastList.push(new myFriend0(elemen.name,elemen.account,elemen.touxianglj,
                   element.timestamp,element.message,elem.isread))
                 }
               }
             }

           }
         }
         console.log('testTagnewMessage1','数组长度',this.lastList.length,resp.length)
       })
       .catch(async  (e:BusinessError)=>{
         this.lastList.splice(this.lastList.length)
         this.accounts = await myRdb.queryNews()
         let isread:boolean = false
         this.myFriends = await myRdb.queryLinkRecord()
         if (this.accounts.length != this.lastList.length) {
           for (let index = 0; index < this.myFriends.length; index++) {
             const element = this.myFriends[index];
             for (let index = 0; index < this.accounts.length; index++) {
               const ele = this.accounts[index];
               this.accounts.find((value)=>{
                 if (value.sender == ele.sender) {
                   isread = value.isread
                 }
               })
               if (element.account == ele.sender) {
                 this.lastList.push(new myFriend0(element.name,element.account,element.touxianglj,ele.timestamp
                   ,ele.message,isread))
               }
             }
           }
         }


         console.log('testTagnewMessage1','请求最新消息出现错误',JSON.stringify(e))
       })
    },2000)
    this.i = ID


}

aboutToDisappear(): void {
clearInterval(this.i)
 }


  build() {
      Column(){
        List(){
          ForEach(this.lastList,(friend:myFriend0,idx:number)=>{
            ListItem(){
                Row(){
                  Badge({value: '',
                  style: { badgeSize: 6, borderColor:!friend.isRead?'#FA2A2D':Color.White,
                    badgeColor:!friend.isRead?'#FA2A2D':Color.White },
                }){
                    Image(friend.avatar).height(45)
                      .borderRadius(5).padding({right:5})
                  }
                  Column(){
                    Row(){
                      Text(friend.name)
                      Blank()
                      Text(PublicUtils.getDateTime(parseFloat(friend.timing),"HH:mm"))
                        .fontSize(10)
                        .fontColor(Color.Gray)
                    }.padding({bottom:5})
                    .width('80%')
                    Text(friend.newMessage).fontSize(10)
                      .fontColor(Color.Gray)
                    Divider().color(Color.Black)
                      .width('100%')
                  }.alignItems(HorizontalAlign.Start).height(40)

                }.margin({left:5}).width('100%')

            }.height(70).width('94%')
            .onClick(()=>{
              friend.isRead = !friend.isRead
              this.lastList.splice(idx,1,new myFriend0(friend.name,friend.account,friend.avatar,
              friend.timing,friend.newMessage,true))
              myRdb.updateNew(friend.account,friend.newMessage,friend.timing,true)
              router.pushUrl({
                url:'pages/CommunicationPage',
                params:{
                      name:friend.name,
                  account:friend.account,
                  avatar:friend.avatar
                }
              })
            })
          })
        }.width('100%').height('100%')
      }
      .width('100%').height('100%')
  }
}


