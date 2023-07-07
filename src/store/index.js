import { createStore } from 'vuex';
import createPersistedState from 'vuex-persistedstate';
import { languageCode } from '@/utils/util';
const moudleA = {
  namespaced: true,
  state: () => {
    return {
      name: ''
    };
  },

  mutations: {
    SET_NAME: (state, data) => {
      state.name = data;
    }
  },

  actions: {
    setName: ({ commit }, data) => {
      commit('SET_NAME', data);
    }
  }
};

export default createStore({
  state: {
    localeLan: languageCode().indexOf('zh_') > -1 ? 'zh' : 'en',
    staySwitch: 'start', // start,cease
    isStayPro: false,
    browserUrl: '',
    selectedTab: {id: 1, name: 'matched_scripts_tab'},
    tabAction: {matched_scripts_tab: 'tab_1', adblock_tab: 'tab_1'},
    darkmodeToggleStatus: 'auto',
    darkmodeTheme: 'Default',
    siteEnabled: true,
    longPressStatus: 'on',
    threeFingerTapStatus: 'on',
    blockStatus: 'on',
    blockerEnabled: '',
  },
  getters: {
    localLanGetter: (state) => {
      return state.localeLan;
    },
    staySwitchGetter: (state) => {
      return state.staySwitch;
    },
    isStayProGetter: (state) => {
      return state.isStayPro;
    },
    browserUrlGetter: (state) => {
      return state.browserUrl;
    },
    selectedTabGetter: (state) => {
      return state.selectedTab;
    },
    darkmodeToggleStatusGetter: (state) => {
      return state.darkmodeToggleStatus;
    },
    darkmodeThemeGetter: (state) => {
      return state.darkmodeTheme;
    },
    siteEnabledGetter: (state) => {
      return state.siteEnabled;
    },
    longPressStatusGetter: (state) => {
      return state.longPressStatus;
    },
    threeFingerTapStatusGetter: (state) => {
      return state.threeFingerTapStatus;
    },
    blockStatusGetter: (state) => {
      return state.blockStatus;
    },
    tabActionGetter: (state) => {
      return state.tabAction;
    },
    blockerEnabledGetter: (state) => {
      return state.tabAction;
    }
  },
  // vuex的store状态更新的唯一方式：提交 mutation
  mutations: {
    setLocalLan: (state, data) => {
      state.localeLan = data;
    },
    setStaySwitch: (state, data) => {
      state.staySwitch = data;
    },
    setIsStayPro: (state, data) => {
      state.isStayPro = data;
    },
    setBrowserUrl: (state, data) => {
      state.browserUrl = data;
    },
    setSelectedTab: (state, data) => {
      state.selectedTab = data;
    },
    setDarkmodeToggleStatus: (state, data) => {
      state.darkmodeToggleStatus = data;
    },
    setDarkmodeTheme: (state, data) => {
      state.darkmodeTheme = data;
    },
    setSiteEnabled: (state, data) => {
      state.siteEnabled = data;
    },
    setLongPressStatus: (state, data) => {
      state.longPressStatus = data;
    },
    setThreeFingerTapStatus: (state, data) => {
      state.threeFingerTapStatus = data;
    },
    setBlockStatus: (state, data) => {
      state.blockStatus = data;
    },
    setTabAction: (state, data) => {
      state.tabAction = data;
    },
    setBlockerEnabled: (state, data) => {
      state.blockerEnabled = data;
    }
  },
  // 异步操作在action中进行，再传递到mutation
  actions: {
    setLocalLanAsync: ({ commit }, data) => {
      commit('setLocalLan', data);
    },
    setStaySwitchAsync: ({ commit }, data) => {
      commit('setStaySwitch', data);
    },
    setIsStayProAsync: ({ commit }, data) => {
      commit('setIsStayPro', data);
    },
    setrowserUrlAsync: ({ commit }, data) => {
      commit('setBrowserUrl', data);
    },
    setSelectedTabAsync: ({ commit }, data) => {
      commit('setSelectedTab', data);
    },
    setDarkmodeToggleStatusAsync: ({ commit }, data) => {
      commit('setDarkmodeToggleStatus', data);
    },
    setDarkmodeThemeAsync: ({ commit }, data) => {
      commit('setDarkmodeTheme', data);
    },
    setSiteEnabledAsync: ({ commit }, data) => {
      commit('setSiteEnabled', data);
    },
    setLongPressStatusAsync: ({ commit }, data) => {
      commit('setLongPressStatus', data);
    },
    setThreeFingerTapStatusAsync: ({ commit }, data) => {
      commit('setThreeFingerTapStatus', data);
    },
    setBlockStatusAsync: ({ commit }, data) => {
      commit('setBlockStatus', data);
    },
    setTabActionAsync: ({ commit }, data) => {
      commit('setTabAction', data);
    },
    setBlockerEnabledAsync: ({ commit }, data) => {
      commit('setBlockerEnabled', data);
    }
  },
  // 当应用变得复杂时，state中管理的变量变多，store对象就有可能变得相当臃肿。为了解决这个问题，
  // vuex允许我们将store分割成模块化（modules），而每个模块拥有着自己的state、mutation、action、getters等
  modules: {
    moudleA
  },
  plugins: [
    createPersistedState({
      // 默认存储在localStorage 可改为sessionStorage
      storage: window.localStorage,
      // 本地存储数据的键名
      key: 'stay-popup-vuex-store-persistence',
      // paths是存储state中的那些数据，如果是模块下具体的数据需要加上模块名称，如moudleA.name
      // 修改state后触发才可以看到本地存储数据的的变化。
      paths: ['moudleA', 'staySwitch', 'selectedTab', 'isStayPro', 'darkmodeToggleStatus', 'darkmodeTheme', 'siteEnabled', 'longPressStatus', 'threeFingerTapStatus', 'blockStatus', 'tabAction']
    })
  ]
});
