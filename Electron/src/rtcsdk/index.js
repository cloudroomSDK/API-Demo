import RTCSDK from "electron-rtcsdk";
import { join } from "node:path";
const rtcsdk = new RTCSDK();
rtcsdk.init({
    path: join(process.cwd(), '/temp'),//SDK工作目录，用于存储配置文件、临时文件、录制文件、影音文件、日志等文件，如果传空值，则默认为sdk的安装目录
    // enableHardwareAcceleration: true,//启动硬件加速
});

export default rtcsdk;
