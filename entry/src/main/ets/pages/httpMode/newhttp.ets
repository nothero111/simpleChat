import { http } from '@kit.NetworkKit';

import { CommonConstant as Const, ContentType } from '../constant/CommonConstant';
import { BusinessError, request, systemDateTime } from '@kit.BasicServicesKit';
import { common, Context } from '@kit.AbilityKit';
import { buffer, util } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';


export class ResponseResult{
  code: number;
//返回的http返回码
  msg: string | Resource;
//返回信息
  data: string | Object | ArrayBuffer;
//返回的数据
  constructor() {
    this.code = 0;
    this.msg = '';
    this.data = '';
  }
}

export function httpRequestGet(name:string,account:string,password:string,verify:string,timing:number,url: string): Promise<ResponseResult> {
  let httpRequest = http.createHttp();
  let responseResult = httpRequest.request(url, {
    method: http.RequestMethod.POST,
    readTimeout: 500,
    header: {
      'Content-Type': ContentType.JSON,
      sender:account,//发送好友请求时，的发送者
      receiver:password,//发送好友请求的接收者
      user:account//返回好友列表
    },
    connectTimeout:500,

    extraData:  {name:name,account:account,password:password,timing:timing,verify:verify}
  });

  let serverData: ResponseResult = new ResponseResult();
  // Processes the data and returns.
  return responseResult.then((value: http.HttpResponse) => {
    console.log(''+value.responseCode)
    if (value.responseCode === Const.HTTP_CODE_200) {
      // Obtains the returned data.
      console.log(JSON.stringify(value.result))
      let result = `${value.result}`;
      let resultJson: ResponseResult = JSON.parse(result);
      if (resultJson.code === 200) {
        serverData.data = resultJson.data;
      }
      serverData.code = resultJson.code;
      serverData.msg = resultJson.msg;
    } else {
      serverData.msg = `"No more data"&${value.responseCode}`;
    }
    return serverData;
  }).catch((err:BusinessError) => {
    serverData.msg = 'No more data';
    console.log('testTag','请求失败',JSON.stringify(err))
    return serverData;
  })
}


export function  postNewMessage<T>(name:string,account:string,password:string,timing:number,verify:string,urL:string): Promise<T> {
  return new Promise((resolve: Function, reject: Function) => {
    let url = `http://192.168.22.49:8080/${urL}`;
    httpRequestGet(name,account,password,verify,timing,url).then((data: ResponseResult) => {
      console.log('testTag',data.msg)
      if (data.msg === 'success'&&data.code ==200) {
        resolve(data.data);
      } else {
        console.log('testTag','发送失败')
        reject();
      }
    }).catch(() => {
      console.log('testTag','发送失败')
      reject();
    });
  });
}


export class isUpload{
  is:string

  constructor(is:string) {
    this.is = is
  }
}




export async function upFile(ctx:Context,fileName:number,account:string){
  // 上传图片
  const task = await request.uploadFile(ctx, {
    url: 'http://192.168.22.49:8080/upload',
    header: {
      'content-type': 'multipart/form-data',
      //Authorization: 'Bearer ' //+ this.currentUser.token
      account:account
    },

    method: http.RequestMethod.POST,
    files: [{
      filename: fileName + '.jpg',
      uri: `internal://cache/${fileName}.jpg`,
      name: 'file',
      type: 'jpg'
    }],
    data: []
  }).then(()=>{
    console.log('testTag','上传成功','第一次回调')
  }).catch((e:BusinessError)=>{
    console.log('testTag',JSON.stringify(e),'第一次回调')
  })
return task
}



//构造上传文件的body内容
export function buildBodyContent(boundary: string, fileName: string, content: Uint8Array, contentType: string = "application/octet-stream") {
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


//从文件读取内容
function readContentFromFile(fileUri: string): ArrayBuffer {
  let file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
  let fsStat = fs.lstatSync(fileUri);
  let buf = new ArrayBuffer(fsStat.size);
  fs.readSync(file.fd, buf);
  fs.fsyncSync(file.fd)
  fs.closeSync(file);
  return buf
}





//上传文件
//  async function uploadFile(uploadFilePath:string,uploadFileName:string,account:string,
//    url:string) {
//   //上传文件使用的分隔符
//   let boundary: string = '----ShandongCaoxianNB666MyBabyBoundary' + ( systemDateTime.getTime(true)).toString()
//
//   let sandFile = await copy2Sandbox(uploadFilePath, uploadFileName)
//
//   //选择要上传的文件的内容
//   let fileContent: Uint8Array = new Uint8Array(readContentFromFile(sandFile))
//
//   //上传请求的body内容
//   let bodyContent = buildBodyContent(boundary, uploadFileName, fileContent)
//
//   //http请求对象
//   let httpRequest = http.createHttp();
//   let opt: http.HttpRequestOptions = {
//     method: http.RequestMethod.POST,
//     header: { 'Content-Type': `multipart/form-data; boundary=${boundary}`,
//       'Content-Length': bodyContent.byteLength.toString(),
//       account:account
//     },
//     extraData: bodyContent
//   }

  //发送上传请求
//   httpRequest.request(url, opt)
//     .then(() => {
//       console.log('testTag','上传成功')
//     })
//     .catch((e:BusinessError) => {
//       console.log('testTag','上传失败',JSON.stringify(e))
//
//     })
// }











//保存文件并返回保存路径



// <form method="post" action="upload4.do" enctype="multipart/form-data">
//   姓名：<input name="name" value="路人"/> <br/>
//   年龄：<input name="age" value="30"/><br/>
//   头像图片：<input name="headImg" type="file"/><br/>
//   多张身份证图片<br/>
//   <input name="idCardImg" type="file"/><br/>
//   <input name="idCardImg" type="file"/><br/>
//   <input type="submit" value="提交">
//   </form>
