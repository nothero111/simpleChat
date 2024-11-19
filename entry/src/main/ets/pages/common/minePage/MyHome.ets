import MyPre from "../../Util/preference"

@Component
export default struct MyHome {
  @State myName: string = ''
  @State myAccount:string = ''
  @State myAvatar: string = ''
 async  aboutToAppear(){
  this.myName = await MyPre.getPre('myName','我') as string
   this.myAvatar = await MyPre.getPre('avatar',$r('app.media.avatar')) as string
 this.myAccount = await MyPre.getPre('myCount',11111) as string
   console.log('testTag',this.myAvatar)
  }

  build() {
    Column({space:70}){
      Row(){
        Image(this.myAvatar).width(100).margin({top:50})
          .padding({right:10})
        Text(this.myName).fontSize(30)

      }.alignItems(VerticalAlign.Bottom)
      Text('账号：'+this.myAccount).fontSize(40)
      Column(){
        Text('扫描下方二维码支持作者')
        Image($r('app.media.zhichi')).width(150)
      }

      Text('更多功能仍在开发中').fontColor(Color.Gray)
    }.width("100%").height('100%')
  }
}