<template>
  <div class="popup-darkmode-wrapper">
    <div class="darkmode-pro">
      <div class="darkmode-setting">
        <div class="setting"  v-for="(item, index) in darkmodeSettings" :class="{active: item.isSelected}" 
        :status="item.status" :key="index" @click="dakmodeSetingClick(item.status)">{{ item.name }}</div>
      </div>
      <div class="darkmode-web">
        <div class="check-box">
          <input id="allowEnabled" @change='changeWebsiteAllowEnabled($event)' :checked="siteEnabled" :disabled="'off'===darkmodeToggleStatus" type="checkbox" class="allow" />
        </div>
        <input id="domainInput" class="website-input" v-model="hostName" type="text" disabled />
      </div>
      <div id="darkmodeAllowNote" class="darkmode-note">{{ siteEnabled ? t('darkmode_enabled'):t('darkmode_disabled') }}</div>
    </div>
  </div>
</template>

<script>
import { reactive, inject, toRefs, watch } from 'vue'
import { useI18n } from 'vue-i18n';
import { getHostname } from '../utils/util'
export default {
  name: 'DarkModeComp',
  props:['siteEnabled', 'darkmodeToggleStatus', 'browserUrl'],
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const hostName = getHostname(props.browserUrl || store.state.browserUrl);
    const state = reactive({
      browserUrl: store.state.browserUrl,
      isStayPro: store.state.isStayPro,
      hostName,
      darkmodeToggleStatus: store.state.darkmodeToggleStatus,
      siteEnabled: store.state.siteEnabled,
      darkmodeSettings: [
        {status:'on', name: t('darkmode_on'), isSelected: props.darkmodeToggleStatus==='on'},
        {status:'auto', name: t('darkmode_auto'), isSelected: props.darkmodeToggleStatus==='auto'},
        {status:'off', name: t('darkmode_off'), isSelected: props.darkmodeToggleStatus==='off'}
      ]
    });

    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.browserUrl = newProps.browserUrl;
        state.hostName = getHostname(newProps.browserUrl);
        state.siteEnabled = newProps.siteEnabled;
        state.darkmodeToggleStatus = newProps.darkmodeToggleStatus;
        state.darkmodeSettings = [
          {status:'on', name: t('darkmode_on'), isSelected: newProps.darkmodeToggleStatus==='on'},
          {status:'auto', name: t('darkmode_auto'), isSelected: newProps.darkmodeToggleStatus==='auto'},
          {status:'off', name: t('darkmode_off'), isSelected: newProps.darkmodeToggleStatus==='off'}
        ]
      },
      { immediate: true, deep: true }
    );

    const dakmodeSetingClick = (status) => {
      console.log('dakmodeSetingClick-----',status, state.darkmodeToggleStatus);
      if(state.darkmodeToggleStatus === status){
        return;
      }
      state.darkmodeToggleStatus = status;
      state.darkmodeSettings.forEach(item => {
        if(item.status === status){
          item.isSelected = true;
        }else{
          item.isSelected = false;
        }
      });
      handleDarkmodeProSetting();
    }

    const handleDarkmodeProSetting = () => {
      if (state.darkmodeToggleStatus){
        store.commit('setDarkmodeToggleStatus', state.darkmodeToggleStatus);
        // console.log('state.darkmodeToggleStatus-----',state.darkmodeToggleStatus);
        global.browser.runtime.sendMessage({ type: 'popup', operate: 'DARKMODE_SETTING', isStayAround: state.isStayPro?'a':'b', status: state.darkmodeToggleStatus, domain: state.hostName, enabled: state.siteEnabled }, (response) => {
          // console.log("DARKMODE_SETTING response----", response);
        })
      }
    }

    const changeWebsiteAllowEnabled = (event) => {
      const disabled = event.target.checked;
      state.siteEnabled = disabled;
      store.commit('setSiteEnabled', state.siteEnabled);
      handleDarkmodeProSetting();
    }
    
    return {
      ...toRefs(state),
      t,
      tm,
      dakmodeSetingClick,
      changeWebsiteAllowEnabled
    };
  }
}
</script>

<style lang="less" scoped>
.popup-darkmode-wrapper{
  width: 78%;
  margin: 0 auto;
  padding: 20px 0;
  .darkmode-setting{
    margin: 0 auto 15px auto;
    display: flex;
    /* flex: 1; */
    background: var(--dm-bg);
    height: 26px;
    width: 100%;
    border: 1px solid var(--s-main);
    border-radius: 7px;
    justify-content: space-between;
    justify-items: center;
    align-items: center;
    position: relative;
    user-select: none;
  }
  .darkmode-setting .setting:first-child{
    border-top-left-radius: 6px;
    border-bottom-left-radius: 6px;
  }
  .darkmode-setting .setting:last-child {
    border-top-right-radius: 6px;
    border-bottom-right-radius: 6px;
  }
  .darkmode-setting .setting{
    width: 33.33%;
    color: var(--dm-font);
    font-size: 13px;
    cursor: pointer;
    font-weight: 400;
    height: 100%;
    display: flex;
    justify-content:center;
    align-items: center;
    justify-items: center;
    text-align: center;
    flex-flow: column;
    user-select: none;
  }
  .darkmode-pro .darkmode-setting .active {
    color: var(--dm-bg);
    background: var(--s-main);
  }
  .darkmode-web{
    border-radius: 7px;
    border: 1px solid var(--s-main);
    position: relative;
    margin-bottom: 10px;
    width: 100%; 
    background: var(--dm-bg);
  }
  .darkmode-web input.website-input{
    width: 100%;
    padding: 0 30px 0 10px;
    height: 24px;
    line-height: 24px;
    font-size: 12px;
    opacity:1;
    border-radius:7px;
    background: var(--dm-bg);
    color: var(--dm-font);
  }
  .check-box{
    position: absolute;
    right: 2px;
    top: 2px;
    width: 26px;
    height: 20px;     
    z-index: 999;  
  }
  .check-box input.allow{
    cursor: pointer;
    position: relative;
    width: 11px;
    height: 11px;
    background: var(--dm-bg);
    color: var(--dm-font);
  }
  input[type='checkbox']:disabled::after {
    opacity: 0.4;
  }
  input[type=checkbox]::after {
    position: absolute;
    top: -2px;
    right: 0px;
    background: var(--dm-bg);
    color: var(--dm-bg);
    height: 12px;
    width: 12px;
    display: inline-block;
    visibility: visible;
    text-align: center;
    content: '';
    border-radius: 2px;
    box-sizing: border-box;
    border: 1px solid var(--s-main);
  }
  input[type='checkbox']:checked::after {
    content: '✓';
    font-size: 10px;
    line-height: 10px;
    font-family: system-ui, -apple-system;
    font-weight: bold;
    color: var(--dm-bg);
    background-color: var(--s-main);
  }
  .darkmode-note{
    font-size: 13px;
    font-weight: 400;
    color: var(--dm-font-3);
  }
}
</style>
