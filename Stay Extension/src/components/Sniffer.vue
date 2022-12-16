<template>
  <div class="popup-sniffer-wrapper">
    <div class="sniffer-video-box" v-if="videoList && videoList.length">
      <div class="sniffer-video" v-for="(item, index) in videoList" :key="index">
        <div class="video-info">
          <div class="img-info">
            <div class="video">
              <img :src="item.poster" v-if="item.poster"/>
              <div class="no-img" v-else>
                <span>{{ getHostname(item.hostUrl) }}</span>
              </div>
            </div>
            <div class="info">
              <div class="title">{{getLevel2domain(item.hostUrl)}}</div>
              <div class="name">{{item.title+"."+(item.downloadUrl?getFiletypeByUrl(item.downloadUrl):"")}}</div>
            </div>
          </div>
          <div class="download"><div class="btn" @click="downloadClickAction(item)">{{ t("download") }}</div></div>
        </div>
        <div class="video-download-info">
          <div class="label-txt">{{ t("save_to_folder") }}&nbsp;:</div>
          <div class="folder select-options">
            <select class="select-container" v-model="selectedFolder" >
              <option v-for="(o, i) in folderOptions" :style="{display: o.id?'block':'none'}" :key="i" :value="o.uuid">{{o.name}}</option>
            </select>
          </div>
          <template v-if="(item.qualityList && item.qualityList.length)">
            <div class="label-txt">{{ t("quality") }}&nbsp;:</div>
            <div class="quality select-options">
              <select class="select-container" v-model="item.selectedQuality" >
                <!-- {downloadUrl, qualityLabel, quality } -->
                <option v-for="(o, i) in item.qualityList" :key="i" :value="o.downloadUrl">{{o.qualityLabel}}</option>
              </select>
            </div>
          </template>
        </div>
      </div>
    </div>
    <div class="sniffer-null" v-else>
      {{ t('sniffer_none') }}
    </div>
  </div>
</template>

<script>
import { reactive, inject, toRefs } from 'vue'
import { getDomain, getHostname, getFilenameByUrl, getLevel2domain, getFiletypeByUrl } from '../utils/util'
import { useI18n } from 'vue-i18n';
export default {
  name: 'SnifferComp',
  props: ['browserUrl'],
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const state = reactive({
      selectedFolder: '',
      folderOptions: [{name: t('select_folder'), uuid: ''}, {name:'download_video', id: '1'},{name:'stay-download-video', id: '2'}],
      videoList: [
        // {
        //   poster: 'https://f7.baidu.com/it/u=3855037150,2522612002&fm=222&app=108&f=JPEG',
        //   downloadUrl: 'https://vd2.bdstatic.com/mda-nkea4tasr6ur1ykf/cae_h264/1668497008894896459/mda-nkea4tasr6ur1ykf.mp4',
        //   title: '美国军机飞抵台海已人困马乏，赖岳谦：若开战会被解放军碾压',
        //   qualityList:[],
        //   selectedQuality: ''
        // }
      ]
    });

    const fetchSnifferFolder = () => {
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchFolders'}, (response) => {
        console.log('fetchSnifferFolder---response-----', response);
        try {
          if(response.body){
            state.folderOptions = [{name: t('select_folder'), uuid: ''}, ...response.body];
            response.body.forEach(item => {
              if(item.selected){
                state.selectedFolder = item.uuid;
              }
            });
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
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'snifferFetchVideoInfo'}, (response) => {
        console.log('snifferFetchVideoInfo---response-----', response);
        try {
          if(response.body && response.body.videoInfoList && response.body.videoInfoList.length){
            let videoList = response.body.videoInfoList;
            videoList.forEach(item=>{
              if(item.qualityList && item.qualityList.length ){
                item.selectedQuality = item.qualityList[0].downloadUrl;
              }
            });
            state.videoList = videoList;
          }else{
            state.videoList = [];
          }
        } catch (e) {
          console.log(e);
        }
      });

      // global.browser.tabs.query({
      //   active: true,
      //   currentWindow: true
      // }, (tabs) => {
      //   console.log('--------global.browser.tabs.--snifferFetchVideoInfo-');
      //   let message = { from: 'popup', operate: 'snifferFetchVideoInfo'};
      //   global.browser.tabs.sendMessage(tabs[0].id, message, res => {
      //     console.log('snifferFetchVideoInfo---response-----', res);
      //     console.log('popup=>content')
          
      //   })
      // })
    }

    snifferFetchVideoInfo();

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
      if(!state.selectedFolder){
        global.toast(t('select_folder'));
        return;
      }
      item.uuid = state.selectedFolder;
      if(item.selectedQuality){
        item.downloadUrl = item.selectedQuality;
      }
      let list = [{title:item.title, downloadUrl: item.downloadUrl, poster: item.poster, hostUrl: getHostname(item.hostUrl), uuid: state.selectedFolder}];
      let downloadUrl = 'stay://x-callback-url/snifferVideo?list='+encodeURIComponent(JSON.stringify(list));
      window.open(downloadUrl);
    }
    return {
      ...toRefs(state),
      t,
      tm,
      getDomain,
      getFilenameByUrl,
      getLevel2domain,
      getFiletypeByUrl,
      downloadClickAction
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
      color: var(--s-000-08);
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
        border-bottom: 0.5px solid var(--s-e0);
        flex: 1;
        .video-info{
          display: flex;
          flex-direction: row;
          width: 100%;
          height: 65px;
          justify-items: center;
          align-items: center;
          padding-bottom: 4px;
          padding-right: 100px;
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
              border: 0.5px solid var(--s-e0);
              background-color: var(--s-f7);
              border-radius: 10px;
              display: flex;
              flex-shrink: 0;
              position: absolute;
              left: 0;
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
                color: var(--s-7a);
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
                color: var(--s-black);
                font-size: 16px;
                font-weight: 400;
                font-family: 'Ping Fang SC';
                padding-top: 8px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
                line-height: 17px;
              }

            }

          }
          .download{
            width: 100px;
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
              width: 94px;
              background-color: var(--s-f7);
              color: var(--s-main);
              font-size: 13px;
              font-weight: 700;
              padding: 2px 0;
              border-radius: 8px;
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
          margin-bottom: 8px;
          padding-right: 10px;
          .label-txt{
            font-size: 13px;
            color: var(--s-black);
            font-weight: 400;
            padding-right: 4px;
          }
          .select-options{
            height: 24px;
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
            }
          }
          .folder{
            width: 155px;
            padding-right: 10px;
          }
          .quality{
            width: 68px;
          }
        }
      }
    }
  }
</style>
