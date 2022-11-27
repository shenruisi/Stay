<template>
  <div class="popup-header-wrapper">

  </div>
</template>

<script>
import { reactive, toRefs } from 'vue'

export default {
  name: 'SnifferComp',
  setup (props, {emit, expose}) {
    const state = reactive({

    });
    return {
      ...toRefs(state)
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-header-wrapper{
    width: 100%;
  }
</style>
