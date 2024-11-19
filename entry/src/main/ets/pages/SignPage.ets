import { isUpload, postNewMessage } from './httpMode/newhttp'
import { router } from '@kit.ArkUI'
import MyPre from './Util/preference'
import { BusinessError } from '@kit.BasicServicesKit'
import { http } from '@kit.NetworkKit'
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
@Entry
@Component
struct SignPage {
@State MyCount:string = ''
@State   myPassword:string = ''
  @State messageCount:string = '账号应该为11位数字'
  @State messagePassword:string = '密码格式错误，密码应为8到20个字符，必须包含至少一个英文字符'
  @State myImage:string = ''//储存文件路径信息
  repPas: RegExp = /[A-Za-z]+/;//正则来匹配密码是否正确
  //resAcc:RegExp = /^\d{11}$/;//用来匹配账号是否正确的正则
  build() {
   Column({space:10}) {

     Row() {
       Image($r('app.media.chazi')).width(20)
         .fillColor(Color.Gray).margin(20)
     }.width('100%')

     Text('账号密码登录').fontSize(20)
       .margin({top:30,bottom:60})
     Column() {
       Row() {
         Text('账号:')
         TextInput({ placeholder: '请输入账号'})
           .onChange((value)=>{
             this.MyCount = value
           })
           .backgroundColor('#e4e4e4')
       }.padding({ right: 10, left: 10 })
       Divider().padding({ right: 5, left: 5 }).opacity(1)
         .color(Color.Gray)
     }
     Column() {
       Row() {
         Text('密码:')
         TextInput({ placeholder: '请输入密码' })
           .onChange((value)=>{
             this.myPassword = value
           })
           .type(InputType.Password)
           .backgroundColor('#e4e4e4')
       }.padding({ right: 26, left: 10 })
       Divider().padding({ right: 5, left: 5 })
         .color(Color.Gray)
     }
Blank()
     Button('确定并继续')
       .onClick(()=>{
        if (this.myPassword.length>=8
          &&this.repPas.test(this.myPassword)){
          MyPre.putPre('avatar',this.myImage)
          postNewMessage<isUpload>('',this.MyCount,this.myPassword,0,'','login')
            .then((resp)=>{
              if(resp.is == '0'){
                AlertDialog.show({
                  message:'账号密码由错误'
                })
              }else{
                this.downFile()
                  .then(()=>{
                    MyPre.putPre('isSkip', true)
                    MyPre.putPre('myCount',this.MyCount)
                    MyPre.putPre('myName',resp.is)
                    MyPre.putPre('avatar',this.myImage)
                    router.replaceUrl({
                      url:'pages/Index'
                    })
                  })

              }
            })



        }else{

            let mas3 = (this.myPassword.length>=8
              &&this.repPas.test(this.myPassword))?'':this.messagePassword
            AlertDialog.show({
              title:'错误',
              message:  mas3
            })
        }

       })
       .fontColor(Color.Black)
       .type(ButtonType.Normal)
       .margin({bottom:100})
       .height(60).borderRadius(20)
       .width(120).backgroundColor(Color.White)
   }//.justifyContent(FlexAlign.SpaceBetween)
   .width('100%').height('100%')
    .backgroundColor('#e4e4e4')
  }

  downFile(){//:Promise<ResponseResult>
    let httpRequest = http.createHttp()
    let opt:http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: { 'Accept-Encoding': 'gzip, deflate, br',
     'Accept-Language': 'zh-CN,zh;q=0.9',
      //这一步很关键，把登录成功后的cookie传递过去
      //'Cookie': 'sessionid=' + this.sessionId,
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        //'content-Type':'application/json',
        account:this.MyCount,
        filename:'123.jpg'
      },
      //extraData:{account:myAccount,password:myPassword},
      //expectDataType: http.HttpDataType.ARRAY_BUFFER,
      extraData:{}
    }
    let downloadUrl:string = 'http://192.168.22.49:8080/download1'
  return httpRequest.request(downloadUrl, opt).then((resp) => {
       // console.log('testTag',JSON.stringify(resp.result))
        let respDisp: string = resp.header["content-disposition"]
        console.log('testTag','数据类型',JSON.parse(JSON.stringify(resp.resultType)))
    console.log('testTag',respDisp)
        //从文件信息提取文件名称，这里包含双引号
        let fileNameWithQuote = respDisp.split('\\')
         let fileName = fileNameWithQuote[fileNameWithQuote.length-1]
        console.log('testTag',fileNameWithQuote.length)
        //去掉文件名称的双引号
       // let fileName = fileNameWithQuote.substring(1, fileNameWithQuote.length - 1)

          console.log('testTag',fileName)
        //保存文件到本地
        this.myImage = this.saveFile(resp.result as ArrayBuffer, fileName)
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