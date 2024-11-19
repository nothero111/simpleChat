import { promptAction, router, window } from '@kit.ArkUI'
import { isUpload, postNewMessage } from './httpMode/newhttp'
import { myFriend, queryFriend1 } from './mode/httpMode'
import MyPre from './Util/preference'
import myRdb from './Util/rdbUtil'
import { http } from '@kit.NetworkKit'
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit'


@Entry
@Component
struct NewFriendListPage {
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

@State friendImage: string = ''

  @State newFriend:queryFriend1[] =[]
  @State myCount:string = ''
 async aboutToAppear() {
    this.myCount = await MyPre.getPre('myCount','') as string
   myRdb.queryNewLinkTable()
     .then((resp)=>{
       console.log('testTag','查询是否有新的好友请求成功')
       this.newFriend = resp
     }).catch((e:BusinessError)=>{
       console.log('testTag','查询是否有新的好友请求失败',JSON.stringify(e))
   })
   console.log('testTag','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',this.newFriend.length)
  }


  build() {
    Column(){
      Row(){
        Text('新朋友').fontSize(30)
          .margin({top:60,bottom:10})
      }.width('100%').backgroundColor('#ededed').justifyContent(FlexAlign.Center)
      if (this.newFriend){
        List({space:20}){
          ForEach(this.newFriend,(friend:queryFriend1,idx:number)=>{
            ListItem(){
              Row({space:5}){
                Image(friend.avatar).width(50)
                Column(){
                  Text('昵称：'+friend.name).fontSize(13)
                  Text('账号：').fontSize(13)
                  Text(friend.account).fontSize(13)
                }.justifyContent(FlexAlign.Start)
                Button('拒绝').backgroundColor(Color.Red)
                  .margin({left:6}).backgroundColor(Color.Gray)
                  .onClick(()=>{
                    this.newFriend.splice(idx,1)
                    postNewMessage<isUpload>('0',friend.account,this.myCount,0,'','refuseAsk')//
                      //上传这两个添加为好友的信息
                      .then((resp)=>{
                        console.log('testTag1',resp.is)
                        myRdb.deleteNewLinkRecord(friend.account)
                        this.newFriend.splice(idx,1)
                        promptAction.showToast({
                          message:'拒绝申请成功'
                        })//马上出现，又马上消失
                      }).catch((e:BusinessError)=>{
                      promptAction.showToast({
                        message:'网络问题，请重试'
                      })//马上出现，又马上消失
                      console.log('testTag0',JSON.stringify(e))
                    })
                  })
                Button('同意').backgroundColor('#65be95')
                  .onClick(()=>{
                    postNewMessage<isUpload>('0',friend.account,this.myCount,0,'','acceptAsk')//
                      //上传这两个添加为好友的信息
                      .then(()=>{
                        myRdb.deleteNewLinkRecord(friend.account)
                        myRdb.putLinkRecord(friend.account,friend.name,friend.avatar as string,'','','','')
                        this.newFriend.splice(idx,1)
                        promptAction.showToast({
                          message:'同意申请成功'
                        })//马上出现，又马上消失
                      }).catch(()=>{
                      promptAction.showToast({
                        message:'网络问题，请重试'
                      })//马上出现，又马上消失
                    })
                  })
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)
            }
          })
        }

      }

        }.width("100%").height('100%')
  }


  downFile(account:string){//:Promise<ResponseResult>
    let httpRequest = http.createHttp()
    let opt:http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: { 'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        //这一步很关键，把登录成功后的cookie传递过去
        //'Cookie': 'sessionid=' + this.sessionId,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        //'content-Type':'application/json',
        account:account,
        filename:'123.jpg'
      },
      //extraData:{account:myAccount,password:myPassword},
      //expectDataType: http.HttpDataType.ARRAY_BUFFER,
      extraData:{}
    }
    let downloadUrl:string = 'http://192.168.22.49:8080/download'
    return httpRequest.request(downloadUrl, opt).then((resp) => {
      // console.log('testTag',JSON.stringify(resp.result))
      let respDisp: string = resp.header["content-disposition"]
      console.log('testTag','数据类型',JSON.parse(JSON.stringify(resp.resultType)))
      console.log('testTag',resp.header["content-disposition"])
      //从文件信息提取文件名称，这里包含双引号
      let fileNameWithQuote = respDisp.split(";")[1].split("=")[1]

      //去掉文件名称的双引号
      let fileName = fileNameWithQuote.substring(1, fileNameWithQuote.length - 1)
      console.log('testTag',fileName)
      //保存文件到本地
      this.friendImage = this.saveFile(resp.result as ArrayBuffer, fileName)
      console.log('testTag','下载成功')
      //读取文件内容并显示
      //return serverData;
    })
      .catch((e:BusinessError) => {
        //serverData.msg = 'No more data';
        console.log('testTag','下载文件失败，失败信息如下：',JSON.stringify(e))
        //return serverData;
      })
  }





  saveFile(buf: ArrayBuffer, fileName: string): string {
    let pathDir = getContext(this).filesDir;
    let filePath = pathDir + "/" + fileName;
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buf);
    //this.msgHistory += "文件已保存到：" + filePath + "\r\n"
    fs.closeSync(file);
    let  uri = fileUri.getUriFromPath(filePath);
    console.log('testTag',uri)
    return uri
  }



}