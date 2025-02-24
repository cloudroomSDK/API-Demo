<template>
	<rtcsdk-videoView ref="videoView" />
</template>

<script>
	export default {
		name: 'rtcsdk-video-view',
		data() {
			return {
				userId: '',
				camId: ''
			}
		},
		watch: {
			usrVideoId(newValue, oldValue) {
				const { userId, camId, qualityLv } = newValue;
				this.setVideo(userId, camId, qualityLv);
			},
			scaleType(newValue, oldValue) {
				this.setScaleType(newValue);
			}
		},
		props: {
			usrVideoId: {
				type: Object || null,
				// 对象或数组默认值必须从一个工厂函数获取
				default () {
					return {
						userId: '',
						camId: '',
					}
				}
			},
			scaleType: {
				type: Number,
				default: 0,
			}
		},
		mounted() {
			if (this.scaleType !== 0) {
				this.setScaleType(this.scaleType);
			}

			if (this.usrVideoId) {
				const { userId, camId, qualityLv } = this.usrVideoId;
				this.setVideo(userId, camId, qualityLv);
			}
		},
		methods: {
			setScaleType(value) {
				this.$refs.videoView.setScaleType(+value);
			},
			setVideo(userId, camId = -1, qualityLv = 1) {
				if (this.userId !== userId && this.camId !== camId) {
					this.userId = userId;
					this.camId = camId;
					this.$refs.videoView.setVideo({
						userId,
						videoID: this.camId,
						qualityLv
					})
				}
			}
		}
	}
</script>