<script>
	export default {
		onLaunch: function() {
			console.log("App Launch");
			console.log(this.globalData.config);
		},
		onShow: function() {
			console.log("App Show");
		},
		onHide: function() {
			console.log("App Hide");
		},
	};
</script>

<style lang="scss">
	.page {
		height: 100vh;
	}
	/*每个页面公共css */
	.btn {
		&:not([disabled]) {
			&.primary {
				&:not([plain]) {
					background-color: $uni-color-primary;
					color: #fff;

					&.button-hover {
						background-color: #2e67ca;
					}
				}

				&[plain] {
					color: $uni-color-primary;
					border: 1rpx solid $uni-color-primary;

					&.button-hover {
						background-color: $uni-color-primary;
						color: #fff;
					}
				}
			}
			&.danger {
				&:not([plain]) {
					background-color: $uni-color-error;
					color: #fff;
			
					&.button-hover {
						background-color: #f00;
					}
				}
			}
		}
		&[disabled] {
			
		}
	}
</style>