import { router, window } from '@kit.ArkUI'
import { myFriend } from './mode/httpMode'

@Entry
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
  }////

  @State aFriend:myFriend = new myFriend('11','',$r('app.media.avatar0'),0,'')
 aboutToAppear() {

   this.aFriend = router.getParams() as myFriend

  }
  build() {
    Column({space:70}){
      Row(){
        Image(this.aFriend.avatar).width(100).margin({top:50})
          .padding({right:10})
        Text(this.aFriend.name).fontSize(30)

      }.alignItems(VerticalAlign.Bottom)
      Text('账号：'+this.aFriend.account).fontSize(40)
      Button('发消息').width(300).height(60).backgroundColor('#f2f3f5')
        .onClick(()=>{
          router.pushUrl({
            url:'pages/CommunicationPage',
            params:{
              name:this.aFriend.name,
              account: this.aFriend.account,
              avatar: this.aFriend.avatar,
            }
          })
        })
        .fontColor('#5caaa7')
    }.width("100%").height('100%')
  }
}