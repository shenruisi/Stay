<template>
  <div class="popup-fotter-wrapper">
    <div class="fotter-box">
      <div class="tab-item" v-for="(item, index) in tabList" :key="index" @click="tabClickAction(item.id)">
        <template v-if="item.name == 'matched_scripts_tab'">
          <img src="../assets/images/script-sel.png" v-if="item.id == selectedTabId" />
          <img src="../assets/images/script.png" v-else/>
        </template>
        <template v-if="item.name == 'darkmode_tab'">
          <img src="../assets/images/dark-sel.png" v-if="item.id == selectedTabId" />
          <img src="../assets/images/dark.png" v-else/>
        </template>
        <template v-if="item.name == 'downloader_tab'">
          <img src="../assets/images/download-sel.png" v-if="item.id == selectedTabId" />
          <img src="../assets/images/download.png" v-else/>
        </template>
        <template v-if="item.name == 'console_tab'">
          <img src="../assets/images/console-sel.png" v-if="item.id == selectedTabId" />
          <img src="../assets/images/console.png" v-else/>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, toRefs } from 'vue'

export default {
  name: 'DarkModeComp',
  props: ['tabId'],
  setup (props, {emit, expose}) {
    const state = reactive({
      tabList: [
        {id: 1, selected: 1, name: 'matched_scripts_tab'},
        {id: 2, selected: 0, name: 'darkmode_tab'},
        {id: 3, selected: 0, name: 'downloader_tab'},
        {id: 4, selected: 0, name: 'console_tab'}
      ],
      selectedTabId: props.tabId
    });

    const tabClickAction = (tabId) => {
      if (!tabId) {
        return;
      }
      state.selectedTabId = tabId
      state.tabList.forEach(item => {
        if (item.id === tabId) {
          emit('setTabName', item);
        }
      })
    }

    return {
      ...toRefs(state),
      tabClickAction
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-fotter-wrapper{
    width: 100%;
    position: fixed;
    height: 52px;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: var(--s-f6);
    border-bottom: 1px solid var(--s-e0);
    z-index: 999;
    .fotter-box{
      position: relative;
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      .tab-item{
        width: 25%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-shrink: 1;
        img{
            max-height: 20px;
            // object-fit: cover;
        }
      }
    }
  }
</style>
