(()=>{var e={};e.id=409,e.ids=[409],e.modules={399:e=>{"use strict";e.exports=require("next/dist/compiled/next-server/app-page.runtime.prod.js")},209:e=>{"use strict";e.exports=require("next/dist/server/app-render/action-async-storage.external.js")},9348:e=>{"use strict";e.exports=require("next/dist/server/app-render/work-async-storage.external.js")},412:e=>{"use strict";e.exports=require("next/dist/server/app-render/work-unit-async-storage.external.js")},5315:e=>{"use strict";e.exports=require("path")},2006:(e,t,r)=>{"use strict";r.r(t),r.d(t,{GlobalError:()=>o.a,__next_app__:()=>m,pages:()=>c,routeModule:()=>u,tree:()=>d});var s=r(3003),n=r(4293),i=r(6550),o=r.n(i),a=r(6979),l={};for(let e in a)0>["default","tree","pages","GlobalError","__next_app__","routeModule"].indexOf(e)&&(l[e]=()=>a[e]);r.d(t,l);let d=["",{children:["/_not-found",{children:["__PAGE__",{},{page:[()=>Promise.resolve().then(r.t.bind(r,2075,23)),"next/dist/client/components/not-found-error"]}]},{}]},{layout:[()=>Promise.resolve().then(r.bind(r,6877)),"D:\\repositories\\PortfolioPulse\\frontend\\app\\layout.tsx"],"not-found":[()=>Promise.resolve().then(r.t.bind(r,2075,23)),"next/dist/client/components/not-found-error"]}],c=[],m={require:r,loadChunk:()=>Promise.resolve()},u=new s.AppPageRouteModule({definition:{kind:n.RouteKind.APP_PAGE,page:"/_not-found/page",pathname:"/_not-found",bundlePath:"",filename:"",appPaths:[]},userland:{loaderTree:d}})},6896:(e,t,r)=>{Promise.resolve().then(r.bind(r,4463)),Promise.resolve().then(r.bind(r,5813))},5677:(e,t,r)=>{Promise.resolve().then(r.t.bind(r,6114,23)),Promise.resolve().then(r.t.bind(r,2639,23)),Promise.resolve().then(r.t.bind(r,9727,23)),Promise.resolve().then(r.t.bind(r,9671,23)),Promise.resolve().then(r.t.bind(r,1868,23)),Promise.resolve().then(r.t.bind(r,4759,23)),Promise.resolve().then(r.t.bind(r,2816,23))},4463:(e,t,r)=>{"use strict";r.d(t,{PerformanceMonitor:()=>i});var s=r(8819),n=r(7266);function i(){let[e,t]=(0,n.useState)(null),[r,i]=(0,n.useState)(!1);if(!e)return null;let o=e=>`${Math.round(e)}ms`,a=(e,t)=>e<t[0]?"text-green-600":e<t[1]?"text-yellow-600":"text-red-600";return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)("button",{onClick:()=>i(!r),className:"fixed bottom-4 right-4 z-50 bg-blue-500 text-white p-2 rounded-full shadow-lg hover:bg-blue-600 transition-colors",title:"查看页面性能指标",children:"\uD83D\uDCCA"}),r&&(0,s.jsxs)("div",{className:"fixed bottom-16 right-4 z-50 bg-white dark:bg-gray-800 p-4 rounded-lg shadow-xl border w-80",children:[(0,s.jsxs)("h3",{className:"font-semibold text-sm mb-3 flex items-center justify-between",children:["页面性能指标",(0,s.jsx)("button",{onClick:()=>i(!1),className:"text-gray-500 hover:text-gray-700",children:"✕"})]}),(0,s.jsxs)("div",{className:"space-y-2 text-xs",children:[(0,s.jsxs)("div",{className:"flex justify-between",children:[(0,s.jsx)("span",{children:"页面加载完成:"}),(0,s.jsx)("span",{className:a(e.pageLoad,[1e3,3e3]),children:o(e.pageLoad)})]}),(0,s.jsxs)("div",{className:"flex justify-between",children:[(0,s.jsx)("span",{children:"DOM 内容加载:"}),(0,s.jsx)("span",{className:a(e.domContentLoaded,[800,1600]),children:o(e.domContentLoaded)})]}),e.firstContentfulPaint&&(0,s.jsxs)("div",{className:"flex justify-between",children:[(0,s.jsx)("span",{children:"首次内容绘制:"}),(0,s.jsx)("span",{className:a(e.firstContentfulPaint,[1800,3e3]),children:o(e.firstContentfulPaint)})]}),e.largestContentfulPaint&&(0,s.jsxs)("div",{className:"flex justify-between",children:[(0,s.jsx)("span",{children:"最大内容绘制:"}),(0,s.jsx)("span",{className:a(e.largestContentfulPaint,[2500,4e3]),children:o(e.largestContentfulPaint)})]})]}),(0,s.jsx)("div",{className:"mt-3 pt-2 border-t text-xs text-gray-500",children:(0,s.jsx)("div",{children:"绿色 = 优秀, 黄色 = 需要改进, 红色 = 较差"})})]})]})}},5813:(e,t,r)=>{"use strict";r.d(t,{ThemeProvider:()=>i});var s=r(8819),n=r(3574);function i({children:e,...t}){return(0,s.jsx)(n.f,{...t,storageKey:"theme",enableSystem:!0,disableTransitionOnChange:!1,defaultTheme:"system",children:e})}},6877:(e,t,r)=>{"use strict";r.a(e,async(e,s)=>{try{r.r(t),r.d(t,{default:()=>m,metadata:()=>u});var n=r(9351),i=r(7366),o=r.n(i),a=r(1865),l=r(8670),d=r(9658);r(7272);var c=e([a,l]);[a,l]=c.then?(await c)():c;let u={title:`${d.J.name} - ${d.J.description}`,description:d.J.longDescription,keywords:d.J.keywords.join(", "),authors:[{name:d.J.author.name}],creator:d.J.author.name,openGraph:{type:"website",locale:"zh_CN",url:d.J.url,title:`${d.J.name} - ${d.J.description}`,description:d.J.longDescription,siteName:d.J.name},twitter:{card:"summary_large_image",title:`${d.J.name} - ${d.J.description}`,description:d.J.longDescription}};function m({children:e}){return(0,n.jsxs)("html",{lang:"zh",suppressHydrationWarning:!0,children:[(0,n.jsx)("head",{children:(0,n.jsx)("script",{dangerouslySetInnerHTML:{__html:`
              (function() {
                function setTheme() {
                  try {
                    const theme = localStorage.getItem('theme') || 'system';
                    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const prefersDark = theme === 'dark' || (theme === 'system' && systemDark);

                    const root = document.documentElement;
                    if (prefersDark) {
                      root.classList.add('dark');
                      root.style.colorScheme = 'dark';
                    } else {
                      root.classList.remove('dark');
                      root.style.colorScheme = 'light';
                    }
                  } catch (e) {
                    // 如果出现错误，回退到系统偏好
                    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    if (systemDark) {
                      document.documentElement.classList.add('dark');
                    }
                  }
                }

                // 立即设置主题
                setTheme();

                // 监听系统主题变化
                const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
                mediaQuery.addListener(function() {
                  const theme = localStorage.getItem('theme') || 'system';
                  if (theme === 'system') {
                    setTheme();
                  }
                });

                // 页面加载完成后启用过渡效果
                function enableTransitions() {
                  document.documentElement.classList.add('transitions-enabled');
                }

                if (document.readyState === 'loading') {
                  window.addEventListener('DOMContentLoaded', function() {
                    setTimeout(enableTransitions, 50);
                  });
                } else {
                  setTimeout(enableTransitions, 50);
                }
              })();
            `}})}),(0,n.jsx)("body",{className:o().className,suppressHydrationWarning:!0,children:(0,n.jsxs)(l.ThemeProvider,{attribute:"class",defaultTheme:"system",enableSystem:!0,disableTransitionOnChange:!0,children:[e,(0,n.jsx)(a.PerformanceMonitor,{})]})})]})}s()}catch(e){s(e)}})},1865:(e,t,r)=>{"use strict";r.a(e,async(e,s)=>{try{r.r(t),r.d(t,{PerformanceMonitor:()=>e});var n=r(1851);let e=(await (0,n.createProxy)(String.raw`D:\repositories\PortfolioPulse\frontend\components\performance-monitor.tsx`)).PerformanceMonitor;s()}catch(e){s(e)}},1)},8670:(e,t,r)=>{"use strict";r.a(e,async(e,s)=>{try{r.r(t),r.d(t,{ThemeProvider:()=>e});var n=r(1851);let e=(await (0,n.createProxy)(String.raw`D:\repositories\PortfolioPulse\frontend\components\theme-provider.tsx`)).ThemeProvider;s()}catch(e){s(e)}},1)},9658:(e,t,r)=>{"use strict";r.d(t,{J:()=>s});let s={name:"Vynix",shortName:"V",description:"在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察",longDescription:"Vynix 表示在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察。它结合了'视野'（vision）、'连接'（link）和'无限'（infinity）的概念，象征 AI 时代中不断进化的智慧与可能性。",keywords:["AI","vision","nexus","infinity","insight","portfolio","projects","showcase"],author:{name:"Vynix",description:"AI 时代的数字洞察者"},url:"https://vynix.com",social:{github:"https://github.com/wyw121/PortfolioPulse"},brandMeaning:{inspiration:{vy:"'Vy' 取自 'vision' 和 'vitality'，暗示 AI 的洞察力和生命力",nix:"'Nix' 灵感来自 'nexus'（枢纽、连接点）和 'phoenix'（凤凰，象征重生与进化）"},characteristics:"整体音节简洁，带点科技感和神秘感，适合 AI 时代的语境"}}},7272:()=>{}};var t=require("../../webpack-runtime.js");t.C(e);var r=e=>t(t.s=e),s=t.X(0,[234],()=>r(2006));module.exports=s})();