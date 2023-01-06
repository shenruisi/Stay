<template>
    <div class="upgrade-pro-warpper" @click="upgradeAction">
      <div class="upgrade-img"></div>
      <div class="upgrade-btn">{{t('upgrade_pro')}}</div>
    </div>
  </template>
  
<script>
import { reactive, toRefs, inject } from 'vue'
import { useI18n } from 'vue-i18n';
  
export default {
  name: 'UpgradeProComp',
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const state = reactive({
  
    });
    const upgradeAction = () => {
      // window.open('stay://x-callback-url/pay?');
      global.openUrlInSafariPopup('stay://x-callback-url/pay?');
    }
    return {
      ...toRefs(state),
      t,
      tm,
      upgradeAction
    };
  }
}
</script>
  
<style lang="less" scoped>
.upgrade-pro-warpper{
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  flex:1;
  .upgrade-img{
    width: 120px;
    height: 120px;
    background: url("../assets/images/upload-pro.png") no-repeat 50% 50%;
    background-size: contain;

  }
  .upgrade-btn{
    background-color: var(--s-btn-bg);
    border-radius:15px;
    width: 175px;
    height: 30px;
    line-height: 30px;
    color: var(--s-btn);
    font-size: 15px;
    font-weight: 500;
    margin: 20px auto;
  }
}
</style>
  