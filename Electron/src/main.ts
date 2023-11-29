import { createApp } from "vue";
import ElementPlus from "element-plus";
import "./element-variables.scss";

import "./style.scss";
import App from "./App.vue";
import "./samples/node-api";
import router from "./router";
import { createPinia } from "pinia";
import { parseTime } from "@/utils";
import useStore from "@/store";
import { ipcRenderer } from "electron";

const pinia = createPinia();

const app = createApp(App);
app.use(ElementPlus);
app.use(router);
app.use(pinia);
import rtcsdk from "./rtcsdk";
app.config.globalProperties.$rtcsdk = rtcsdk;
app.config.globalProperties.parseTime = parseTime;
interface VideoCfg {
    type: 0 | 1 | 2;
    userId?: String;
    videoId?: Number;
}

//设置视频指令集
app.directive("setVideo", {
    // 在绑定元素的父组件
    // 及他自己的所有子节点都挂载完成后调用
    mounted(el, binding, vnode, prevVnode) {
        console.log("mounted", el, binding);
        const { type = 0, userId, camId = -1, notifyFrameReceived } = binding.value;
        const videoUI = rtcsdk.createVideoUI(el, {
            notifyFrameReceived: notifyFrameReceived
        });
        el.videoUI = videoUI;
        try {
            let videoCfg: VideoCfg = { type: type };
            if (type === 0 && userId) {
                videoCfg = {
                    ...videoCfg,
                    userId: userId,
                    videoId: camId,
                };
            }

            videoUI.setVideo(videoCfg);
        } catch (error) {}

        // videoUI.setConfig({ scaleType: 1 });
    },
    // 绑定元素的父组件更新前调用
    beforeUpdate(el, binding, vnode, prevVnode) {
        const { type = 0, userId, camId = -1 } = binding.value;
        const { type: oldType = 0, userId: oldUserId, camId: oldCamId = -1 } = binding.oldValue;

        if (type !== oldType || userId !== oldUserId || camId !== oldCamId) {
            const videoUI = el.videoUI;
            let videoCfg: VideoCfg = { type: type };
            if (type === 0 && userId) {
                videoCfg = {
                    ...videoCfg,
                    userId: userId,
                    videoId: camId,
                };
            }

            videoUI.setVideo(videoCfg);
        }
    },
    // 绑定元素的父组件卸载前调用
    beforeUnmount(el, binding, vnode, prevVnode) {},
    // 绑定元素的父组件卸载后调用
    unmounted(el, binding, vnode, prevVnode) {
        el.videoUI.destroy();
        el.videoUI = null;
    },
});

const store = useStore();
window.onbeforeunload = (event) => {
    // 如果在会议中，此时关闭窗口，要退出会议
    if (store.meetId) {
        rtcsdk.exitMeeting();
    }
};

app.mount("#app").$nextTick(() => {
    postMessage({ payload: "removeLoading" }, "*");
});

window.onkeydown = (e) => {
    if (e.key === "F12") {
        ipcRenderer.send("toggleDevTools"); //通知主进程弹出文件选择框
    }
};
