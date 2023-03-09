<template>
  <transition name="show">
    <div class="m-notice" v-show="showNotice">
      <div class="m-msg" v-html="title"></div>
      <div class="m-msg" v-if="subTitle" v-html="subTitle"></div>
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
    subTitle: {
      type: String
    }
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
    transform: translate(-50%, 100%);
  }
  100% {
    transform: translate(-50%, -50%);
  }
}

@keyframes hide {
  0% {
    transform: translate(-50%, -50%);
  }
  100% {
    transform: translate(-50%, 100%);
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
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 280px;
  border-radius: 6px;
  background-color: var(--s-white);
  box-shadow: var(--shadow-3);
  padding: 16px;
  display: block;
  // animation: show 0.3s ease-out;
  .m-msg {
    width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    white-space: nowrap;
    font-size: 16px;
    color: var(--s-black);
    text-align: center;
    line-height: 20px;
    // margin-top: 8px;
  }
}
@media (prefers-color-scheme: dark) {
  .m-notice {
    background-color: var(--s-151-f6);
    // box-shadow: var(--shadow-3);
  }
}
</style>
