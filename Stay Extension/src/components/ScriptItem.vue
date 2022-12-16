<template>
  <div class="script-item">

  </div>
</template>

<script>
import { reactive, inject, toRefs } from 'vue'
import { useI18n } from 'vue-i18n';


export default {
  name: 'ScriptItemComp',
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const state = reactive({
      browserUrl: store.state.browserUrl,
    });
    
    const intoAppScriptDetail = (uuid) => {
      window.open('stay://x-callback-url/userscript?id='+uuid);
    }

    return {
      ...toRefs(state),
      t,
      tm,
      intoAppScriptDetail,
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-header-wrapper{
    width: 100%;
  }
</style>
