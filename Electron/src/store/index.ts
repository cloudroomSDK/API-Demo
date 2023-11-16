import { defineStore } from "pinia";

interface rateConfig {
    name: string;
    height: number;
    width: number;
    minRatio: number;
    maxRatio: number;
    ratioStep: number;
    defaultRatio: number;
}
interface NetworkCam {
    id: number;
    type: String;
    url: String | null;
}

interface State {
    meetId: number | null;
    memberList: {};
    networkCam: NetworkCam | null;
    myUserId: String | null;
    isLogin: Boolean;
    shareType: Number,  //共享状态：0未共享，1影音共享 2屏幕共享
    rateConfigs: rateConfig[];
}

export default defineStore("app", {
    state: (): State => {
        return {
            meetId: null,
            isLogin: false,
            memberList: {},
            myUserId: null,
            networkCam: null,
            shareType: 0,
            rateConfigs: [
                {
                    name: "360P",
                    height: 360,
                    width: 640,
                    minRatio: 175,
                    maxRatio: 700,
                    defaultRatio: 350,
                    ratioStep: 35,
                },
                {
                    name: "480P",
                    height: 480,
                    width: 848,
                    minRatio: 500,
                    maxRatio: 2000,
                    ratioStep: 100,
                    defaultRatio: 1000,
                },
                {
                    name: "720P",
                    height: 720,
                    width: 1280,
                    minRatio: 500,
                    maxRatio: 2000,
                    ratioStep: 100,
                    defaultRatio: 1000,
                },
            ],
        };
    },
});
