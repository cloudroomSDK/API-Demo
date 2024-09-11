import { PreferencesUtil } from '@pura/harmony-utils';

interface LoginObj {
  addr: string,
  useToken: boolean,
  useHTTPS: boolean,
  AppID?: string,
  AppSecret?: string,
  Token?: string,
}

const defaultConfig: LoginObj = {
  addr: 'sdk.cloudroom.com',
  AppID: '',
  AppSecret: '',
  Token: '',
  useToken: false,
  useHTTPS: true,
}

class LoginConfig implements LoginObj {
  addr: string;
  useToken: boolean;
  useHTTPS: boolean;
  AppID?: string;
  AppSecret?: string;
  Token?: string;

  constructor() {
    const config = PreferencesUtil.getSync('loginConfig', defaultConfig) as LoginObj;
    this.addr = config.addr;
    this.useToken = config.useToken;
    this.useHTTPS = config.useHTTPS;
    this.AppID = config.AppID;
    this.AppSecret = config.AppSecret;
    this.Token = config.Token;
  }

  getDefaultConfig(): LoginObj {
    return defaultConfig;
  }

  sava(config: LoginObj) {
    this.useHTTPS = config.useHTTPS;
    this.useToken = config.useToken;
    this.addr = config.addr;
    if (this.useToken) {
      this.Token = config.Token;
    } else {
      this.AppID = config.AppID;
      this.AppSecret = config.AppSecret;
    }
    PreferencesUtil.put('loginConfig', config);
  }
}

export default new LoginConfig();