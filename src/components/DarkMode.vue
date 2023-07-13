<template>
  <div class="popup-darkmode-wrapper">
    <div id="colorPicker" class="color-picker" ref="colorPicker">你好 colorPicker</div>
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
  </div>
</template>

<script>
import { reactive, inject, ref, onMounted, toRefs, watch } from 'vue'
import { useI18n } from 'vue-i18n';
import { getHostname } from '../utils/util'
import SwitchButtonComp from '../components/SwitchButtonComp.vue'
import SwitchComp from './SwitchComp.vue';
import Pickr from '@simonwep/pickr';
import '@simonwep/pickr/dist/themes/monolith.min.css';
// import Pickr from '@simonwep/pickr/dist/pickr.es5.min';
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
      darkmodeTheme: props.darkmodeTheme,
      siteEnabled: store.state.siteEnabled,
      hostSwitchStatus: store.state.siteEnabled?'on':'off',
      switchList: [
        {value:'on', name: t('darkmode_on'), isSelected: props.darkmodeToggleStatus==='on'},
        {value:'auto', name: t('darkmode_auto'), isSelected: props.darkmodeToggleStatus==='auto'},
        {value:'off', name: t('darkmode_off'), isSelected: props.darkmodeToggleStatus==='off'}
      ],
      themeList: [
        {value:'Default', name: t('darkmode_theme_default'), isSelected: props.darkmodeTheme==='Default'},
        {value:'Eco', name: t('darkmode_theme_eco'), isSelected: props.darkmodeTheme==='Eco'},
        {value:'Eyecare', name: t('darkmode_theme_eyecare'), isSelected: props.darkmodeTheme==='Eyecare'}
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
        state.darkmodeTheme = newProps.darkmodeTheme;
        state.switchList = [
          {value:'on', name: t('darkmode_on'), isSelected: newProps.darkmodeToggleStatus==='on'},
          {value:'auto', name: t('darkmode_auto'), isSelected: newProps.darkmodeToggleStatus==='auto'},
          {value:'off', name: t('darkmode_off'), isSelected: newProps.darkmodeToggleStatus==='off'}
        ];
        state.themeList = [
          {value:'Default', name: t('darkmode_theme_default'), isSelected: newProps.darkmodeTheme==='Default'},
          {value:'Eco', name: t('darkmode_theme_eco'), isSelected: newProps.darkmodeTheme==='Eco'},
          {value:'Eyecare', name: t('darkmode_theme_eyecare'), isSelected: newProps.darkmodeTheme==='Eyecare'}
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
      store.commit('setDarkmodeToggleStatus', state.darkmodeSwitchStatus);
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

    const handleDarkmodeProSetting = () => {
      console.log('handleDarkmodeProSetting request----------', state.darkmodeSwitchStatus, state.darkmodeTheme);
      global.browser.runtime.sendMessage({ type: 'popup', operate: 'DARKMODE_SETTING', isStayAround: state.isStayPro?'a':'b', status: state.darkmodeSwitchStatus, darkmodeColorTheme: state.darkmodeTheme, domain: state.hostName, enabled: state.siteEnabled }, (response) => {
        // console.log("DARKMODE_SETTING response----", response);
      })
    }

    const themeSwitchAction = (darkmodeTheme) => {
      console.log('themeSwitchAction-----',darkmodeTheme)
      if(state.darkmodeTheme === darkmodeTheme){
        return;
      }
      state.darkmodeTheme = darkmodeTheme;
      state.themeList.forEach(item => {
        if(item.value === darkmodeTheme){
          item.isSelected = true;
        }else{
          item.isSelected = false;
        }
      });
      store.commit('setDarkmodeTheme', state.darkmodeTheme);
      handleDarkmodeProSetting();
    }

    const allowEnabledAction = (hostSwitchStatus) => {
      state.hostSwitchStatus = hostSwitchStatus
      state.siteEnabled = hostSwitchStatus=='on'?true:false;
      store.commit('setSiteEnabled', state.siteEnabled);
      handleDarkmodeProSetting();
    }

    state.switchNote = handleSwitchNote(props.darkmodeToggleStatus);
    
    const colorPicker = ref(null);

    onMounted(()=>{
      console.log('colorPicker---------------',colorPicker.value);
      const pickr = Pickr.create({
        el: colorPicker.value,
        theme: 'monolith', // or 'monolith', or 'nano'
        swatches: [
          'rgba(244, 67, 54, 1)',
          'rgba(233, 30, 99, 0.95)',
          'rgba(156, 39, 176, 0.9)',
          'rgba(103, 58, 183, 0.85)',
          'rgba(63, 81, 181, 0.8)',
          'rgba(33, 150, 243, 0.75)',
          'rgba(3, 169, 244, 0.7)',
          'rgba(0, 188, 212, 0.7)',
          'rgba(0, 150, 136, 0.75)',
          'rgba(76, 175, 80, 0.8)',
          'rgba(139, 195, 74, 0.85)',
          'rgba(205, 220, 57, 0.9)',
          'rgba(255, 235, 59, 0.95)',
          'rgba(255, 193, 7, 1)'
        ],
  
        components: {
  
          // Main components
          preview: true,
          opacity: true,
          hue: true,
  
          // Input / output Options
          interaction: {
            hex: true,
            rgba: true,
            hsla: false,
            hsva: false,
            cmyk: false,
            input: true,
            clear: true,
            save: true
          }
        }
      });
  
      pickr.on('init', instance => {
        console.log('Event: "init"', instance);
      }).on('hide', instance => {
        console.log('Event: "hide"', instance);
      }).on('show', (color, instance) => {
        console.log('Event: "show"', color, instance);
      }).on('save', (color, instance) => {
        console.log('Event: "save"', color, instance);
      }).on('clear', instance => {
        console.log('Event: "clear"', instance);
      }).on('change', (color, source, instance) => {
        console.log('Event: "change"', color, source, instance);
      }).on('changestop', (source, instance) => {
        console.log('Event: "changestop"', source, instance);
      }).on('cancel', instance => {
        console.log('Event: "cancel"', instance);
      }).on('swatchselect', (color, instance) => {
        console.log('Event: "swatchselect"', color, instance);
      });
    })
    
    return {
      colorPicker,
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
}
</style>
