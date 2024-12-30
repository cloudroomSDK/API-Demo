import { app, BrowserWindow, shell, ipcMain, Menu, dialog, systemPreferences, crashReporter, screen } from "electron";
import { release } from "node:os";
import { join } from "node:path";
import "./electron-store";

//获取崩溃日志堆栈文件
const getCrashReport = () => {
    // 崩溃日志堆栈文件存放路径
    try {
        // 获取崩溃日志堆栈文件存放路径 -- electron 9.0.0 版本之后
        console.log("------crashFilePath------", app.getPath("crashDumps"));
    } catch (error) {
        console.error("------获取奔溃文件路径失败------", error);
    }
    // 开启 crash 捕获
    crashReporter.start({
        uploadToServer: false, // 是否上传服务器
        ignoreSystemCrashHandler: false, // 不忽略系统自带的奔溃处理，为 true 时表示忽略，奔溃时不会生成奔溃堆栈文件
    });
};
getCrashReport();

// The built directory structure
//
// ├─┬ dist-electron
// │ ├─┬ main
// │ │ └── index.js    > Electron-Main
// │ └─┬ preload
// │   └── index.js    > Preload-Scripts
// ├─┬ dist
// │ └── index.html    > Electron-Renderer
//
process.env.DIST_ELECTRON = join(__dirname, "..");
process.env.DIST = join(process.env.DIST_ELECTRON, "../dist");
process.env.VITE_PUBLIC = process.env.VITE_DEV_SERVER_URL ? join(process.env.DIST_ELECTRON, "../public") : process.env.DIST;

// Disable GPU Acceleration for Windows 7
if (release().startsWith("6.1")) app.disableHardwareAcceleration();

// Set application name for Windows 10+ notifications
if (process.platform === "win32") app.setAppUserModelId(app.getName());

if (!app.requestSingleInstanceLock()) {
    app.quit();
    process.exit(0);
}

// Remove electron security warnings
// This warning only shows in development mode
// Read more on https://www.electronjs.org/docs/latest/tutorial/security
// process.env['ELECTRON_DISABLE_SECURITY_WARNINGS'] = 'true'

let win: BrowserWindow | null = null;
let screenOptionWin: BrowserWindow | null = null;
// Here, you can also use other preload
const preload = join(__dirname, "../preload/index.js");
const url = process.env.VITE_DEV_SERVER_URL;
const indexHtml = join(process.env.DIST, "index.html");

async function createWindow() {
    win = new BrowserWindow({
        title: "Api Demo",
        icon: join(process.env.VITE_PUBLIC, "favicon.ico"),
        width: 1080,
        height: 720,
        minWidth: 1080,
        minHeight: 720,
        webPreferences: {
            preload,
            // Warning: Enable nodeIntegration and disable contextIsolation is not secure in production
            // Consider using contextBridge.exposeInMainWorld
            // Read more on https://www.electronjs.org/docs/latest/tutorial/context-isolation
            nodeIntegration: true,
            contextIsolation: false,
        },
    });
    Menu.setApplicationMenu(null);
    if (process.env.VITE_DEV_SERVER_URL) {
        // electron-vite-vue#298
        win.loadURL(url);
        // Open devTool if the app is not packaged
        win.webContents.openDevTools();
    } else {
        win.loadFile(indexHtml);
    }

    // Test actively push message to the Electron-Renderer
    win.webContents.on("did-finish-load", () => {
        win?.webContents.send("main-process-message", new Date().toLocaleString());
    });

    // Make all links open with the browser, not with the application
    win.webContents.setWindowOpenHandler(({ url }) => {
        if (url.startsWith("https:")) shell.openExternal(url);
        return { action: "deny" };
    });

    win.on("close", () => {
        if (screenOptionWin) {
            screenOptionWin.close();
        }
    });
    if (process.platform === "linux") {
        // linux使用父子窗口，监听父窗口的最小化时，显示子窗口
        win.on("minimize", () => {
            if (screenOptionWin) {
                screenOptionWin.show();
            }
        });
    }
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
    win = null;
    app.quit();
});

app.on("second-instance", () => {
    if (win) {
        // Focus on the main window if the user tried to open another
        if (win.isMinimized()) win.restore();
        win.focus();
    }
});

app.on("activate", () => {
    const allWindows = BrowserWindow.getAllWindows();
    if (allWindows.length) {
        allWindows[0].focus();
    } else {
        createWindow();
    }
});

async function checkDeviceAccessPrivilege() {
    const cameraAccessPrivilege = systemPreferences.getMediaAccessStatus("camera");
    if (cameraAccessPrivilege !== "granted") {
        await systemPreferences.askForMediaAccess("camera");
    }

    const micAccessPrivilege = systemPreferences.getMediaAccessStatus("microphone");
    if (micAccessPrivilege !== "granted") {
        await systemPreferences.askForMediaAccess("microphone");
    }

    systemPreferences.getMediaAccessStatus("screen");
}

if (process.platform == "darwin") {
    // mac动态权限申请，如果不申请权限可能会奔溃
    checkDeviceAccessPrivilege();
}

