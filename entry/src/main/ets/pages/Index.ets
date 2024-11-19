import Header from './common/messagePage/header'
import { router, window } from '@kit.ArkUI'
import friendList from './common/messagePage/frinedList'
import connectionList from './common/connectionList/connectionList'
import MyHome from './common/minePage/MyHome'




@Entry
@Component
struct Index {
    aboutToAppear(): void {
      router.clear()
    }
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


@State selectChoose:number = 0//设置选中的选项卡样式
@State name:number = 0
build() {
  Tabs({barPosition:BarPosition.End}){
  TabContent(){
    Column(){
      Header().backgroundColor('#ededed')
        .height(80)
      Divider()
friendList().layoutWeight(1)
    }.height('100%')
  }
  .tabBar(this.TabBarBuilder($r('app.media.news'),'消息',0))
    TabContent(){
      Column(){
        Header({name:'联系人'}).backgroundColor('#ededed')
          .height(80)
        connectionList().layoutWeight(1)
      }.height('100%')
    }
    .tabBar(this.TabBarBuilder($r('app.media.link'),'联系人',1,25,8))
    TabContent(){
      MyHome().margin({top:10})

    }.height('100%').backgroundColor('#ededed').width('100%')
    .tabBar(this.TabBarBuilder($r('app.media.mine'),'我的',2,25,8))
}
.barHeight(80)//自定义bar的高度
.divider({strokeWidth:0.2,color:Color.Black})
  .onChange(inx=>{
      this.selectChoose = inx
  })
  .width('100%').height('100%')

  }
  @Builder TabBarBuilder(image:Resource,text:string,index:number,width?:number,marin?:number){
      Column(){
       Image(image)
         .fillColor(this.selectChoose == index ? '#ffdc00':Color.Black)
         .width(width?width:30)
         .margin(marin?marin:5)
        Text(text)
          .fontColor(this.selectChoose == index ? '#ffdc00':Color.Black)
          .fontSize(10)
          .height(20)

      }.width('100%').height('100%')

      .justifyContent(FlexAlign.Start)
    .backgroundColor('#ededed')

  }//控制tab样式

}


