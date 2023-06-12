<template>
  <div class="popup-sniffer-wrapper" :style="{paddingBottom:isMobile?'60px':'0'}">
    <div class="sniffer-video-box" v-if="videoList && videoList.length">
      <div class="sniffer-video" v-for="(item, index) in videoList" :key="index">
        <div class="video-info">
          <div class="img-info">
            <div class="video">
              <img :src="item.poster" v-if="item.poster"/>
              <div class="no-img" v-else>
                <span>{{ getDomain(item.hostUrl) }}</span>
              </div>
            </div>
            <div class="info">
              <div class="title">{{getHostname(item.hostUrl)}}</div>
              <div class="name" v-html="item.title"></div>
            </div>
          </div>
          <div class="download"><div class="btn" @click="downloadClickAction(item)">{{item.type=='ad'? (t("download") + ' ' + t("ad")) : t("download") }}</div></div>
        </div>
        <div class="video-download-info">
          <div class="label-txt">{{ t("save_to_folder") }}&nbsp;:</div>
          <div class="folder select-options">
            <div class="selected-text" >{{item.selectedFolderText}}</div>
            <select class="select-container" :ref="`folder_${index}`"  v-model="item.selectedFolder" @change="changeSelectFolder(index, $event)">
              <option v-for="(o, i) in folderOptions" :style="{display: o.id?'block':'none'}" :name="o.name" :key="i" :value="o.uuid">{{o.name}}</option>
            </select>
          </div>
          <template v-if="(item.qualityList && item.qualityList.length)">
            <div class="label-txt">{{ t("quality") }}&nbsp;:</div>
            <div class="quality select-options">
              <div class="selected-text" >{{item.selectedQualityText}}</div>
              <select class="select-container" :ref="`quality_${index}`" v-model="item.selectedQuality" @change="changeSelectQuality(index, $event)">
                <!-- {downloadUrl, qualityLabel, quality } -->
                <option v-for="(o, i) in item.qualityList" :key="i" :name="o.qualityLabel" :value="o.downloadUrl">{{o.qualityLabel}}</option>
              </select>
            </div>
          </template>
        </div>
      </div>
    </div>
    <div class="sniffer-null" v-else>
      <div class="null-title">{{ t('sniffer_none') }}</div>
      <div class="desc-prompt">{{t('sniffer_none_prompt')}}
        <span class="mail-to" @click="contactClick">{{t('contact_us')}}</span>
      </div>
    </div>
    <div class="long-press-switch"  v-if="isMobile">
      <div class="switch-text">{{  t('longpress') }}</div>
      <!-- <div class="switch" :class="longPressStatusRes=='on'?'switch-on':'switch-off'" @click="longPressSwitchClick">{{ longPressSwitch }}</div> -->
      <SwitchComp class="switch" :switchStatus="threeFingerTapStatus" @switchAction="longPressSwitchClick"></SwitchComp>
    </div>
  </div>
</template>

