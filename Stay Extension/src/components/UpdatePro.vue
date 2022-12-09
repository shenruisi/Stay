<template>
    <div class="update-pro-warpper">
  
    </div>
  </template>
  
<script>
import { reactive, toRefs } from 'vue'
  
export default {
  name: 'UpdateProComp',
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
.update-pro-warpper{
    width: 100%;
}
</style>
  