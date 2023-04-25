<template>
  <div class="popup-adblock-wrapper">
    <div class="adblock-manage">
      <div class="manage-info">
        <div class="title">{{  t('taging_manage_title') }}</div>
        <div class="block-status" :class="blockStatus=='on'?'block-on':'block-off'">{{ blockStatusText }}</div>
      </div>
      <div class="manage-btn" @click="tagToManageClick">{{  t('taging_manage_btn') }}</div>
    </div>
    <div class="taging-status" @click="tagingStatusClick">{{  t('taging_status_btn') }}</div>
    <div class="three-finger-switch"  v-if="isMobileOrIpad">
      <div class="switch-text">{{  t('taging') }}</div>
      <div class="switch" :class="threeFingerTapStatus=='on'?'switch-on':'switch-off'" @click="threeFingerSwitchClick">{{ threeFingerTapSwitch }}</div>
    </div>
  </div>
</template>
<script>
import { reactive, inject, toRefs } from 'vue'
import { isMobileOrIpad } from '../utils/util'
import { useI18n } from 'vue-i18n';
    
    
export default {
  name: 'AdBlockComp',
  setup (props, {emit, expose}) {
    const global = inject('global');
    const store = global.store;
    const { t, tm } = useI18n();
    const state = reactive({
      scriptConsole: [],
      blockStatus: store.state.blockStatus,
      blockStatusText: store.state.blockStatus == 'on' ? t('state_actived'):t('state_stopped'),
      isMobileOrIpad: isMobileOrIpad(),
      tagingStatus: '',
      threeFingerTapStatus: store.state.threeFingerTapStatus,
      threeFingerTapSwitch: store.state.threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off'),
    });

    const threeFingerSwitchClick = () => {
      // console.log('threeFingerSwitchClick====')
      if(state.threeFingerTapStatus == 'on'){
        state.threeFingerTapStatus = 'off';
      }else{
        state.threeFingerTapStatus = 'on';
      }
      state.threeFingerTapSwitch = state.threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off');
      store.commit('setThreeFingerTapStatusAsync', state.threeFingerTapStatus);

      global.browser.tabs.query({
        active: true,
        currentWindow: true
      }, (tabs) => {
        const message = { from: 'popup', operate: 'pushThreeFingerTapStatus', type: 'popup', threeFingerTapStatus:state.threeFingerTapStatus}
        global.browser.tabs.sendMessage(tabs[0].id, message, response => {
          console.log('setThreeFingerTapStatus====',response);
        })
      })

      
     
    }

    const fetchTagingStatus = () => {
      // global.browser.runtime.sendMessage({ from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
      //   console.log('getMakeupTagStatus====',response);
      //   let makeupTagStatus = response.makeupTagStatus ? response.makeupTagStatus : 'on';
      //   state.tagingStatus = makeupTagStatus;
      // })
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'getThreeFingerTapStatus'}, (response) => {
        console.log('getThreeFingerTapStatus====',response);
        let threeFingerTapStatus = response.threeFingerTapStatus ? response.threeFingerTapStatus : 'on';
        state.threeFingerTapStatus = threeFingerTapStatus;
        state.threeFingerTapSwitch = threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off');
        store.commit('setThreeFingerTapStatusAsync', state.blockStatus);
      })
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'getBlockStatus'}, (response) => {
        console.log('getBlockStatus====',response);
        let blockStatus = response&&response.blockStatus ? response.blockStatus : 'on';
        state.blockStatus = blockStatus;
        store.commit('setBlockStatusAsync', state.blockStatus);
        state.blockStatusText = blockStatus == 'on' ? t('state_actived'):t('state_stopped');
      })
    }

    fetchTagingStatus();

    const tagingStatusClick = () => {
      global.browser.tabs.query({
        active: true,
        currentWindow: true
      }, (tabs) => {
        const message = { from: 'popup', operate: 'startMakeupTagStatus', makeupTagStatus: 'on', type: 'popup'};
        global.browser.tabs.sendMessage(tabs[0].id, message, response => {
          console.log('setMakeupTagStatus====',response);
          window.close();
        })

      })
      
      // global.browser.runtime.sendMessage({ from: 'popup', operate: 'setMakeupTagStatus', makeupTagStatus: state.tagingStatus, type: 'popup'}, (response) => {
      //   console.log('setMakeupTagStatus====',response);
      //   window.close();
      // })
    }

    const tagToManageClick = () => {
      let openUrl = 'stay://x-callback-url/block';
      global.openUrlInSafariPopup(openUrl);
    }
    
    
    
    return {
      ...toRefs(state),
      t,
      threeFingerSwitchClick,
      tagingStatusClick,
      tagToManageClick,
    };
  }
}
</script>
    
<style lang="less" scoped>
  .popup-adblock-wrapper{
    width: 100%;
    height: 100%;
    padding: 10px;
    .adblock-manage{
      background-color: var(--dm-bg);
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
      width: 100%;
      padding: 0 13px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border: 1px solid var(--dm-bd);
      border-radius: 10px;
      margin-bottom: 15px;
      margin-top: 15px;
      height: 70px;
      .manage-info{
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: flex-start;
        height: 46px;
        .title{
          color: var(--dm-font);
          font-size: 16px;
          font-weight: 400;
        }
        .block-status{
          font-size: 13px;
          position: relative;
          padding-left: 20px;
          &::after{
            content: '';
            position: absolute;
            left: 0px;
            width: 10px;
            height: 10px;
            top: 50%;
            transform: translateY(-50%);
            object-fit: contain;
            border-radius: 50%;
          }
        }
        .block-on{
          &::after{
            background: var(--s-main);
          }
        }
        .block-off{
          &::after{
          background: var(--dm-bd);
          }
        }
      }
      .manage-btn{
        width: 90px;
        height: 25px;
        line-height: 23px;
        border-radius: 8px;
        border: 1px solid var(--s-main);
        font-size: 13px;
        color: var(--s-main);
      }
    }
    .taging-status{
      width: 100%;
      height: 45px;
      line-height: 45px;
      text-align: center;
      font-size: 16px;
      font-weight: 700;
      border-radius: 10px;
      color: var(--s-main);
      border: 1px solid var(--s-main);
      margin-bottom: 18px;
    }
    .three-finger-switch{
      width: 90%;
      position: fixed;
      z-index: 999;
      bottom: 90px;
      height: 42px;
      border-radius: 8px;
      left: 5%;
      border: 1px solid var(--dm-bd);
      background-color: var(--dm-bg-f7);
      display: flex;
      padding: 0 20px;
      justify-content: center;
      justify-items: center;
      align-items: center;
      user-select: none;
      .switch-text{
        width: 80%;
        text-align: left;
        color: var(--dm-font);
        height: 100%;
        display: flex;
        align-items: center;
        user-select: none;
      }
      .switch{
        width: 20%;
        color: var(--dm-font-2);
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        user-select: none;
        position: relative;
        &::after{
          content: '';
          position: absolute;
          right: 0px;
          /* background: url(../img/option.png) 50% 50% no-repeat; */
          /* background-size: 50%; */
          width: 10px;
          height: 10px;
          top: 50%;
          transform: translateY(-50%);
          object-fit: contain;
          border-radius: 50%;
        }
      }
      .switch-on{
        &::after{
          background: var(--s-main);
        }
      }
      .switch-off{
        &::after{
          background: var(--dm-bd);
        }
      }
    }
  }
</style>
    