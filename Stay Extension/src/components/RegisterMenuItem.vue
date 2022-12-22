<template>
  <transition name="show">
    <div class="popup-menu-wrapper">
      <DaisyLoading :style="{position: 'absolute',top: '2px',right: '16px',}" :size="0.2" v-if="loading" />
      <div class="register-menu-warpper">
        <div class="register-menu">
          <div class="menu-close">
            <div class="close" @click="closeMenuPopup" >{{t("menu_close")}}</div>
          </div>
          <div class="menu-item-box" >
            <div class="menu-content" v-if="registerMenuList.length">
              <div class="menu-item" v-for="(item, index) in registerMenuList" :key="index" @click="handleRegisterMenuClickAction(item.id, item.uuid)">{{item.caption}}</div>
            </div>
            <div class="menu-content none-menu" v-else>
              {{t('null_register_menu')}}
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
import { useI18n } from 'vue-i18n';

export default {
  name: 'MenuItemComp',
  components: {
    DaisyLoading
  },
  props: ['registerMenu'],
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const state = reactive({
      loading: true,
      registerMenuList: props.registerMenu || [],
    });

    watch(
      props, 
      (newProps) => {
        // 接收到的props的值
        if(newProps.registerMenu){
          state.registerMenuList = newProps.registerMenu;
          state.loading = false;
        }
        // console.log('newProps.registerMenu==========',newProps.registerMenu)
      },
      { immediate: true, deep: true }
    );


    /**
     * click for register menu item
     * @param {string}     menuId
     */
    const handleRegisterMenuClickAction = (menuId, uuid) => {
      console.log(menuId);
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'execRegisterMenuCommand', id: menuId, uuid: uuid }, (res)=>{
        if (res.id && res.uuid){
          window.close();
        }
      });
      closeMenuPopup();
    }

    const closeMenuPopup = () => {
      emit('closeMenuPopup');
    }

    return {
      ...toRefs(state),
      t,
      tm,
      handleRegisterMenuClickAction,
      closeMenuPopup,
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
.show-enter-active {
  animation: show 0.3s ease-out;
}

.show-leave-active {
  animation: hide 0.3s ease-in;
}

.show-leave-to {
  opacity: 0;
}
.popup-menu-wrapper{
    width: 100%;
    position: fixed;
    top: 48px;
    left: 0;
    height: 100%;
    z-index: 9999;
    .register-menu-warpper{
        width: 100%;
        height: 100%;
        position: absolute;
        left: 0;
        bottom: 0;
        border-radius: 10px;
        border: 1px solid var(--s-151-f02);
        border-bottom: 0;
        background-color: var(--s-f6);
    }
    .register-menu{
        position: relative;
        width: 100%;
        height: 100%;
        overflow-y: auto;
        padding-bottom: 20px;
    }
    .menu-close{
        background-color: var(--s-f6);
        color: var(--s-black);
        border-top-left-radius: 10px;
        border-top-right-radius: 10px;
        /* border-bottom: 1px solid rgba(151,151,151,0.2); */
        position: absolute;
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
        padding: 40px 10px 10px 10px;
        overflow-y: auto;
    }
    .menu-content{
        background: var(--s-white);
        border: 1px solid var(--s-151-f02);
        border-radius: 10px;
        padding-left: 10px;
        width: 100%;
    }
    .menu-item{
        width: 100%;
        display: flex;
        padding: 10px 50px 10px 0;
        border-bottom: 1px solid var(--s-e0);
        position: relative;
        font-size: 14px;
        color: var(--s-black);
    }
    .menu-content .menu-item:last-child{
        border-bottom: none;
    }
    .none-menu{
        text-align: center;
        padding: 10px;
    }
}
</style>
  