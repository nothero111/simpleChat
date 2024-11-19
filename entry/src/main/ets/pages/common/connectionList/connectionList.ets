

import { router } from '@kit.ArkUI';
import { myFriend, queryFriend, queryFriend1, returnLink } from '../../mode/httpMode';
import myRdb from '../../Util/rdbUtil';
import {  postNewMessage } from '../../httpMode/newhttp';
import MyPre from '../../Util/preference';

import { BusinessError } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';
import {  fileIo as fs,fileUri } from '@kit.CoreFileKit';


@Component
export default struct connectionList {
  @State isNewFriend:boolean = false //判断是否有新朋友。默认为没有
  @State newFriend:myFriend[] = []//设置储存新添加好友的数组
  @State myCount:string = ''
  @State myFriends:queryFriend[] = []
  @State image:string = ''
  @State i:number = 0//设置控制轮询的值
 async  onPageShow() {


  }
 async aboutToAppear() {

   this.myCount = await MyPre.getPre('myCount','') as string


   myRdb.queryNewLinkTable()
     .then((resp)=>{
       console.log('testTag','查询是否有新的好友请求成功')
       newFriend = resp
     }).catch((e:BusinessError)=>{
     console.log('testTag','查询是否有新的好友请求失败',JSON.stringify(e))
   })
   console.log('testTag','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',this.newFriend.length)
   //查询是否有新的好友请求

   postNewMessage<returnLink[]>('0',this.myCount,'',0,'','haoyouliebiao')//表示从服务端取出所有的//好友列表
     .then(async (resp)=>{
       for (let index = 0; index < resp.length; index++) {
         const a = resp[index].friendList;
         for (let index = 0; index < a.length; index++) {
           this.myFriends.push(a[index])
         }
       }
       console.log('testTaghaoyouliebiao','请求数据成功')
       myRdb.deleteLinkRecord()
       for (let index = 0; index < this.myFriends.length; index++) {
         let element = this.myFriends[index];
         this.downFile(element.account).then(()=>{
           console.log('testTaghaoyouliebiao','url',this.image)
           myRdb.putLinkRecord(element.first,element.password,element.verify,this.image,
             //this.Image图片用来接收得到的url路径
             element.name,element.account,element.timing)
         })//从服务端获取土图片并下载到本地

       }
     })
     .catch(async  (err:BusinessError)=>{
       this.myFriends = await myRdb.queryLinkRecord()
       console.log('testTaghaoyouliebiao','请求数据失败',JSON.stringify(err))
     })

    let newFriend:queryFriend1[] = []



   this.isNewFriend = await MyPre.getPre('whetherNew',false) as boolean



      let Id = setInterval(()=>{


     myRdb.queryNewLinkTable()
       .then((resp)=>{
         console.log('testTa','查询是否有新的好友请求成功')
         newFriend = resp
       }).catch((e:BusinessError)=>{
       console.log('testTa','查询是否有新的好友请求失败',JSON.stringify(e))
     })
     console.log('testTa','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',newFriend.length)
     postNewMessage<queryFriend[]>('',this.myCount,'',0,'','getAskedList')//,表示询问是否有新的好友请求添加
       .then((resp)=>{
         let isHave:boolean = false//判断数据库是否要添加新的好友信息。默认不需要
         if (resp[0].account == 'NO_REQUESTS'){
           console.log('testTa','没有')
           console.log('testTa',isHave)
         }
         else{
           console.log('testTa',isHave)

           if (resp.length == newFriend.length){
             isHave = false
           }else {
             isHave = true
           }
           console.log('testTa',isHave)

           if (isHave) {

             MyPre.putPre('whetherNew',true)//判断是否有新的好友申请
             this.isNewFriend = true
             for (let index = 0; index < resp.length; index++){
               console.log('testT',resp[index].account)
               myRdb.addNewLinkTable(resp[index].first,resp[index].password,resp[index].verify,
                 resp[index].touxianglj as string,
                 resp[index].name,resp[index].account,resp[index].timing)
             }
           }
         }
       }).catch((e:BusinessError)=>{
       console.log('testTa','网络错误',JSON.stringify(e))
     })
   },500)//在该页面不停的发送
this.i = Id
  }
  aboutToDisappear(): void {
  clearInterval(this.i)
  }//删除定时任务

