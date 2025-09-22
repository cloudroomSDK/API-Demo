const packageJson = require("./package.json");
// const packageJson_meet = require('./webmeeting/package.json');

const version = packageJson.version;
// const meetAppVer = packageJson_meet.version;

module.exports = {
  version,
  info: `RTC SDK ver: ${packageJson.version}; Last modified: ${
    packageJson.Date
  } ${packageJson.author.name}; Last packing: ${new Date().toLocaleString()}`,
  // meetAppVer,
  // meetAppInfo: `[WebMeet] Meet App ver: ${packageJson_meet.version}; Last modified: ${packageJson_meet.Date} ${packageJson_meet.author.name}`
};
