var interval;
setTimeout(function(){
    if (!interval){
        interval = setInterval(function(){
            document.querySelectorAll('.look_more_a')?.forEach(_=>_.remove());
            document.querySelector('.callApp_fl_btn')?.remove();
            document.querySelector('#artFoldBox')?.remove();
            let article_body = document.querySelector('section.s_card.z_c1');
            article_body?.removeAttribute("style")
            if (article_body && !article_body.hasAttribute('style')) {
                clearInterval(interval);
                interval = null;
            }
        }, 100)
    }
},1000)
