<template>
  <div class="popup-header-wrapper">
    <div class="stay-icon" @click="clickStayAction"></div>
    <div class="header-content">
      <slot></slot>
    </div>
    <div class="stay-switch" :class="staySwitch" @click="clickStaySwitchAction(staySwitch)"></div>
  </div>
</template>

<script>
import { reactive, toRefs, inject } from 'vue'

export default {
  name: 'headerComp',
  setup (props, {emit, expose}) {
    const global = inject('global');
    const store = global.store;
    const state = reactive({
      staySwitch: store.state.staySwitch
    })

    const clickStayAction = () => {
      window.open('stay://');
    }
    const clickStaySwitchAction = (staySwitch) => {
      if(staySwitch == 'start'){
        state.staySwitch = 'cease';
      }else{
        state.staySwitch = 'start';
      }
      store.commit('setStaySwitch', state.staySwitch);
    }
    
    return {
      ...toRefs(state),
      clickStayAction,
      clickStaySwitchAction
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
    z-index: 999;
    .stay-icon{
      position: absolute;
      left: 0;
      width: 48px;
      height: 38px;
      top: 50%;
      padding: 2px;
      transform: translate(0, -50%);
      background: url("../assets/images/stay-header.png") no-repeat 50% 50%;
      background-size: 40%;
    }
    .stay-switch{
      position: absolute;
      right: 0;
      width: 48px;
      height: 38px;
      top: 50%;
      padding: 2px;
      transform: translate(0, -50%);
      &.start{
        background: url("../assets/images/pause.png") no-repeat 50% 50%;
        background-size: 40%;
      }
      &.cease{
        background: url("../assets/images/play.png") no-repeat 50% 50%;
        background-size: 40%;
      }
      
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