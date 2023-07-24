<template>
  <div class="edit-themes-prop" v-show="showPopup">
    <div class="close-popup" ><div class="close" @click="closePopupAction">{{ t('menu_close') }}</div></div>
    <div class="themes-box" >
      <template v-if="isStayPro">
        <div class="theme-name">
          <div class="label">{{ t('theme_name') }}</div>
          <div class="name-input">
            <input type="text" v-model="themeName" >
          </div>
          <div class="error-msg" v-if="errorMsg">{{ errorMsg }}</div>
        </div>
        <div class="theme-colors">
          <div class="label">{{ t('theme_color') }}</div>
          <div class="colors-input">
            <div class="bg-color color-item">
              <div class="color-name">{{ t('bg_color') }}</div>
              <div class="color-area" :style="{background: bgColor}" @click="pickerColorAction('background')"></div>
            </div>
            <div class="text-color color-item">
              <div class="color-name">{{ t('text_color') }}</div>
              <div class="color-area" :style="{background: textColor}" @click="pickerColorAction('text')"></div>
            </div>
          </div>
        </div>
        <div class="btn-box">
          <div class="save-btn btn" @click="saveDarkmodeThemeAction">{{ t('save') }}</div>
          <div class="del-btn btn" @click="deleteDarkmodeThemeAction" v-if="actionType=='modify'">{{ t('delete') }}</div>
        </div>
        <div id="colorPicker" class="color-picker" ref="colorPicker" >colorPicker</div>
      </template>
      <UpgradePro tabId="2" v-else>
        <a class="what-it" href="https://www.craft.do/s/PHKJvkZL92BTep" target="_blank">{{ t('what_darkmode') }}</a>
      </UpgradePro>
    </div>
  </div>
</template>

<script>
import { reactive, inject, ref, onMounted, toRefs, watch } from 'vue'
import Pickr from '@simonwep/pickr';
import { hexMD5 } from '../utils/util'
import { useI18n } from 'vue-i18n';
import UpgradePro from './UpgradePro.vue'

