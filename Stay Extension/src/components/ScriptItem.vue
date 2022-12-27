<template>
  <div class="script-item-box" >
    <div class="script-item" :class="{disabled: script.disabledUrl && script.disabledUrl!='' }">
      <div class="script-info" :class="script.active?'activated':'stopped'" :style="{paddingLeft: script.iconUrl?'60px':'0px'}">
        <div class="script-icon" v-if="script.iconUrl">
          <img :src="script.iconUrl" />
        </div>
        <div class="active-state state" @click="activeStateClick(script)"></div>
        <div class="author overflow">{{script.author+"@"+script.name}}</div>
        <div class="desc overflow">{{script.description}}</div>
      </div>
      <div class="website-cell">
        <div class="check-box" :class="{ active: script.disabledUrl}" >
          <input :ref="script.uuid" v-model="script.disableChecked" 
          @change='changeWebsiteDisabled(script.uuid, script.website, $event)' type="checkbox" class="allow" />
        </div>
        <div class="website"  @click="disabledUrlClick(script.uuid)">{{t("disable_website")}}</div>
        <div class="select-options">
          <div class="selected-text">{{script.website}}</div>
          <select class="select-container" v-model="script.website" @change='changeSelectWebsite(script.uuid, $event)' >
            <option v-for="(website, i) in websiteList" :key="i" :value="website">{{website}}</option>
          </select>
        </div>
      </div>
      <div class="action-cell">
        <div class="cell-icon menu" v-if="script.grants.length && (script.grants.includes('GM.registerMenuCommand') || script.grants.includes('GM_registerMenuCommand'))" @click="showRegisterMenu(script.uuid, script.active)">{{t("menu")}}</div>
        <div class="cell-icon manually" v-if="!script.active" @click="runManually(script.uuid, script.name)">{{t("run_manually")}}</div>
        <div class="cell-icon open-app" @click="openInAPP(script.uuid)">{{t("open_app")}}</div>
      </div>
    </div>
    
  </div>
</template>

<script>
import { reactive, ref, getCurrentInstance, inject, toRefs } from 'vue'
import { useI18n } from 'vue-i18n';
import { getHostname } from '../utils/util'



