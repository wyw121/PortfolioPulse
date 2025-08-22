2:"$Sreact.fragment"
4:I[4258,["185","static/chunks/app/layout-f31c7bdc969a7394.js"],"ThemeProvider",1]
5:I[9275,[],""]
6:I[1343,[],""]
7:I[4037,["185","static/chunks/app/layout-f31c7bdc969a7394.js"],"PerformanceMonitor",1]
8:I[9149,["138","static/chunks/138-0fe642092a8e715d.js","916","static/chunks/916-e1f1da964998a0df.js","895","static/chunks/app/projects/page-2b8a83ec030a80d9.js"],"Navigation",1]
9:I[9910,["138","static/chunks/138-0fe642092a8e715d.js","916","static/chunks/916-e1f1da964998a0df.js","895","static/chunks/app/projects/page-2b8a83ec030a80d9.js"],"AnimatedContainer",1]
a:I[2135,["138","static/chunks/138-0fe642092a8e715d.js","916","static/chunks/916-e1f1da964998a0df.js","895","static/chunks/app/projects/page-2b8a83ec030a80d9.js"],"ProjectGrid",1]
b:I[3120,[],"OutletBoundary"]
d:I[3120,[],"MetadataBoundary"]
f:I[3120,[],"ViewportBoundary"]
11:I[6130,[],""]
1:HL["/_next/static/css/3e19a7cd4283ebdd.css","style"]
3:T81b,
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
            0:{"P":null,"b":"_BeMw5mUA6L9OqVswwMPb","p":"","c":["","projects"],"i":false,"f":[[["",{"children":["projects",{"children":["__PAGE__",{}]}]},"$undefined","$undefined",true],["",["$","$2","c",{"children":[[["$","link","0",{"rel":"stylesheet","href":"/_next/static/css/3e19a7cd4283ebdd.css","precedence":"next","crossOrigin":"$undefined","nonce":"$undefined"}]],["$","html",null,{"lang":"zh","suppressHydrationWarning":true,"children":[["$","head",null,{"children":["$","script",null,{"dangerouslySetInnerHTML":{"__html":"$3"}}]}],["$","body",null,{"className":"__className_e8ce0c","suppressHydrationWarning":true,"children":["$","$L4",null,{"attribute":"class","defaultTheme":"system","enableSystem":true,"disableTransitionOnChange":true,"children":[["$","$L5",null,{"parallelRouterKey":"children","segmentPath":["children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L6",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":[["$","title",null,{"children":"404: This page could not be found."}],["$","div",null,{"style":{"fontFamily":"system-ui,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\"","height":"100vh","textAlign":"center","display":"flex","flexDirection":"column","alignItems":"center","justifyContent":"center"},"children":["$","div",null,{"children":[["$","style",null,{"dangerouslySetInnerHTML":{"__html":"body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}"}}],["$","h1",null,{"className":"next-error-h1","style":{"display":"inline-block","margin":"0 20px 0 0","padding":"0 23px 0 0","fontSize":24,"fontWeight":500,"verticalAlign":"top","lineHeight":"49px"},"children":"404"}],["$","div",null,{"style":{"display":"inline-block"},"children":["$","h2",null,{"style":{"fontSize":14,"fontWeight":400,"lineHeight":"49px","margin":0},"children":"This page could not be found."}]}]]}]}]],"notFoundStyles":[]}],["$","$L7",null,{}]]}]}]]}]]}],{"children":["projects",["$","$2","c",{"children":[null,["$","$L5",null,{"parallelRouterKey":"children","segmentPath":["children","projects","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L6",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined"}]]}],{"children":["__PAGE__",["$","$2","c",{"children":[["$","div",null,{"className":"min-h-screen bg-white dark:bg-gray-900","children":[["$","div",null,{"className":"fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90"}],["$","$L8",null,{}],["$","main",null,{"className":"pt-20","children":[["$","div",null,{"className":"max-w-6xl mx-auto px-6 py-12","children":["$","$L9",null,{"direction":"up","duration":600,"children":["$","div",null,{"className":"text-center mb-12","children":[["$","h1",null,{"className":"text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent","children":"我的项目"}],["$","p",null,{"className":"text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto","children":"这里展示了我在不同技术领域的探索和实践，从Web应用到开源工具，每个项目都代表着一次学习和成长的经历。"}]]}]}]}],["$","$La",null,{}]]}]]}],null,["$","$Lb",null,{"children":"$Lc"}]]}],{},null]},null]},null],["$","$2","h",{"children":[null,["$","$2","sTL4DSdCBsykkme40bO-t",{"children":[["$","$Ld",null,{"children":"$Le"}],["$","$Lf",null,{"children":"$L10"}],null]}]]}]]],"m":"$undefined","G":"$11","s":false,"S":true}
10:[["$","meta","0",{"name":"viewport","content":"width=device-width, initial-scale=1"}]]
e:[["$","meta","0",{"charSet":"utf-8"}],["$","title","1",{"children":"Vynix - 在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察"}],["$","meta","2",{"name":"description","content":"Vynix 表示在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察。它结合了'视野'（vision）、'连接'（link）和'无限'（infinity）的概念，象征 AI 时代中不断进化的智慧与可能性。"}],["$","meta","3",{"name":"author","content":"Vynix"}],["$","meta","4",{"name":"keywords","content":"AI, vision, nexus, infinity, insight, portfolio, projects, showcase"}],["$","meta","5",{"name":"creator","content":"Vynix"}],["$","meta","6",{"property":"og:title","content":"Vynix - 在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察"}],["$","meta","7",{"property":"og:description","content":"Vynix 表示在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察。它结合了'视野'（vision）、'连接'（link）和'无限'（infinity）的概念，象征 AI 时代中不断进化的智慧与可能性。"}],["$","meta","8",{"property":"og:url","content":"https://vynix.com"}],["$","meta","9",{"property":"og:site_name","content":"Vynix"}],["$","meta","10",{"property":"og:locale","content":"zh_CN"}],["$","meta","11",{"property":"og:type","content":"website"}],["$","meta","12",{"name":"twitter:card","content":"summary_large_image"}],["$","meta","13",{"name":"twitter:title","content":"Vynix - 在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察"}],["$","meta","14",{"name":"twitter:description","content":"Vynix 表示在 AI 驱动的数字世界中，通过数据与直觉的融合，达到对复杂系统或真理的动态洞察。它结合了'视野'（vision）、'连接'（link）和'无限'（infinity）的概念，象征 AI 时代中不断进化的智慧与可能性。"}]]
c:null
