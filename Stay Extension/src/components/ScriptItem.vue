<template>
  <div class="script-item-box">
    <div class="script-item" :class="{disabled: script.disabledUrl && script.disabledUrl!='' }">
      <div class="script-info" :class="script.active?'activated':'stopped'" :style="{paddingLeft: script.iconUrl?'50px':'0px'}">
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
          <select class="select-container" v-model="script.website" @change='changeSelectWebsite(script.uuid, $event)' >
            <option v-for="(website, i) in websiteList" :key="i" :value="website">{{website}}</option>
          </select>
        </div>
      </div>
      <div class="action-cell"></div>
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
  setup (props, {emit, expose}) {
    const { proxy } = getCurrentInstance();
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const hostName = getHostname(store.state.browserUrl);
    const state = reactive({
      browserUrl: store.state.browserUrl,
      script: {...props.scriptItem, disableChecked:props.scriptItem.disabledUrl?true:false, website: props.scriptItem.disabledUrl?props.scriptItem.disabledUrl:hostName},
      hostName,
      websiteList: [hostName,store.state.browserUrl]
    });

    const intoAppScriptDetail = (uuid) => {
      window.open('stay://x-callback-url/userscript?id='+uuid);
    }
    
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
          console.log('setScriptActive response,',response)
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
      console.log('website------',website);
      emit('handleWebsite', uuid, website);
    }
    const changeWebsiteDisabled = (uuid, website, event) => {
      const disabled = event.target.checked;
      let websiteReq = '';
      if(disabled){
        websiteReq = website;
      }
      state.script.disabledUrl = websiteReq;
      state.script.disableChecked = disabled;
      global.browser.runtime.sendMessage({
        from: 'popup',
        operate: 'setDisabledWebsites',
        uuid: uuid,
        website: websiteReq
      }, (response) => {
        console.log('setDisabledWebsites response,',response)
      })
      console.log('------website---enabled------',event, websiteReq, disabled);
      emit('handleWebsiteDisabled', uuid, websiteReq);
    }
    return {
      ...toRefs(state),
      t,
      tm,
      intoAppScriptDetail,
      activeStateClick,
      disabledUrlClick,
      changeSelectWebsite,
      changeWebsiteDisabled
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
    &.disabled{
      .script-info{
        .state{
          opacity: 0.3;
        }
      }
    }
    .script-info{
      width: 100%;
      height: 40px;
      padding-left: 50px;
      padding-right: 50px;
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
        width: 40px;
        height: 40px;
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
      }
      &.activated{
        .state{
          background: url("../assets/images/stop-icon.png") no-repeat 50% 50%;
          background-size: 50%;
        }
      }
      .author{
        font-size: 16px;
        font-weight: 400;
        color: var(--s-black);
        text-align: left;
        font-family: 'Ping Fang SC';
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
      }


    }
    .website-cell{
      width: 100%;
      display: flex;
      justify-content: start;
      align-items: center;
      position: relative;
      .check-box{
        width: 16px;
        height: 16px;
        z-index: 999;
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
        width: 125px;
        select.select-container{
          width: 100%;
          height: 100%;
          font-size: 13px;
          font-weight: 700;
          color: var(--s-black);
          position: relative;
          appearance:none;  
          -moz-appearance:none;  
          -webkit-appearance:none;  
          background: url("../assets/images/dropdown.png") no-repeat 100% 50%;  
          background-size: 12px;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-box-orient: vertical;
          padding-right: 6px;
          option{
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            width: 100%;
            display: -webkit-box;
          }
        }
      }

    }
    .action-cell{

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
