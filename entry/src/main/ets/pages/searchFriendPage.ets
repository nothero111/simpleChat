import { router } from '@kit.ArkUI'
import { postNewMessage } from './httpMode/newhttp'
import { queryFriend } from './mode/httpMode'
import MyPre from './Util/preference'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct SearchFriendPage {
  @State myCount: string = ''

  async aboutToAppear() {
    this.myCount = await MyPre.getPre('myCount', '') as string
  }
@State account:string = ''
  @State isEnter: boolean = false

  build() {
    Column() {
      Row() {
        TextInput({ placeholder: '请输入账号' })
          .onChange((value) => {
            this.account = value
          })
          .onSubmit(() => {
            console.log('testTag',this.account)
            postNewMessage<queryFriend>('',this.account, '', 0, '', 'chaxun')
              .then((resp) => {
                if (resp.name != '查无此人') {
                  router.pushUrl({
                    url: 'pages/addUserPage',
                    params: {
                      name: resp.name,
                      account: resp.account,
                      avatar: resp.touxianglj,
                    }
                  })
                } else {
                  AlertDialog.show({
                    message: '查无此人'
                  })
                }
              }).catch((e:BusinessError)=>{
              AlertDialog.show({
                message: '网络出现问题'
              })
                console.log('testTag',JSON.stringify(e))
            })
            this.isEnter = false
            console.log('testTag','按下')
          })
          .width(290).margin({ left: 5, right: 5 })
        Text('取消')
          .onClick(() => {
            router.back()
          })
          .fontSize(20).fontColor(Color.Blue)
          .fontWeight(FontWeight.Regular)
      }.width('100%')
    }.width('100%').height('100%')
  }



}