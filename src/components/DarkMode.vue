<template>
  <div class="popup-darkmode-wrapper">
    
    <div class="settings-box" v-if="showTab == 'settings'">
      <div class="darkmode-switch-box">
        <div class="title">{{ t('dark_in_safari') }}</div>
        <SwitchButtonComp :buttonList="switchList" @switchAction="darkmodeSwitchAction" class="switch-comp"></SwitchButtonComp>
        <div class="switch-note" v-html="switchNote"></div>
      </div>
      <div class="darkmode-theme-box">
        <div class="title">{{ t('dark_theme') }}</div>
        <!-- <SwitchButtonComp :buttonList="themeList" @switchAction="themeSwitchAction" class="switch-comp"></SwitchButtonComp> -->
        <div class="theme-select-options">
          <div class="selected-theme" >
            <div class="theme-name">{{ selectedDarkmodeTheme.name }}</div>
            <div class="color-sample">
              <div class="color-area" :style="{background: selectedDarkmodeTheme.bgColor, color: selectedDarkmodeTheme.textColor}">{{ t('text') }}</div>
            </div>
            <select class="select-container" @change="changeSelectTheme($event)">
              <option v-for="(theme, i) in themeList" class="option" :disabled="isStayPro?false:theme.isPro" :style="{display: theme.value?'block':'none'}" :name="theme.name" :key="i" :value="theme.value">
                {{`${theme.name}  ${theme.isPro?'(PRO)':''}`}}
              </option>
            </select>
          </div>
        </div>
      </div>
      <div class="darkmode-host-box">
        <div class="title">{{ t('dark_switch_on_web') }}</div>
        <div class="switch-on-host">
          <div class="host-info">{{ hostName }}</div>
          <SwitchComp class="switch-rule" :switchStatus="hostSwitchStatus" @switchAction="allowEnabledAction" :disabled="'off'===darkmodeSwitchStatus"></SwitchComp>
        </div>
      </div>
    </div>
    <div class="themes-box" v-if="showTab == 'themes'">
      <div class="create-theme" @click="createNewThemeAction">
        <img src="../assets/images/theme.png">
        <div>{{ t("new_themes") }}</div>
      </div>
      <div class="theme-list-box">
        <div class="theme-item" v-for="(theme, index) in themeList" :key="index" :class="theme.edit?'self-theme':''" @click="modifyDarkmodeThemeAction(theme)">
          <div class="name" :class="theme.isPro&&!isStayPro?'pro':''">{{ theme.name }}</div>
          <div class="theme-con" :style="{background: theme.bgColor, color: theme.textColor}">
            {{ t('text') }}
          </div>
        </div>
      </div>
    </div>
    <ThemeColorComp :showEditTheme="showEditTheme" :themeObj="modifyTheme" :actionType="actionType" @handleCallbackAction="handleCallbackAction"></ThemeColorComp>
  </div>
</template>

<script>
import { reactive, inject, ref, onMounted, toRefs, watch } from 'vue'
import { useI18n } from 'vue-i18n';
import { getHostname } from '../utils/util'
import SwitchButtonComp from '../components/SwitchButtonComp.vue'
import ThemeColorComp from '../components/ThemeColorComp.vue'
import SwitchComp from './SwitchComp.vue';

