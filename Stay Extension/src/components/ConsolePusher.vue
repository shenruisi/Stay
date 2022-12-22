<template>
  <div class="popup-console-wrapper">
    <template v-if="scriptConsole.length">
      <div class="console-item" v-for="(item, index) in scriptConsole" :class="item.msgType=='error'?'error-log':''" :key="index">
        <div class="console-header">
          <div class="console-time">{{item.time}}</div>
          <div class="console-name">{{item.name}}</div>
        </div>
        <div class="console-con">{{item.message}}</div>
      </div>
    </template>
    <div v-else>
      
    </div>
  </div>
</template>

<script>
import { reactive, inject, toRefs } from 'vue'
import { useI18n } from 'vue-i18n';


export default {
  name: 'ConsolePusherComp',
  setup (props, {emit, expose}) {
    const global = inject('global');
    const state = reactive({
      scriptConsole: [],
    });

    const fetchMatchedScriptConsole = () => {
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchMatchedScriptLog' }, (response) => {
        // console.log('fetchMatchedScriptLog response----', response)
        if (response && response.body && response.body.length > 0) {
          response.body.forEach(item => {
            if (item.logList && item.logList.length > 0) {
              item.logList.forEach(logMsg => {
                let logType = logMsg.msgType ? logMsg.msgType : 'log'
                let dateTime = logMsg && logMsg.time ? logMsg.time : ''
                let data = {
                  uuid: item.uuid,
                  name: item.name,
                  time: dateTime,
                  msgType: logType,
                  message: logMsg.msg
                };
                state.scriptConsole.push(data)
              })
            }
          })
        } else {
          state.scriptConsole = [];
        }
      })
    }

    fetchMatchedScriptConsole();

    return {
      ...toRefs(state)
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-console-wrapper{
    width: 100%;
    height: 100%;
    padding-left: 10px;
    .error-log .console-con{
      color: #f81948;
    }
    .console-item{
      width: 100%;
      /* display: flex; */
      /* flex-direction: row; */
      padding: 10px 0;
      /* justify-content: space-between; */
      padding: 10px 10px 10px 0;
      border-bottom: 1px solid #E0E0E0;
    }
    .console-con{
      /* display: flex; */
      text-align: left;
      color: #000000;
      font-size: 13px;
      line-height: 17px;
    }
    .console-header{
      display: flex;
      flex-direction: row;
      justify-content: space-between;
    }
    .console-time{
      text-align: left;
      white-space: nowrap;
      color: rgba(0,0,0,0.5);
      font-size: 13px;
      padding-bottom: 4px;
    }
    .console-name{
      /* display: flex; */
      /* flex: auto 1; */
      text-align: right;
      white-space: pre-wrap;
      color: rgba(0,0,0,0.5);
      font-size: 13px;
      padding-bottom: 4px;
    }

    .console-item:last-child{
      border-bottom: none;
    }
  }
</style>