<script>
import { reactive, getCurrentInstance, inject, toRefs, watch } from 'vue'
import { getDomain, getHostname, getFilenameByUrl, getLevel2domain, getFiletypeByUrl, isMobile } from '../utils/util'
import { useI18n } from 'vue-i18n';
import store from '../store';
import SwitchComp from './SwitchComp.vue';
export default {
  name: 'SnifferComp',
  props: ['browserUrl', 'longPressStatus'],
  components:{SwitchComp},
  setup (props, {emit, expose}) {
    const { proxy } = getCurrentInstance();
    const { t, tm } = useI18n();
    const global = inject('global');
    const state = reactive({
      selectedFolder: '',
      selectedFolderText: '',
      folderOptions: [{name: t('select_folder'), uuid: ''}, {name:'download_video', id: '1'},{name:'stay-download-video', id: '2'}],
      videoList: [
        // {
        //   poster: 'https://f7.baidu.com/it/u=3855037150,2522612002&fm=222&app=108&f=JPEG',
        //   downloadUrl: 'https://vd2.bdstatic.com/mda-nkea4tasr6ur1ykf/cae_h264/1668497008894896459/mda-nkea4tasr6ur1ykf.mp4',
        //   title: '美国军机飞抵台海已人困马乏，赖岳谦：若开战会被解放军碾压',
        //   qualityList:[],
        //   selectedQuality: ''
        // }
      ],
      // longPressSwitch: props.longPressStatus == 'on' ? t('switch_on') : t('switch_off'),
      threeFingerTapStatus: props.longPressStatus,
      isMobile: isMobile()
    });

    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.browserUrl = newProps.browserUrl;
        state.threeFingerTapStatus = newProps.longPressStatus;
        // state.longPressSwitch = newProps.longPressStatus == 'on' ? t('switch_on') : t('switch_off');
      },
      { immediate: true, deep: true }
    );
    const fetchSnifferFolder = () => {
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchFolders'}, (response) => {
        // console.log('fetchSnifferFolder---response-----', response);
        try {
          if(response.body){
            state.folderOptions = [{name: t('select_folder'), uuid: ''}, ...response.body];
            response.body.forEach(item => {
              if(item.selected){
                state.selectedFolder = item.uuid;
                state.selectedFolderText = item.name;
              }
            });
            snifferFetchVideoInfo();
          }else{
            // state.folderOptions = [];
          }
        } catch (e) {
          console.log(e);
        }
      });
    }

    fetchSnifferFolder();

    const snifferFetchVideoInfo = () => {
      global.browser.tabs.query({
        active: true,
        currentWindow: true
      }, (tabs) => {
        // console.log('--------global.browser.tabs.--snifferFetchVideoInfo-');
        let message = { from: 'popup', operate: 'snifferFetchVideoInfo'};
        global.browser.tabs.sendMessage(tabs[0].id, message, response => {
          // console.log('snifferFetchVideoInfo---response-----', response);
          if(response.body && response.body.videoInfoList && response.body.videoInfoList.length){
            let videoList = response.body.videoInfoList;
            videoList.forEach(item=>{
              item.selectedFolder = state.selectedFolder;
              item.selectedFolderText = state.selectedFolderText;
              if(item.qualityList && item.qualityList.length ){
                item.qualityList.forEach(quality=>{
                  if(item.downloadUrl == quality.downloadUrl){
                    item.selectedQuality = quality.downloadUrl;
                    item.selectedQualityText = quality.qualityLabel;
                    item.audioUrl = quality.audioUrl;
                  }
                })
                if(!item.selectedQuality){
                  item.selectedQuality = item.qualityList[0].downloadUrl;
                  item.selectedQualityText = item.qualityList[0].qualityLabel;
                  item.audioUrl = item.qualityList[0].audioUrl;
                }
              }
            });
            state.videoList = videoList;
          }else{
            state.videoList = [];
          }
          
        })
      })
    }

    /**
     * title:xxx,
     * hostUrl:xxx,
     * downloadUrl:xxx,
     * poster:xxx 
     * uuid:xxx
     * title:xxx,
     * 
     * stay://x-callback-url/snifferVideo?list=encodeURIComponent([{hostUrl,title,icon,downloadUrl}])
     */
    const downloadClickAction = (item) => {
      if(!item.selectedFolder){
        global.toast(t('select_folder'));
        return;
      }
      if(item.selectedQuality){
        item.downloadUrl = item.selectedQuality;
      }
      let list = [{title:item.title, downloadUrl: item.downloadUrl, poster: item.poster, hostUrl: getHostname(item.hostUrl), uuid: item.selectedFolder, audioUrl: item.audioUrl?item.audioUrl:'', protect: item.protect?item.protect:false, qualityLabel: item.selectedQualityText }];
      console.log(list);
      let downloadUrl = 'stay://x-callback-url/snifferVideo?list='+encodeURIComponent(JSON.stringify(list));
      global.openUrlInSafariPopup(downloadUrl);
    }
    const changeSelectFolder = (index, event) => {
      const selectOpt = event.target;
      // console.log(selectOpt);
      state.videoList.forEach((item, i)=>{
        if(index == i){
          item.selectedFolder = selectOpt.value;
          item.selectedFolderText = selectOpt.options[selectOpt.selectedIndex].text;
        }
      })

    }
    const changeSelectQuality = (index, event) => {
      const selectOpt = event.target;
      console.log(selectOpt, selectOpt.value, selectOpt.selectedIndex, selectOpt.options);
      state.videoList.forEach((item, i)=>{
        if(index == i){
          let qualityList = item.qualityList;
          console.log('item.qualityList-------',qualityList)
          item.selectedQuality = selectOpt.value;
          let qualityIndex = selectOpt.selectedIndex;
          item.selectedQualityIndex = qualityIndex;
          item.audioUrl = qualityList[qualityIndex].audioUrl;
          item.protect = qualityList[qualityIndex].protect;
          item.selectedQualityText = selectOpt.options[qualityIndex].text;
        }
      })
    }

    const contactClick = () => {
      global.openUrlInSafariPopup(`mailto:feedback@fastclip.app?subject=${t('sniffer_none')}&body=${encodeURIComponent(props.browserUrl)}`);
    }

    const longPressSwitchClick = () => {
      // console.log('longPressSwitchClick====')
      if(state.threeFingerTapStatus == 'on'){
        state.threeFingerTapStatus = 'off';
      }else{
        state.threeFingerTapStatus = 'on';
      }
      store.commit('setLongPressStatus', state.threeFingerTapStatus);
      global.browser.runtime.sendMessage({ from: 'popup', longPressStatus: state.threeFingerTapStatus, operate: 'setLongPressStatus'}, (response) => {
        // console.log('longPressSwitchClick----response',response)
        if(response){
          global.browser.runtime.sendMessage({ from: 'popup', operate: 'refreshTargetTabs'});
        }
      });
    }

    return {
      ...toRefs(state),
      t,
      tm,
      getDomain,
      getHostname,
      getFilenameByUrl,
      getLevel2domain,
      getFiletypeByUrl,
      downloadClickAction,
      changeSelectQuality,
      changeSelectFolder,
      contactClick,
      longPressSwitchClick,
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-sniffer-wrapper{
    width: 100%;
    height: 100%;
    // user-select: none;
    .sniffer-null{
      width: 100%;
      padding: 40px 10px;
      font-size: 16px;
      font-weight: 400;
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      cursor: default;
      .null-title{
        color: var(--dm-font);
      }
      .desc-prompt{
        // color: var(--s-7a);
        color: var(--dm-font-2);
        font-size: 15px;
        line-height: 25px;
        cursor: default;
        .mail-to{
          display: inline;
          text-decoration: underline;
          color: var(--dm-font);
          font-weight: 700;
          padding-left: 2px;
          cursor: default;
        }
      }
    }
    .long-press-switch{
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
      padding: 0 80px 0 20px;
      justify-content: center;
      justify-items: center;
      align-items: center;
      user-select: none;
      .switch-text{
        width: 100%;
        color: var(--dm-font);
        height: 100%;
        display: flex;
        align-items: center;
        user-select: none;
      }
      .switch{
        position: absolute;
        right: 8px;
        top: 50%;
        transform: translateY(-50%);
      }
      
    }
    .sniffer-video-box{
      padding: 0px 0 0px 10px;
      width: 100%;
      .sniffer-video{
        width: 100%;
        padding-top: 10px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        justify-items: center;
        border-bottom: 0.5px solid var(--dm-bd);
        flex: 1;
        .video-info{
          display: flex;
          flex-direction: row;
          width: 100%;
          height: 65px;
          justify-items: center;
          align-items: center;
          padding-bottom: 4px;
          padding-right: 110px;
          position: relative;
          user-select: none;
          .img-info{
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            padding-left: 60px;
            position: relative;
            .video{
              width: 60px;
              height: 60px;
              border: 0.5px solid var(--dm-bd);
              background-color: var(--dm-bg-f7);
              border-radius: 10px;
              display: flex;
              flex-shrink: 0;
              position: absolute;
              left: 0;
              align-items: center;
              justify-content: center;
              img{
                max-width: 100%;
                max-height: 100%;
              }
              .no-img{
                background: url("../assets/images/video-default.png") no-repeat 50% 32%;
                width: 100%;
                height: 100%;
                background-size: 50%;
                span{
                  position: relative;
                  top: 51%;
                  font-family: 'Helvetica Neue';
                  font-size: 10px;
                  user-select: none;
                  // color: var(--s-7a);
                  color: var(--dm-font-2);
                }
              }
            }
            .info{
              width: 100%;
              display: flex;
              flex-direction: column;
              justify-content: center;
              align-items: center;
              text-align: left;
              padding-left: 10px;
              user-select: none;
              .title{
                width: 100%;
                // color: var(--s-7a);
                color: var(--dm-font-2);
                font-size: 13px;
                font-family: 'Helvetica Neue';
                text-align: left;
                line-height: 16px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-box-orient: vertical;
                user-select: none;
              }
              .name{
                user-select: none;
                width: 100%;
                text-align: left;
                color: var(--dm-font);
                font-size: 16px;
                font-weight: 400;
                padding-top: 5px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
                line-height: 17px;
                span{
                  font-weight: 700;
                }
              }

            }

          }
          .download{
            width: 110px;
            height: 100%;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding-right: 10px;
            position:absolute;
            right: 0;
            user-select: none;
            .btn{
              width: 100px;
              // background-color: var(--dm-bg-f7);
              color: var(--s-main);
              font-size: 13px;
              font-weight: 700;
              height: 25px;
              user-select: none;
              cursor: default;
              line-height: 23px;
              border-radius: 13px;
              border: 1px solid var(--s-main);
            }
          }
        }
        .video-download-info{
          display: flex;
          flex-direction: row;
          width: 100%;
          height: 24px;
          justify-items: center;
          align-items: center;
          margin-bottom: 6px;
          padding-right: 10px;
          .label-txt{
            font-size: 13px;
            color: var(--dm-font);
            font-weight: 400;
            padding-right: 4px;
            height: 24px;
            line-height: 24px;
            user-select: none;
            word-break:keep-all;
          }
          .select-options{
            height: 24px;
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
              color: var(--dm-font);
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
          .select-options.folder{
            width: 140px;
            padding-right: 8px;
            position: relative;
            .selected-text{
              min-width: 80px;
            }
          }
          .quality{
            width: 80px;
          }
        }
      }
    }
  }
@media (prefers-color-scheme: dark) {
  .popup-sniffer-wrapper{
    .sniffer-video-box{
      .sniffer-video{
        .video-download-info{
          .select-options{
            .selected-text{
              &::after{
                filter: drop-shadow(var(--dm-font) -12px 0);
                border-left: 12px solid transparent;
                overflow: hidden;
                right: -12px;
                transform: translateZ(0px);
                top: 6px;
              }
            }
          }
        }
      }
    }
  }  
  
}
</style>