  @Builder itemHead(title: string) {
    Text(title)
      .fontSize(14)
      .visibility("" === title ? Visibility.None : Visibility.Visible)
      .backgroundColor("#EDEDED")
      .height(36)
      .width("100%")
      .padding({ left: 20 })
  }
  
  build() {
  Column(){
    Row(){
      Badge({value: '',
        style: { badgeSize: 6, borderColor:this.isNewFriend?'#FA2A2D':Color.White,
          badgeColor:this.isNewFriend?'#FA2A2D':Color.White },
      }){
        Image($r('app.media.newFriend'))
          .width(46)
          .height(46)
          .borderRadius(4)
          .margin({ left: 20, right: 15 })
          .objectFit(ImageFit.Cover)
      }
      Text('新朋友')
        .fontSize(19)
        .fontWeight(500)
        .width("100%")
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ right: 30 })
        .fontColor(Color.Black)
    }.onClick(()=>{
      this.isNewFriend = false
      MyPre.putPre('whetherNew',false)
      router.pushUrl({
        url:'pages/newFriendListPage'
      })//跳转到显示申请好友的页面
    })
    .backgroundColor(Color.White)
    .width("100%")
    .height(60)
    List(){
      ForEach(this.myFriends,(friend:queryFriend)=>{
        ListItem(){
          Row(){
            ListContactItem({head:friend.touxianglj,name:friend.name})
              .onClick(()=>{
                router.pushUrl({
                  url:'pages/UserHomePage',
                  params:{
                    name:friend.name,
                    account:friend.account,
                    avatar:friend.touxianglj,
                    timing:friend.timing,
                    newMessage:''
                  }
                })
              })
            Divider()
          }

        }
      })
    }.width('100%').height('100%')
  }

  }
  downFile(account:string) { //:Promise<ResponseResult>
    let httpRequest = http.createHttp()
    let opt: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: {
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        //这一步很关键，把登录成功后的cookie传递过去
        //'Cookie': 'sessionid=' + this.sessionId,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        //'content-Type':'application/json',
        account: account,
        filename: '123.jpg'
      },
      //extraData:{account:myAccount,password:myPassword},
      //expectDataType: http.HttpDataType.ARRAY_BUFFER,
      extraData: {}
    }
    let downloadUrl: string = 'http://192.168.22.49:8080/download1'
    return httpRequest.request(downloadUrl, opt).then((resp) => {
      // console.log('testTag',JSON.stringify(resp.result))
      let respDisp: string = resp.header["content-disposition"]
      console.log('testTaghaoyouliebiao', '数据类型', JSON.parse(JSON.stringify(resp.resultType)))
      console.log('testTaghaoyouliebiao', respDisp)
      //从文件信息提取文件名称，这里包含双引号
      let fileNameWithQuote = respDisp.split('\\')
      let fileName = fileNameWithQuote[fileNameWithQuote.length-1]
      console.log('testTaghaoyouliebiao', fileNameWithQuote.length)
      //去掉文件名称的双引号
      // let fileName = fileNameWithQuote.substring(1, fileNameWithQuote.length - 1)

      console.log('testTaghaoyouliebiao', fileName)
        //保存文件到本地
      let aaa:string = ''
        aaa = this.saveFile(resp.result as ArrayBuffer, fileName)
      this.image = aaa
      console.log('testTaghaoyouliebiao','aaa',aaa,'this.image',this.image)
      console.log('testTaghaoyouliebiao', '下载成功')
      //读取文件内容并显示
      //return serverData;
    })
      .catch((e: BusinessError) => {
        //serverData.msg = 'No more data';
        console.log('testTaghaoyouliebiao', '下载文件失败，失败信息如下：', JSON.stringify(e))
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

    return uri
  }

}
@Component
struct ListContactItem {
  private head: string | PixelMap | Resource = ''
  private name: string = ''

  build() {
    Row() {
      Image(this.head)
        .width(46)
        .height(46)
        .borderRadius(4)
        .margin({ left: 20, right: 15 })
        .objectFit(ImageFit.Cover)

      Text(this.name)
        .fontSize(19)
        .fontWeight(500)
        .width("100%")
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ right: 30 })
        .fontColor(Color.Black)
    }
    .backgroundColor(Color.White)
    .width("100%")
    .height(60)
  }
}
