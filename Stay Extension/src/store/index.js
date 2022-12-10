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
      paths: ['moudleA', 'localeLan', 'staySwitch']
    })
  ]
});
