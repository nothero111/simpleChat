

import { router, window } from '@kit.ArkUI';
import { isUpload, postNewMessage } from './httpMode/newhttp';
import { talkList, talkReturn} from './mode/rdbTalkMode';
import MyPre from './Util/preference';
import { BusinessError } from '@kit.BasicServicesKit';
import myRdb from './Util/rdbUtil';


class  myFriend{
  name:string
  avatar:string|Resource
  account:string

  constructor(name: string, avatar: string|Resource, account: string) {
    this.name = name;
    this.avatar = avatar;
    this.account = account;
  }

}
@Entry
@Component
struct CommunicationPage {
  //预览器效果显示
  windowClass?: window.Window
  async setFullScreen(flag: boolean) {
    if (!this.windowClass) {
      this.windowClass = await window.getLastWindow(getContext(this))
    }
    this.windowClass.setWindowLayoutFullScreen(flag)
  }
  onPageShow(): void {
    this.setFullScreen(true)
  }
  onPageHide(): void {
    this.setFullScreen(false)
  }
@State message:string = ''
@State talks:talkReturn[] = []
  @State talkList:talkList[] = [] //创建一个数组，
  //用来放置最终的
@State i:number = 0//清理定时器任务
  @State myCount:string = ''
@State parm:myFriend = new myFriend('1','','')
  @State myImage:string = ''//储存我的头像
  @State myName: string = ''//储存我的名字
async aboutToAppear() {
  this.parm = router.getParams() as myFriend
 this.myCount = await MyPre.getPre('myCount','') as string
  this.myName = await MyPre.getPre('myName','') as string
  this.myImage = await MyPre.getPre('avatar','') as string
  let Id = setInterval(()=>{
    postNewMessage<talkReturn[]>('',this.myCount,this.parm.account,0,'','receive1')//发送的名字是2，希望可以收到所有的聊天内容
      .then(async  (resp)=>{
          this.talks = resp
        console.log('testTagNewreceive','数组长度',resp.length)
        myRdb.deleteTalk()
        for (let index = 0; index < resp.length; index++) {
          const element = resp[index];
            myRdb.addTalk(element.sender,element.receiver,element.message,element.timestamp.toString())
        }
        if (this.talks.length != this.talkList.length) {
          this.talkList.splice(0)
          for (let index = 0; index < this.talks.length; index++) {
            const element = this.talks[index];
            let postAvatar:string = ''
            let receiverAvatar:string = ''
            let postName:string = ''
            let receiverName:string = ''
            if (element.sender == this.myCount) {
              postAvatar = this.myImage
              postName = this.myName
              receiverAvatar = this.parm.avatar as string
              receiverName = this.parm.name
            }else {
              postAvatar = this.parm.avatar as string
              postName = this.parm.name
              receiverAvatar = this.myImage
              receiverName = this.myName
            }
            this.talkList.push(new talkList(
              element.sender,element.receiver,element.message,postName,receiverName,
              postAvatar,receiverAvatar,parseFloat(element.timestamp)
            ))
          }
        }
      }).catch(async (e:BusinessError)=>{
      this.talks = await myRdb.queryTalk()
      if (this.talks.length != this.talkList.length) {
        this.talkList.splice(0)
        for (let index = 0; index < this.talks.length; index++) {
          const element = this.talks[index];
          let postAvatar:string = ''
          let receiverAvatar:string = ''
          let postName:string = ''
          let receiverName:string = ''
          if (element.sender == this.myCount) {
            postAvatar = this.myImage
            postName = this.myName
            receiverAvatar = this.parm.avatar as string
            receiverName = this.parm.name
          }else {
            postAvatar = this.parm.avatar as string
            postName = this.parm.name
            receiverAvatar = this.myImage
            receiverName = this.myName
          }
          this.talkList.push(new talkList(
            element.sender,element.receiver,element.message,postName,receiverName,
            postAvatar,receiverAvatar,parseFloat(element.timestamp)
          ))
        }
      }
      console.log("testTagNewreceive",JSON.stringify(e))
    })

  },500)//在该页面不停的发送
  this.i = Id


console.log('testTagNewreceive',this.talkList.length)

}

aboutToDisappear(): void {
    clearInterval(this.i)
}
@State isEnter:boolean = false
@State name:string = '小明'
  build() {
    Column(){
      Column(){
        header({name:this.parm.name}).backgroundColor('#ededed')
          .height(80)
        Divider()
      }.width('100%')
      List(){
          ForEach(this.talkList,(dialog:talkList)=>{
            ListItem(){
              if(dialog.postAccount != this.myCount){
                Row(){
                  Image(dialog.postAvatar).width(30)
                    .borderRadius(5)
                    .margin({right:5})
                    Text(' '+dialog.message+' ').height(30)
                      .padding(5)
                      .fontSize(15).borderRadius(5)
                      .backgroundColor('#fefdfb')
                }.padding({left:5})
              }else{
                Row(){
                  Text(' '+dialog.message+' ').height(30)
                    .margin({right:5})
                    .backgroundColor('#65c097')
                    .borderRadius(5).fontSize(15)
                  Image(dialog.postAvatar).width(30)
                }.width('100%').justifyContent(FlexAlign.End)
                .padding({right:5})
              }
            }.padding({bottom:5,top:5})
          })
      }.width('100%').layoutWeight(1)
      TextInput({placeholder:'写下你想说的话',text:this.message})
        .onSubmit(()=>{
          this.isEnter = !this.isEnter
          console.log('testTagNewMessage',this.isEnter)
          if(this.isEnter == true){
            postNewMessage<isUpload>('',this.myCount,this.parm.account,0,this.message,'send')//当name为3时，发送聊天记录
              .then(()=>{
                myRdb.addTalk(this.myCount,this.parm.account,this.message,Date.now().toString())
                this.talkList.push(new talkList(this.myCount,this.parm.account,this.message,this.myName,this.parm.name
                  ,this.myImage,this.parm.avatar,Date.now()))
                this.message = ''
                console.log('testTagNewMessage','发送成功')
                //console.log('testTagNewMessage',this.talkList[0].postAccount)
                return
              }).catch(()=>{
              console.log('testTagNewMessage','发送失败')
              AlertDialog.show({
                message:'网络问题，未发送'
              })
              this.isEnter == false
            })
          }
        })
        .onChange((value)=>{
          this.message = value
        //写下将来向服务器发送的内容

      })
        .margin({bottom:10})
    }.width('100%').height('100%')
    .backgroundColor('#ededed')

  }
}
@Component
struct header {
  @State name:string = ''
  build() {
    Row(){
      Text(this.name).fontSize(20)
        .margin({right:135,left:135})
      Image($r('app.media.more')).width(20)
    }.width('100%')
    .margin({top:40})
    .justifyContent(FlexAlign.Center)
  }
}