export default {
  name: 'ScriptItemComp',
  props: ['scriptItem'],
  components: {
  },
  setup (props, {emit, expose}) {
    const { proxy } = getCurrentInstance();
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const hostName = getHostname(store.state.browserUrl);
    const origin = new URL(store.state.browserUrl).origin;
    const state = reactive({
      browserUrl: store.state.browserUrl,
      script: {...props.scriptItem, disableChecked:props.scriptItem.disabledUrl?true:false, website: props.scriptItem.disabledUrl?props.scriptItem.disabledUrl:hostName},
      hostName,
      websiteList: [origin,store.state.browserUrl],
      showMenu: false
    });
    
    const activeStateClick = (scriptItem) => {
      if(scriptItem.disabledUrl){
        return;
      }
      let uuid = scriptItem.uuid;
      let active = scriptItem.active;
      if (uuid && uuid != '' && typeof uuid == 'string') {
        global.browser.runtime.sendMessage({
          from: 'popup',
          operate: 'setScriptActive',
          uuid: uuid,
          active: !active
        }, (response) => {
          // console.log('setScriptActive response,',response)
        })
        state.script.active = !active;
        refreshTargetTabs();
        emit('handleState', uuid, !active);
      }
    }
    /**
     * 刷新页面
     * 当启动脚本时，调用
     */
    const refreshTargetTabs = () => {
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'refreshTargetTabs'});
    }
    const disabledUrlClick = (refId) => {
      // console.log('disabledUrlClick----', refId, proxy.$refs);
      proxy.$refs[refId].dispatchEvent(new MouseEvent('click'));
    }
    const changeSelectWebsite = (uuid, event) => {
      const website = event.target.value;
      disabledUrlToReq(uuid, state.script.disableChecked, state.script.disabledUrl);
      // console.log('website------',website);
      emit('handleWebsite', uuid, website);
    }
    const changeWebsiteDisabled = (uuid, website, event) => {
      const disabled = event.target.checked;
      let websiteReq = website;
      state.script.disabledUrl = websiteReq;
      state.script.disableChecked = disabled;
      disabledUrlToReq(uuid, disabled, websiteReq);
      // console.log('------website---enabled------',event, websiteReq, disabled);
      emit('handleWebsiteDisabled', uuid, websiteReq);
    }

    const disabledUrlToReq = (uuid, disabled, websiteReq) => {
      global.browser.runtime.sendMessage({
        from: 'popup',
        operate: 'setDisabledWebsites',
        on: disabled,
        uuid: uuid,
        website: websiteReq
      }, (response) => {
        console.log('setDisabledWebsites response,',response)
      })
    }
    
    const openInAPP = (uuid) => {
      window.open('stay://x-callback-url/userscript?id='+uuid);
    }

    const showRegisterMenu = (uuid, active) => {
      if(active){
        // console.log('showRegisterMenu------',uuid, active);
        // state.showMenu = true;
        global.browser.runtime.sendMessage({ from: 'popup', uuid: uuid, operate: 'fetchRegisterMenuCommand' });
        emit('handleRegisterMenu', uuid);
      }else{
        global.toast(t('toast_keep_active'))
      }
    }

    const runManually = (uuid, name) => {
      if (uuid && uuid != '' && typeof uuid == 'string') {
        global.browser.runtime.sendMessage({
          from: 'popup',
          operate: 'exeScriptManually',
          uuid: uuid,
        }, (response) => {
          console.log('exeScriptManually response,', response)
        });
        // // 改变数据manually状态
        // scriptStateList.forEach(function (item, index) {
        //   if (uuid == item.uuid) {
        //     item.manually = "1";
        //   }
        // })
        // renderScriptContent(scriptStateList)
        global.toast({title: name, subTitle: t('run_manually')})
        
      }
    }
    return {
      ...toRefs(state),
      t,
      tm,
      activeStateClick,
      disabledUrlClick,
      changeSelectWebsite,
      changeWebsiteDisabled,
      showRegisterMenu,
      runManually,
      openInAPP
    };
  }
}
</script>

