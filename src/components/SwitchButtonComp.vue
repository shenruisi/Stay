<template>
  <div class="switch-button-box">
    <div v-for="(item,index) in buttonList" class="switch-item" :class="item.isSelected?'active':''"  :key="index" @click.stop="switchButtonAction(item.value)">
      {{ item.name }}
    </div>
  </div>
</template>
<script>
import { reactive, getCurrentInstance, inject, toRefs, watch } from 'vue'
export default ({
  name: 'SwitchButtonComp',
  props: ['buttonList'],
  setup (props, {emit, expose}) {
    const state = reactive({
      buttonList: props.buttonList
    });
    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        state.buttonList = newProps.buttonList;
      },
      { immediate: true, deep: true }
    );
    const switchButtonAction = (value) => {
      emit('switchAction', value);
    }
  
    return {
      ...toRefs(state),
      switchButtonAction
        
    };
  
  }
})
</script>
  <style lang="less" scoped>
  .switch-button-box {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 42px;
    background-color: var(--dm-bg);
    box-shadow: 0 0 10px 0 rgba(0, 0, 0, 5%);
    border: 1px solid var(--dm-bd);
    padding: 6px 10px;
    border-radius: 10px;
    .switch-item{
      width: 33.33%;
      height: 100%;
      display: flex;justify-content: center;align-items: center;
      font-size: 16px;
      font-weight: 700;
      color: var(--dm-font-2);
      &.active{
        background-color: var(--s-main);
        color: var(--s-white);
        border-radius: 8px;
      }
    }
  }
  
  
  </style>