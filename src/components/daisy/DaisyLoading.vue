<template>
  <div class="__loading-warpper" :class="props.class" :style="props.style">
    <div class="__loading-con" :style="{ zoom: size }">
      <div class="line1"></div>
      <div class="line2"></div>
      <div class="line3"></div>
      <div class="line4"></div>
      <div class="line5"></div>
      <div class="line6"></div>
      <div class="line7"></div>
      <div class="line8"></div>
      <div class="line9"></div>
      <div class="line10"></div>
      <div class="line11"></div>
      <div class="line12"></div>
    </div>
  </div>
</template>
<script>
import { reactive, toRefs } from 'vue';
export default {
  name: 'DaisyLoadingComp',
  props: ['class', 'style', 'size'],
  setup(props, context) {
    const state = reactive({
      size: props.size || 0.2,
      props,
    });
    return {
      ...toRefs(state),
    };
  },
};
</script>
<style lang="less" type="text/scss" scoped>
@keyframes loading {
  from {
    opacity: 0.8;
    width: 5px;
    height: 20px;
  }
  to {
    opacity: 0.25;
    width: 5px;
    height: 20px;
  }
}
.__loading-con {
  position: relative;
  // top: 50%;
  // left: 50%;
  display: inline-block;
  //zoom: 0.2; /*通过修改这个值(值的区间为0-1)的大小来设置菊花的大小*/
}
.__loading-con div {
  width: 3px;
  height: 16px;
  background: #a4a2a4;
  position: absolute;
  left: 100%;
  top: 100%;
  opacity: 1;
  animation: loading 1.2s linear infinite;
}
.__loading-con .line1 {
  transform: rotate(0deg) translate(0, -28px);
  animation-delay: 0s;
}
.__loading-con .line2 {
  transform: rotate(30deg) translate(0, -28px);
  animation-delay: 0.1s;
}
.__loading-con .line3 {
  transform: rotate(60deg) translate(0, -28px);
  animation-delay: 0.2s;
}
.__loading-con .line4 {
  transform: rotate(90deg) translate(0, -28px);
  animation-delay: 0.3s;
}
.__loading-con .line5 {
  transform: rotate(120deg) translate(0, -28px);
  animation-delay: 0.4s;
}
.__loading-con .line6 {
  transform: rotate(150deg) translate(0, -28px);
  animation-delay: 0.5s;
}
.__loading-con .line7 {
  transform: rotate(180deg) translate(0, -28px);
  animation-delay: 0.6s;
}
.__loading-con .line8 {
  transform: rotate(210deg) translate(0, -28px);
  animation-delay: 0.7s;
}
.__loading-con .line9 {
  transform: rotate(240deg) translate(0, -28px);
  animation-delay: 0.8s;
}
.__loading-con .line10 {
  transform: rotate(270deg) translate(0, -28px);
  animation-delay: 0.9s;
}
.__loading-con .line11 {
  transform: rotate(300deg) translate(0, -28px);
  animation-delay: 1s;
}
.__loading-con .line12 {
  transform: rotate(330deg) translate(0, -28px);
  animation-delay: 1.1s;
}
</style>
