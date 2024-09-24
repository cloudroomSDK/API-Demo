import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';

let flag = false;

//开启长时任务，参见 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/continuous-task-V5
export const startContinuousTask = () => {
  if (flag) {
    return;
  }
  let wantAgentInfo: wantAgent.WantAgentInfo = {
    // 点击通知后，将要执行的动作列表
    // 添加需要被拉起应用的bundleName和abilityName
    wants: [
      {
        bundleName: "com.cloudroom.apidemo",
        abilityName: "EntryAbility"
      }
    ],
    // 指定点击通知栏消息后的动作是拉起ability
    actionType: wantAgent.OperationType.START_ABILITY,
    // 使用者自定义的一个私有值
    requestCode: 0,
    // 点击通知后，动作执行属性
    // actionFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
  };

  // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
  wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
    backgroundTaskManager.startBackgroundRunning(getContext(),
      backgroundTaskManager.BackgroundMode.AUDIO_RECORDING, wantAgentObj).then(() => {
      // 此处执行具体的长时任务逻辑，如放音等。
      console.info(`Succeeded in operationing startBackgroundRunning.`);
      flag = true;
    }).catch((err: BusinessError) => {
      console.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
    });
  });
}

export const stopContinuousTask = () => {
  if (!flag) {
    return;
  }
  backgroundTaskManager.stopBackgroundRunning(getContext()).then(() => {
    console.info(`Succeeded in operationing stopBackgroundRunning.`);
    flag = false;
  }).catch((err: BusinessError) => {
    console.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
  });
}