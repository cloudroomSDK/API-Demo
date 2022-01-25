<template>
  <div class="not-found">
    <img class="not-found-pic" src="@/assets/image/m404.png" alt="404">
    <p class="p1">您访问的网址不存在</p>
    <p class="p2">您访问的页面地址过期或错误</p>
  </div>
</template>

<style lang="scss" scoped>
.not-found {
  position: absolute;
  left: 50%;
  top: 35%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.not-found-pic {
}

.p1 {
  line-height: 1;
  font-size: 18px;
  color: #333333;
  margin-top: 52px;
}

.p2 {
  line-height: 1;
  font-size: 14px;
  color: #666666;
  margin-top: 16px;
}
</style>
