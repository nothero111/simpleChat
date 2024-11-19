import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

class myPre{
  dataPreferences: preferences.Preferences | null = null;

  loadPre(context:common.UIAbilityContext,preName:string){
    let options: preferences.Options = { name: preName };
      this.dataPreferences = preferences.getPreferencesSync(context, options);
  }//加载一个用户首选项的实例


 async putPre(key:string,value:preferences.ValueType){
    if(!this.dataPreferences){
      console.log(
        'testTag','preference尚未初始化')
      return
    }else{
      try {
        await this.dataPreferences.put(key, value)
        await this.dataPreferences.flush()
        console.log('testTag', '写入成功')
      } catch (e) {
        console.log('testTag','保存preference失败',JSON.stringify(e))
      }
    }
  }//向用户首选项里写入实例
async getPre(key:string,defaultValue:preferences.ValueType){
    if(!this.dataPreferences){
      console.log(
        'testTag','preference尚未初始化')
      return
    }
    try {
      let value = await this.dataPreferences.get(key, defaultValue)
      console.log('testTag', `读取preference${key}成功`)
      return value
    } catch (e) {
      console.log('testTag','读取preference失败',JSON.stringify(e))
      return
    }
  }
}

const MyPre: myPre = new myPre()
export default MyPre