export default {
  name: 'DarkModeComp',
  props:['siteEnabled', 'darkmodeToggleStatus', 'browserUrl', 'darkmodeTheme', 'currentTab'],
  components:{
    SwitchButtonComp,
    SwitchComp,
    ThemeColorComp
  },
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
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
    const hostName = getHostname(props.browserUrl || store.state.browserUrl);
    const switchNote = handleSwitchNote(props.darkmodeToggleStatus);
    const themeList = [
      {value:'Default', name: t('darkmode_theme_default'), bgColor: '#181a1b', textColor: '#e8e6e3', isPro: false, edit: false},
      {value:'Eco', name: t('darkmode_theme_eco'), bgColor: '#000000', textColor: '#969696', isPro: true, edit: false},
      {value:'Eyecare', name: t('darkmode_theme_eyecare'), bgColor: '#ffffcc', textColor: '#695011',isPro: true, edit: false}
    ]
    const  selectedDarkmodeTheme = {value:'Default', name: t('darkmode_theme_default'), bgColor: '#181a1b', textColor: '#e8e6e3', isPro: false, edit: false};
    const state = reactive({
      browserUrl: store.state.browserUrl,
      isStayPro: store.state.isStayPro,
      hostName,
      darkmodeSwitchStatus: store.state.darkmodeToggleStatus,
      darkmodeThemeValue: props.darkmodeTheme,
      selectedDarkmodeTheme: selectedDarkmodeTheme,
      siteEnabled: store.state.siteEnabled,
      hostSwitchStatus: store.state.siteEnabled?'on':'off',
      switchList: [
        {value:'on', name: t('darkmode_on'), isSelected: props.darkmodeToggleStatus==='on'},
        {value:'auto', name: t('darkmode_auto'), isSelected: props.darkmodeToggleStatus==='auto'},
        {value:'off', name: t('darkmode_off'), isSelected: props.darkmodeToggleStatus==='off'}
      ],
      themeList: themeList,
      switchNote: switchNote,
      showTab: props.currentTab && 'tab_1'== props.currentTab ? 'settings':'themes',
      showEditTheme: false,
      modifyTheme: {},
      actionType: 'add', // add/modify
    });
    console.log('siteEnabled----',state.siteEnabled);
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
          {value:'on', name: t('darkmode_on'), isSelected: newProps.darkmodeToggleStatus==='on'},
          {value:'auto', name: t('darkmode_auto'), isSelected: newProps.darkmodeToggleStatus==='auto'},
          {value:'off', name: t('darkmode_off'), isSelected: newProps.darkmodeToggleStatus==='off'}
        ];
        state.darkmodeThemeValue = newProps.darkmodeTheme;
        state.showTab = newProps.currentTab && 'tab_1'== newProps.currentTab ? 'settings':'themes';
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

    const handleSelectedDarkmodeTheme = () => {
      let selectedTheme = selectedDarkmodeTheme;
      if(state.isStayPro){
        state.themeList.forEach(item => {
          if(state.darkmodeThemeValue == item.value){
            selectedTheme = item;
          }
        })
      }
      return selectedTheme;
    }
    
    state.selectedDarkmodeTheme = handleSelectedDarkmodeTheme();

    const handleDarkmodeProSetting = () => {
      console.log('handleDarkmodeProSetting request----------', state.darkmodeSwitchStatus, state.selectedDarkmodeTheme);
      let message = { 
        type: 'popup', 
        operate: 'DARKMODE_SETTING', 
        isStayAround: state.isStayPro?'a':'b', 
        status: state.darkmodeSwitchStatus, 
        darkmodeColorTheme: state.selectedDarkmodeTheme.value, 
        backgroundColor: state.selectedDarkmodeTheme.bgColor,
        textColor: state.selectedDarkmodeTheme.textColor,
        domain: state.hostName, 
        enabled: state.siteEnabled 
      }
      global.browser.runtime.sendMessage(message, (response) => {
        // console.log("DARKMODE_SETTING response----", response);
      })
    }

    const changeThemeToDarkmode = (bgColor, textColor) => {
      console.log('changeThemeToDarkmode-------', bgColor, textColor)
      let message = { 
        type: 'popup', 
        operate: 'CHANGE_DARKMODE_THEME', 
        darkmodeColorTheme: state.selectedDarkmodeTheme.value, 
        backgroundColor: bgColor,
        textColor: textColor,
      }
      global.browser.runtime.sendMessage(message, (response) => {
        // console.log("DARKMODE_SETTING response----", response);
      })
    }
    

    const allowEnabledAction = (hostSwitchStatus) => {
      state.hostSwitchStatus = hostSwitchStatus
      state.siteEnabled = hostSwitchStatus=='on'?true:false;
      store.commit('setSiteEnabled', state.siteEnabled);
      handleDarkmodeProSetting();
    }


    const createNewThemeAction = () => {
      state.actionType = 'add';
      state.modifyTheme = {};
      state.showEditTheme = true;
    }

    const modifyDarkmodeThemeAction = (item) => {
      if(item.edit){
        state.actionType = 'modify';
        state.modifyTheme = item;
        state.showEditTheme = true;
      }
    }

    const handleCallbackAction = (flag, bgColor, textColor) => {
      if(flag == 'themeAction'){
        fetchDarkmodeThemeList();
      }else if(flag == 'closeAction'){
        state.showEditTheme = false;
        state.modifyTheme = {};
        state.actionType = 'add';
      }else if(flag == 'change'){
        changeThemeToDarkmode(bgColor, textColor)
      }else if(flag == 'clear'){
        handleDarkmodeProSetting();
      }
      
      
    }

    const changeSelectTheme = (event) => {
      const selectOpt = event.target;
      const index = selectOpt.selectedIndex
      console.log(index, selectOpt); 
      state.themeList.forEach((item, i)=>{
        if(item.value == selectOpt.value){
          state.selectedDarkmodeTheme = item;
          state.darkmodeThemeValue = item.value;
        }
      })
      store.commit('setDarkmodeTheme', state.darkmodeThemeValue);
      handleDarkmodeProSetting();
    }

    const fetchDarkmodeThemeList = () => {
      global.browser.runtime.sendMessage({from: 'popup', operate: 'getDarkmodeThemeList'}, (response) => {
        console.log('fetchDarkmodeThemeList response----', response);
        const resThemeList = response.themes || [];
        if(resThemeList && resThemeList.length){
          state.themeList = [...themeList, ...resThemeList];
        }else{
          state.themeList = [...themeList];
        }
      })
    }

    fetchDarkmodeThemeList();
    
    return {
      ...toRefs(state),
      t,
      tm,
      darkmodeSwitchAction,
      allowEnabledAction,
      createNewThemeAction,
      handleCallbackAction,
      changeSelectTheme,
      modifyDarkmodeThemeAction
    };
  }
}
</script>

