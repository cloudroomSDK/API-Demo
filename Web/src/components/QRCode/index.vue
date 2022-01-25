<template>
  <div>
    <div class="title">扫码体验移动端</div>
    <img v-if="src" :src="src">
  </div>
</template>

<script>
import QRCode from 'qrcode'

export default {
  data() {
    return {
      src: null
    }
  },
  created() {
    this.generateQR(window.location.href)
  },
  methods: {
    async generateQR(text) {
      try {
        this.src = await QRCode.toDataURL(text, {
          width: 276,
          margin: 0
        })
      } catch (err) {
        console.error(err)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.title {
  margin-bottom: 10px;
}
img {
  width: 100%;
}
</style>
