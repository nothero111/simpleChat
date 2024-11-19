import { router } from "@kit.ArkUI";

@Component
export default  struct Header{
  @State MunShow:boolean = true
@State name:string = '消息'
  @State image:string = 'add'
  @Builder myMun(){
    Menu(){
      MenuItem({
        content:'添加好友',
        startIcon:$r('app.media.addFriend')
      }).onClick(()=>{
        router.pushUrl({
          url:'pages/searchFriendPage'
        })
      })
        .selected(this.MunShow)
        .onChange((selected) => {
          console.info("menuItem select" + selected);
          this.MunShow = selected
        })
    }
  }
  build() {
        Row(){
          Text(this.name).fontSize(20)
            .margin({right:135,left:135})
          Image($r(`app.media.${this.image}`)).width(20)
            .bindMenu(this.myMun)
        }.width('100%')
        .margin({top:40})
    .justifyContent(FlexAlign.Center)
  }
}