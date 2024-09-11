import { PreferencesUtil, RandomUtil } from '@pura/harmony-utils';

interface UserObj {
  userID: string,
  nickName: string,
}

const random = RandomUtil.getRandomNumber(1e3, 1e4);
const defaultObj: UserObj = {
  userID: `harmony_${random}`,
  nickName: `harmony_${random}`
}

class UserConfig implements UserObj {
  userID: string;
  nickName: string;

  constructor() {
    if (PreferencesUtil.hasSync('userConfig')) {
      const config = PreferencesUtil.getSync('userConfig', defaultObj) as UserObj;
      this.userID = config.userID;
      this.nickName = config.nickName;
    } else {
      this.userID = defaultObj.userID;
      this.nickName = defaultObj.nickName;
      PreferencesUtil.put('userConfig', defaultObj);
    }
  }

  changeUserID(userID: string) {
    this.userID = userID;
  }
}

export default new UserConfig();