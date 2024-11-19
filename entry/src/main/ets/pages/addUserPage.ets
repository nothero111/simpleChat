import { promptAction, router, window } from '@kit.ArkUI'
import { isUpload, postNewMessage } from './httpMode/newhttp'
import { myFriend, queryFriend, queryFriend1 } from './mode/httpMode'
import MyPre from './Util/preference'

@Entry
@Component
struct UserHomePage {
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
@State myCount:string = ''
  @State friend:queryFriend1 = new queryFriend1('小明','111111',$r('app.media.avatar0'))
async aboutToAppear() {
  this.friend =  router.getParams() as queryFriend1
   this.myCount = await MyPre.getPre('myCount','') as string
  }

  @State isEnter:boolean = false

  build() {
    Column(){
      Row(){
        Image($r('app.media.back')).width(20)
          .onClick(()=>{
            router.back()
          })
          .margin({left:5,top:30})
        Blank()
          Image($r('app.media.more')).width(20)
            .margin({right:5,top:30})
      }.width('100%').backgroundColor(Color.White)
      Column(){
        Row(){
          Image(this.friend.avatar).width(70)
            .margin({left:10}).padding({right:10})
          Text(this.friend.name)
        }.width('100%')
          Text('账号：'+this.friend.account)
      }.width('100%').backgroundColor(Color.White).height(150)
        .padding({top:20})
      Row(){
        Text('添加为好友').fontColor('#639265')
          .onClick(()=>{
            postNewMessage<isUpload>('0',this.myCount,this.friend.account,0,'','sendAsk')//当name传为5，表示我发送好友请求给friend
              .then((resp)=>{
                if (resp.is == '1') {
                  promptAction.showToast({
                    message:'已申请好友'
                  })
                }else{
                  promptAction.showToast({
                    message:'已发送过好友申请'
                  })
                }

              })
              .catch(()=>{
                promptAction.showToast({
                  message:'网络出现问题'
                })
              })
          })
      }.width('100%').height(100).margin({top:20})

      .backgroundColor(Color.White).justifyContent(FlexAlign.Center)

    }.justifyContent(FlexAlign.Start)
    .width('100%').height('100%')
    .backgroundColor('#ededed')


  }
}