export default {
  name: 'ThemeColorComp',
  props:['showEditTheme', 'actionType', 'themeObj'],
  components:{
    UpgradePro
  },
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const state = reactive({
      isStayPro: store.state.isStayPro,
      showPopup: props.showEditTheme,
      showPickerColor: false,
      themeName: t('new_theme'),
      bgColor: '#181a1b',
      textColor: '#e8e6e3',
      pickr: null,
      type: 'background',
      themeItem: props.themeObj || {},
      errorMsg: '',
      showPickerColorStatus: false,
    })
    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.showPopup = newProps.showEditTheme;
        state.themeItem = newProps.themeObj;
        if(newProps.actionType == 'modify'){
          state.bgColor = state.themeItem.bgColor;
          state.textColor = state.themeItem.textColor;
          state.themeName = state.themeItem.name;
        }else{
          state.bgColor = '#181a1b';
          state.textColor = '#e8e6e3';
          state.themeName = t('new_theme');
        }
      },
      { immediate: true, deep: true }
    );
    const colorPicker = ref(null);
    onMounted(()=>{
      // console.log('colorPicker---------------',colorPicker.value);
      if(state.isStayPro){
        state.pickr = Pickr.create({
          el: colorPicker.value,
          theme: 'monolith', // or 'monolith', or 'nano'
          swatches: [
            'rgba(244, 67, 54, 1)',
            'rgba(233, 30, 99, 0.95)',
            'rgba(156, 39, 176, 0.9)',
            'rgba(103, 58, 183, 0.85)',
            'rgba(63, 81, 181, 0.8)',
            'rgba(33, 150, 243, 0.75)',
            'rgba(3, 169, 244, 0.7)',
            'rgba(0, 188, 212, 0.7)',
            'rgba(0, 150, 136, 0.75)',
            'rgba(76, 175, 80, 0.8)',
            'rgba(139, 195, 74, 0.85)',
            'rgba(205, 220, 57, 0.9)',
            'rgba(255, 235, 59, 0.95)',
            'rgba(255, 193, 7, 1)'
          ],
          // container: '.edit-themes-prop',
          autoReposition: false,
          comparison: false,
          useAsButton: true,
          position: 'bottom-middle',
          appClass: 'color-picker-wrapper',
          components: {
            // Main components
            preview: false,
            opacity: true,
            hue: true,
            // Input / output Options
            interaction: {
              hex: true,
              rgba: true,
              hsla: false,
              hsva: false,
              cmyk: false,
              input: true,
              clear: false,
              save: false
            }
          }
        });
    
        state.pickr.on('init', instance => {
          console.log('Event: "init"', instance);
        }).on('hide', instance => {
          console.log('Event: "hide"', instance, instance._color.toHEXA().toString(), state.pickr.getColor().toHEXA().toString());
          handleColorPicker(instance, 'hide');
          state.showPickerColorStatus = false;
        }).on('show', (color, instance) => {
          console.log('Event: "show"', color, instance);
        }).on('save', (color, instance) => {
          console.log('Event: "save"', color, instance, state.pickr.getColor().toHEXA().toString());
          handleColorPicker(instance);
          state.pickr.hide();
        }).on('clear', instance => {
          console.log('Event: "clear"', instance, instance._color.toHEXA().toString());
          handleColorPicker(instance);
        }).on('change', (color, source, instance) => {
          console.log('Event: "change"', color, color.toHEXA().toString(), instance._color.toHEXA().toString(), source, instance);
          handleColorPicker(instance, 'change');
        }).on('changestop', (source, instance) => {
          console.log('Event: "changestop"', source, instance);
        }).on('cancel', instance => {
          console.log('Event: "cancel"', instance);
        }).on('swatchselect', (color, instance) => {
          console.log('Event: "swatchselect"', color, instance);
        });
      }
    })

    const handleColorPicker = (instance, type) => {
      // toRGBA()
      const color = instance._color.toHEXA().toString();
      if('background' == state.type){
        state.bgColor = color;
      }else{
        state.textColor = color;
      }
      if(type == 'hide'){
        // recover to modify theme
        emit('handleCallbackAction', 'clear');
      }else if(type == 'change'){
        // emit('changeThemeToDarkmode', state.bgColor, state.textColor);
        emit('handleCallbackAction', 'change', state.bgColor, state.textColor);
      }
    }

    const closePopupAction = () => {
      state.showPopup = false;
      state.errorMsg = '';
      emit('handleCallbackAction', 'closeAction');
    }

    const pickerColorAction = (type) => {
      if(state.showPickerColorStatus){
        return;
      }
      state.type = type;
      if('background' == type){
        state.pickr.setColor(state.bgColor);
      }else{
        state.pickr.setColor(state.textColor);
      }
      state.pickr.show();
      state.showPickerColorStatus = true;

    }

    const deleteDarkmodeThemeAction = () => {
      deleteDarkmodeTheme();
    }

    const saveDarkmodeThemeAction = () => {
      if(!state.themeName){
        state.errorMsg = t('theme_name_error');
        return;
      }
      state.errorMsg = '';
      if(props.actionType == 'add'){
        state.themeItem.value = hexMD5(`${state.themeName}_${new Date().getTime()}`);
        state.themeItem.name = state.themeName;
        state.themeItem.bgColor = state.bgColor;
        state.themeItem.textColor = state.textColor;
        state.themeItem.isPro = true;
        state.themeItem.edit = true;
        saveDarkmodeTheme()
      }else{
        if(state.themeItem.name != state.themeName || state.themeItem.bgColor != state.bgColor || state.themeItem.textColor != state.textColor){
          state.themeItem.name = state.themeName;
          state.themeItem.bgColor = state.bgColor;
          state.themeItem.textColor = state.textColor;
          modifyDarkmodeTheme()
        }else{
          state.showEditTheme = false;
          // state.pickr.destroy();
          emit('handleCallbackAction', 'closeAction');
        }
      }
    }

    const saveDarkmodeTheme = () => {
      console.log('saveDarkmodeTheme----', state.themeItem);
      global.browser.runtime.sendMessage({from: 'popup', operate: 'addDarkmodeTheme',  theme: state.themeItem}, (response) => {
        console.log('saveDarkmodeTheme response----', response);
        state.showEditTheme = false;
        // state.pickr.destroy();
        emit('handleCallbackAction', 'themeAction');
      })
    }

    const deleteDarkmodeTheme = () => {
      console.log('deleteDarkmodeTheme----', state.themeItem);
      global.browser.runtime.sendMessage({from: 'popup', operate: 'deleteDarkmodeTheme',  theme: state.themeItem}, (response) => {
        console.log('saveDarkmodeTheme response----', response);
        state.showEditTheme = false;
        // state.pickr.destroy();
        emit('handleCallbackAction', 'themeAction');
      })
    }

    const modifyDarkmodeTheme = () => {
      console.log('deleteDarkmodeTheme----', state.themeItem);
      global.browser.runtime.sendMessage({from: 'popup', operate: 'modifyDarkmodeTheme',  theme: state.themeItem}, (response) => {
        console.log('saveDarkmodeTheme response----', response);
        state.showEditTheme = false;
        // state.pickr.destroy();
        emit('handleCallbackAction', 'themeAction');
      })
    }

    return {
      ...toRefs(state),
      colorPicker,
      t,
      tm,
      closePopupAction,
      pickerColorAction,
      saveDarkmodeThemeAction,
      deleteDarkmodeThemeAction,
    };
  }
}

