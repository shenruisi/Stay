<template>
  <div class="popup-fotter-wrapper" :class="isMobile?'mobile':'mac'">
    <div class="fotter-box">
      <div class="tab-item" v-for="(item, index) in tabList" :key="index" @click="tabClickAction(item.id)">
        <div class="tab-img" :key="item.name" v-if="item.name == 'matched_scripts_tab'">
          <img src="../assets/images/script-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected" src="../assets/images/script.png" v-else/>
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'darkmode_tab'">
          <img src="../assets/images/dark-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected"  src="../assets/images/dark.png" v-else/>
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'downloader_tab'">
          <img src="../assets/images/download-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected"  src="../assets/images/download.png" v-else/>
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'adblock_tab'">
          <img src="../assets/images/block-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected" src="../assets/images/block.png" v-else/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, toRefs } from 'vue'
import { isMobile } from '../utils/util'
export default {
  name: 'DarkModeComp',
  props: ['tabId'],
  setup (props, {emit, expose}) {
    const state = reactive({
      tabList: [
        {id: 1, selected: 1, name: 'matched_scripts_tab'},
        {id: 2, selected: 0, name: 'darkmode_tab'},
        {id: 3, selected: 0, name: 'downloader_tab'},
        {id: 4, selected: 0, name: 'adblock_tab'}
      ],
      selectedTabId: props.tabId,
      isMobile: isMobile()
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
.mobile{
  height: 72px;
}
.mac{
  height: 60px;
}
.popup-fotter-wrapper{
  width: 100%;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: var(--dm-bg-f6);
  border-top: 1px solid var(--dm-bd);
  z-index: 999;
  transform: translateZ(0px);
  -webkit-transform: translateZ(0px);
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
      .tab-img{
        width: 40px;
        height: 40px;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-shrink: 1;
        overflow: hidden;
        position: relative;
        top: -6px;
        img{
          height: 40px;
          width: 40px;
        }
      }
    }
  }
}
@media (prefers-color-scheme: dark) {
  .popup-fotter-wrapper{
    .fotter-box{
      .tab-item{
        .tab-img{
          img.unselected{
            -webkit-filter: drop-shadow(var(--s-dc) 40px 0);
            filter: drop-shadow(var(--s-dc) 40px 0);
            border-right: 40px solid transparent;
            position: relative;
            left: -20px;
            transform: translateZ(100px);
            z-index: 888;
          }
        }
      }
    }
  }
  
}
</style>
