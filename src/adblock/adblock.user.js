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
    let selectDom = null;
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
                        background-color:rgba(0,0,0,0.3);
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
                    .__stay_select_target{display:none;position:fixed; box-sizing:border-box;z-index:2147483647; background-color:rgba(0,0,0,0);border: ${borderSize}px solid #B620E0; border-radius: 6px;box-shadow: 1px -1px 20px rgba(0,0,0,0.2);}
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
                        height:45px;
                        border-bottom: 1px solid #e0e0e0;
                        display:flex;
                        justify-content: space-between;
                        align-items: center;
                        padding-left: 2px;
                        padding-right: 12px;
                        font-size: 16px;
                    }
                    .__stay_menu_item:last-child {
                        border-bottom: none;
                    }
                    .__stay_menu_item img{
                        width:15px;
                    }
                `;
        styleDom.appendChild(document.createTextNode(styleText));
        document.head.appendChild(styleDom);
      }
      
    }

    /**
     * 绑定三指手势触屏事件
     */
    function add3FingerEventListener(){
      let start = null;
      let end = null;
      const distance = 10;
      // console.log('add3FingerEventListener---------')
      document.addEventListener('gesturestart', (event) => {
        // console.log('add3FingerEventListener----gesturestart----',event);
        if (event.scale === 1 && event.rotation === 0) {
          start = event.pageX;
          if(!showMakeupTagPanel){
            if('on' == makeupTagListenerObj.makeupStatus){
              startSelecteTagAndMakeupAd()
            }else{
              makeupTagListenerObj.makeupStatus = 'on'
            }
          }
        }
        event.preventDefault();
      });

      document.addEventListener('gesturechange', (event) => {
        // console.log('add3FingerEventListener----gesturechange----',event);
        if (event.scale === 1 && event.rotation === 0) {
          end = event.pageX;
          let moveDistance = Math.abs(Utils.sub(end, start));
          if(moveDistance <= distance && !showMakeupTagPanel){
            if('on' == makeupTagListenerObj.makeupStatus){
              startSelecteTagAndMakeupAd()
            }else{
              makeupTagListenerObj.makeupStatus = 'on'
            }
          }
        }
        // 阻止默认事件
        event.preventDefault();
      });

      document.addEventListener('gestureend', (event) => {
        // console.log('add3FingerEventListener----gestureend----',event);
        start = null;
        end = null;
      });
    }

    async function startFetchMakeupTagStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          console.log('getMakeupTagStatus-----true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
            console.log('getMakeupTagStatus---------',response)
            let makeupTagStatus = response&&response.makeupTagStatus?response.makeupTagStatus:'on';
            makeupTagListenerObj.makeupStatus = makeupTagStatus;
          });
        }else{
          console.log('getMakeupTagStatus-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_MAKEUP_TAG_STATUS_RESP') return;
            console.log('getMakeupTagStatus---------',e.data.makeupTagStatus)
            window.removeEventListener('message', callback);
            let makeupStatus = e.data.makeupTagStatus
            makeupTagListenerObj.makeupStatus = makeupStatus;
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_MAKEUP_TAG_STATUS' });
          window.addEventListener('message', callback);
        }
      })
    }

    function startMakeupTag(){
      startFetchMakeupTagStatus();
      if(Utils.isMobileOrIpad()){
        add3FingerEventListener();
      }
    }

    startMakeupTag();
    
    
    function handleStartMakeupStatus(makeupStatus){
      if(makeupStatus && makeupStatus == 'on'){
        startSelecteTagAndMakeupAd();
      }else{
        // 如果有正在标记广告，则需要清楚当前标记内容
        stopSelecteTagAndMakeupAd();
      }
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
        const closeTagingDom = document.createElement('div');
        closeTagingDom.id='__stay_close';
        closeTagingDom.classList.add('__stay_close_con');
        moveWrapperDom.appendChild(closeTagingDom);
        document.body.appendChild(moveWrapperDom);
        window.addEventListener('scroll', () => {
          hideSeletedTagContentModal();
          if(showMakeupTagMenu){
            showMakeupTagMenu = false;
            document.querySelector('#__stay_makeup_menu').remove();
            startListenerMove();
          }
        });
        closeTagingDom.addEventListener(clickEvent, (event)=>{
          event.stopPropagation();
          event.preventDefault();
          console.log('closeTagingDom addListener click---------------');
          // stopSelecteTagAndMakeupAd();
          makeupTagListenerObj.makeupStatus = 'off';

        })
      }else{
        moveWrapperDom.style.display = 'block';
      }
      if(!document.querySelector('#__stay_selected_tag')){
        selectDom = document.createElement('div');
        selectDom.id='__stay_selected_tag';
        selectDom.classList.add('__stay_select_target');
        document.body.appendChild(selectDom);
      }
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
      event.preventDefault();
      console.log('addListener click---------------');
      if(showMakeupTagMenu){
        console.log('showTagingOperateMenu=======showMakeupTagMenu is true');
        return;
      }
      showMakeupTagMenu = true;
      stopListenerMove();
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
      const selectedDomRect = selectDom.getBoundingClientRect();
      // console.log('selectedDomRect-----',selectedDomRect, ',tagMenuDomWidth--',tagMenuDomWidth,',tagMenuDomHeight---',tagMenuDomHeight);
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
          tagMenuDom.style.top = '50%';
          tagMenuDom.style.transform = 'translateY(-50%)';
        }
      }
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
      selectDom.appendChild(tagMenuDom);

      
      
      const menuItemCancelEvent = document.querySelector('#__stay_makeup_menu #__stay_menu_cancel').addEventListener(clickEvent, handleMenuItemClick);
      const menuItemTagingEvent = document.querySelector('#__stay_makeup_menu #__stay_menu_tag').addEventListener(clickEvent, handleMenuItemClick);
     
    }

    function handleMenuItemClick(e){
      e.preventDefault();
      e.stopPropagation();
      let menuItemType = e.currentTarget.getAttribute('type');
          
      if('cancel' === menuItemType){
        console.log('menu----cancel')
          
        document.querySelector('#__stay_makeup_menu #__stay_menu_cancel').removeEventListener(clickEvent, handleMenuItemClick);
      }else if('tag' === menuItemType){
        console.log('menu----tag')
        // todo
        document.querySelector('#__stay_makeup_menu #__stay_menu_tag').removeEventListener(clickEvent, handleMenuItemClick);
          
          
      }
      selectDom.removeChild(document.querySelector('#__stay_makeup_menu'));
      hideSeletedTagContentModal()
      console.log('handleMenuItemClick------removeChild---------', selectDom);
      showMakeupTagMenu = false;
      startListenerMove()
    }
  
    /**
     * 隐藏标记中的模态框内容
     */
    function hideSeletedTagContentModal(){
      if(selectDom !=null){
        selectDom.removeEventListener(clickEvent, showTagingOperateMenu);
        selectDom.style.width = '0px';
        selectDom.style.height = '0px';
        selectDom.style.left = '0px';
        selectDom.style.top = '0px';
        selectDom.style.display = 'none';
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
        moveWrapperDom.style.display = 'none';
        showMakeupTagPanel = false;
      }
    }

    function handleMoveAndSelecteDom(event){
      event.preventDefault();
      console.log('touchmove------handleMoveAndSelecteDom', event)
      let moveX = event.x || event.touches[0].clientX;
      let moveY = event.y || event.touches[0].clientY;
      const moveDoms = document.elementsFromPoint(moveX, moveY);
      console.log('moveDoms-----',moveDoms);
      let moveDom = moveDoms[0];
      if(moveDoms && moveDoms.length>1){
        if(moveDoms.length<3){
          moveDom = moveDoms[1];
        }else if(moveDoms.length > 5){
          moveDom = moveDoms[3];
        }
      }else{
        return;
      }
      console.log('moveDom-----',moveDom);
      const moveDomRect = moveDom.getBoundingClientRect();
      if(!moveDomRect || !Object.keys(moveDomRect)){
        return;
      }
      let targetWidth = moveDomRect.width;
  
      let targetHeight = moveDomRect.height;
      let targetX = moveDomRect.left;
      let targetY = moveDomRect.top;
  
      if(targetX == 0){
        targetX = moveDom.offsetLeft;
        if(targetX<0){
          targetX = targetX*(-1);
        }
      }
  
      console.log('targetWidth=',targetWidth,',targetHeight=',targetHeight,',targetX=',targetX,',targetY=',targetY);
      while(selectDom.firstChild){
        selectDom.removeChild(selectDom.firstChild)
      }
      selectDom.style.display = 'block';
      showMakeupTagMenu = false;
      selectDom.addEventListener(clickEvent, showTagingOperateMenu);
      // 计算蒙层裁剪区域
  
      moveWrapperDom.style.clipPath = calcPolygonPoints(targetX, targetY, targetWidth, targetHeight);
      selectDom.style.width = targetWidth+'px';
      selectDom.style.height = targetHeight+'px';
      selectDom.style.left = targetX+'px';
      selectDom.style.top = targetY+'px';
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
        console.log('makeupTagListenerObj---newValue-----',makeupStatus);
        //监听makeupStatus, 如果发生变化, 则需要触发状态方法
        handleStartMakeupStatus(makeupStatus)
      }
    });

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
  })

})()