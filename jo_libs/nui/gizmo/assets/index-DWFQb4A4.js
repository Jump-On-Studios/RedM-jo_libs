function ne(r){return r&&r.__esModule&&Object.prototype.hasOwnProperty.call(r,"default")?r.default:r}var J={exports:{}},K={};/**
 * @license React
 * scheduler.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */var Y;function te(){return Y||(Y=1,function(r){function v(e,n){var t=e.length;e.push(n);e:for(;0<t;){var u=t-1>>>1,l=e[u];if(0<s(l,n))e[u]=n,e[t]=l,t=u;else break e}}function i(e){return e.length===0?null:e[0]}function d(e){if(e.length===0)return null;var n=e[0],t=e.pop();if(t!==n){e[0]=t;e:for(var u=0,l=e.length,T=l>>>1;u<T;){var y=2*(u+1)-1,F=e[y],h=y+1,E=e[h];if(0>s(F,t))h<l&&0>s(E,F)?(e[u]=E,e[h]=t,u=h):(e[u]=F,e[y]=t,u=y);else if(h<l&&0>s(E,t))e[u]=E,e[h]=t,u=h;else break e}}return n}function s(e,n){var t=e.sortIndex-n.sortIndex;return t!==0?t:e.id-n.id}if(typeof performance=="object"&&typeof performance.now=="function"){var g=performance;r.unstable_now=function(){return g.now()}}else{var _=Date,j=_.now();r.unstable_now=function(){return _.now()-j}}var f=[],c=[],q=1,o=null,a=3,w=!1,b=!1,m=!1,N=typeof setTimeout=="function"?setTimeout:null,O=typeof clearTimeout=="function"?clearTimeout:null,$=typeof setImmediate<"u"?setImmediate:null;typeof navigator<"u"&&navigator.scheduling!==void 0&&navigator.scheduling.isInputPending!==void 0&&navigator.scheduling.isInputPending.bind(navigator.scheduling);function C(e){for(var n=i(c);n!==null;){if(n.callback===null)d(c);else if(n.startTime<=e)d(c),n.sortIndex=n.expirationTime,v(f,n);else break;n=i(c)}}function M(e){if(m=!1,C(e),!b)if(i(f)!==null)b=!0,L(R);else{var n=i(c);n!==null&&S(M,n.startTime-e)}}function R(e,n){b=!1,m&&(m=!1,O(p),p=-1),w=!0;var t=a;try{for(C(n),o=i(f);o!==null&&(!(o.expirationTime>n)||e&&!A());){var u=o.callback;if(typeof u=="function"){o.callback=null,a=o.priorityLevel;var l=u(o.expirationTime<=n);n=r.unstable_now(),typeof l=="function"?o.callback=l:o===i(f)&&d(f),C(n)}else d(f);o=i(f)}if(o!==null)var T=!0;else{var y=i(c);y!==null&&S(M,y.startTime-n),T=!1}return T}finally{o=null,a=t,w=!1}}var I=!1,P=null,p=-1,B=5,z=-1;function A(){return!(r.unstable_now()-z<B)}function D(){if(P!==null){var e=r.unstable_now();z=e;var n=!0;try{n=P(!0,e)}finally{n?k():(I=!1,P=null)}}else I=!1}var k;if(typeof $=="function")k=function(){$(D)};else if(typeof MessageChannel<"u"){var G=new MessageChannel,H=G.port2;G.port1.onmessage=D,k=function(){H.postMessage(null)}}else k=function(){N(D,0)};function L(e){P=e,I||(I=!0,k())}function S(e,n){p=N(function(){e(r.unstable_now())},n)}r.unstable_IdlePriority=5,r.unstable_ImmediatePriority=1,r.unstable_LowPriority=4,r.unstable_NormalPriority=3,r.unstable_Profiling=null,r.unstable_UserBlockingPriority=2,r.unstable_cancelCallback=function(e){e.callback=null},r.unstable_continueExecution=function(){b||w||(b=!0,L(R))},r.unstable_forceFrameRate=function(e){0>e||125<e?console.error("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported"):B=0<e?Math.floor(1e3/e):5},r.unstable_getCurrentPriorityLevel=function(){return a},r.unstable_getFirstCallbackNode=function(){return i(f)},r.unstable_next=function(e){switch(a){case 1:case 2:case 3:var n=3;break;default:n=a}var t=a;a=n;try{return e()}finally{a=t}},r.unstable_pauseExecution=function(){},r.unstable_requestPaint=function(){},r.unstable_runWithPriority=function(e,n){switch(e){case 1:case 2:case 3:case 4:case 5:break;default:e=3}var t=a;a=e;try{return n()}finally{a=t}},r.unstable_scheduleCallback=function(e,n,t){var u=r.unstable_now();switch(typeof t=="object"&&t!==null?(t=t.delay,t=typeof t=="number"&&0<t?u+t:u):t=u,e){case 1:var l=-1;break;case 2:l=250;break;case 5:l=1073741823;break;case 4:l=1e4;break;default:l=5e3}return l=t+l,e={id:q++,callback:n,priorityLevel:e,startTime:t,expirationTime:l,sortIndex:-1},t>u?(e.sortIndex=t,v(c,e),i(f)===null&&e===i(c)&&(m?(O(p),p=-1):m=!0,S(M,t-u))):(e.sortIndex=l,v(f,e),b||w||(b=!0,L(R))),e},r.unstable_shouldYield=A,r.unstable_wrapCallback=function(e){var n=a;return function(){var t=a;a=n;try{return e.apply(this,arguments)}finally{a=t}}}}(K)),K}var V;function ae(){return V||(V=1,J.exports=te()),J.exports}var Q={exports:{}},U={};/**
 * @license React
 * scheduler.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */var X;function re(){return X||(X=1,function(r){function v(e,n){var t=e.length;e.push(n);e:for(;0<t;){var u=t-1>>>1,l=e[u];if(0<s(l,n))e[u]=n,e[t]=l,t=u;else break e}}function i(e){return e.length===0?null:e[0]}function d(e){if(e.length===0)return null;var n=e[0],t=e.pop();if(t!==n){e[0]=t;e:for(var u=0,l=e.length,T=l>>>1;u<T;){var y=2*(u+1)-1,F=e[y],h=y+1,E=e[h];if(0>s(F,t))h<l&&0>s(E,F)?(e[u]=E,e[h]=t,u=h):(e[u]=F,e[y]=t,u=y);else if(h<l&&0>s(E,t))e[u]=E,e[h]=t,u=h;else break e}}return n}function s(e,n){var t=e.sortIndex-n.sortIndex;return t!==0?t:e.id-n.id}if(typeof performance=="object"&&typeof performance.now=="function"){var g=performance;r.unstable_now=function(){return g.now()}}else{var _=Date,j=_.now();r.unstable_now=function(){return _.now()-j}}var f=[],c=[],q=1,o=null,a=3,w=!1,b=!1,m=!1,N=typeof setTimeout=="function"?setTimeout:null,O=typeof clearTimeout=="function"?clearTimeout:null,$=typeof setImmediate<"u"?setImmediate:null;typeof navigator<"u"&&navigator.scheduling!==void 0&&navigator.scheduling.isInputPending!==void 0&&navigator.scheduling.isInputPending.bind(navigator.scheduling);function C(e){for(var n=i(c);n!==null;){if(n.callback===null)d(c);else if(n.startTime<=e)d(c),n.sortIndex=n.expirationTime,v(f,n);else break;n=i(c)}}function M(e){if(m=!1,C(e),!b)if(i(f)!==null)b=!0,L(R);else{var n=i(c);n!==null&&S(M,n.startTime-e)}}function R(e,n){b=!1,m&&(m=!1,O(p),p=-1),w=!0;var t=a;try{for(C(n),o=i(f);o!==null&&(!(o.expirationTime>n)||e&&!A());){var u=o.callback;if(typeof u=="function"){o.callback=null,a=o.priorityLevel;var l=u(o.expirationTime<=n);n=r.unstable_now(),typeof l=="function"?o.callback=l:o===i(f)&&d(f),C(n)}else d(f);o=i(f)}if(o!==null)var T=!0;else{var y=i(c);y!==null&&S(M,y.startTime-n),T=!1}return T}finally{o=null,a=t,w=!1}}var I=!1,P=null,p=-1,B=5,z=-1;function A(){return!(r.unstable_now()-z<B)}function D(){if(P!==null){var e=r.unstable_now();z=e;var n=!0;try{n=P(!0,e)}finally{n?k():(I=!1,P=null)}}else I=!1}var k;if(typeof $=="function")k=function(){$(D)};else if(typeof MessageChannel<"u"){var G=new MessageChannel,H=G.port2;G.port1.onmessage=D,k=function(){H.postMessage(null)}}else k=function(){N(D,0)};function L(e){P=e,I||(I=!0,k())}function S(e,n){p=N(function(){e(r.unstable_now())},n)}r.unstable_IdlePriority=5,r.unstable_ImmediatePriority=1,r.unstable_LowPriority=4,r.unstable_NormalPriority=3,r.unstable_Profiling=null,r.unstable_UserBlockingPriority=2,r.unstable_cancelCallback=function(e){e.callback=null},r.unstable_continueExecution=function(){b||w||(b=!0,L(R))},r.unstable_forceFrameRate=function(e){0>e||125<e?console.error("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported"):B=0<e?Math.floor(1e3/e):5},r.unstable_getCurrentPriorityLevel=function(){return a},r.unstable_getFirstCallbackNode=function(){return i(f)},r.unstable_next=function(e){switch(a){case 1:case 2:case 3:var n=3;break;default:n=a}var t=a;a=n;try{return e()}finally{a=t}},r.unstable_pauseExecution=function(){},r.unstable_requestPaint=function(){},r.unstable_runWithPriority=function(e,n){switch(e){case 1:case 2:case 3:case 4:case 5:break;default:e=3}var t=a;a=e;try{return n()}finally{a=t}},r.unstable_scheduleCallback=function(e,n,t){var u=r.unstable_now();switch(typeof t=="object"&&t!==null?(t=t.delay,t=typeof t=="number"&&0<t?u+t:u):t=u,e){case 1:var l=-1;break;case 2:l=250;break;case 5:l=1073741823;break;case 4:l=1e4;break;default:l=5e3}return l=t+l,e={id:q++,callback:n,priorityLevel:e,startTime:t,expirationTime:l,sortIndex:-1},t>u?(e.sortIndex=t,v(c,e),i(f)===null&&e===i(c)&&(m?(O(p),p=-1):m=!0,S(M,t-u))):(e.sortIndex=l,v(f,e),b||w||(b=!0,L(R))),e},r.unstable_shouldYield=A,r.unstable_wrapCallback=function(e){var n=a;return function(){var t=a;a=n;try{return e.apply(this,arguments)}finally{a=t}}}}(U)),U}var Z;function ue(){return Z||(Z=1,Q.exports=re()),Q.exports}var oe=ue(),W,x;function le(){if(x)return W;x=1;function r(v,i,d){var s,g,_,j,f;i==null&&(i=100);function c(){var o=Date.now()-j;o<i&&o>=0?s=setTimeout(c,i-o):(s=null,d||(f=v.apply(_,g),_=g=null))}var q=function(){_=this,g=arguments,j=Date.now();var o=d&&!s;return s||(s=setTimeout(c,i)),o&&(f=v.apply(_,g),_=g=null),f};return q.clear=function(){s&&(clearTimeout(s),s=null)},q.flush=function(){s&&(f=v.apply(_,g),_=g=null,clearTimeout(s),s=null)},q}return r.debounce=r,W=r,W}var ie=le();const fe=ne(ie);function ee(){return ee=Object.assign?Object.assign.bind():function(r){for(var v=1;v<arguments.length;v++){var i=arguments[v];for(var d in i)({}).hasOwnProperty.call(i,d)&&(r[d]=i[d])}return r},ee.apply(null,arguments)}export{ee as _,ue as a,fe as c,ne as g,ae as r,oe as s};
