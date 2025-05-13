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

interface MemberInfo {
    userId: string;
    nickname: string;
    audioStatus: number;
    videoStatus: number;
    defaultCamId: number;
    multipleVideos: number[];
}

interface WatchInfo extends MemberInfo {
    key: string;
    camId: number;
}

interface State {
    meetId: number | null;
    memberList: Record<string, MemberInfo>;
    networkCam: NetworkCam | null;
    myUserId: String | null;
    isLogin: Boolean;
    shareType: Number; //共享状态：0未共享，1影音共享 2屏幕共享
    isMyScreenShare: Boolean; //自己开启的屏幕共享
    enableMutiVideos: Boolean; //开启多摄像头
    hasCtrlMode: Boolean; //有远程屏幕控制权限
    rateConfigs: rateConfig[];
    platform: NodeJS.Platform;
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
            isMyScreenShare: false,
            enableMutiVideos: false,
            hasCtrlMode: false,
            platform: process.platform,
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
    getters: {
        watchList(state) {
            const { memberList } = state;
            const arr: WatchInfo[] = [];

            Object.keys(memberList).some((userId) => {
                const userInfo = memberList[userId];

                arr.push({
                    key: `${userId}_${userInfo.defaultCamId}`,
                    camId: userInfo.defaultCamId,
                    ...userInfo,
                });

                if (userInfo.videoStatus === 3) {
                    if (userInfo.multipleVideos.length) {
                        userInfo.multipleVideos.some((camId) => {
                            arr.push({
                                key: `${userId}_${camId}`,
                                camId,
                                ...userInfo,
                            });
                            if (arr.length >= 9) return true;
                        });
                    }
                }

                // 因为elecrton渲染视图性能有限，仅渲染包括自己在内9个摄像头
                if (arr.length >= 9) return true;
            });
            return arr;
        },
    },
});
