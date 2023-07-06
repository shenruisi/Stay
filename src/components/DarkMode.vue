<template>
  <div class="popup-darkmode-wrapper">
    <div class="darkmode-switch-box">
      <div class="title">{{ t('dark_in_safari') }}</div>
      <SwitchButtonComp :buttonList="switchList" @switchAction="darkmodeSwitchAction" class="switch-comp"></SwitchButtonComp>
      <div class="switch-note" v-html="switchNote"></div>
    </div>
    <div class="darkmode-theme-box">
      <div class="title">{{ t('dark_theme') }}</div>
      <SwitchButtonComp :buttonList="themeList" @switchAction="themeSwitchAction" class="switch-comp"></SwitchButtonComp>
      <div class="theme-note">{{ themeNote }}</div>
    </div>
    <div class="darkmode-host-box">
      <div class="title">{{ t('dark_switch_on_web') }}</div>
      <div class="switch-on-host">
        <div class="host-info">{{ hostName }}</div>
        <SwitchComp class="switch-rule" :switchStatus="hostSwitchStatus" @switchAction="allowEnabledAction" :disabled="'off'===darkmodeSwitchStatus"></SwitchComp>
      </div>
    </div>
    <!-- <div class="darkmode-pro">
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
    </div> -->
  </div>
</template>

<script>
import { reactive, inject, toRefs, watch } from 'vue'
import { useI18n } from 'vue-i18n';
import { getHostname } from '../utils/util'
import SwitchButtonComp from '../components/SwitchButtonComp.vue'
import SwitchComp from './SwitchComp.vue';
export default {
  name: 'DarkModeComp',
  props:['siteEnabled', 'darkmodeToggleStatus', 'browserUrl', 'darkmodeTheme'],
  components:{
    SwitchButtonComp,
    SwitchComp
  },
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const hostName = getHostname(props.browserUrl || store.state.browserUrl);
    
    const state = reactive({
      browserUrl: store.state.browserUrl,
      isStayPro: store.state.isStayPro,
      hostName,
      darkmodeSwitchStatus: store.state.darkmodeToggleStatus,
      darkmodeTheme: store.state.darkmodeTheme,
      siteEnabled: store.state.siteEnabled,
      hostSwitchStatus: store.state.siteEnabled?'on':'off',
      switchList: [
        {value:'on', name: t('darkmode_on'), isSelected: props.darkmodeToggleStatus==='on'},
        {value:'auto', name: t('darkmode_auto'), isSelected: props.darkmodeToggleStatus==='auto'},
        {value:'off', name: t('darkmode_off'), isSelected: props.darkmodeToggleStatus==='off'}
      ],
      themeList: [
        {value:'default', name: t('darkmode_theme_default'), isSelected: props.darkmodeTheme==='default'},
        {value:'eco', name: t('darkmode_theme_eco'), isSelected: props.darkmodeTheme==='eco'},
        {value:'eyecare', name: t('darkmode_theme_eyecare'), isSelected: props.darkmodeTheme==='eyecare'}
      ],
      switchNote: '',
      themeNote: '',
    });
    console.log('siteEnabled----',state.siteEnabled)
    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.browserUrl = newProps.browserUrl;
        state.hostName = getHostname(newProps.browserUrl);
        state.siteEnabled = newProps.siteEnabled;
        state.hostSwitchStatus = newProps.siteEnabled?'on':'off';
        state.darkmodeSwitchStatus = newProps.darkmodeToggleStatus;
        state.switchList = [
          {value:'on', name: t('darkmode_on'), isSelected: props.darkmodeToggleStatus==='on'},
          {value:'auto', name: t('darkmode_auto'), isSelected: props.darkmodeToggleStatus==='auto'},
          {value:'off', name: t('darkmode_off'), isSelected: props.darkmodeToggleStatus==='off'}
        ];
      },
      { immediate: true, deep: true }
    );

    const darkmodeSwitchAction = (status) => {
      console.log('dakmodeSetingClick-----',status, state.darkmodeSwitchStatus);
      if(state.darkmodeSwitchStatus === status){
        return;
      }
      state.darkmodeSwitchStatus = status;
      state.switchList.forEach(item => {
        if(item.value === status){
          item.isSelected = true;
          state.switchNote = handleSwitchNote(status);
        }else{
          item.isSelected = false;
        }
      });
      handleDarkmodeProSetting();
    }

    const handleSwitchNote = (switchStatus) => {
      if(!switchStatus){
        return;
      }
      let switchNote = '';
      switch(switchStatus){
        case 'on':
          switchNote = t('switch_on_note');
          break;
        case 'off':
          switchNote = t('switch_off_note');
          break;
        case 'auto':
          switchNote = t('switch_auto_note');
          break;
      }
      return switchNote;
    }

    // const dakmodeSetingClick = (status) => {
    //   console.log('dakmodeSetingClick-----',status, state.darkmodeToggleStatus);
    //   if(state.darkmodeToggleStatus === status){
    //     return;
    //   }
    //   state.darkmodeToggleStatus = status;
    //   state.darkmodeSettings.forEach(item => {
    //     if(item.status === status){
    //       item.isSelected = true;
    //     }else{
    //       item.isSelected = false;
    //     }
    //   });
    //   handleDarkmodeProSetting();
    // }

    const handleDarkmodeProSetting = () => {
      if (state.darkmodeSwitchStatus){
        store.commit('setDarkmodeToggleStatus', state.darkmodeSwitchStatus);
        // console.log('state.darkmodeToggleStatus-----',state.darkmodeToggleStatus);
        global.browser.runtime.sendMessage({ type: 'popup', operate: 'DARKMODE_SETTING', isStayAround: state.isStayPro?'a':'b', status: state.darkmodeSwitchStatus, domain: state.hostName, enabled: state.siteEnabled }, (response) => {
          // console.log("DARKMODE_SETTING response----", response);
        })
      }
    }

    const themeSwitchAction = (theme) => {
      console.log('themeSwitchAction-----',theme)
    }

    const allowEnabledAction = (hostSwitchStatus) => {
      // state.siteEnabled = siteEnabled;
      state.hostSwitchStatus = hostSwitchStatus
      state.siteEnabled = hostSwitchStatus=='on'?true:false;
      store.commit('setSiteEnabled', state.siteEnabled);
      handleDarkmodeProSetting();
    }

    state.switchNote = handleSwitchNote(props.darkmodeToggleStatus);
    // const changeWebsiteAllowEnabled = (event) => {
    //   const disabled = event.target.checked;
    //   state.siteEnabled = disabled;
    //   store.commit('setSiteEnabled', state.siteEnabled);
    //   handleDarkmodeProSetting();
    // }
    
    return {
      ...toRefs(state),
      t,
      tm,
      darkmodeSwitchAction,
      themeSwitchAction,
      allowEnabledAction
    };
  }
}
</script>

