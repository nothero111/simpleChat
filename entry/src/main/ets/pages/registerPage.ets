import { photoAccessHelper } from '@kit.MediaLibraryKit';

import { fileIo as fs } from '@kit.CoreFileKit';
import { promptAction, router } from '@kit.ArkUI';
import {  isUpload, postNewMessage, upFile } from './httpMode/newhttp';
import MyPre from './Util/preference';
import { buffer, JSON, util } from '@kit.ArkTS';
import { BusinessError, request, systemDateTime } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';


//实例化图库选择对象，用来支撑选择图片/视频等场景
const photoPicker = new photoAccessHelper.PhotoViewPicker()
//获取到一个photoAccessHelper的实例，用来调用相册来设置头像



@Entry
@Component
struct RegisterPage {
@State msgHistory:string = ''

 @State uploadFilePath:string = ''
  @State uploadFileName:string = ''
@State verify:string = ''//记录验证码
@State canLoad:string = '0'

@State MyCount:string = ''//邮箱
@State myPassword:string = ''  //账号密码
@State myName:string = ''//用户名
   rep: RegExp = /[A-Za-z]+/;//正则来匹配密码是否正确
@State messagePassword:string = '密码格式错误，密码应为8到20个字符，必须包含至少一个英文字符'
//设置密码格式发生错误时的警告
@State messageName:string = '未设置用户名'
  //设置用户名未设置时的警告
@State isChangeAvatar:boolean = false

  //设置账号未生成时的警告
  @State avatarUrl: Resource|string = $r('app.media.avatar')
  @State timing:number = 0
   ctx = getContext(this)//定义一个变量，用来得到下文的context

