import RtcCloud from './rtcCloud.js'

export default class RTCSDK {
	constructor(){
		return RtcCloud.getInstance();
	}

	static getInstance(){
		return RtcCloud.getInstance();
	}
}