<style lang="less" scoped>
.popup-darkmode-wrapper{
  width: 100%;
  margin: 0 auto;
  padding: 10px;
  .darkmode-switch-box, .darkmode-theme-box, .darkmode-host-box{
    width: 100%;
    .title{
      padding: 5px;
      font-weight: 500;
      font-size: 15px;
      color: var(--dm-font-2);
      text-align: left;
    }
    .switch-comp{
      width: 100%;
      margin-bottom: 10px;
    }
    .switch-on-host{
      width: 100%;
      margin-bottom: 10px;
      height: 42px;
      padding: 8px 80px 8px 8px;
      width: 100%;
      border: 1px solid var(--dm-bd);
      background-color: var(--dm-bg);
      border-radius: 10px;
      display: flex;
      justify-content: flex-start;
      align-items: center;
      position: relative;
      .host-info{
        width: 100%;
        height: 100%;
        text-align: left;
        color: var(--dm-font);
        font-size: 16px;
        overflow: hidden;
        text-overflow: ellipsis;
        display: inline-block;
        -webkit-box-orient: vertical;
        user-select: none;
      }
      .switch-rule{
        position: absolute;
        right: 8px;
        top: 50%;
        transform: translateY(-50%);
      }
    }
    .switch-note{
      margin-bottom: 10px;
      width: 100%;
      background-color: var(--s-main-f10);
      color: var(--s-main);
      font-size: 16px;
      text-align: left;
      padding: 12px;
      border-radius: 10px;
      user-select: none;
    }
  }
  
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