<style lang="less" scoped>
.popup-darkmode-wrapper{
  width: 100%;
  margin: 0 auto;
  padding: 10px;
  height: 100%;
  .settings-box{
    width: 100%;

  }
  
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
      height: 45px;
      padding: 0px 80px 0px 8px;
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
        line-height: 40px;
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
    .theme-select-options{
      width: 100%;
      position: relative;
      margin-bottom: 10px;
      .selected-theme{
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 45px;
        background-color: var(--dm-bg);
        border-radius: 10px;
        border: 1px solid var(--dm-bd);
        box-shadow: 0 0px 10px rgba(0,0,0,0.05);
        padding: 0 15px;
        position: relative;
        .theme-name{
          color: var(--dm-font);
          font-weight: 700;
          font-size: 16px;
          width: 75%;
          height: 100%;
          background-color: var(--dm-bg);
          display: flex;
          justify-content: flex-start;
          align-items: center;
          position: relative;
          z-index: 999;
        }
        .color-sample{
          width: 25%;
          height: 100%;
          display: flex;
          justify-content: flex-end;
          align-items: center;
          position: relative;
          padding-right: 25px;
          .color-area{
            width: 28px;
            height: 28px;
            border-radius: 14px;
            font-weight: 600;
            line-height: 28px;
            text-align: center;
            overflow: hidden;
          }
          &::after{
            content: '';
            background: url("../assets/images/option.png") 50% 50% no-repeat;
            background-size: 20px;
            width: 20px;
            height: 40px;
            position: absolute;
            right: 0px;
            top: 2px;
          }
          
        }
        .select-container{
          width: 50%;
          position: absolute;
          height: 100%;
          top: 0;
          right: 0;
          background: none;
          z-index: 555;
        }
      }
    }
  }
  
  .themes-box{
    width: 100%;
    height: 100%;
    overflow-y: auto;
    .create-theme{
      width: 120px;
      // padding: 0 20px 0 30px;
      border: 1px solid var(--dm-bd);
      border-radius: 10px;
      height: 35px;
      display: flex;
      justify-content: center;
      align-items: center;
      margin-bottom: 10px;
      cursor: pointer;
      img{
        width: 15px;
      }
      div{
        padding-left: 6px;
        font-size: 15px;
        color: var(--dm-font-2);
      }
    }
    .theme-list-box{
      width: 100%;
      border-radius: 10px;
      padding-left: 15px;
      background-color: var(--dm-bg);
      .theme-item{
        width: 100%;
        height: 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid var(--dm-bd);
        font-size: 16px;
        color: var(--dm-font);
        padding-right: 20px;
        // padding-left: 10px;
        &.self-theme{
          position: relative;
          padding-right: 35px;
          &::after{
            content: '';
            position: absolute;
            background: url('../assets/images/arrow_right.png') 50% 50% no-repeat;
            right: 16px;
            top: 50%;
            background-size: 10px;
            width: 15px;height: 15px;
            transform: translateY(-50%);
          }
        }
        .name{
          position: relative;
          font-weight: 700;
          &.pro{
            padding-right: 5px;
            &::after{
              position: absolute;
              top: 2px;
              left: 100%;
              content: "PRO";
              width: 30px;
              height: 15px;
              text-align: center;
              line-height: 15px;
              font-size: 10px;
              color: #84561D;
              background-color: #F9DF8D;
              border: 1px solid #E7CA7C;
              font-weight: 700;
              border-radius: 5px;
            }
          }
        }
        .theme-con{
          width: 28px;
          height: 28px;
          border-radius: 14px;
          font-weight: 600;
          line-height: 28px;
          text-align: center;
          overflow: hidden;
        }
      }
      .theme-item:last-child{
        border-bottom: none;
      }
    }
  }
}
</style>