const screenOptionHtml = join(__dirname, "../../screenOption/index.html");
// 创建屏幕选项组件
function createScreenOptionComponent() {
    const child = new BrowserWindow({
        width: 472,
        height: 36,
        show: false,
        frame: false, // 无边框窗口
        transparent: true, // 透明窗口
        resizable: false, // 禁止调整大小
        movable: false, // 禁止移动
        parent: process.platform === "linux" ? win : undefined, // linux设置父窗口为主窗口
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false,
        },
    });
    Menu.setApplicationMenu(null);
    child.loadFile(screenOptionHtml);
    child.setAlwaysOnTop(true, "pop-up-menu");
    process.platform === "win32" && child.setSkipTaskbar(true); //使窗口不显示在任务栏中。
    child.setVisibleOnAllWorkspaces(true, {
        visibleOnFullScreen: true, // 设置当前窗口是否可以在全屏窗口之上显示，这里有个bug，mac上会使任务栏图标消失。
    });
    // child.webContents.openDevTools();

    child.once("ready-to-show", () => {
        const workArea = screen.getPrimaryDisplay().workArea;
        // 计算窗口的x坐标，使其水平居中于工作区域
        const x = Math.round((workArea.width - 236) / 2);
        // 设置窗口的位置，y坐标为0使其紧贴屏幕顶部
        child.setPosition(x, 0);
        child.show();
    });
    screenOptionWin = child;
}
// 销毁屏幕选项组件
function closeScreenOptionComponent() {
    if (screenOptionWin) {
        screenOptionWin.close();
        screenOptionWin = null;

        //mac上使任务栏图标恢复
        process.platform === "darwin" &&
            win.setVisibleOnAllWorkspaces(true, {
                visibleOnFullScreen: false,
            });
    }
}

ipcMain.handle("common", (event, { module, method, data }) => {
    if (module === "win") {
        win && win.webContents.send(method, data);
    } else if (module === "screenOption") {
        screenOptionWin && screenOptionWin.webContents.send(method, data);
    } else {
        switch (method) {
            case "get-logs-path": //日志路径
                return app.getPath("logs");
            case "openSelectFolder": {
                //打开选择文件夹
                const path = dialog.showOpenDialogSync(BrowserWindow.fromWebContents(event.sender), {
                    title: data.title,
                    properties: ["openDirectory"],
                });
                return path && path[0];
            }
            case "openSelectVideo": {
                //用于影音共享时弹出文件选择逻辑
                const path = dialog.showOpenDialogSync(BrowserWindow.fromWebContents(event.sender), {
                    title: "选择需要共享的视频文件",
                    filters: [{ name: "Videos", extensions: ["mp4", "flv", "avi", "wmv", "mkv", "mov", "3gp", "wma", "mp3", "m4a", "wav"] }],
                    properties: ["openFile"],
                });

                return path && path[0];
            }

            default:
                break;
        }
    }
});

ipcMain.on("common", (event, { module, method, data }) => {
    if (module === "win") {
        win && win.webContents.send(method, data);
    } else if (module === "screenOption") {
        screenOptionWin && screenOptionWin.webContents.send(method, data);
    } else {
        switch (method) {
            case "toggleDevTools": //打开控制台
                event.sender.toggleDevTools();
                break;
            case "openFile": //打开文件
                shell.openPath(data);
                break;
            case "createScreenOption":
                createScreenOptionComponent();
                break;
            case "exitMeeting": //退出房间
            case "destoryScreenOption":
                closeScreenOptionComponent();
                break;
            case "marker-start": //点击了浮窗的开始标注
                screenOptionWin.hide(); //截图时浮窗隐藏，后面再显示出来
                setTimeout(() => {
                    win.webContents.send("marker-start"); //win窗口调用SDK接口开始标注
                    setTimeout(() => {
                        screenOptionWin.show(); //截图完成后显示浮窗
                        win.show(); //让截图窗口前置
                        setTimeout(() => {
                            win.setFullScreen(true); //开启全屏
                        }, 100);
                    }, 200);
                }, 300);
                break;
            case "marker-clear": //点击了浮窗的清空标注
                win.webContents.send("marker-clear");
                break;
            case "marker-stop": //点击了浮窗的停止标注
                win.webContents.send("marker-stop");
                win.setFullScreen(false);
                break;
            case "screen-destory": //点击了浮窗的停止共享
                closeScreenOptionComponent();
                win.webContents.send("screen-destory");
                win.setFullScreen(false);
                break;
            case "onScreenOptionMouseleave":
                if (process.platform === "win32" || process.platform === "darwin") {
                    screenOptionWin.setIgnoreMouseEvents(true, { forward: true });
                }
                break;
            case "onScreenOptionMouseenter":
                if (process.platform === "win32" || process.platform === "darwin") {
                    screenOptionWin.setIgnoreMouseEvents(false);
                }
                break;
            case "resizeScreenOption": //修改浮窗大小
                screenOptionWin.setResizable(true);
                screenOptionWin.setSize(data.w, data.h);
                screenOptionWin.setResizable(false);
                const position = screenOptionWin.getPosition();
                const workArea = screen.getPrimaryDisplay().workArea;
                const x = Math.round((workArea.width - data.w) / 2);
                screenOptionWin.setPosition(x + workArea.x, position[1]);
                break;

            default:
                break;
        }
    }
});
