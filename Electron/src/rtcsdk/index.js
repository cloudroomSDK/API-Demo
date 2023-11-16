import RTCSDK from "electron-rtcsdk";
import { join } from "node:path";
const rtcsdk = new RTCSDK();
rtcsdk.init(join(process.cwd(), '/temp'), {
    // enableHardwareAcceleration: true,//启动硬件加速
});

export default rtcsdk;
