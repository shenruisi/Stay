import { createVNode, render } from "vue";
import Toast from "./toast";

// 准备一个DOM容器
const div = document.createElement("div");
// div.setAttribute("class", "toast-wrapper");
document.body.appendChild(div);

let timer = null;

export default (options) => {
  let title, duration;
  if (
    typeof options === "string" ||
    typeof options === "undefined" ||
    !options
  ) {
    title = options || "加载中...";
    duration = 3500;
  } else {
    title = options.title || "加载中...";
    duration = options.duration || 3500;
  }

  // 创建虚拟dom  (组件对象， props)
  const vnode = createVNode(Toast, { title });

  // 把虚拟dom渲染到div
  render(vnode, div);
  clearTimeout(timer);
  timer = setTimeout(() => {
    render(null, div);
  }, duration);
};