</script>

<style lang="less" scoped>
@import '@simonwep/pickr/dist/themes/monolith.min.css';
.edit-themes-prop{
  position: fixed;
  z-index: 9990;
  width: 100%;
  height: 100%;
  top: 36px;
  left: 0;
  background-color: var(--dm-bg-f7);
  border: 1px solid var(--dm-bd);
  border-top-left-radius: 10px;
  border-top-right-radius: 10px;
  padding: 36px 15px 35px 15px;
  box-sizing: border-box;
  .pickr{
    display: none!important;
  }
  .color-picker{
    display: none;
  }
  .close-popup{
    height: 36px;
    width: 100%;
    position: fixed;
    top: 36px;
    left: 0;
    background-color: var(--dm-bg-f7);
    border-top: 1px solid var(--dm-bd);
    border-left: 1px solid var(--dm-bd);
    border-right: 1px solid var(--dm-bd);
    border-top-left-radius: 10px;
    border-top-right-radius: 10px;
    .close{
      color: var(--s-main);
      font-size: 16px;
      height: 100%;
      width: 70px;
      text-align: center;
      line-height: 36px;
      position: absolute;
      right: 0;
    }
  }
  .themes-box{
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    flex: 1;
    overflow-y: auto;
    padding-bottom: 20px;
    .theme-name{
      width: 100%;
      padding-bottom: 18px;
      position: relative;
      .error-msg{
        color: var(--s-e02020);
        font-size: 10px;
        position: absolute;
        left: 5px;
        bottom: 4px;
      }
      .name-input{
        width: 100%;
        height: 45px;
        border: 1px solid var(--dm-bd);
        border-radius: 10px;
        box-shadow: 0 0px 10px rgba(0,0,0,0.05);
        input{
          color: var(--dm-font);
          font-size: 16px;
          font-weight: 700;
          width: 100%;
          height: 100%;
          border-radius: 10px;
          padding: 0 15px;
        }
      }
    }
    .theme-colors{
      width: 100%;
      padding-bottom: 18px;
      .colors-input{
        padding-left: 15px;
        background-color: var(--dm-bg);
        border-radius: 10px;
        border: 1px solid var(--dm-bd);
        box-shadow: 0 0px 10px rgba(0,0,0,0.05);
        .color-name{
          font-size: 16px;
          color: var(--dm-font);
        }
        .color-area{
          width: 28px;
          height: 28px;
          border-radius: 50%;
        }
        .color-item{
          width: 100%;
          height: 45px;
          padding-right: 20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .text-color{

        }
        .bg-color{
          border-bottom: 1px solid var(--dm-bd);
        }

      }
    }
    .label{
      width: 100%;
      text-align: left;
      padding-bottom: 6px;
      font-size: 15px;
      font-weight: 700;
      color: var(--dm-font-2);
      padding-left: 5px;
    }
    .btn-box{
      width: 100%;
      margin-top: 5px;
      .btn{
        width: 100%;
        line-height: 45px;
        height: 45px;
        border-radius: 10px;
        text-align: center;
        font-size: 16px;
        font-weight: 600;
        margin-bottom: 10px;
        user-select: n;
        cursor: pointer;
      }
      .save-btn{
        border: 1px solid var(--s-main);
        color: var(--s-main);
      }
      .del-btn{
        color: var(--s-white);
        background-color: var(--s-e02020);
      }
    }
  }
}

</style>