<template>
  <section class="app-main">
    <transition name="fade-transform" mode="out-in">
      <router-view
        :key="key"
        class="main"
        :class="isMobile ? 'mobile' : 'desktop'"
      />
    </transition>
  </section>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  name: 'AppMain',
  computed: {
    key() {
      return this.$route.path
    },
    ...mapGetters(['isMobile'])
  }
}
</script>

<style scoped>
.app-main {
  /*50 = navbar  */
  min-height: calc(100vh - 50px);
  width: 100%;
  position: relative;
  overflow: hidden;
}
.fixed-header + .app-main {
  margin-top: 50px;
}
</style>

<style lang="scss" scoped>
@import '~@/styles/layout.scss';
</style>
