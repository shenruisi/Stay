<template>
  <div class="popup-header-wrapper">

  </div>
</template>

<script>
import { reactive } from "vue"

export default {
  name: 'PusherCloneComp',
  setup(props, {emit, expose}){

    const state = reactive({

    })
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