<template>
  <transition name="show">
    <div class="m-notice" v-show="showNotice">
      <div class="m-msg">{{ title }}</div>
    </div>
  </transition>
</template>

<script>
import { reactive, onMounted, toRefs } from 'vue';
export default {
  name: 'ToastComp',
  props: {
    title: {
      type: String,
      default: '加载中...',
    },
  },
  setup() {
    const state = reactive({
      showNotice: false,
    });
    onMounted(() => {
      state.showNotice = true;
    });

    return {
      ...toRefs(state),
    };
  },
};
</script>

<style lang="less" scoped>
@keyframes show {
  0% {
    transform: translateX(370px);
  }
  100% {
    transform: translateX(0px);
  }
}

@keyframes hide {
  0% {
    transform: translateX(0px);
  }
  100% {
    transform: translateX(370px);
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

.m-notice {
  position: fixed;
  z-index: 9999;
  right: 20px;
  top: 20px;
  width: 330px;
  border-radius: 6px;
  background-color: var(--s-white);
  box-shadow: 0 2px 12px 0 rgb(0 0 0 / 10%);
  padding: 16px;
  // animation: show 0.3s ease-out;
  .m-msg {
    font-size: 16px;
    color: var(--s-black);
    // margin-top: 8px;
  }
}
</style>
