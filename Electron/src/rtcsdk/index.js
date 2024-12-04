import RTCSDK from "@cloudroom/electron-rtcsdk";
import { ipcRenderer } from 'electron';
const rtcsdk = new RTCSDK();

import useAppStore from "@/store";

const notifyGiveCtrlRight = (operUserId, targetUserId) => {
    const appStore = useAppStore();
    if (appStore.myUserId !== targetUserId) return;
    appStore.hasCtrlMode = true;
}
const notifyReleaseCtrlRight = (operUserId, targetUserId) => {
    const appStore = useAppStore();
    if (appStore.myUserId !== targetUserId) return;
    appStore.hasCtrlMode = false;
}

async function start() {
    const logsPath = await ipcRenderer.invoke("get-logs-path");
    console.log('logs: ', logsPath);

    rtcsdk.init({
        path: logsPath,//SDK工作目录，用于存储配置文件、临时文件、录制文件、影音文件、日志等文件，如果传空值，则默认为sdk的安装目录
        // enableHardwareAcceleration: true,//启动硬件加速
        jsonParam: JSON.stringify({
            Timeout: 10000, //网络通信超时时间，单位是毫秒，取值范围：10000-120000, 缺省值:60000(60秒)
        })
    });

    /* 
        这几个回调写在这里是因为入会后权限无法主动查询，只能靠通知接受，入会后如果有权限会触发notifyGiveCtrlRight通知
        同时因为入会后会跳转vue组件，大概率无法在vue组件中第一时间触发通知，所以写到这个全局的JS里
     */
    //通知给予某人控制权限
    rtcsdk.on("notifyGiveCtrlRight", notifyGiveCtrlRight);
    //通知释放了控制权限
    rtcsdk.on("notifyReleaseCtrlRight", notifyReleaseCtrlRight);
}
start();
export default rtcsdk;

