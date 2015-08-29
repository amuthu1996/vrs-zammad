/**
 * Class Applier module for Rangy.
 * Adds, removes and toggles classes on Ranges and Selections
 *
 * Part of Rangy, a cross-browser JavaScript range and selection library
 * https://github.com/timdown/rangy
 *
 * Depends on Rangy core.
 *
 * Copyright 2015, Tim Down
 * Licensed under the MIT license.
 * Version: 1.3.0-beta.1
 * Build date: 12 February 2015
 */
!function(e,t){"function"==typeof define&&define.amd?define(["./rangy-core"],e):"undefined"!=typeof module&&"object"==typeof exports?module.exports=e(require("rangy")):e(t.rangy)}(function(e){return e.createModule("ClassApplier",["WrappedSelection"],function(e,t){function n(e,t){for(var n in e)if(e.hasOwnProperty(n)&&t(n,e[n])===!1)return!1;return!0}function s(e){return e.replace(/^\s\s*/,"").replace(/\s\s*$/,"")}function r(e){return e&&e.split(/\s+/).sort().join(" ")}function o(e){return r(e.className)}function a(e,t){return o(e)==o(t)}function l(e,t){for(var n=t.split(/\s+/),i=0,r=n.length;r>i;++i)if(!I(e,s(n[i])))return!1;return!0}function u(e,t,n,s,i){var r=e.node,o=e.offset,a=r,l=o;r==s&&o>i&&++l,r!=t||o!=n&&o!=n+1||(a=s,l+=i-n),r==t&&o>n+1&&--l,e.node=a,e.offset=l}function f(e,t,n){e.node==t&&e.offset>n&&--e.offset}function c(e,t,n,s){-1==n&&(n=t.childNodes.length);var i=e.parentNode,r=M.getNodeIndex(e);$(s,function(e){u(e,i,r,t,n)}),t.childNodes.length==n?t.appendChild(e):t.insertBefore(e,t.childNodes[n])}function d(e,t){var n=e.parentNode,s=M.getNodeIndex(e);$(t,function(e){f(e,n,s)}),e.parentNode.removeChild(e)}function p(e,t,n,s,i){for(var r,o=[];r=e.firstChild;)c(r,t,n++,i),o.push(r);return s&&d(e,i),o}function h(e,t){return p(e,e.parentNode,M.getNodeIndex(e),!0,t)}function m(e,t){var n=e.cloneRange();n.selectNodeContents(t);var s=n.intersection(e),i=s?s.toString():"";return""!=i}function g(e){for(var t,n=e.getNodes([3]),s=0;(t=n[s])&&!m(e,t);)++s;for(var i=n.length-1;(t=n[i])&&!m(e,t);)--i;return n.slice(s,i+1)}function N(e,t){if(e.attributes.length!=t.attributes.length)return!1;for(var n,s,i,r=0,o=e.attributes.length;o>r;++r)if(n=e.attributes[r],i=n.name,"class"!=i){if(s=t.attributes.getNamedItem(i),null===n!=(null===s))return!1;if(n.specified!=s.specified)return!1;if(n.specified&&n.nodeValue!==s.nodeValue)return!1}return!0}function v(e,t){for(var n,s=0,i=e.attributes.length;i>s;++s)if(n=e.attributes[s].name,(!t||!z(t,n))&&e.attributes[s].specified&&"class"!=n)return!0;return!1}function y(e){var t;return e&&1==e.nodeType&&((t=e.parentNode)&&9==t.nodeType&&"on"==t.designMode||V(e)&&!V(e.parentNode))}function C(e){return(V(e)||1!=e.nodeType&&V(e.parentNode))&&!y(e)}function E(e){return e&&1==e.nodeType&&!k.test(U(e,"display"))}function T(e){if(0==e.data.length)return!0;if(q.test(e.data))return!1;var t=U(e.parentNode,"whiteSpace");switch(t){case"pre":case"pre-wrap":case"-moz-pre-wrap":return!1;case"pre-line":if(/[\r\n]/.test(e.data))return!1}return E(e.previousSibling)||E(e.nextSibling)}function b(e){var t,n,s=[];for(t=0;n=e[t++];)s.push(new j(n.startContainer,n.startOffset),new j(n.endContainer,n.endOffset));return s}function A(e,t){for(var n,s,i,r=0,o=e.length;o>r;++r)n=e[r],s=t[2*r],i=t[2*r+1],n.setStartAndEnd(s.node,s.offset,i.node,i.offset)}function S(e,t){return M.isCharacterDataNode(e)?0==t?!!e.previousSibling:t==e.length?!!e.nextSibling:!0:t>0&&t<e.childNodes.length}function x(e,n,s,i){var r,o,a=0==s;if(M.isAncestorOf(n,e))return e;if(M.isCharacterDataNode(n)){var l=M.getNodeIndex(n);if(0==s)s=l;else{if(s!=n.length)throw t.createError("splitNodeAt() should not be called with offset in the middle of a data node ("+s+" in "+n.data);s=l+1}n=n.parentNode}if(S(n,s)){r=n.cloneNode(!1),o=n.parentNode,r.id&&r.removeAttribute("id");for(var u,f=0;u=n.childNodes[s];)c(u,r,f++,i);return c(r,o,M.getNodeIndex(n)+1,i),n==e?r:x(e,o,M.getNodeIndex(r),i)}if(e!=n){r=n.parentNode;var d=M.getNodeIndex(n);return a||d++,x(e,r,d,i)}return e}function R(e,t){return e.namespaceURI==t.namespaceURI&&e.tagName.toLowerCase()==t.tagName.toLowerCase()&&a(e,t)&&N(e,t)&&"inline"==U(e,"display")&&"inline"==U(t,"display")}function P(e){var t=e?"nextSibling":"previousSibling";return function(n,s){var i=n.parentNode,r=n[t];if(r){if(r&&3==r.nodeType)return r}else if(s&&(r=i[t],r&&1==r.nodeType&&R(i,r))){var o=r[e?"firstChild":"lastChild"];if(o&&3==o.nodeType)return o}return null}}function w(e){this.isElementMerge=1==e.nodeType,this.textNodes=[];var t=this.isElementMerge?e.lastChild:e;t&&(this.textNodes[0]=t)}function O(e,t,i){var o,a,l,u,f=this;f.cssClass=f.className=e;var c=null,d={};if("object"==typeof t&&null!==t){for("undefined"!=typeof t.elementTagName&&(t.elementTagName=t.elementTagName.toLowerCase()),i=t.tagNames,c=t.elementProperties,d=t.elementAttributes,a=0;u=J[a++];)t.hasOwnProperty(u)&&(f[u]=t[u]);o=t.normalize}else o=t;f.normalize="undefined"==typeof o?!0:o,f.attrExceptions=[];var p=document.createElement(f.elementTagName);f.elementProperties=f.copyPropertiesToElement(c,p,!0),n(d,function(e){f.attrExceptions.push(e)}),f.elementAttributes=d,f.elementSortedClassName=f.elementProperties.hasOwnProperty("className")?r(f.elementProperties.className+" "+e):e,f.applyToAnyTagName=!1;var h=typeof i;if("string"==h)"*"==i?f.applyToAnyTagName=!0:f.tagNames=s(i.toLowerCase()).split(/\s*,\s*/);else if("object"==h&&"number"==typeof i.length)for(f.tagNames=[],a=0,l=i.length;l>a;++a)"*"==i[a]?f.applyToAnyTagName=!0:f.tagNames.push(i[a].toLowerCase());else f.tagNames=[f.elementTagName]}function W(e,t,n){return new O(e,t,n)}var I,L,H,M=e.dom,j=M.DomPosition,z=M.arrayContains,B=M.isHtmlNamespace,$=e.util.forEach,D="span";e.util.isHostObject(document.createElement("div"),"classList")?(I=function(e,t){return e.classList.contains(t)},L=function(e,t){return e.classList.add(t)},H=function(e,t){return e.classList.remove(t)}):(I=function(e,t){return e.className&&new RegExp("(?:^|\\s)"+t+"(?:\\s|$)").test(e.className)},L=function(e,t){e.className?I(e,t)||(e.className+=" "+t):e.className=t},H=function(){function e(e,t,n){return t&&n?" ":""}return function(t,n){t.className&&(t.className=t.className.replace(new RegExp("(^|\\s)"+n+"(\\s|$)"),e))}}());var U=M.getComputedStyleProperty,V=function(){var e=document.createElement("div");return"boolean"==typeof e.isContentEditable?function(e){return e&&1==e.nodeType&&e.isContentEditable}:function(e){return e&&1==e.nodeType&&"false"!=e.contentEditable?"true"==e.contentEditable||V(e.parentNode):!1}}(),k=/^inline(-block|-table)?$/i,q=/[^\r\n\t\f \u200B]/,F=P(!1),G=P(!0);w.prototype={doMerge:function(e){var t=this.textNodes,n=t[0];if(t.length>1){var s,i=M.getNodeIndex(n),r=[],o=0;$(t,function(t,a){s=t.parentNode,a>0&&(s.removeChild(t),s.hasChildNodes()||s.parentNode.removeChild(s),e&&$(e,function(e){e.node==t&&(e.node=n,e.offset+=o),e.node==s&&e.offset>i&&(--e.offset,e.offset==i+1&&len-1>a&&(e.node=n,e.offset=o))})),r[a]=t.data,o+=t.data.length}),n.data=r.join("")}return n.data},getLength:function(){for(var e=this.textNodes.length,t=0;e--;)t+=this.textNodes[e].length;return t},toString:function(){var e=[];return $(this.textNodes,function(t,n){e[n]="'"+t.data+"'"}),"[Merge("+e.join(",")+")]"}};var J=["elementTagName","ignoreWhiteSpace","applyToEditableOnly","useExistingElements","removeEmptyElements","onElementCreate"],K={};O.prototype={elementTagName:D,elementProperties:{},elementAttributes:{},ignoreWhiteSpace:!0,applyToEditableOnly:!1,useExistingElements:!0,removeEmptyElements:!0,onElementCreate:null,copyPropertiesToElement:function(e,t,n){var s,i,o,a,l,u,f={};for(var c in e)if(e.hasOwnProperty(c))if(a=e[c],l=t[c],"className"==c)L(t,a),L(t,this.className),t[c]=r(t[c]),n&&(f[c]=a);else if("style"==c){i=l,n&&(f[c]=o={});for(s in e[c])e[c].hasOwnProperty(s)&&(i[s]=a[s],n&&(o[s]=i[s]));this.attrExceptions.push(c)}else t[c]=a,n&&(f[c]=t[c],u=K.hasOwnProperty(c)?K[c]:c,this.attrExceptions.push(u));return n?f:""},copyAttributesToElement:function(e,t){for(var n in e)e.hasOwnProperty(n)&&!/^class(?:Name)?$/i.test(n)&&t.setAttribute(n,e[n])},appliesToElement:function(e){return z(this.tagNames,e.tagName.toLowerCase())},getEmptyElements:function(e){var t=this;return e.getNodes([1],function(e){return t.appliesToElement(e)&&!e.hasChildNodes()})},hasClass:function(e){return 1==e.nodeType&&(this.applyToAnyTagName||this.appliesToElement(e))&&I(e,this.className)},getSelfOrAncestorWithClass:function(e){for(;e;){if(this.hasClass(e))return e;e=e.parentNode}return null},isModifiable:function(e){return!this.applyToEditableOnly||C(e)},isIgnorableWhiteSpaceNode:function(e){return this.ignoreWhiteSpace&&e&&3==e.nodeType&&T(e)},postApply:function(e,t,n,s){var r,o,a=e[0],l=e[e.length-1],u=[],f=a,c=l,d=0,p=l.length;$(e,function(e){o=F(e,!s),o?(r||(r=new w(o),u.push(r)),r.textNodes.push(e),e===a&&(f=r.textNodes[0],d=f.length),e===l&&(c=r.textNodes[0],p=r.getLength())):r=null});var h=G(l,!s);if(h&&(r||(r=new w(l),u.push(r)),r.textNodes.push(h)),u.length){for(i=0,len=u.length;len>i;++i)u[i].doMerge(n);t.setStartAndEnd(f,d,c,p)}},createContainer:function(e){var t=e.createElement(this.elementTagName);return this.copyPropertiesToElement(this.elementProperties,t,!1),this.copyAttributesToElement(this.elementAttributes,t),L(t,this.className),this.onElementCreate&&this.onElementCreate(t,this),t},elementHasProperties:function(e,t){var s=this;return n(t,function(t,n){if("className"==t)return l(e,n);if("object"==typeof n){if(!s.elementHasProperties(e[t],n))return!1}else if(e[t]!==n)return!1})},elementHasAttributes:function(e,t){return n(t,function(t,n){return e.getAttribute(t)!==n?!1:void 0})},applyToTextNode:function(e){var t=e.parentNode;if(1==t.childNodes.length&&this.useExistingElements&&B(t)&&this.appliesToElement(t)&&this.elementHasProperties(t,this.elementProperties)&&this.elementHasAttributes(t,this.elementAttributes))L(t,this.className);else{var n=this.createContainer(M.getDocument(e));e.parentNode.insertBefore(n,e),n.appendChild(e)}},isRemovable:function(e){return B(e)&&e.tagName.toLowerCase()==this.elementTagName&&o(e)==this.elementSortedClassName&&this.elementHasProperties(e,this.elementProperties)&&!v(e,this.attrExceptions)&&this.elementHasAttributes(e,this.elementAttributes)&&this.isModifiable(e)},isEmptyContainer:function(e){var t=e.childNodes.length;return 1==e.nodeType&&this.isRemovable(e)&&(0==t||1==t&&this.isEmptyContainer(e.firstChild))},removeEmptyContainers:function(e){var t=this,n=e.getNodes([1],function(e){return t.isEmptyContainer(e)}),s=[e],i=b(s);$(n,function(e){d(e,i)}),A(s,i)},undoToTextNode:function(e,t,n,s){if(!t.containsNode(n)){var i=t.cloneRange();i.selectNode(n),i.isPointInRange(t.endContainer,t.endOffset)&&(x(n,t.endContainer,t.endOffset,s),t.setEndAfter(n)),i.isPointInRange(t.startContainer,t.startOffset)&&(n=x(n,t.startContainer,t.startOffset,s))}this.isRemovable(n)?h(n,s):H(n,this.className)},splitAncestorWithClass:function(e,t,n){var s=this.getSelfOrAncestorWithClass(e);s&&x(s,e,t,n)},undoToAncestor:function(e,t){this.isRemovable(e)?h(e,t):H(e,this.className)},applyToRange:function(e,t){var n=this;t=t||[];var s=b(t||[]);e.splitBoundariesPreservingPositions(s),n.removeEmptyElements&&n.removeEmptyContainers(e);var i=g(e);if(i.length){$(i,function(e){n.isIgnorableWhiteSpaceNode(e)||n.getSelfOrAncestorWithClass(e)||!n.isModifiable(e)||n.applyToTextNode(e,s)});var r=i[i.length-1];e.setStartAndEnd(i[0],0,r,r.length),n.normalize&&n.postApply(i,e,s,!1),A(t,s)}var o=n.getEmptyElements(e);$(o,function(e){L(e,n.className)})},applyToRanges:function(e){for(var t=e.length;t--;)this.applyToRange(e[t],e);return e},applyToSelection:function(t){var n=e.getSelection(t);n.setRanges(this.applyToRanges(n.getAllRanges()))},undoToRange:function(e,t){var n=this;t=t||[];var s=b(t);e.splitBoundariesPreservingPositions(s),n.removeEmptyElements&&n.removeEmptyContainers(e,s);var i,r,o=g(e),a=o[o.length-1];if(o.length){n.splitAncestorWithClass(e.endContainer,e.endOffset,s),n.splitAncestorWithClass(e.startContainer,e.startOffset,s);for(var l=0,u=o.length;u>l;++l)i=o[l],r=n.getSelfOrAncestorWithClass(i),r&&n.isModifiable(i)&&n.undoToAncestor(r,s);e.setStartAndEnd(o[0],0,a,a.length),n.normalize&&n.postApply(o,e,s,!0),A(t,s)}var f=n.getEmptyElements(e);$(f,function(e){H(e,n.className)})},undoToRanges:function(e){for(var t=e.length;t--;)this.undoToRange(e[t],e);return e},undoToSelection:function(t){var n=e.getSelection(t),s=e.getSelection(t).getAllRanges();this.undoToRanges(s),n.setRanges(s)},isAppliedToRange:function(e){if(e.collapsed||""==e.toString())return!!this.getSelfOrAncestorWithClass(e.commonAncestorContainer);var t=e.getNodes([3]);if(t.length)for(var n,s=0;n=t[s++];)if(!this.isIgnorableWhiteSpaceNode(n)&&m(e,n)&&this.isModifiable(n)&&!this.getSelfOrAncestorWithClass(n))return!1;return!0},isAppliedToRanges:function(e){var t=e.length;if(0==t)return!1;for(;t--;)if(!this.isAppliedToRange(e[t]))return!1;return!0},isAppliedToSelection:function(t){var n=e.getSelection(t);return this.isAppliedToRanges(n.getAllRanges())},toggleRange:function(e){this.isAppliedToRange(e)?this.undoToRange(e):this.applyToRange(e)},toggleSelection:function(e){this.isAppliedToSelection(e)?this.undoToSelection(e):this.applyToSelection(e)},getElementsWithClassIntersectingRange:function(e){var t=[],n=this;return e.getNodes([3],function(e){var s=n.getSelfOrAncestorWithClass(e);s&&!z(t,s)&&t.push(s)}),t},detach:function(){}},O.util={hasClass:I,addClass:L,removeClass:H,hasSameClasses:a,hasAllClasses:l,replaceWithOwnChildren:h,elementsHaveSameNonClassAttributes:N,elementHasNonClassAttributes:v,splitNodeAt:x,isEditableElement:V,isEditingHost:y,isEditable:C},e.CssClassApplier=e.ClassApplier=O,e.createCssClassApplier=e.createClassApplier=W}),e},this);