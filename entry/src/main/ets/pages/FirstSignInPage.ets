
import { router } from '@kit.ArkUI'
import MyPre from './Util/preference'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct FirstSignInPage {

aboutToAppear() {
    MyPre.getPre('isSkip', false)
      .then((value)=>{
        let isSkip = value as boolean
        console.log('testTag','首次登录页面成功得到isSkip的值')
        if (isSkip == true) {
          router.pushUrl({
            url:'pages/Index'
          })
        }
      }).catch((err:BusinessError)=>{
        console.log('testTag','未得到isSkip的值',JSON.stringify(err))
    })
}
  build() {
    Column({space:20}){
      Column(){
        Text('简：是一种交流').fontColor(Color.White).fontSize(35)
          .width('100%')
        Text('的艺术').fontColor(Color.White).fontSize(35)
          .width('100%')
        Text('Simple:It\'s a kind of communication')
          .width('100%')
        Text('The are of')
          .width('100%')
      }.width('100%').padding({left:10})

    Row({space:80}){
        Button('注册')//跳转到注册页面的按钮
          .onClick(()=>{
            router.pushUrl({
              url:'pages/registerPage'
            })
          })//跳转到登录界面
          .type(ButtonType.Normal).width(120)
          .borderRadius(5).backgroundColor('#48a6ae')
      Button('登录')//跳转到登录页面的按钮
        .onClick(()=>{
          router.replaceUrl({
            url:'pages/SignPage'
          })
        })//跳转到注册界面
        .type(ButtonType.Normal).width(120)
        .borderRadius(5).backgroundColor('#ffd4c9')
    }
    }
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.END])



    .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.signIn'))
.backgroundImageSize(ImageSize.Cover)
  }
}