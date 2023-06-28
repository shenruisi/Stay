<template>
  <div class="popup-fotter-wrapper" ref="fotterRef" :class="isMobile?'mobile':'mac'">
    <div class="fotter-box">
      <div class="tab-item" v-for="(item, index) in tabList" :key="index" @click="tabClickAction(item.id)">
        <div class="tab-img" :key="item.name" v-if="item.name == 'matched_scripts_tab'">
          <div class="selected-script" v-if="item.id == selectedTabId" ></div>
          <div class="unselected-script" v-else ></div>
          <!-- <img src="../assets/images/script-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected" src="../assets/images/script.png" v-else/> -->
          <!-- <img class="unselected" src="../assets/images/tab-userscript-dark.png" v-else/> -->
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'darkmode_tab'">
          <div class="selected-darkmode" v-if="item.id == selectedTabId" ></div>
          <div class="unselected-darkmode" v-else ></div>
          <!-- <img src="../assets/images/dark-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected"  src="../assets/images/dark.png" v-else/> -->
          <!-- <img class="unselected"  src="../assets/images/tab-darkmode-dark.png" v-else/> -->
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'downloader_tab'">
          <div class="selected-downloader" v-if="item.id == selectedTabId" ></div>
          <div class="unselected-downloader" v-else ></div>
          <!-- <img src="../assets/images/download-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected"  src="../assets/images/download.png" v-else/> -->
          <!-- <img class="unselected"  src="../assets/images/tab-download-dark.png" v-else/> -->
        </div>
        <div class="tab-img" :key="item.name" v-if="item.name == 'adblock_tab'">
          <div class="selected-adblock" v-if="item.id == selectedTabId" ></div>
          <div class="unselected-adblock" v-else ></div>
          <!-- <img src="../assets/images/block-sel.png" v-if="item.id == selectedTabId" />
          <img class="unselected" src="../assets/images/block.png" v-else/> -->
          <!-- <img class="unselected" src="../assets/images/tab-block-dark.png" v-else/> -->
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, toRefs, ref, onMounted } from 'vue'
import { isMobile } from '../utils/util'
export default {
  name: 'DarkModeComp',
  props: ['tabId'],
  setup (props, {emit, expose}) {
    const state = reactive({
      tabList: [
        {id: 1, selected: 1, name: 'matched_scripts_tab', whatisurl: '', whatistitle:''},
        {id: 2, selected: 0, name: 'darkmode_tab', whatisurl: 'https://www.craft.do/s/PHKJvkZL92BTep', whatistitle:'what_darkmode'},
        {id: 3, selected: 0, name: 'downloader_tab', whatisurl: 'https://www.craft.do/s/sYLNHtYc0n2rrV', whatistitle:'what_downloader'},
        {id: 4, selected: 0, name: 'adblock_tab', whatisurl: 'https://www.craft.do/s/nmtd0ZD3a9Z48w', whatistitle:'what_adblock'}
      ],
      selectedTabId: props.tabId,
      isMobile: isMobile()
    });
    const fotterRef = ref(null);

    onMounted(()=>{
      let mountedTimer = setTimeout(() => {
        fotterRef.value.style = '-webkit-backdrop-filter: blur(16px) saturate(150%)';
        clearTimeout(mountedTimer);
        mountedTimer = null;
      }, 800)
    })

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
      fotterRef,
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
  background-color: var(--dm-bg-f6drop);
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 999;
  transform: translateZ(0px);
  -webkit-transform: translateZ(0px);
  border-top: 1px solid var(--dm-bd);
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
      -webkit-user-select: none;
      -moz-user-select: none;
      -ms-user-select: none;
      user-select: none;
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
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
        z-index: 999;
        .selected-script{
          width: 40px;
          height: 40px;
          background: url("../assets/images/script-sel.png") no-repeat 50% 50%;
          background-size: 100%;

        }
        .selected-darkmode{
          width: 40px;
          height: 40px;
          background: url("../assets/images/dark-sel.png") no-repeat 50% 50%;
          background-size: 100%;
        }
        .selected-downloader{
          width: 40px;
          height: 40px;
          background: url("../assets/images/download-sel.png") no-repeat 50% 50%;
          background-size: 100%;
          
        }
        .selected-adblock{
          width: 40px;
          height: 40px;
          background: url("../assets/images/block-sel.png") no-repeat 50% 50%;
          background-size: 100%;
        }
        .unselected-script{
          width: 40px;
          height: 40px;
          background: url("../assets/images/script.png") no-repeat 50% 50%;
          background-size: 100%;

        }
        .unselected-darkmode{
          width: 40px;
          height: 40px;
          background: url("../assets/images/dark.png") no-repeat 50% 50%;
          background-size: 100%;
        }
        .unselected-downloader{
          width: 40px;
          height: 40px;
          background: url("../assets/images/download.png") no-repeat 50% 50%;
          background-size: 100%;
          
        }
        .unselected-adblock{
          width: 40px;
          height: 40px;
          background: url("../assets/images/block.png") no-repeat 50% 50%;
          background-size: 100%;
        }
        img{
          height: 40px;
          width: 40px;
          -webkit-user-select: none;
          -moz-user-select: none;
          -ms-user-select: none;
          user-select: none;
          z-index: 999;
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
            -webkit-filter: drop-shadow(#DCDCDC 40px 0);
            filter: drop-shadow(#DCDCDC 40px 0);
            border-right: 40px solid transparent;
            position: relative;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            left: -20px;
            z-index: 888;
          }
          .unselected-script{
            background: url("../assets/images/tab-userscript-dark.png") no-repeat 50% 50%;
            background-size: 100%;

          }
          .unselected-darkmode{
            background: url("../assets/images/tab-darkmode-dark.png") no-repeat 50% 50%;
            background-size: 100%;
          }
          .unselected-downloader{
            background: url("../assets/images/tab-download-dark.png") no-repeat 50% 50%;
            background-size: 100%;
            
          }
          .unselected-adblock{
            background: url("../assets/images/tab-block-dark.png") no-repeat 50% 50%;
            background-size: 100%;
          }
        }
      }
    }
  }
  
}
</style>
