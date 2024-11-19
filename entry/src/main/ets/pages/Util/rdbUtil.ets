import { relationalStore } from '@kit.ArkData'

import {  newest, queryFriend, queryFriend1, } from '../mode/httpMode'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { talk1, talkReturn } from '../mode/rdbTalkMode'

class MyRdb {
  private rdbStore: relationalStore.RdbStore|null = null
  creatNewRDB(context:common.UIAbilityContext){
    const config: relationalStore.StoreConfig = {
      name: 'MyApplication.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    const sqlnewest = `CREATE TABLE IF NOT EXISTS newest (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  account TEXT NOT NULL,
                  timestamp Text NOT NULL,
                  message TEXT NOT NULL,
                  isread bit
                 );`//创建最新消息的表

    const sqlTalkTable = `CREATE TABLE IF NOT EXISTS talktable (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  sender TEXT NOT NULL,
                  receiver TEXT NOT NULL,
                  message TEXT NOT NULL,
                  timestamp TEXT NOT NULL
                 );`//创建有关聊天记录的表
    const sqlLinkTable = `CREATE TABLE IF NOT EXISTS linktable (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  first TEXT NOT NULL,
                  password TEXT NOT NULL,
                  verify TEXT NOT NULL,
                  touxianglj TEXT NOT NULL,
                  name TEXT NOT NULL,
                  account TEXT NOT NULL,
                  timing INTEGER NOT NULL
                 );`//创建有关联系人的表
    const sqlNewLinkTable = `CREATE TABLE IF NOT EXISTS NEWLINKTABLE (
                  ID INTEGER PRIMARY KEY AUTOINCREMENT,
                  FIRST TEXT NOT NULL,
                  PASSWORD TEXT NOT NULL,
                  VERIFY TEXT NOT NULL,
                  TOUXIANGLJ TEXT NOT NULL,
                  NAME TEXT NOT NULL,
                  ACCOUNT TEXT NOT NULL,
                  TIMING TEXT NOT NULL
                 );`//创建有关请求成为联系人的表
    // 3.获取rdb
    relationalStore.getRdbStore(context, config, (err, rdbStore) => {
      if(err){
        console.log('testTag', '获取rdbStore失败！')
        return
      }
      // 执行Sql
      rdbStore.executeSql(sqlTalkTable).then(()=>{
        console.log('testTag','创建有关聊天记录的表成功')
      }).catch((err:BusinessError)=>{
        console.log('testTag','创建有关聊天记录的表失败',JSON.stringify(err))
      })
      rdbStore.executeSql(sqlLinkTable).then(()=>{
        console.log('testTag','创建有关联系人的表成功')
      }).catch((err:BusinessError)=>{
        console.log('testTag','创建有关联系人的表失败',JSON.stringify(err))
      })
      rdbStore.executeSql(sqlNewLinkTable).then(()=>{
        console.log('testTag','创建有关请求成为联系人的表成功')
      }).catch((err:BusinessError)=>{
        console.log('testTag','创建有关请求成为联系人的表失败',JSON.stringify(err))
      })
      rdbStore.executeSql(sqlnewest).then(()=>{
        console.log('testTag','创建有关请求成为联系人的表成功')
      }).catch((err:BusinessError)=>{
        console.log('testTag','创建有关请求成为联系人的表失败',JSON.stringify(err))
      })
      // 保存rdbStore
      this.rdbStore = rdbStore
    })
  }

  addTalk(sender:string,receiver:string,message:string,timestamp:string){
    return this.rdbStore!.insert('talktable', {sender,receiver,message,timestamp}).then((resp)=>{
      console.log('testTagNewreceive','插入数据成功行数：',resp)
    }).catch((e:BusinessError)=>{
      console.log('testTagNewreceive','插入数据失败',JSON.stringify(e))
    })
  }//添加聊天记录
 async queryTalk(){
    return await new Promise<talkReturn[]>((resolve, reject) => {
      this.rdbStore!.querySql('SELECT * FROM talktable', [])
        .then(set => {
          let types: talkReturn[] = [];
          console.log('testTagNewreceive', set.columnNames, set.columnCount, set.rowCount);
          if (set.rowCount === 0) {
            console.log('testTagNewreceive','No data found in the table');
            resolve(types); // Resolve with an empty array if no data is found
            return;
          }
          set.goToFirstRow();
          console.log('testTagNewreceive', set.columnNames, set.columnCount, set.rowCount);
          while (set.isAtLastRow !== true) { // Check if we are not at the last row
            types.push(new talkReturn(
             '1',
              set.getString(set.getColumnIndex('sender')),
              set.getString(set.getColumnIndex('receiver')),
              set.getString(set.getColumnIndex('message')),
              set.getString(set.getColumnIndex('timestamp'))
            ));
            set.goToNextRow();
          }
          types.push(new talkReturn(
            '0',
            set.getString(set.getColumnIndex('sender')),
            set.getString(set.getColumnIndex('receiver')),
            set.getString(set.getColumnIndex('message')),
            set.getString(set.getColumnIndex('timestamp'))
          ))
          resolve(types);
        })
        .catch((error:BusinessError) => {
          console.error( 'testTagNewreceive','NewLinkTable Database query failed:', error);
          reject(error); // Reject the promise if there is an error
        });
    });
  }//查找所有的聊天信息
deleteTalk(){
  let predicates = new relationalStore.RdbPredicates("talktable");
  if(this.rdbStore != undefined) {
    (this.rdbStore as relationalStore.RdbStore).delete(predicates, (err, rows) => {
      if (err) {
        console.error('testTagNewreceive', `Delete failed, code is ${err.code},message is ${err.message}`);
        return;
      }
      console.info('testTagNewreceive', `Delete rows: ${rows}`);
    })
  }
}//删除所有的聊天记录



  addNews(account:string,message:string,timestamp:string,isread:boolean){
    return this.rdbStore!.insert('newest', {account,message,timestamp,isread}).then((resp)=>{
      console.log('testTagnewMessage1','插入数据成功行数：',resp)
    }).catch((e:BusinessError)=>{
      console.log('testTagnewMessage1','插入数据失败',JSON.stringify(e))
    })
  }//向最新消息的表里添加数据


  async queryNews(): Promise<newest[]> {
    return await new Promise<newest[]>((resolve, reject) => {
      this.rdbStore!.querySql('SELECT * FROM newest', [])
        .then(set => {
          let types: newest[] = [];
          console.log('testTagnewMessage1', set.columnNames, set.columnCount, set.rowCount);
          if (set.rowCount === 0) {
            console.log('testTagnewMessage1','No data found in the table');
            resolve(types); // Resolve with an empty array if no data is found
            return;
          }
          set.goToFirstRow();
          console.log('testTagnewMessage1', set.columnNames, set.columnCount, set.rowCount);
          while (set.isAtLastRow !== true) { // Check if we are not at the last row
            types.push(new newest(0,
              set.getString(set.getColumnIndex('account')),
              set.getString(set.getColumnIndex('message')),
              !!set.getLong(set.getColumnIndex('isread')),
              set.getString(set.getColumnIndex('timestamp'))
            ));
            set.goToNextRow();
          }
          types.push(new newest(0,
            set.getString(set.getColumnIndex('account')),
            set.getString(set.getColumnIndex('message')),
            !!set.getLong(set.getColumnIndex('isread')),
            set.getString(set.getColumnIndex('timestamp'))
          ))
          resolve(types);
        })
        .catch((error:BusinessError) => {
          console.error( 'testTagnewMessage1','newest Database query failed:', error);
          reject(error); // Reject the promise if there is an error
        });
    });
  } //查询最新的消息
  //////以上是有关查询最新数据的封装函数
  deleteNew(){
    let predicates = new relationalStore.RdbPredicates("newest");
    if(this.rdbStore != undefined) {
      (this.rdbStore as relationalStore.RdbStore).delete(predicates, (err, rows) => {
        if (err) {
          console.error('testTagnewMessage1', `Delete failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        console.info('testTagnewMessage1', `Delete rows: ${rows}`);
      })
    }
  }//删除所有的信息

  updateNew(account:string,message:string,timestamp:string,isread:boolean){
    let predicates = new relationalStore.RdbPredicates("newest");
    predicates.equalTo("account", account);
    if(this.rdbStore != undefined) {
      (this.rdbStore as relationalStore.RdbStore).update({account,message,timestamp,isread}
        , predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE).then(async (rows: Number) => {
        console.info('testTagnewMessage1',`Updated row count: ${rows}`);
      }).catch((err: BusinessError) => {
        console.error('testTagnewMessage1',`Updated failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }//要跟新的最新消息

    addNewLinkTable(first:string,password:string,verify:string,touxianglj:string,name:string,account:string
    ,timing:string){
        return this.rdbStore!.insert('NEWLINKTABLE', {first,password,verify,
          touxianglj,name,account,timing}).then((resp)=>{
            console.log('testTag','插入数据成功行数：',resp)
        }).catch((e:BusinessError)=>{
          console.log('testTag','插入数据失败',JSON.stringify(e))
        })
    }//向保存最新消息的表里储存数据



  async queryNewLinkTable(): Promise<queryFriend1[]> {
    return await new Promise<queryFriend1[]>((resolve, reject) => {
      this.rdbStore!.querySql('SELECT * FROM NEWLINKTABLE', [])
        .then(set => {
          let types: queryFriend1[] = [];
          console.log('testTag', set.columnNames, set.columnCount, set.rowCount);
          if (set.rowCount === 0) {
            console.log('testTag','No data found in the table');
            resolve(types); // Resolve with an empty array if no data is found
            return;
          }
          set.goToFirstRow();
          console.log('testTag', set.columnNames, set.columnCount, set.rowCount);

          while (set.isAtLastRow !== true) { // Check if we are not at the last row
            types.push(new queryFriend1(
              set.getString(set.getColumnIndex('NAME')),
              set.getString(set.getColumnIndex('ACCOUNT')),
              set.getString(set.getColumnIndex('TOUXIANGLJ'))
            ));
            set.goToNextRow();
          }
          types.push(new queryFriend1(
              set.getString(set.getColumnIndex('NAME')),
              set.getString(set.getColumnIndex('ACCOUNT')),
              set.getString(set.getColumnIndex('TOUXIANGLJ'))
          ))
          resolve(types);
        })
        .catch((error:BusinessError) => {
          console.error( 'testTag','NewLinkTable Database query failed:', error);
          reject(error); // Reject the promise if there is an error
        });
    });
  }
  deleteNewLinkRecord(account:string){
    let predicates = new relationalStore.RdbPredicates("NEWLINKTABLE");
    predicates.equalTo("account", account);
    if(this.rdbStore != undefined) {
      (this.rdbStore as relationalStore.RdbStore).delete(predicates, (err, rows) => {
        if (err) {
          console.error('testTag', `Delete failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        console.info('testTag', `Delete rows: ${rows}`);
      })
    }
  }//删除申请好友的用户的全部信息
////////以上是关于申请好友的函数

  putLinkRecord(first:string,password:string,verify:string,touxianglj:string,name:string,account:string
    ,timing:string) {
    return this.rdbStore!.insert('linktable', {first,password,verify,
      touxianglj,name,account,timing}).then((resp)=>{
      console.log('testTaghaoyouliebiao','插入数据成功行数：',resp)
    }).catch((e:BusinessError)=>{
      console.log('testTaghaoyouliebiao','插入数据失败',JSON.stringify(e))
    })
  } //新增联系人表数据

 async  queryLinkRecord() {
    return await new Promise<queryFriend[]>((resolve, reject) => {
      this.rdbStore!.querySql('SELECT * FROM linktable', [])
        .then(set => {
          let types: queryFriend[] = [];
          if (set.rowCount === 0) {
            console.log('testTaghaoyouliebiao','No data found in the table');
            resolve(types); // Resolve with an empty array if no data is found
            return;
          }
          set.goToFirstRow();
          console.log('testTaghaoyouliebiao', set.columnNames, set.columnCount, set.rowCount);

          while (set.isAtLastRow !== true) { // Check if we are not at the last row
            //console.log('testTag', set.getString(set.getColumnIndex('name')));
            types.push(new queryFriend(
              set.getLong(set.getColumnIndex('id')),
              set.getString(set.getColumnIndex('first')),
              set.getString(set.getColumnIndex('password')),
              set.getString(set.getColumnIndex('verify')),
              set.getString(set.getColumnIndex('touxianglj')),
              set.getString(set.getColumnIndex('name')),
              set.getString(set.getColumnIndex('account')),
              set.getString(set.getColumnIndex('timing'))
            ));
            set.goToNextRow();
          }
          types.push(new queryFriend(
            set.getLong(set.getColumnIndex('id')),
            set.getString(set.getColumnIndex('first')),
            set.getString(set.getColumnIndex('password')),
            set.getString(set.getColumnIndex('verify')),
            set.getString(set.getColumnIndex('touxianglj')),
            set.getString(set.getColumnIndex('name')),
            set.getString(set.getColumnIndex('account')),
            set.getString(set.getColumnIndex('timing'))

          ));
          resolve(types);
        })
        .catch((error:BusinessError) => {
          console.error( 'testTaghaoyouliebiao','linktable Database query failed:', error);
          reject(error); // Reject the promise if there is an error
        });
    });
  } //返回联系人全部信息
deleteLinkRecord(){
  let predicates = new relationalStore.RdbPredicates("linktable");
  if(this.rdbStore != undefined) {
    (this.rdbStore as relationalStore.RdbStore).delete(predicates, (err, rows) => {
      if (err) {
        console.error('testTaghaoyouliebiao', `Delete failed, code is ${err.code},message is ${err.message}`);
        return;
      }
      console.info('testTaghaoyouliebiao', `Delete rows: ${rows}`);
    })
  }
}//删除联系人列表的全部信息






}
const myRdb: MyRdb = new MyRdb()
export default myRdb




