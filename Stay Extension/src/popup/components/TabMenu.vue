<template>
  <div class="popup-fotter-wrapper">
    <div class="fotter-box">
      <div></div>
      <div></div>
      <div></div>
      <div></div>
    </div>
  </div>
</template>

<script>
import { reactive, toRefs } from 'vue'

export default {
  name: 'DarkModeComp',
  setup (props, {emit, expose}) {
    const state = reactive({

    });

    return {
      ...toRefs(state)
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-fotter-wrapper{
    width: 100%;
    position: fixed;
    height: 52px;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: var(--s-f6);
    border-bottom: 1px solid var(--s-e0);
    .fotter-box{
      position: relative;
      width: 100%;
      height: 100%;
    }
  }
</style>