  @State cacheImage:string = ''//保存图片的缓存地址
  build() {
      Column({space:5}) {

          Row() {
            Image($r('app.media.chazi')).width(20)
              .onClick(()=>{
                router.back()
              })
              .fillColor(Color.Gray).margin(20)
          }.width('100%')//左上角返回按钮

          Text('账号注册').fontSize(20)
        Column(){
          Image(this.avatarUrl).width(60)
            .onClick(async ()=>{
            //   this.isChangeAvatar = true
            //   //调用select方法拉起相册，返回一个Promise对象
            // let pickRes = await photoPicker.select({
            //   //设置可选择图片类型
            //   MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
            //   //设置选择文件数量最大值
            //   maxSelectNumber:1
            // })
            //   this.avatarUrl = pickRes.photoUris[0]
            //   const fileName = Date.now()
            //   this.timing = fileName
            //   this.copy2Sandbox(this.avatarUrl,`${fileName}.jpg`)
            //   console.log('testTag',this.avatarUrl)


              //以只读的方式打开文件
             // const photoFd = fs.openSync(this.avatarUrl, fs.OpenMode.READ_ONLY).fd
             //  //获取上下文对象
             //  const ctx = getContext(this)
             //  this.ctx  = ctx
             //  // 以当前的时间戳作为存储到缓存目录的文件名
             //
             //  this.timing = fileName
             //  await fs.copyFile(photoFd, ctx.cacheDir + '/' + `${fileName}.jpg`)
              this.selectImagFile1()
              this.isChangeAvatar = !this.isChangeAvatar
             //  this.cacheImage = pickRes.photoUris[0]
             //  console.log('testTag',photoFd)
             //  console.log('testTag',ctx.cacheDir + '/' + `${fileName}.jpg`)

            })//点击更换头像
            .margin({bottom:6})
          Text('点击图片，更换默认头像').fontSize(10)
            .fontColor(Color.Gray)
        }//设置用户头像
            .margin({top:30,bottom:60})
        Divider().padding({ right: 5, left: 5 }).opacity(1)
          .color(Color.Gray)
        Column() {
          Row() {
            Text('邮箱:')
            TextInput({ placeholder: '请输入邮箱' })
              .onChange((value)=>{
                this.MyCount = value
              })
              .maxLength(20)
              .backgroundColor('#e4e4e4')

          }.padding({ right: 26, left: 25 })
        }
        Column() {
          Row() {
            Text('验证码:')
            TextInput({ placeholder: '请输入验证码' })
              .onChange((value)=>{
                this.verify = value
                console.log(this.myName)
              }).width(180)
              .backgroundColor('#e4e4e4').maxLength(20)
            Button('获取验证码').type(ButtonType.Normal).fontColor(Color.Black)
              .borderRadius(10).height(30).width(80).backgroundColor(Color.White)
              .onClick(() => {
                if(this.MyCount == ''){
                  promptAction.showToast({
                    message:'邮箱未填写'
                  })//马上出现，又马上消失
                }else{
                  postNewMessage<isUpload>('',this.MyCount,'',0,'','sendVerificationCode')
                }

            })
          }.padding({ right: 26, left: 10 }).width('100%')
        }

        Divider().padding({ right: 5, left: 5 })
          .color(Color.Gray)
          Column() {
            Row() {
              Text('密码:')
              TextInput({ placeholder: '请输入密码' })
                .onChange((value)=>{
                  this.myPassword = value
                })
                .maxLength(20)
                .type(InputType.Password)
                .backgroundColor('#e4e4e4')

            }.padding({ right: 26, left: 25 })
          }
        Divider().padding({ right: 5, left: 5 }).opacity(1)
          .color(Color.Gray)
        Column() {
          Row() {
            Text('用户名:')
            TextInput({ placeholder: '请输入用户名' })
              .onChange((value)=>{
                this.myName = value
                console.log(this.myName)
              })
              .backgroundColor('#e4e4e4').maxLength(20)
          }.padding({ right: 26, left: 10 })

        }
        Divider().padding({ right: 5, left: 5 }).opacity(1)
          .color(Color.Gray)
          Blank()
          Button('确定并继续')
            .onClick(()=>{
              if(this.myName!=''&&this.myPassword.length>=8
                &&this.rep.test(this.myPassword)){
                if (this.isChangeAvatar){//如果用户更换头像
                  postNewMessage<isUpload>(this.myName,this.MyCount,this.myPassword,this.timing,this.verify,'register')
                    .then( resp => {
                      this.canLoad =   resp.is
                      console.log('testTag','接收信号成功',resp.is)
                     if (this.canLoad == '1'){//当这个返回值为1时，
                       try {
                         this.uploadFile(this.uploadFilePath, this.uploadFileName, this.MyCount,
                           "http://192.168.22.49:8080/upload")
                           .then(() => {
                             console.log('testTag', '文件传输', this.msgHistory)
                           })
                           .catch((e: BusinessError) => {
                             console.log('testTag', '文件传输', this.msgHistory, JSON.stringify(e))
                           })
                       } catch (e) {
                         console.log('testTag', '文件传输', this.msgHistory, JSON.stringify(e))

                       }
                        MyPre.putPre('isSkip', true)
                          .then(()=>{
                            console.log('testTag','成功写入数据')
                            router.replaceUrl({
                              url:'pages/Index'
                            })
                          }).catch((e:BusinessError)=>{
                          console.log('testTag','数据写入失败',JSON.stringify(e))
                        })//用户首选项
                        MyPre.putPre('myName',this.myName)
                          .then(()=>{
                            console.log('testTag','成功写入数据')
                            router.replaceUrl({
                              url:'pages/Index'
                            })
                          }).catch((e:BusinessError)=>{
                          console.log('testTag','数据写入失败',JSON.stringify(e))
                        })//用户首选项
                        MyPre.putPre('myName',this.myName)
                        MyPre.putPre('myCount',this.MyCount)
                        MyPre.putPre('avatar',this.avatarUrl)

                      }else{
                        AlertDialog.show({
                          message:'验证码错误'
                        })
                      }
                    }).catch((err:BusinessError)=>{
                    console.log('testTag','接收失败123',JSON.stringify(err))
                  })

                }else{
                  postNewMessage<isUpload>(this.myName,this.MyCount,this.myPassword,0,this.verify,'register')//如果用户不上传头像，把timing置1，告诉服务端
                    .then( resp => {
                      this.canLoad =   resp.is
                      console.log('接收信号成功',resp.is)
                      if (this.canLoad == '1'){//当返回值为1时，
                        //表示邮箱验证成功
                        MyPre.putPre('isSkip', true)
                          .then(()=>{
                            console.log('testTag','成功写入数据')
                            router.replaceUrl({
                              url:'pages/Index'
                            })
                          }).catch((e:BusinessError)=>{
                          console.log('testTag','数据写入失败',JSON.stringify(e))
                        })//用户首选项
                        MyPre.putPre('myName',this.myName)
                        MyPre.putPre('myCount',this.MyCount)
                        MyPre.putPre('avatar',$r('app.media.avatar'))
                      }else{
                        AlertDialog.show({
                          message:'验证码错误'
                        })
                      }
                    }).catch((err:BusinessError)=>{
                    console.log('testTag','接收失败',JSON.stringify(err))
                  })
                }
                }
              else{//如果输入账号密码格式有错误，根据错误的弹出不同的警告

                let mas2 = this.myName!=''?'':this.messageName
                let mas3 = (this.myPassword.length>=8
                  &&this.rep.test(this.myPassword))?'':this.messagePassword
                  AlertDialog.show({
                    title:'错误',
                    message:  mas2+ '\n'+ mas3
                  })
              }
            })
            .fontColor(Color.Black)
            .type(ButtonType.Normal)
            .margin({bottom:100})
            .height(60).borderRadius(10)
            .width(120).backgroundColor('#e4e4f4')
        }
        .width('100%').height('100%')
        .backgroundColor('#e4e4e4')

  }