<style lang="less" scoped>
.script-item-box{
  width: 100%;
  padding: 10px 0 0 10px;
  .script-item{
    width: 100%;
    border-bottom: 1px solid var(--s-e0);
    background-color: var(--s-white);
    user-select: none;
    padding-bottom: 6px;
    &.disabled{
      .script-info{
        .state{
          opacity: 0.3;
        }
      }
    }
    .script-info{
      width: 100%;
      height: 48px;
      padding-left: 60px;
      padding-right: 60px;
      position: relative;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: start;
      flex: 1;
      .script-icon{
        position: absolute;
        left: 0;
        top: 0;
        width: 48px;
        height: 48px;
        border: 0.5px solid var(--s-e0);
        border-radius: 8px;
        padding: 8px;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-shrink: 0;
        img{
          max-width: 100%;
          max-height: 100%;
          border-radius: 4px;
        }
      }
      .active-state{
        position: absolute;
        right: 0;
        top: 0;
        width: 40px;
        height: 40px;
      }
      &.stopped{
        .state{
          background: url("../assets/images/start-icon.png") no-repeat 50% 50%;
          background-size: 40%;
        }
        .author{
          opacity: 0.7;
        }
        .desc{
          opacity: 0.7;
        }
      }
      &.activated{
        .state{
          background: url("../assets/images/stop-icon.png") no-repeat 50% 50%;
          background-size: 50%;
        }
      }
      .author{
        font-size: 16px;
        font-weight: 700;
        color: var(--s-black);
        text-align: left;
        // padding-top: 8px;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        // line-height: 20px;
      }
      .overflow{
        width: 100%;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        white-space: nowrap;
      }
      .desc{
        font-size: 13px;
        color: var(--s-8a);
        font-weight: 400;
        text-align: left;
        line-height: 17px;
        padding-top: 4px;
      }


    }
    .website-cell{
      width: 100%;
      display: flex;
      justify-content: start;
      align-items: center;
      position: relative;
      padding: 4px 0 2px 0;
      .check-box{
        width: 16px;
        height: 16px;
        z-index: 889;
        display: flex;
        justify-content: center;
        align-items: center;
      }
      .check-box input.allow{
        cursor: pointer;
        position: relative;
        width: 14px;
        height: 14px;
        background: #fff;
        color: #000000;
      }
      input[type='checkbox']:disabled::after {
        opacity: 0.4;
      }
      input[type=checkbox]::after {
        position: absolute;
        top: 0px;
        right: 0px;
        background: #fff;
        color: #fff;
        height: 14px;
        width: 14px;
        display: inline-block;
        visibility: visible;
        text-align: center;
        content: '';
        border-radius: 2px;
        box-sizing: border-box;
        border: 1px solid #B620E0;
      }
      input[type='checkbox']:checked::after {
        content: '✓';
        font-size: 12px;
        line-height: 12px;
        font-weight: bold;
        font-family: -apple-system;
        color: #ffffff;
        background-color: #B620E0;
      }
      .website{
        font-size: 13px;
        color: var(--s-black);
        font-weight: 400;
        padding: 0 5px;
      }
      .select-options{
        height: 24px;
        width: 200px;
        position: relative;
        text-align: left;
        .selected-text{
          max-width: 100%;
          min-width: 60px;
          height: 24px;
          line-height: 24px;
          z-index: 555;
          font-size: 13px;
          font-weight: 700;
          color: var(--s-black);
          position: relative;
          appearance:none;  
          -moz-appearance:none;  
          -webkit-appearance:none;  
          overflow: hidden;
          text-overflow: ellipsis;
          display: inline-block;
          -webkit-box-orient: vertical;
          padding-right: 16px;
          text-align: center;
          &::after{
            background: url("../assets/images/dropdown.png") no-repeat 50% 50%;  
            background-size: 12px;
            content: "";
            position: absolute;
            right: 0;
            top: 50%;
            transform: translate(0, -50%);
            width: 12px;
            height: 12px;
          }
        }
        select.select-container{
          width: 100%;
          height: 100%;
          left: 0;
          top: 0;
          position: absolute;
          background: transparent !important;
          color: transparent !important;
          z-index: 777;
        }
      }

    }
    .action-cell{
      width: 100%;
      padding: 2px 0;
      display: flex;
      justify-content: start;
      align-items: center;
      position: relative;
      .cell-icon{
        position: relative;
        height: 24px;
        line-height: 24px;
        margin-right: 4px;
        padding-left: 30px;
        padding-right: 8px;
        font-family: Helvetica Neue;
        font-size: 13px;
        color: var(--s-main);
        font-weight: 700;
        border-radius: 8px;
        background-color: var(--s-f7);
      }
      .menu{
        &::before{
          position:absolute;
          left: 6px;
          top: 50%;
          transform: translate(0, -50%);
          content: "";
          width: 19px;
          height: 19px;
          background: url("../assets/images/menu.png") no-repeat 50% 50%;
          background-size: contain;
        }
      }
      .manually::after{
        position:absolute;
        left: 6px;
        top: 50%;
        transform: translate(0, -50%);
        content: "";
        width: 19px;
        height: 19px;
        background: url("../assets/images/manaully.png") no-repeat 50% 50%;
        background-size: contain;
      }
      .open-app::after{
        position:absolute;
        left: 6px;
        top: 50%;
        transform: translate(0, -50%);
        content: "";
        width: 19px;
        height: 19px;
        background: url("../assets/images/openinapp.png") no-repeat 50% 50%;
        background-size: contain;

      }

    }
  }
  
}
@media (prefers-color-scheme: dark) {
  .script-item-box{
    .script-item{
      .script-info{
        .activated{
          .state{
            background: url("../assets/images/stop-dark.png");
          }
        }
      }
    }
  }
}
</style>
