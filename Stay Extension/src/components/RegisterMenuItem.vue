<template>
    <transition name="show">
        <div class="popup-menu-wrapper">
            <DaisyLoading
                :style="{
                    position: 'absolute',
                    top: '2px',
                    right: '16px',
                }"
                :size="0.2"
                v-if="loading"
            />
            <div class="register-menu-box" style="display: none;" id="registerMenuPopup">
                <div class="register-menu-warpper" id="registerMenuWarpper">
                    <div class="register-menu">
                        <div class="menu-close">
                            <div class="close" data-i18n="menu_close">关闭</div>
                        </div>
                        <div class="menu-item-box" >
                            <div class="menu-content" id="registerMenuCon">
                                <div class="menu-item"></div>
                            </div>
                            <div class="menu-content none-menu" id="noneMenu" data-i18n="null_register_menu">
                                
                            </div>
                        </div>
                    </div>
            
                </div>
            </div>
        </div>
    </transition>
    
</template>
  
<script>
import { reactive, inject, watch, toRefs } from 'vue'
import DaisyLoading from './daisy/DaisyLoading.vue';

export default {
  name: 'MenuItemComp',
  components: {
    DaisyLoading
  },
  setup (props, {emit, expose}) {
    const global = inject('global');
    const state = reactive({
      loading: true,
      registerMenu: {},
      uuid: ''
    });

    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.registerMenu = newProps.registerMenu;
      },
      { immediate: true, deep: true }
    );

    return {
      ...toRefs(state)
        
    };
  }
}
</script>
  
<style lang="less" scoped>
@keyframes show {
  0% {
    transform: translate(0%, 100%);
  }
  100% {
    transform: translate(0%, 0%);
  }
}
.popup-menu-wrapper{
    width: 100%;
    position: fixed;
    bottom: 0;
    left: 0;
    height: 100%;
    .register-menu-box{
        width: 100%;
        height: 100%;
        position: fixed;
        bottom: 0;
        left: 0;
        top: 0;
        z-index: 999;
        background-color: rgba(255, 255, 255, 0);
    }
    .register-menu-warpper{
        width: 100%;
        position: absolute;
        padding-top: 41px;
        bottom: 0;
        border-radius: 10px;
        border: 1px solid rgba(151,151,151,0.2);
        border-bottom: 0;
        background-color: #f6f6f6;
    }
    .register-menu{
        position: relative;
        width: 100%;
        height: 100%;
        overflow-y: auto;
        padding-bottom: 41px;
    }
    .menu-close{
        background-color: #f6f6f6;
        color: #000000;
        border-top-left-radius: 10px;
        border-top-right-radius: 10px;
        /* border-bottom: 1px solid rgba(151,151,151,0.2); */
        position: fixed;
        height: 40px;
        width: 100%;
        top: 0px;
        display: flex;
        justify-content: flex-end;
        align-items: center;
    }
    .menu-close .close{
        padding: 0 15px;
        height: 100%;
        align-items: center;
        display: flex;
    }
    .menu-item-box{
        width: 100%;
        height: 100%;
        padding: 10px;
        overflow-y: auto;
    }
    .menu-content{
        display: none;
        background:#fff;
        border: 1px solid rgba(151,151,151,0.2);
        border-radius: 10px;
        padding-left: 10px;
        width: 100%;
    }
    .menu-item{
        width: 100%;
        display: flex;
        padding: 10px 50px 10px 0;
        border-bottom: 1px solid #E0E0E0;
        position: relative;
        font-size: 14px;
        color: #000000;
    }
    .menu-content .menu-item:last-child{
        border-bottom: none;
    }
    .none-menu{
        text-align: left;
        padding: 10px;
    }
}
</style>
  