  //复制文件到缓存
  async copy2Sandbox(srcUri: string, fileName: string): Promise<string> {
  let context = getContext(this)
  //计划复制到的目标路径
  let realUri = context.cacheDir + "/" + fileName

  //复制选择的文件到沙箱cache文件夹
  try {
    let file = await fs.open(srcUri);
    fs.copyFileSync(file.fd, realUri)
    fs.close(file)
  } catch (err) {
    // this.msgHistory += 'err.code : ' + err.code + ', err.message : ' + err.message;
    console.log('testTag',JSON.stringify(err))
  }
  return realUri
}

  //从文件读取内容
readContentFromFile(fileUri: string): ArrayBuffer {
  let file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
  let fsStat = fs.lstatSync(fileUri);
  let buf = new ArrayBuffer(fsStat.size);
  fs.readSync(file.fd, buf);
  fs.fsyncSync(file.fd)
  fs.closeSync(file);
  return buf
}





  //上传文件
  async uploadFile(uploadFilePath:string,uploadFileName:string,account:string,
  url:string) {
  //上传文件使用的分隔符
  let boundary: string = '----ShandongCaoxianNB666MyBabyBoundary' + ( systemDateTime.getTime(true)).toString()

  let sandFile = await this.copy2Sandbox(uploadFilePath, uploadFileName)

  //选择要上传的文件的内容
  let fileContent: Uint8Array = new Uint8Array(this.readContentFromFile(sandFile))

  //上传请求的body内容
  let bodyContent = this.buildBodyContent(boundary, uploadFileName, fileContent)

  //http请求对象
  let httpRequest = http.createHttp();
  let opt: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': `multipart/form-data; boundary=${boundary}`,
      'Content-Length': bodyContent.byteLength.toString(),
      account:account
    },
    extraData: bodyContent
  }
  //发送上传请求
  httpRequest.request(url, opt)
    .then((resp) => {
      this.msgHistory += "响应码：" + resp.responseCode + "\r\n"
      this.msgHistory += "上传成功\r\n"
      console.log('testTag',this.msgHistory,'文件传输')
    })
    .catch((e:BusinessError) => {
      this.msgHistory += "请求失败：" + e.message + "\r\n"
      console.log('testTag',this.msgHistory,'文件传输')

    })
}

  //构造上传文件的body内容
  buildBodyContent(boundary: string, fileName: string, content: Uint8Array, contentType: string = "application/octet-stream") {
    let textEncoder = new util.TextEncoder();

    //构造文件内容前的部分
    let preFileContent = `--${boundary}\r\n`
    preFileContent = preFileContent + `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n`
    preFileContent = preFileContent + `Content-Type: ${contentType}\r\n`
    preFileContent = preFileContent + '\r\n'
    let preArray = textEncoder.encodeInto(preFileContent)

    //构造文件内容后的部分
    let aftFileContent = '\r\n'
    aftFileContent = aftFileContent + `--${boundary}`
    aftFileContent = aftFileContent + '--\r\n'
    let aftArray = textEncoder.encodeInto(aftFileContent)

    //文件前后内容和文件内容组合
    let bodyBuf = buffer.concat([preArray, content, aftArray])
    return bodyBuf.buffer
  }



  async selectImagFile1(){
    let pickRes = await photoPicker.select({
      //设置可选择图片类型
      MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      //设置选择文件数量最大值
      maxSelectNumber:1
    })
    this.avatarUrl = pickRes.photoUris[0]
    this.uploadFilePath = pickRes.photoUris[0]
    this.msgHistory += "select file: " + this.uploadFilePath + "\r\n";
    //this.canUpload = true
    let segments = this.uploadFilePath.split('/')
    this.uploadFileName = segments[segments.length-1]

  }

}