import { app, BrowserWindow, shell, ipcMain, Menu, dialog, systemPreferences, crashReporter } from "electron";
import { release } from "node:os";
import { join } from "node:path";
import "./electron-store";

//获取崩溃日志堆栈文件
const getCrashReport = () => {
    // 崩溃日志堆栈文件存放路径
    try {
        // 获取崩溃日志堆栈文件存放路径 -- electron 9.0.0 版本之后
        console.log('------crashFilePath------', app.getPath('crashDumps'))
    } catch (error) {
        console.error('------获取奔溃文件路径失败------', error)
    }
    // 开启 crash 捕获
    crashReporter.start({
        uploadToServer: false, // 是否上传服务器
        ignoreSystemCrashHandler: false // 不忽略系统自带的奔溃处理，为 true 时表示忽略，奔溃时不会生成奔溃堆栈文件
    })
}
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
    // win.webContents.on('will-navigate', (event, url) => { }) #344
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

//返回日志路径
ipcMain.handle("get-logs-path", (event) => {
    return app.getPath('logs');
});

//用于影音共享时弹出文件选择逻辑
ipcMain.handle("electron-select-meida", (event) => {
    const path = dialog.showOpenDialogSync(win, {
        title: "选择需要共享的视频文件",
        filters: [{ name: "Videos", extensions: ["mp4", "flv", "avi", "wmv", "mkv", "mov", "3gp", "wma", "mp3", "m4a", "wav"] }],
        properties: ["openFile"],
    });

    return path && path[0];
});

//用于本地录制时弹出文件夹选择逻辑
ipcMain.handle("electron-select-localMixer", (event) => {
    const path = dialog.showOpenDialogSync(win, {
        title: "选择存储视频的目录",
        properties: ["openDirectory"],
    });
    return path && path[0];
});

//用于本地录制完成后点击打开录像文件
ipcMain.on("electron-open-localMixer", (event, filePath) => {
    shell.openPath(filePath);
});

//打开控制台
ipcMain.on("toggleDevTools", (event, filePath) => {
    win.webContents.toggleDevTools();
});

async function checkDeviceAccessPrivilege() {
    const cameraAccessPrivilege = systemPreferences.getMediaAccessStatus('camera');
    if (cameraAccessPrivilege !== 'granted') {
        await systemPreferences.askForMediaAccess('camera');
    }

    const micAccessPrivilege = systemPreferences.getMediaAccessStatus('microphone');
    if (micAccessPrivilege !== 'granted') {
        await systemPreferences.askForMediaAccess('microphone');
    }

    systemPreferences.getMediaAccessStatus('screen');
}

if (process.platform == 'darwin') {
    // mac动态权限申请，如果不申请权限可能会奔溃
    checkDeviceAccessPrivilege()
}