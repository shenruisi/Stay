/**
 * 解析页面video标签
 */

let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function () {

  async function fetchStayAroundStatus(){
    return new Promise((resolve, reject) => {
      browser.runtime.sendMessage({from: 'content_script', operate: 'GET_STAY_AROUND'}, (response) => {
        console.log('GET_STAY_AROUND---------',response)
        let isStayAround = '';
        if(response.body && JSON.stringify(response.body)!='{}'){
          console.log('isStayAround---------', response.body)
          
          isStayAround = response.body;
            
        }
        resolve(isStayAround)
      });
    })
  }

  async function startInjectScript(){
    let isStayAround = await fetchStayAroundStatus();
    if(isStayAround == 'a'){
      try {
        // for page
        handleInjectScriptToPage();
        document.addEventListener('securitypolicyviolation', (e) => {
          // for content
          injectSelectedAdTagJS(true);
        })
      } catch (error) {
                
      }
    }
  }
  
  startInjectScript();

  
  /**
   * for page 
   */ 
  function handleInjectScriptToPage(){
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let contentHost = window.location.host;
    let scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.id = '__stay_inject_selecte_ad_tag_js_'+contentHost;
    let injectJSContent = `\n\nconst handleInjectSelectedAdTagJS = ${injectSelectedAdTagJS}\n\nhandleInjectSelectedAdTagJS(false);`;
    scriptTag.appendChild(document.createTextNode(injectJSContent));
    if (document.body) {
      document.body.appendChild(scriptTag);
    } else {
      let observerBody = new MutationObserver((mutations, observer) => {
        if (document.body) {
          document.body.appendChild(scriptTag);
          observerBody.disconnect();
        }
      });
      observerBody.observe(document.documentElement, { attributes: true, childList: true, characterData: true, subtree: true });
    }
  }

  /**
   * 注入标记广告方法
   * @param {boolean} isContent false:page模式，true:content模式
   */
  function injectSelectedAdTagJS(isContent){
    let showMakeupTagPanel = false;
    let showMakeupTagMenu = false;
    let makeupTagListenerObj = {};
    let moveWrapperDom = null;
    let closeTagingDom = null;
    let preselectedTargetDom = null;
    let threeFingerMoveStart = null;
    let threeFingerMoveEnd = null;
    let selectedDom = null;
    const distance = 10;
    const Utils = {
      parseToDOM(str){
        let divDom = document.createElement('template');
        if(typeof str == 'string'){
          divDom.innerHTML = str;
          return divDom.content;
        }
        return str;
      },
      isMobileOrIpad: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        return getArr.length ? true : false;
      },
      sub(a, b) {
        let c, d, e;
        try {
          c = a.toString().split('.')[1].length;
        } catch (f) {
          c = 0;
        }
        try {
          d = b.toString().split('.')[1].length;
        } catch (f) {
          d = 0;
        }
        e = Math.pow(10, Math.max(c, d));
        return (this.mul(a, e) - this.mul(b, e)) / e;
      },
      mul(a,b){
        let c = 0,
          d = a.toString(),
          e = b.toString();
        try {
          c += d.split('.')[1].length;
        } catch (f) {}
        try {
          c += e.split('.')[1].length;
        } catch (f) {}
        return Number(d.replace('.', '')) * Number(e.replace('.', '')) / Math.pow(10, c);
      },
      add(a,b){
        let c, d, e;
        try {
          c = a.toString().split('.')[1].length;
        } catch (f) {
          c = 0;
        }
        try {
          d = b.toString().split('.')[1].length;
        } catch (f) {
          d = 0;
        }
        e = Math.pow(10, Math.max(c, d));
        return (this.mul(a, e) + this.mul(b, e)) / e;
      },
    }
    const clickEvent = Utils.isMobileOrIpad()?'touchstart':'click';
    const borderSize = 2;
    function createStyleTag(){
      if(!document.querySelector('#__stay_select_style')){
        const styleDom = document.createElement('style');
        styleDom.type = 'text/css';
        styleDom.id='__stay_select_style';
        const styleText = `
                    .__stay_move_wrapper{
                      position:fixed;
                      left:0;
                      right:0;
                      top:0;
                      bottom:0;
                      z-index:2147483600;
                      width:100%;
                      height:100%;
                      background-color:rgba(0,0,0,0.4);
                      box-sizing: border-box;
                    }
                    .__stay_close_con{
                      position:absolute;
                      right: 20px;
                      top: 20px;
                      width:26px;
                      height:26px;
                      background: url("https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png") 50% 50% no-repeat;
                      background-size: 40%;
                      background-color: #ffffff;
                      border-radius:50%;
                    }
                    .__stay_select_target{display:none;position:fixed; box-sizing:border-box;z-index:2147483647; background-color:rgba(0,0,0,0);border: ${borderSize}px solid #ffffff; border-radius: 6px;box-shadow: 1px -1px 20px rgba(0,0,0,0.2);}
                    .__stay_makeup_menu_wrapper{
                      width:187px;
                      position:absolute;
                      padding: 8px 0;
                      box-sizing: border-box;
                    }
                    .__stay_makeup_menu_item_box{
                      width:100%;
                      box-sizing: border-box;
                      background-color: #ffffff;
                      padding-left: 12px;
                      border-radius: 5px;
                      box-shadow: 0px 2px 10px rgba(0,0,0,0.3);
                    }
                    .__stay_menu_item{
                      -webkit-user-select: none;
                      height:45px;
                      border-bottom: 1px solid #e0e0e0;
                      display:flex;
                      justify-content: space-between;
                      align-items: center;
                      padding-left: 2px;
                      padding-right: 12px;
                      font-size: 16px;
                      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
                      -webkit-font-smoothing: antialiased;
                      -moz-osx-font-smoothing: grayscale;
                    }
                    .__stay_menu_item:last-child {
                      border-bottom: none;
                    }
                    .__stay_menu_item img{
                      width:15px;
                    }
                    .__stay_tagged_wrapper{
                      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
                      -webkit-font-smoothing: antialiased;
                      -moz-osx-font-smoothing: grayscale;
                      position:fixed; 
                      z-index:2147483647;
                      width:160px;
                      height: 44px;
                      border-radius: 22px;
                      line-height: 44px;
                      text-align: center;
                      padding-left: 15px;
                      box-sizing: border-box;
                      background-color: #fff;
                      color: #000;
                      font-weight: 700;
                      font-size: 16px;
                      animation: dropIn 0.5s forwards;
                      left: 50%;
                      transform: translate(-50%, -50%);
                      top: -68px;
                    }
                    .__stay_tagged_wrapper::before{
                      content: '';
                      background: url("https://res.stayfork.app/scripts/63A0624BB9B6793A0F389D1800E403EA/icon.png") 50% 50% no-repeat;
                      background-size: 20px;
                      width: 20px;
                      height: 20px;
                      position: absolute;
                      left: 20px;
                      top: 50%;
                      transform: translate(0, -50%);
                    }
                    @keyframes dropIn {
                      0% {
                        transform: translate(-50%, -100%);
                      }
                      100% {
                        transform: translate(-50%, 80px);
                      }
                    }
                    @keyframes dropOut {
                      0% {
                        transform: translate(-50%, 80px);
                      }
                      100% {
                        transform: translate(-50%, -100%);
                      }
                    }
                `;
        styleDom.appendChild(document.createTextNode(styleText));
        document.head.appendChild(styleDom);
      }
      
    }

    function handleThreeFingerEvent(threeFingerTapStatus){
      if(!Utils.isMobileOrIpad()){
        return;
      }
      if(threeFingerTapStatus == 'on'){
        add3FingerEventListener();
      }else{
        remove3FingerEventListener();
      }
      asyncSetThreeFingerTapStatus(threeFingerTapStatus)
    }

    /**
     * 绑定三指手势触屏事件
     */
    function add3FingerEventListener(){
      // console.log('add3FingerEventListener---------')
      const threeFingerGesturestart = document.addEventListener('gesturestart', handleGesturestartEvent);
      const threeFingerGesturechange =  document.addEventListener('gesturechange', handleGesturechangeEvent);
      const threeFingerGestureend =  document.addEventListener('gestureend', handleGestureendEvent);
    }

    /**
     * 移除三指手势触屏事件
     */
    function remove3FingerEventListener(){
      // console.log('remove3FingerEventListener---------')
      document.removeEventListener('gesturestart', handleGesturestartEvent);
      document.removeEventListener('gesturechange', handleGesturechangeEvent);
      document.removeEventListener('gestureend', handleGestureendEvent);
    }

    function handleGesturestartEvent(event){
      if (event.scale === 1 && event.rotation === 0) {
        threeFingerMoveStart = event.pageX;
        if(!showMakeupTagPanel){
          if('on' == makeupTagListenerObj.makeupStatus){
            startSelecteTagAndMakeupAd()
          }else{
            makeupTagListenerObj.makeupStatus = 'on';
          }
        }
      }
      event.preventDefault();
    }

    function handleGesturechangeEvent(event){
      if (event.scale === 1 && event.rotation === 0) {
        threeFingerMoveEnd = event.pageX;
        let moveDistance = Math.abs(Utils.sub(threeFingerMoveEnd, threeFingerMoveStart));
        if(moveDistance <= distance && !showMakeupTagPanel){
          if('on' == makeupTagListenerObj.makeupStatus){
            startSelecteTagAndMakeupAd()
          }else{
            makeupTagListenerObj.makeupStatus = 'on';
          }
        }
      }
      // 阻止默认事件
      event.preventDefault();
    }

    function handleGestureendEvent(event){
      event.preventDefault();
      threeFingerMoveStart = null;
      threeFingerMoveEnd = null;
    }

    /**
     * 异步获取标记标签状态
     * @returns 
     */
    async function asyncFetchMakeupTagStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          console.log('asyncFetchMakeupTagStatus---isContent--true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
            console.log('asyncFetchMakeupTagStatus---------',response)
            let makeupTagStatus = response&&response.makeupTagStatus?response.makeupTagStatus:'on';
            makeupTagListenerObj.makeupStatus = makeupTagStatus;
          });
        }else{
          console.log('asyncFetchMakeupTagStatus---isContent--false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_MAKEUP_TAG_STATUS_RESP') return;
            console.log('asyncFetchMakeupTagStatus---------',e.data.makeupTagStatus)
            window.removeEventListener('message', callback);
            let makeupStatus = e.data.makeupTagStatus
            makeupTagListenerObj.makeupStatus = makeupStatus;
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_MAKEUP_TAG_STATUS' });
          window.addEventListener('message', callback);
        }
        resolve(true)
      })
    }

    /**
     * 异步获取三指触屏状态
     * @returns 
     */
    async function asyncFetchThreeFingerTapStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          console.log('asyncFetchThreeFingerTapStatus---isContent--true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getThreeFingerTapStatus'}, (response) => {
            console.log('getThreeFingerTapStatus---------',response)
            let threeFingerTapStatus = response&&response.threeFingerTapStatus?response.threeFingerTapStatus:'on';
            makeupTagListenerObj.shouldSetThreeFingerTapStatus = false;
            makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
          });
          resolve(true);
        }else{
          console.log('getThreeFingerTapStatus--isContent---false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_THREE_FINGER_TAG_STATUS_RESP') return;
            let threeFingerTapStatus = e.data.threeFingerTapStatus
            console.log('getThreeFingerTapStatus---------', threeFingerTapStatus)
            //监听到content发过来的消息就不需要再set
            makeupTagListenerObj.shouldSetThreeFingerTapStatus = false;
            makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
            window.removeEventListener('message', callback);
            resolve(true);
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_THREE_FINGER_TAG_STATUS' });
          window.addEventListener('message', callback);
        }
      })
    }

    async function asyncSetThreeFingerTapStatus(threeFingerTapStatus){
      return new Promise((resolve, reject) => {
        if(!makeupTagListenerObj.shouldSetThreeFingerTapStatus){
          resolve(false);
          return;
        }
        if(isContent){
          console.log('asyncSetThreeFingerTapStatus-----true');
          browser.runtime.sendMessage({from: 'content_script', operate: 'setThreeFingerTapStatus', threeFingerTapStatus, type: 'content'}, (response) => {
            console.log('asyncSetThreeFingerTapStatus---------',response)
          });
        }else{
          console.log('asyncSetThreeFingerTapStatus-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid: pid, name: 'SET_THREE_FINGER_TAG_STATUS',  threeFingerTapStatus, type: 'content'});
        }
        resolve(true);
      })
    }


    function listenerMakeupStatusFromPopup(){
      const callback = e => {
        const name = e.data.name;
        if (!e.data.pid) return;
        if(name == 'pushMakeupTagStatus'){
          let makeupStatus = e.data.makeupTagStatus
          console.log('pushMakeupTagStatus---------',makeupStatus)
          makeupTagListenerObj.makeupStatus = makeupStatus;
        }
        else if(name == 'pushThreeFingerTapStatus'){
          let threeFingerTapStatus = e.data.threeFingerTapStatus
          if(threeFingerTapStatus == makeupTagListenerObj.threeFingerTapStatus){
            return;
          }
          console.log('pushThreeFingerTapStatus---------',threeFingerTapStatus)
          makeupTagListenerObj.shouldSetThreeFingerTapStatus = true;
          makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
        }
      };
      window.addEventListener('message', callback);
    }

    function handleStartMakeupStatus(makeupStatus){
      if(makeupStatus && makeupStatus == 'on'){
        startSelecteTagAndMakeupAd();
      }else{
        // 如果有正在标记广告，则需要清楚当前标记内容
        stopSelecteTagAndMakeupAd();
      }
      // asyncSetMakeupTagStatus(makeupStatus)
    }

    function startSelecteTagAndMakeupAd(){
      showMakeupTagPanel = true;
      createOrShowSeleteTagPanelWithModal();

      startListenerMove();
    }

    function stopSelecteTagAndMakeupAd(){
      stopListenerMove();
      hideSeletedTagContentModal();
      hideSeletedTagPanel();
    }

    /**
     * 创建标记tab面板，
     */
    function createOrShowSeleteTagPanelWithModal(){
      createStyleTag();
      if(!document.querySelector('#__stay_wrapper')){
        moveWrapperDom = document.createElement('div');
        moveWrapperDom.id='__stay_wrapper';
        moveWrapperDom.classList.add('__stay_move_wrapper');
        // https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png
        closeTagingDom = document.createElement('div');
        closeTagingDom.id='__stay_close';
        closeTagingDom.classList.add('__stay_close_con');
        moveWrapperDom.appendChild(closeTagingDom);
        document.body.appendChild(moveWrapperDom);
        window.addEventListener('scroll', () => {
          hideSeletedTagContentModal();
          if(showMakeupTagMenu){
            showMakeupTagMenu = false;
            document.querySelector('#__stay_makeup_menu').remove();
          }
          startListenerMove();
        });
      }else{
        moveWrapperDom.style.display = 'block';
      }
      addListenerClosePanelEvent();
      if(!document.querySelector('#__stay_selected_tag')){
        preselectedTargetDom = document.createElement('div');
        preselectedTargetDom.id='__stay_selected_tag';
        preselectedTargetDom.classList.add('__stay_select_target');
        document.body.appendChild(preselectedTargetDom);
      }
    }

    function addListenerClosePanelEvent(){
      closeTagingDom.addEventListener(clickEvent, handleCloseTagingPanel)
    }

    function removeListenerClosePanelEvent(){
      closeTagingDom.removeEventListener(clickEvent, handleCloseTagingPanel)
    }

    function handleCloseTagingPanel(event){
      event.stopPropagation(); 
      event.preventDefault();
      console.log('closeTagingDom addListener click---------------');
      // makeupTagListenerObj.shouldSetMakeupStatus = true;
      makeupTagListenerObj.makeupStatus = 'off';
    }


    /**
     * 开始监听面板move（touchstart）事件
     * 
     */
    function startListenerMove(){
      if(Utils.isMobileOrIpad()){
        const mouseMoveHandler = moveWrapperDom.addEventListener('touchstart', handleMoveAndSelecteDom);
      }else{
        const mouseMoveHandler = document.body.addEventListener('mousemove', handleMoveAndSelecteDom);
      }
      
    }

    /**
     * 移除面板move（touchstart）事件
     */
    function stopListenerMove(){
      if(Utils.isMobileOrIpad()){
        if(moveWrapperDom){
          moveWrapperDom.removeEventListener('touchstart', handleMoveAndSelecteDom);
        }
      }else{
        document.body.removeEventListener('mousemove', handleMoveAndSelecteDom);
      }
    }

    /**
     * 展示标记菜单
     */
    function showTagingOperateMenu(event){
      event.stopPropagation();
      // event.preventDefault();
      console.log('addListener click---------------');
      if(showMakeupTagMenu){
        console.log('showTagingOperateMenu=======showMakeupTagMenu is true');
        return;
      }
      showMakeupTagMenu = true;
      stopListenerMove();
      stopWindowScroll();
      preselectedTargetDom.style.borderColor = '#B620E0';
      // todo
      // https://res.stayfork.app/scripts/D83C97B84E098F26C669507121FE9EEC/icon.png
      const tagMenuDom = document.createElement('div');
      tagMenuDom.id = '__stay_makeup_menu';
      tagMenuDom.classList.add('__stay_makeup_menu_wrapper');
      const tagMenuDomStr = [
        '<div class="__stay_makeup_menu_item_box">',
        '<div class="__stay_menu_item" id="__stay_menu_tag" type="tag"><div>Tag as ad</div><img src="https://res.stayfork.app/scripts/D83C97B84E098F26C669507121FE9EEC/icon.png"></div>',
        '<div class="__stay_menu_item" id="__stay_menu_cancel" type="cancel"><div>Cancel</div><img src="https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png"></div>',
        '</div>'
      ];
      tagMenuDom.appendChild(Utils.parseToDOM(tagMenuDomStr.join('')));
      const clientHeight = document.documentElement.clientHeight;
      const tagMenuDomHeight = 45*2 + 20;
      const tagMenuDomWidth = 187;
      const selectedDomRect = preselectedTargetDom.getBoundingClientRect();
      // console.log('selectedDomRect-----',selectedDomRect, ',tagMenuDomWidth--',tagMenuDomWidth,',tagMenuDomHeight---',tagMenuDomHeight);
      
      const clientWidth = document.documentElement.clientWidth;
      const selectedRightX = Utils.add(selectedDomRect.x,  selectedDomRect.width);
      // 选中区域的left+宽度大于菜单宽度，或者right小于等于0，则与选中区域右边对齐 
      if(selectedRightX >= tagMenuDomWidth){
        if(selectedRightX <= clientWidth){
          tagMenuDom.style.right = `-${borderSize}px`;
        }else{
          tagMenuDom.style.right = Utils.sub(selectedDomRect.right, clientWidth)+'px';
        }
      }else{
        if(((selectedDomRect.left + selectedDomRect.width) <= tagMenuDomWidth && selectedDomRect.left < clientWidth/2) || selectedDomRect.left <= 0){
          tagMenuDom.style.left = `-${borderSize}px`;
        }else{
          tagMenuDom.style.left = Utils.sub(clientWidth, selectedDomRect.left)+'px';
        }
      }

      const selectedBottomY = Utils.add(selectedDomRect.y,  selectedDomRect.height);
      const selectedBottomHeight = Utils.sub(clientHeight, selectedBottomY);
      // 选中区域的selectedBottomHeight距离大于菜单高度，菜单放在选中区域下方；
      if(selectedBottomHeight >= tagMenuDomHeight){
        tagMenuDom.style.top = '100%';
      }else{
        // 选中区域的top距离大于菜单高度，菜单放在选中区域上方；
        if(selectedDomRect.y >= tagMenuDomHeight){
          tagMenuDom.style.bottom = '100%';
        }else{
          // 均不符合上要求，则在选中区域中居中展示
          tagMenuDom.style.position = 'fixed';
          tagMenuDom.style.top = '50%';
          tagMenuDom.style.left = '50%';
          tagMenuDom.style.transform = 'translate(-50%, -50%)';
        }
      }
      preselectedTargetDom.appendChild(tagMenuDom);
      const menuItemCancelEvent = document.querySelector('#__stay_makeup_menu #__stay_menu_cancel').addEventListener(clickEvent, handleMenuItemClick);
      const menuItemTagingEvent = document.querySelector('#__stay_makeup_menu #__stay_menu_tag').addEventListener(clickEvent, handleMenuItemClick);
    }

    function handleMenuItemClick(e){
      e.preventDefault();
      e.stopPropagation();
      let menuItemType = e.currentTarget.getAttribute('type');
          
      if('cancel' === menuItemType){
        // console.log('menu----cancel')
        document.querySelector('#__stay_makeup_menu #__stay_menu_cancel').removeEventListener(clickEvent, handleMenuItemClick);
      }else if('tag' === menuItemType){
        // console.log('menu----tag')
        document.querySelector('#__stay_makeup_menu #__stay_menu_tag').removeEventListener(clickEvent, handleMenuItemClick);
        handleSelectedTag();
        
      }
      preselectedTargetDom.removeChild(document.querySelector('#__stay_makeup_menu'));
      hideSeletedTagContentModal()
      // console.log('handleMenuItemClick------removeChild---------', preselectedTargetDom);
      showMakeupTagMenu = false;
      startListenerMove();
      removeStopWindowScroll();
    }

    function stopWindowScroll(){
      if(Utils.isMobileOrIpad()){
        moveWrapperDom.addEventListener('touchstart', handleStopScroll);
        moveWrapperDom.addEventListener('touchmove', handleStopScroll);
        moveWrapperDom.addEventListener('touchend', handleStopScroll);
      }else{
        document.body.addEventListener('mousemove', handleStopScroll);
      }
    }

    function removeStopWindowScroll(){
      if(Utils.isMobileOrIpad()){
        moveWrapperDom.removeEventListener('touchstart', handleStopScroll);
        moveWrapperDom.removeEventListener('touchmove', handleStopScroll);
        moveWrapperDom.removeEventListener('touchend', handleStopScroll);
      }else{
        document.body.removeEventListener('mousemove', handleStopScroll);
      }
    }
    function handleStopScroll(event){
      event.preventDefault();
      event.stopPropagation();
    }

    function handleSelectedTag(){
      let finishTaggedDom = document.querySelector('#__stay_tagged')
      if(!finishTaggedDom){
        finishTaggedDom = document.createElement('div');
        finishTaggedDom.id = '__stay_tagged';
        finishTaggedDom.classList.add('__stay_tagged_wrapper');
        finishTaggedDom.innerText = 'Tagged';
        document.body.appendChild(finishTaggedDom);
      }else{
        finishTaggedDom.style.animation = 'dropIn 0.5s forwards';
      }
      
      let durationTimer = setTimeout(()=>{
        finishTaggedDom.style.animation = 'dropOut 0.5s forwards';
        clearTimeout(durationTimer);
        durationTimer = 0;
      }, 2000);

      
      sendSelectedTagToHandler();
    }

    async function sendSelectedTagToHandler(){
      return new Promise((resolve, reject)=>{
        const selector = getSelector(selectedDom);
        const url = window.location.href;
        console.log('sendSelectedTagToHandler----------------', selector, url);
        if(isContent){
          console.log('sendSelectedTagToHandler-----true');
          browser.runtime.sendMessage({from: 'adblock', operate: 'sendSelectorToHandler', selector, url}, (response) => {
            console.log('sendSelectedTagToHandler---------',response)
          });
        }else{
          console.log('sendSelectedTagToHandler-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid: pid, name: 'SEND_SELECTOR_TO_HANDLER',  selector, url});
        }
      })
    }
  
    /**
     * 隐藏标记中的模态框内容
     */
    function hideSeletedTagContentModal(){
      if(preselectedTargetDom !=null){
        preselectedTargetDom.removeEventListener(clickEvent, showTagingOperateMenu);
        preselectedTargetDom.style.width = '0px';
        preselectedTargetDom.style.height = '0px';
        preselectedTargetDom.style.left = '0px';
        preselectedTargetDom.style.top = '0px';
        preselectedTargetDom.style.display = 'none';
        preselectedTargetDom.style.borderColor = '#ffffff';
      }
      if(moveWrapperDom!=null){
        moveWrapperDom.style.clipPath = 'none';
      }
      
    }

    /**
     * 隐藏标记tab面板
     * @returns 
     */
    function hideSeletedTagPanel(){
      if(moveWrapperDom!=null){
        removeListenerClosePanelEvent();
        moveWrapperDom.style.display = 'none';
        showMakeupTagPanel = false;
      }
    }

    function handleMoveAndSelecteDom(event){
      console.log('touchmove------handleMoveAndSelecteDom', event)
      let moveX = event.x || event.touches[0].clientX;
      let moveY = event.y || event.touches[0].clientY;
      const moveDoms = document.elementsFromPoint(moveX, moveY);
      console.log('moveDoms-----',moveDoms);
      selectedDom = moveDoms[0];
      let moveDomRect = selectedDom.getBoundingClientRect();
      if(moveDoms && moveDoms.length>1){
        if(moveDoms.length<3){
          selectedDom = moveDoms[1];
        }else if(moveDoms.length > 5){
          let i = 3;
          selectedDom = moveDoms[i];
          while(moveDomRect.height >= document.documentElement.clientHeight){
            i = i - 1;
            selectedDom = moveDoms[i];
            moveDomRect = selectedDom.getBoundingClientRect();
            if(i == 1){
              break;
            }
          }
        }
      }else{
        return;
      }
      console.log('moveDom-----',selectedDom);
      moveDomRect = selectedDom.getBoundingClientRect();
      if(!moveDomRect || !Object.keys(moveDomRect)){
        return;
      }
      let targetWidth = moveDomRect.width;
  
      let targetHeight = moveDomRect.height;
      let targetX = moveDomRect.left;
      let targetY = moveDomRect.top;
  
      if(targetX == 0){
        targetX = selectedDom.offsetLeft;
        if(targetX<0){
          targetX = targetX*(-1);
        }
      }
  
      // console.log('targetWidth=',targetWidth,',targetHeight=',targetHeight,',targetX=',targetX,',targetY=',targetY);
      while(preselectedTargetDom.firstChild){
        preselectedTargetDom.removeChild(preselectedTargetDom.firstChild)
      }
      preselectedTargetDom.style.display = 'block';
      showMakeupTagMenu = false;
      preselectedTargetDom.addEventListener(clickEvent, showTagingOperateMenu);
      // 计算蒙层裁剪区域
  
      moveWrapperDom.style.clipPath = calcPolygonPoints(targetX, targetY, targetWidth, targetHeight);
      preselectedTargetDom.style.width = targetWidth+'px';
      preselectedTargetDom.style.height = targetHeight+'px';
      preselectedTargetDom.style.left = targetX+'px';
      preselectedTargetDom.style.top = targetY+'px';
    }
  
  
    function calcPolygonPoints(targetX, targetY, targetWidth, targetHeight){
      targetX = Utils.add(targetX, borderSize);
      targetY = Utils.add(targetY, borderSize);
      targetWidth = Utils.sub(targetWidth, Utils.mul(borderSize, 2));
      targetHeight = Utils.sub(targetHeight, Utils.mul(borderSize, 2));
      let rectRightPointX = Utils.add(targetX, targetWidth);
      let rectBottomPointY = Utils.add(targetY, targetHeight);
      let polygon = `polygon(0 0, 0 ${targetY}px, ${targetX}px ${targetY}px, ${rectRightPointX}px ${targetY}px, ${rectRightPointX}px ${rectBottomPointY}px, ${targetX}px ${rectBottomPointY}px, ${targetX}px ${targetY}px, 0 ${targetY}px, 0 100%,100% 100%, 100% 0)`;
      return polygon;
    }
  
    function getSelector(el) {
      if (!(el instanceof Element)) return;
      let path = [];
      while (el.nodeType === Node.ELEMENT_NODE) {
        let selector = el.nodeName.toLowerCase();
        if (el.id) {
          selector += '#' + el.id;
          path.unshift(selector);
          break;
        } else {
          let sib = el,
            nth = 1;
          while (sib.nodeType === Node.ELEMENT_NODE && (sib = sib.previousSibling) && nth++);
          selector += ':nth-child(' + nth + ')';
        }
        path.unshift(selector);
        el = el.parentNode;
      }
      return path.join(' > ');
    }

    

    /* eslint-disable */
    Object.defineProperty(makeupTagListenerObj, 'makeupStatus', {
      get:function(){
        return makeupStatus;
      },
      set:function(newValue){
        makeupStatus = newValue;
        console.log('makeupTagListenerObj---makeupStatus-----',newValue);
        //监听makeupStatus, 如果发生变化, 则需要触发状态方法
        handleStartMakeupStatus(newValue)
      }
    });

    /* eslint-disable */
    Object.defineProperty(makeupTagListenerObj, 'threeFingerTapStatus', {
      get:function(){
        return threeFingerTapStatus;
      },
      set:function(newValue){
        threeFingerTapStatus = newValue;
        console.log('makeupTagListenerObj-----threeFingerTapStatus-----',newValue);
        handleThreeFingerEvent(newValue)
      }
    });

    function startMakeupTag(){
      makeupTagListenerObj.makeupStatus = 'off';
      asyncFetchThreeFingerTapStatus();
      // asyncFetchMakeupTagStatus();
      listenerMakeupStatusFromPopup();
    }
  
    startMakeupTag();

  }


  window.addEventListener('message', (e) => {
    if (!e || !e.data || !e.data.name) return;
    const name = e.data.name;
    if(name === 'GET_MAKEUP_TAG_STATUS'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
        // console.log(response);
        let makeupTagStatus = response&&response.makeupTagStatus?response.makeupTagStatus:'on';
        window.postMessage({pid:pid, name: 'GET_MAKEUP_TAG_STATUS_RESP', makeupTagStatus});
      });
    }
    else if(name === 'SET_MAKEUP_TAG_STATUS'){
      let pid = e.data.pid;
      let makeupTagStatus = e.data.makeupTagStatus;
      let type = e.data.type;
      browser.runtime.sendMessage({from: 'popup', operate: 'setMakeupTagStatus', makeupTagStatus, type}, (response) => {
        console.log('SET_MAKEUP_TAG_STATUS----',response);
      });
    }
    else if(name === 'GET_THREE_FINGER_TAG_STATUS'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'popup', operate: 'getThreeFingerTapStatus'}, (response) => {
        // console.log(response);
        let threeFingerTapStatus = response&&response.threeFingerTapStatus?response.threeFingerTapStatus:'on';
        window.postMessage({pid:pid, name: 'GET_THREE_FINGER_TAG_STATUS_RESP', threeFingerTapStatus});
      });
    }
    else if(name === 'SET_THREE_FINGER_TAG_STATUS'){
      let threeFingerTapStatus = e.data.threeFingerTapStatus;
      let type = e.data.type;
      browser.runtime.sendMessage({from: 'content_script', operate: 'setThreeFingerTapStatus', threeFingerTapStatus, type}, (response) => {
      });
    }
    // else if(name === 'pushMakeupTagStatus'){
    //   let pid = e.data.pid;
    //   let makeupTagStatus = e.data.makeupTagStatus
    //   window.postMessage({pid:pid, name: 'pushMakeupTagStatus', makeupTagStatus});
    // }
    // else if(name === 'pushThreeFingerTapStatus'){
    //   let pid = e.data.pid;
    //   let threeFingerTapStatus = e.data.threeFingerTapStatus
    //   window.postMessage({pid:pid, name: 'pushThreeFingerTapStatus', threeFingerTapStatus});
    // }
    else if(name === 'SEND_SELECTOR_TO_HANDLER'){
      let pid = e.data.pid;
      let selector = e.data.selector;
      let url = window.location.href;
      browser.runtime.sendMessage({from: 'adblock', operate: 'sendSelectorToHandler', selector, url}, (response) => {
        console.log('sendSelectedTagToHandler---------',response)
      });
    }
  })


  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const requestFrom = request.from;
    const operate = request.operate;
    if('popup' === requestFrom){
      // if("getMakeupTagStatus" == request.operate){
      //   let makeupTagStatus = 'on';
      //   browser.storage.local.get("stay_makeup_tag_status", (res) => {
      //       console.log("getMakeupTagStatus-------stay_makeup_tag_status,--------res=",res)
      //       if(res && res["stay_makeup_tag_status"]){
      //           makeupTagStatus = res["stay_makeup_tag_status"]
      //       }
      //       sendResponse({makeupTagStatus});
      //   });
      // }
      if('startMakeupTagStatus' == operate){
        let makeupTagStatus = request.makeupTagStatus;
        // console.log('startMakeupTagStatus------', makeupTagStatus)
        let type = request.type;
        if(makeupTagStatus){
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid:pid, name: 'pushMakeupTagStatus', makeupTagStatus});
        }
        sendResponse({makeupTagStatus})
      }
      else if('pushThreeFingerTapStatus' == operate){
        let threeFingerTapStatus = request.threeFingerTapStatus;
        let type = request.type;
        console.log('pushThreeFingerTapStatus---threeFingerTapStatus---', threeFingerTapStatus)
        if(threeFingerTapStatus){
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid:pid, name: 'pushThreeFingerTapStatus', threeFingerTapStatus});
        }
      }
    }


    return true;
  });

})()