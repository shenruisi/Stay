let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
// ==UserScript==
// @name         record
// @namespace    http://stay.app/
// @version      0.1
// @description  record voice to recognize word
// @author       Stay
// @match        *://*/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @run-at       document-start
// ==/UserScript==

(function() {
  function parseToDOM(str){
    let divDom = document.createElement('template');
    if(typeof str == 'string'){
      divDom.innerHTML = str;
      return divDom.content;
    }
    return str;
  }
  function createRecordDom(){
    let styleDom = document.createElement('style');//先添加一个临时的，减少延迟，最后会remove掉
    styleDom.type = 'text/css';
    styleDom.id='__stay_record_style';
    const styleText = `
          .__stay_record_box{
              position: fixed;
              z-index: 999999;
              background: #a8a8a8;
              border: 1px solid #fff;
              left: -1px;
              top: 300px;
              width: 100px;
              height: 40px;
              border-bottom-right-radius: 20px;
              border-top-right-radius: 20px;
              box-shadow: 1px -1px 20px rgba(0,0,0,0.2);
              box-sizing: border-box;
              line-height: 38px;
              text-align: center;
              color: red;
              user-select: none;
              font-size: 14px;
          }
          .__stay_record_status{
              padding-left: 10px;
              width:100%;
              box-sizing: border-box;
              user-select: none;
          }
          .__stay_use_record{
              width:100%;
              box-sizing: border-box;
              line-height: 38px;
              text-align: left;
              color:#fff;
              cursor: pointer;
              font-weight: 600;
              user-select: none;
              font-size: 12px;
          }
          .__record_stop{
              display:none;
          }
          .__record_start{
              display:none;
  
          }
          .__stay_img{
              width: 38px;
              height: 38px;
              padding: 12px;
              box-sizing: border-box;
              cursor: default;
          }
          .__stay_img img{
              max-width: 100%;
              max-height: 100%;
          }
          `;
    styleDom.appendChild(document.createTextNode(styleText));
    document.head.appendChild(styleDom);
    let recordDom = document.createElement('div');
    recordDom.id='__stayRecordBox';
    let recordStatusDom = `
              <div class="__stay_record_status">
              <div id="__stayUseRecord" class="__stay_use_record">Use Record</div>
              <div id="__recordStart" class="__record_start __stay_img">
              <img  src="data:image/png;base64,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">
              </div>
              <div id="__recordStop" class="__record_stop __stay_img">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACoAAAA2CAYAAAHG0DstAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAKqADAAQAAAABAAAANgAAAABxCt+IAAADy0lEQVRoBe1az2sTQRTO5kdpaZpUGi8ttnooIqgHT1qKpbnYFmmreBfEu9Kj/4AnBf8ABe3ZEkpTAk0bA4V6CggeajwYAs3BQJo06a/89HtL3zq73aQRJ1JhBrZv5s23b779dnZ2XrYOR6vSQAmFQo8IQ3WyTvpjVzrRUa1W9UHtxvvtOzg4qDM9slRs2XTCqdMoFos6Axp5eXl5grlRmwv5dAIul4v7HfV6/aLRsFRs2VowRvOcgN1EqKenxwUVHjidzvr8/HyIScIXRP0CBEiyr33LOpLlsxKJRIb9Kysri01V8Hq9fj4J9EabAhnEVgFZCVv79/LUajXjduJxr2s0Tjgcvo9G1+zsbFTTtD3y4T5rNKuoPjc3t6QDqRGJRJ6OjIy8wrTSHyw8U41MJrMUDAYfU79Y4vH4NcyFT319fb3sz2azP8bGxm5iIIOJg9cUnl1seTnkk8kmk8l97hft+vr6Z+pvWyQCt1tU0HaVah+nNG1fq3aRndU0nU6XrEzy+XwDz3jM6gd2yerDWuHAQvPM6pfW1lcpLArOra2tL4FA4ApHxpZh//Dw8O74+Pg39pEFVtvY2Hg/NDREL1D9fKyRtVQqtTA9Pf3WwGKNXBRXG67TO9EAnVRWV1cnuF+0tG9hrH6juru7R9khWvH9yf5yuWy7dxH3N529+8xEhlVMZahojqE0Nesho6U0laGiOYbS1KyHjNZ/pimlHnaXLaYn3E9vUK43s/rl4/29QDsMa9nZ2flo9fX398dp52L1izscI+XBu/8GGBuvagySQ6YdN6UwJ5FA1ofcOAiMTsrtdpdnZmbCjDWC8sg4QcOG4TpOuIzDw362lNZXKpW9ycnJBFgXOBD3N7MUF1foj8Vitzwej48JiXjEruBIgeDXlnGj0eid7e3tIt2fs8ru7m4dudgHDBwQB7OrEwaxF0HU+EWnWXwaGxz21tbWbouxTFMfoFfDw8O9uCoRY1uHmtrg4OBDDD5hCxCchKE9ot/vP3UHBZhepbHBwQvFX4t9JkaYF6a2CLSrY5uHO6SdOThhCGsXo5nPyuWPiDUL+i/8iqhslZWiSlHZCsiOp+aoUlS2ArLjqTmqFJWtgOx4ao4qRWUrIDveuZ2jlF6LF2sienR09B2ZqNjfsl4qlfLI2362BKGzq6srC2zhLBz3E4fj42PTFw8Ta7oKfNB94vP5ng8MDFxC6qr/TwEHIIs0tkGfT3BEQOCl9ROKiBXrm5ubVyHEC6TZ9/BBg1Jy09gnsau5XC5dKBTeTE1NvYMIp36SEWOey/ovt0g1ZOyvG2UAAAAASUVORK5CYII=" />
              </div>
              </div>
          `;
    recordDom.appendChild(parseToDOM(recordStatusDom));
    recordDom.classList.add('__stay_record_box');
    document.body.appendChild(recordDom);
  
  }
  createRecordDom();
  const __stayUseRecord = document.querySelector('#__stayUseRecord');
  function createMediaDevices(){
    // 老的浏览器可能根本没有实现 mediaDevices，所以我们可以先设置一个空的对象
    if (navigator.mediaDevices === undefined) {
      navigator.mediaDevices = {};
    }
  
    // 一些浏览器部分支持 mediaDevices。我们不能直接给对象设置 getUserMedia
    // 因为这样可能会覆盖已有的属性。这里我们只会在没有 getUserMedia 属性的时候添加它。
    if (navigator.mediaDevices.getUserMedia === undefined) {
      navigator.mediaDevices.getUserMedia = function(constraints) {
  
        // 首先，如果有 getUserMedia 的话，就获得它
        let getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
  
        // 一些浏览器根本没实现它 - 那么就返回一个 error 到 promise 的 reject 来保持一个统一的接口
        if (!getUserMedia) {
          const __stayRecordBox = document.querySelector('#__stayRecordBox');
          __stayRecordBox.innerText = 'No Support';
          return Promise.reject(new Error('getUserMedia is not implemented in this browser'));
        }
  
        // 否则，为老的 navigator.getUserMedia 方法包裹一个 Promise
        return new Promise(function(resolve, reject) {
          getUserMedia.call(navigator, constraints, resolve, reject);
        });
      }
    }
  
    navigator.mediaDevices.getUserMedia({ audio: true}).then(function(stream) {
      // 创建MediaRecorder对象
      const mediaRecorder = new MediaRecorder(stream);
  
      // 录音数据存储数组
      const chunks = [];
      __stayUseRecord.style.display = 'none';
      const __recordStart = document.querySelector('#__recordStart');
      __recordStart.style.display = 'flex';
      const __recordStop = document.querySelector('#__recordStop');
  
      // 开始录音
      __recordStart.addEventListener('click', (event)=>{
        mediaRecorder.start();
        __recordStart.style.display = 'none';
        __recordStop.style.display = 'flex';
      })
      // 停止录音
      __recordStop.addEventListener('click', (event)=>{
        mediaRecorder.stop();
        __recordStart.style.display = 'flex';
        __recordStop.style.display = 'none';
      })
  
  
      // 录音数据可用时存储到数组中
      mediaRecorder.addEventListener('dataavailable', function(event) {
        chunks.push(event.data);
      });
  
      // 停止录音并生成录音文件
      mediaRecorder.addEventListener('stop', function() {
        console.log('send---start----');
        window.postMessage({name: 'AUDIO_RECORD', recording: chunks});
        console.log('send----end---');
        const blob = new Blob(chunks, { type: 'audio/ogg; codecs=opus' });
        const url = URL.createObjectURL(blob);
        console.log('录音文件URL:', url);
      });
  
      // 5秒后停止录音
      // setTimeout(function() {
      //     mediaRecorder.stop();
      // }, 5000);
  
    }).catch(function(err) {
      console.log(err.name + ': ' + err.message);
    });
  }
  
  
  // __stayUseRecord.addEventListener("touchstart", (event)=>{
  //     console.log("touchstart--------createMediaDevices");
  //     __stayUseRecord.style.opacity = 0.6;
  //     createMediaDevices();
  // })
  __stayUseRecord.addEventListener('click', (event)=>{
    console.log('click--------createMediaDevices');
    __stayUseRecord.style.opacity = 0.6;
    createMediaDevices();
  })
  
})();