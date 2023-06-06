<template>
  <label class="switch">
    <input type="checkbox" :checked="switchStatus=='on'" @change='switchAction($event)'>
    <span class="slider"></span>
  </label>
</template>
<script>
import { reactive, getCurrentInstance, inject, toRefs, watch } from 'vue'
export default ({
  name: 'SwitchComp',
  props: ['switchStatus'],
  setup (props, {emit, expose}) {
    const state = reactive({
      
      switchStatus: props.switchStatus,
      
    });
    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.switchStatus = newProps.switchStatus;
      },
      { immediate: true, deep: true }
    );
    const switchAction = (event) => {
      const disabled = event.target.checked;
      state.switchStatus = disabled?'on':'off';
      emit('switchAction', state.switchStatus);
    }

    return {
      ...toRefs(state),
      switchAction
      
    };

  }
})
</script>
<style lang="less" scoped>
.switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 30px;
}

.switch input {
  display: none;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 34px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 2px;
  bottom: 2px;
  background-color: var(--s-white);
  transition: .4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--s-main);
}

input:checked + .slider:before {
  transform: translateX(20px);
}
</style>