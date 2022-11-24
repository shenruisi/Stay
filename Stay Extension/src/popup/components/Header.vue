<template>
  <div class="popup-header-wrapper">
    <div class="stay-icon" @click="clickStayAction"></div>
    <div class="header-content">
      <slot></slot>
    </div>
  </div>
</template>

<script>
import { reactive, toRefs } from 'vue'

export default {
  name: 'headerComp',
  setup (props, {emit, expose}) {
    const state = reactive({

    });

    const clickStayAction = () => {
      window.open('stay://');
    }
    
    return {
      ...toRefs(state),
      clickStayAction
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-header-wrapper{
    width: 100%;
    position: fixed;
    height: 38px;
    top: 0;
    left: 0;
    right: 0;
    background-color: var(--s-f6);
    border-bottom: 1px solid var(--s-e0);
    .stay-icon{
        position: absolute;
        left: 0;
        width: 48px;
        height: 38px;
        top: 50%;
        transform: translate(0, -50%);
        background: url("../../assets/images/stay-large-icon.png") no-repeat 50% 50%;
        background-size: 50%;
    }
    .header-content{
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        justify-items: center;
        align-items: center;
        font-weight: 700;
        font-size: 15px;
        color: var(--s-black);
    }
  }
</style>