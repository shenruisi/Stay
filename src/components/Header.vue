<template>
  <div class="popup-header-wrapper" ref="headerRef" >
    <div class="header-content">
      <div class="stay-icon" @click="clickStayAction"></div>
      <div class="pro" v-if="isStayPro">PRO</div>
      <div class="title">{{ title }}</div>
    </div>
    <slot></slot>
    <!-- <div class="stay-switch" :class="staySwitch" @click="clickStaySwitchAction(staySwitch)"></div> -->
  </div>
</template>

<script>
import { reactive, toRefs, inject, watch, ref, onMounted,nextTick } from 'vue'
import { useI18n } from 'vue-i18n';
export default {
  name: 'headerComp',
  props:['titleInfo', 'isStayPro'],
  setup (props, {emit, expose}) {
    console.log('props-----', props, props.titleInfo);
    const global = inject('global');
    const store = global.store;
    const { t, tm, locale } = useI18n();
    const state = reactive({
      staySwitch: store.state.staySwitch,
      isStayPro: props.isStayPro,
      title: props.titleInfo
    })
    const headerRef = ref(null);

    onMounted(() => {
      console.log(headerRef.value);
      let timer = setTimeout(() => {
        headerRef.value.style = '-webkit-backdrop-filter: blur(16px) saturate(150%)';
        clearTimeout(timer);
        timer = null;
      }, 800)
    })
    const clickStayAction = () => {
      // window.open('stay://');
      global.openUrlInSafariPopup('stay://');
    }
    const clickStaySwitchAction = (staySwitch) => {
      if(staySwitch == 'start'){
        state.staySwitch = 'cease';
      }else{
        state.staySwitch = 'start';
      }
      store.commit('setStaySwitch', state.staySwitch);
    }
    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.title = newProps.titleInfo;
        state.isStayPro = newProps.isStayPro;
      },
      { immediate: true, deep: true }
    );
    
    return {
      headerRef,
      ...toRefs(state),
      clickStayAction,
      clickStaySwitchAction,
      t
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-header-wrapper{
    width: 100%;
    background-color: var(--dm-bg-f6drop);
    // -webkit-backdrop-filter: saturate(150%) blur(16px);
    // backdrop-filter: saturate(150%) blur(16px);
    transform: translateZ(0);
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    border-bottom: 1px solid var(--dm-bd);
    z-index: 999;
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
      padding-left: 35px;
      display: flex;
      justify-content: flex-start;
      justify-items: center;
      align-items: center;
      position: relative;
      height: 38px;
      .stay-icon{
        position: absolute;
        left: 0;
        width: 40px;
        height: 38px;
        top: 50%;
        padding: 2px;
        transform: translate(0, -50%);
        background: url("../assets/images/stay-header.png") no-repeat 50% 50%;
        background-size: 50%;
      }
      .pro{
        width: 30px;
        height: 15px;
        text-align: center;
        line-height: 13px;
        font-size: 10px;
        color: #84561D;
        background-color: #F9DF8D;
        border: 1px solid #E7CA7C;
        font-weight: 700;
        border-radius: 5px;
      }
      .title{
        font-weight: 700;
        font-size: 15px;
        color: var(--dm-font);
        padding-left: 8px;
      }
    }
  }
</style>