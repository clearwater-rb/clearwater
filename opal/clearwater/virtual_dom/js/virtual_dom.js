(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else if(typeof exports === 'object')
		exports["virtualDom"] = factory();
	else
		root["virtualDom"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	var diff       = __webpack_require__(1)
	var patch      = __webpack_require__(14)
	var h          = __webpack_require__(23)
	var create     = __webpack_require__(33)
	var VNode      = __webpack_require__(25)
	var VText      = __webpack_require__(26)
	var svg        = __webpack_require__(34)

	module.exports = {
	  diff: diff,
	  patch: patch,
	  h: h,
	  create: create,
	  VNode: VNode,
	  VText: VText,
	  svg: svg,
	}


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var diff = __webpack_require__(2)

	module.exports = diff


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	var isArray = __webpack_require__(3)

	var VPatch = __webpack_require__(4)
	var isVNode = __webpack_require__(6)
	var isVText = __webpack_require__(7)
	var isWidget = __webpack_require__(8)
	var isThunk = __webpack_require__(9)
	var handleThunk = __webpack_require__(10)

	var diffProps = __webpack_require__(11)

	module.exports = diff

	function diff(a, b) {
	    var patch = { a: a }
	    walk(a, b, patch, 0)
	    return patch
	}

	function walk(a, b, patch, index) {
	    if (a === b) {
	        return
	    }

	    var apply = patch[index]
	    var applyClear = false

	    if (isThunk(a) || isThunk(b)) {
	        thunks(a, b, patch, index)
	    } else if (b == null) {

	        // If a is a widget we will add a remove patch for it
	        // Otherwise any child widgets/hooks must be destroyed.
	        // This prevents adding two remove patches for a widget.
	        if (!isWidget(a)) {
	            clearState(a, patch, index)
	            apply = patch[index]
	        }

	        apply = appendPatch(apply, new VPatch(VPatch.REMOVE, a, b))
	    } else if (isVNode(b)) {
	        if (isVNode(a)) {
	            if (a.tagName === b.tagName &&
	                a.namespace === b.namespace &&
	                a.key === b.key) {
	                var propsPatch = diffProps(a.properties, b.properties)
	                if (propsPatch) {
	                    apply = appendPatch(apply,
	                        new VPatch(VPatch.PROPS, a, propsPatch))
	                }
	                apply = diffChildren(a, b, patch, apply, index)
	            } else {
	                apply = appendPatch(apply, new VPatch(VPatch.VNODE, a, b))
	                applyClear = true
	            }
	        } else {
	            apply = appendPatch(apply, new VPatch(VPatch.VNODE, a, b))
	            applyClear = true
	        }
	    } else if (isVText(b)) {
	        if (!isVText(a)) {
	            apply = appendPatch(apply, new VPatch(VPatch.VTEXT, a, b))
	            applyClear = true
	        } else if (a.text !== b.text) {
	            apply = appendPatch(apply, new VPatch(VPatch.VTEXT, a, b))
	        }
	    } else if (isWidget(b)) {
	        if (!isWidget(a)) {
	            applyClear = true
	        }

	        apply = appendPatch(apply, new VPatch(VPatch.WIDGET, a, b))
	    }

	    if (apply) {
	        patch[index] = apply
	    }

	    if (applyClear) {
	        clearState(a, patch, index)
	    }
	}

	function diffChildren(a, b, patch, apply, index) {
	    var aChildren = a.children
	    var orderedSet = reorder(aChildren, b.children)
	    var bChildren = orderedSet.children

	    var aLen = aChildren.length
	    var bLen = bChildren.length
	    var len = aLen > bLen ? aLen : bLen

	    for (var i = 0; i < len; i++) {
	        var leftNode = aChildren[i]
	        var rightNode = bChildren[i]
	        index += 1

	        if (!leftNode) {
	            if (rightNode) {
	                // Excess nodes in b need to be added
	                apply = appendPatch(apply,
	                    new VPatch(VPatch.INSERT, null, rightNode))
	            }
	        } else {
	            walk(leftNode, rightNode, patch, index)
	        }

	        if (isVNode(leftNode) && leftNode.count) {
	            index += leftNode.count
	        }
	    }

	    if (orderedSet.moves) {
	        // Reorder nodes last
	        apply = appendPatch(apply, new VPatch(
	            VPatch.ORDER,
	            a,
	            orderedSet.moves
	        ))
	    }

	    return apply
	}

	function clearState(vNode, patch, index) {
	    // TODO: Make this a single walk, not two
	    unhook(vNode, patch, index)
	    destroyWidgets(vNode, patch, index)
	}

	// Patch records for all destroyed widgets must be added because we need
	// a DOM node reference for the destroy function
	function destroyWidgets(vNode, patch, index) {
	    if (isWidget(vNode)) {
	        if (typeof vNode.destroy === "function") {
	            patch[index] = appendPatch(
	                patch[index],
	                new VPatch(VPatch.REMOVE, vNode, null)
	            )
	        }
	    } else if (isVNode(vNode) && (vNode.hasWidgets || vNode.hasThunks)) {
	        var children = vNode.children
	        var len = children.length
	        for (var i = 0; i < len; i++) {
	            var child = children[i]
	            index += 1

	            destroyWidgets(child, patch, index)

	            if (isVNode(child) && child.count) {
	                index += child.count
	            }
	        }
	    } else if (isThunk(vNode)) {
	        thunks(vNode, null, patch, index)
	    }
	}

	// Create a sub-patch for thunks
	function thunks(a, b, patch, index) {
	    var nodes = handleThunk(a, b)
	    var thunkPatch = diff(nodes.a, nodes.b)
	    if (hasPatches(thunkPatch)) {
	        patch[index] = new VPatch(VPatch.THUNK, null, thunkPatch)
	    }
	}

	function hasPatches(patch) {
	    for (var index in patch) {
	        if (index !== "a") {
	            return true
	        }
	    }

	    return false
	}

	// Execute hooks when two nodes are identical
	function unhook(vNode, patch, index) {
	    if (isVNode(vNode)) {
	        if (vNode.hooks) {
	            patch[index] = appendPatch(
	                patch[index],
	                new VPatch(
	                    VPatch.PROPS,
	                    vNode,
	                    undefinedKeys(vNode.hooks)
	                )
	            )
	        }

	        if (vNode.descendantHooks || vNode.hasThunks) {
	            var children = vNode.children
	            var len = children.length
	            for (var i = 0; i < len; i++) {
	                var child = children[i]
	                index += 1

	                unhook(child, patch, index)

	                if (isVNode(child) && child.count) {
	                    index += child.count
	                }
	            }
	        }
	    } else if (isThunk(vNode)) {
	        thunks(vNode, null, patch, index)
	    }
	}

	function undefinedKeys(obj) {
	    var result = {}

	    for (var key in obj) {
	        result[key] = undefined
	    }

	    return result
	}

	// List diff, naive left to right reordering
	function reorder(aChildren, bChildren) {
	    // O(M) time, O(M) memory
	    var bChildIndex = keyIndex(bChildren)
	    var bKeys = bChildIndex.keys
	    var bFree = bChildIndex.free

	    if (bFree.length === bChildren.length) {
	        return {
	            children: bChildren,
	            moves: null
	        }
	    }

	    // O(N) time, O(N) memory
	    var aChildIndex = keyIndex(aChildren)
	    var aKeys = aChildIndex.keys
	    var aFree = aChildIndex.free

	    if (aFree.length === aChildren.length) {
	        return {
	            children: bChildren,
	            moves: null
	        }
	    }

	    // O(MAX(N, M)) memory
	    var newChildren = []

	    var freeIndex = 0
	    var freeCount = bFree.length
	    var deletedItems = 0

	    // Iterate through a and match a node in b
	    // O(N) time,
	    for (var i = 0 ; i < aChildren.length; i++) {
	        var aItem = aChildren[i]
	        var itemIndex

	        if (aItem.key) {
	            if (bKeys.hasOwnProperty(aItem.key)) {
	                // Match up the old keys
	                itemIndex = bKeys[aItem.key]
	                newChildren.push(bChildren[itemIndex])

	            } else {
	                // Remove old keyed items
	                itemIndex = i - deletedItems++
	                newChildren.push(null)
	            }
	        } else {
	            // Match the item in a with the next free item in b
	            if (freeIndex < freeCount) {
	                itemIndex = bFree[freeIndex++]
	                newChildren.push(bChildren[itemIndex])
	            } else {
	                // There are no free items in b to match with
	                // the free items in a, so the extra free nodes
	                // are deleted.
	                itemIndex = i - deletedItems++
	                newChildren.push(null)
	            }
	        }
	    }

	    var lastFreeIndex = freeIndex >= bFree.length ?
	        bChildren.length :
	        bFree[freeIndex]

	    // Iterate through b and append any new keys
	    // O(M) time
	    for (var j = 0; j < bChildren.length; j++) {
	        var newItem = bChildren[j]

	        if (newItem.key) {
	            if (!aKeys.hasOwnProperty(newItem.key)) {
	                // Add any new keyed items
	                // We are adding new items to the end and then sorting them
	                // in place. In future we should insert new items in place.
	                newChildren.push(newItem)
	            }
	        } else if (j >= lastFreeIndex) {
	            // Add any leftover non-keyed items
	            newChildren.push(newItem)
	        }
	    }

	    var simulate = newChildren.slice()
	    var simulateIndex = 0
	    var removes = []
	    var inserts = []
	    var simulateItem

	    for (var k = 0; k < bChildren.length;) {
	        var wantedItem = bChildren[k]
	        simulateItem = simulate[simulateIndex]

	        // remove items
	        while (simulateItem === null && simulate.length) {
	            removes.push(remove(simulate, simulateIndex, null))
	            simulateItem = simulate[simulateIndex]
	        }

	        if (!simulateItem || simulateItem.key !== wantedItem.key) {
	            // if we need a key in this position...
	            if (wantedItem.key) {
	                if (simulateItem && simulateItem.key) {
	                    // if an insert doesn't put this key in place, it needs to move
	                    if (bKeys[simulateItem.key] !== k + 1) {
	                        removes.push(remove(simulate, simulateIndex, simulateItem.key))
	                        simulateItem = simulate[simulateIndex]
	                        // if the remove didn't put the wanted item in place, we need to insert it
	                        if (!simulateItem || simulateItem.key !== wantedItem.key) {
	                            inserts.push({key: wantedItem.key, to: k})
	                        }
	                        // items are matching, so skip ahead
	                        else {
	                            simulateIndex++
	                        }
	                    }
	                    else {
	                        inserts.push({key: wantedItem.key, to: k})
	                    }
	                }
	                else {
	                    inserts.push({key: wantedItem.key, to: k})
	                }
	                k++
	            }
	            // a key in simulate has no matching wanted key, remove it
	            else if (simulateItem && simulateItem.key) {
	                removes.push(remove(simulate, simulateIndex, simulateItem.key))
	            }
	        }
	        else {
	            simulateIndex++
	            k++
	        }
	    }

	    // remove all the remaining nodes from simulate
	    while(simulateIndex < simulate.length) {
	        simulateItem = simulate[simulateIndex]
	        removes.push(remove(simulate, simulateIndex, simulateItem && simulateItem.key))
	    }

	    // If the only moves we have are deletes then we can just
	    // let the delete patch remove these items.
	    if (removes.length === deletedItems && !inserts.length) {
	        return {
	            children: newChildren,
	            moves: null
	        }
	    }

	    return {
	        children: newChildren,
	        moves: {
	            removes: removes,
	            inserts: inserts
	        }
	    }
	}

	function remove(arr, index, key) {
	    arr.splice(index, 1)

	    return {
	        from: index,
	        key: key
	    }
	}

	function keyIndex(children) {
	    var keys = {}
	    var free = []
	    var length = children.length

	    for (var i = 0; i < length; i++) {
	        var child = children[i]

	        if (child.key) {
	            keys[child.key] = i
	        } else {
	            free.push(i)
	        }
	    }

	    return {
	        keys: keys,     // A hash of key name to index
	        free: free      // An array of unkeyed item indices
	    }
	}

	function appendPatch(apply, patch) {
	    if (apply) {
	        if (isArray(apply)) {
	            apply.push(patch)
	        } else {
	            apply = [apply, patch]
	        }

	        return apply
	    } else {
	        return patch
	    }
	}


/***/ },
/* 3 */
/***/ function(module, exports) {

	var nativeIsArray = Array.isArray
	var toString = Object.prototype.toString

	module.exports = nativeIsArray || isArray

	function isArray(obj) {
	    return toString.call(obj) === "[object Array]"
	}


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	var version = __webpack_require__(5)

	VirtualPatch.NONE = 0
	VirtualPatch.VTEXT = 1
	VirtualPatch.VNODE = 2
	VirtualPatch.WIDGET = 3
	VirtualPatch.PROPS = 4
	VirtualPatch.ORDER = 5
	VirtualPatch.INSERT = 6
	VirtualPatch.REMOVE = 7
	VirtualPatch.THUNK = 8

	module.exports = VirtualPatch

	function VirtualPatch(type, vNode, patch) {
	    this.type = Number(type)
	    this.vNode = vNode
	    this.patch = patch
	}

	VirtualPatch.prototype.version = version
	VirtualPatch.prototype.type = "VirtualPatch"


/***/ },
/* 5 */
/***/ function(module, exports) {

	module.exports = "2"


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	var version = __webpack_require__(5)

	module.exports = isVirtualNode

	function isVirtualNode(x) {
	    return x && x.type === "VirtualNode" && x.version === version
	}


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	var version = __webpack_require__(5)

	module.exports = isVirtualText

	function isVirtualText(x) {
	    return x && x.type === "VirtualText" && x.version === version
	}


/***/ },
/* 8 */
/***/ function(module, exports) {

	module.exports = isWidget

	function isWidget(w) {
	    return w && w.type === "Widget"
	}


/***/ },
/* 9 */
/***/ function(module, exports) {

	module.exports = isThunk

	function isThunk(t) {
	    return t && t.type === "Thunk"
	}


/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	var isVNode = __webpack_require__(6)
	var isVText = __webpack_require__(7)
	var isWidget = __webpack_require__(8)
	var isThunk = __webpack_require__(9)

	module.exports = handleThunk

	function handleThunk(a, b) {
	    var renderedA = a
	    var renderedB = b

	    if (isThunk(b)) {
	        renderedB = renderThunk(b, a)
	    }

	    if (isThunk(a)) {
	        renderedA = renderThunk(a, null)
	    }

	    return {
	        a: renderedA,
	        b: renderedB
	    }
	}

	function renderThunk(thunk, previous) {
	    var renderedThunk = thunk.vnode

	    if (!renderedThunk) {
	        renderedThunk = thunk.vnode = thunk.render(previous)
	    }

	    if (!(isVNode(renderedThunk) ||
	            isVText(renderedThunk) ||
	            isWidget(renderedThunk))) {
	        throw new Error("thunk did not return a valid node");
	    }

	    return renderedThunk
	}


/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	var isObject = __webpack_require__(12)
	var isHook = __webpack_require__(13)

	module.exports = diffProps

	function diffProps(a, b) {
	    var diff

	    for (var aKey in a) {
	        if (!(aKey in b)) {
	            diff = diff || {}
	            diff[aKey] = undefined
	        }

	        var aValue = a[aKey]
	        var bValue = b[aKey]

	        if (aValue === bValue) {
	            continue
	        } else if (isObject(aValue) && isObject(bValue)) {
	            if (getPrototype(bValue) !== getPrototype(aValue)) {
	                diff = diff || {}
	                diff[aKey] = bValue
	            } else if (isHook(bValue)) {
	                 diff = diff || {}
	                 diff[aKey] = bValue
	            } else {
	                var objectDiff = diffProps(aValue, bValue)
	                if (objectDiff) {
	                    diff = diff || {}
	                    diff[aKey] = objectDiff
	                }
	            }
	        } else {
	            diff = diff || {}
	            diff[aKey] = bValue
	        }
	    }

	    for (var bKey in b) {
	        if (!(bKey in a)) {
	            diff = diff || {}
	            diff[bKey] = b[bKey]
	        }
	    }

	    return diff
	}

	function getPrototype(value) {
	  if (Object.getPrototypeOf) {
	    return Object.getPrototypeOf(value)
	  } else if (value.__proto__) {
	    return value.__proto__
	  } else if (value.constructor) {
	    return value.constructor.prototype
	  }
	}


/***/ },
/* 12 */
/***/ function(module, exports) {

	"use strict";

	module.exports = function isObject(x) {
		return typeof x === "object" && x !== null;
	};


/***/ },
/* 13 */
/***/ function(module, exports) {

	module.exports = isHook

	function isHook(hook) {
	    return hook &&
	      (typeof hook.hook === "function" && !hook.hasOwnProperty("hook") ||
	       typeof hook.unhook === "function" && !hook.hasOwnProperty("unhook"))
	}


/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	var patch = __webpack_require__(15)

	module.exports = patch


/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	var document = __webpack_require__(16)
	var isArray = __webpack_require__(3)

	var render = __webpack_require__(18)
	var domIndex = __webpack_require__(20)
	var patchOp = __webpack_require__(21)
	var VPatch = __webpack_require__(4)
	module.exports = patch

	function patch(rootNode, patches, renderOptions) {
	    renderOptions = renderOptions || {}
	    renderOptions.patch = renderOptions.patch && renderOptions.patch !== patch
	        ? renderOptions.patch
	        : patchRecursive
	    renderOptions.render = renderOptions.render || render

	    return renderOptions.patch(rootNode, patches, renderOptions)
	}

	function patchRecursive(rootNode, patches, renderOptions) {
	    var indices = patchIndices(patches)

	    if (indices.length === 0) {
	        return rootNode
	    }

	    var index = domIndex(rootNode, patches.a, indices)
	    var ownerDocument = rootNode.ownerDocument

	    if (!renderOptions.document && ownerDocument !== document) {
	        renderOptions.document = ownerDocument
	    }

	    for (var i = 0; i < indices.length; i++) {
	        var nodeIndex = indices[i]
	        rootNode = applyPatch(rootNode,
	            index[nodeIndex],
	            patches[nodeIndex],
	            renderOptions)
	    }

	    return rootNode
	}

	function applyPatch(rootNode, domNode, patchList, renderOptions) {
	    if (!domNode) {
	        return rootNode
	    }

	    var newNode

	    if (isArray(patchList)) {
	        var propsPatchList = [];

	        for (var i = 0; i < patchList.length; i++) {
	            if (patchList[i].type != VPatch.PROPS) {
	                newNode = patchOp(patchList[i], domNode, renderOptions)

	                if (domNode === rootNode) {
	                    rootNode = newNode
	                }
	            }
	            else {
	                propsPatchList.push(patchList[i]);
	            }
	        }

	        // Properties like scrollTop should be set after all children have been
	        // patched, otherwise they wouldn't take effect.
	        for (var i = 0; i < propsPatchList.length; i++) {
	            newNode = patchOp(propsPatchList[i], domNode, renderOptions)

	            if (domNode === rootNode) {
	                rootNode = newNode
	            }
	        }
	    } else {
	        newNode = patchOp(patchList, domNode, renderOptions)

	        if (domNode === rootNode) {
	            rootNode = newNode
	        }
	    }

	    return rootNode
	}

	function patchIndices(patches) {
	    var indices = []

	    for (var key in patches) {
	        if (key !== "a") {
	            indices.push(Number(key))
	        }
	    }

	    return indices
	}


/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {var topLevel = typeof global !== 'undefined' ? global :
	    typeof window !== 'undefined' ? window : {}
	var minDoc = __webpack_require__(17);

	if (typeof document !== 'undefined') {
	    module.exports = document;
	} else {
	    var doccy = topLevel['__GLOBAL_DOCUMENT_CACHE@4'];

	    if (!doccy) {
	        doccy = topLevel['__GLOBAL_DOCUMENT_CACHE@4'] = minDoc;
	    }

	    module.exports = doccy;
	}

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 17 */
/***/ function(module, exports) {

	/* (ignored) */

/***/ },
/* 18 */
/***/ function(module, exports, __webpack_require__) {

	var document = __webpack_require__(16)

	var applyProperties = __webpack_require__(19)

	var isVNode = __webpack_require__(6)
	var isVText = __webpack_require__(7)
	var isWidget = __webpack_require__(8)
	var handleThunk = __webpack_require__(10)

	module.exports = createElement

	function createElement(vnode, opts) {
	    var doc = opts ? opts.document || document : document
	    var warn = opts ? opts.warn : null

	    vnode = handleThunk(vnode).a

	    if (isWidget(vnode)) {
	        return vnode.init()
	    } else if (isVText(vnode)) {
	        return doc.createTextNode(vnode.text)
	    } else if (!isVNode(vnode)) {
	        if (warn) {
	            warn("Item is not a valid virtual dom node", vnode)
	        }
	        return null
	    }

	    var node = (vnode.namespace === null) ?
	        doc.createElement(vnode.tagName) :
	        doc.createElementNS(vnode.namespace, vnode.tagName)

	    var props = vnode.properties

	    var children = vnode.children

	    for (var i = 0; i < children.length; i++) {
	        var childNode = createElement(children[i], opts)
	        if (childNode) {
	            node.appendChild(childNode)
	        }
	    }

	    applyProperties(node, props)

	    return node
	}


/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	var isObject = __webpack_require__(12)
	var isHook = __webpack_require__(13)

	module.exports = applyProperties

	function applyProperties(node, props, previous) {
	    for (var propName in props) {
	        var propValue = props[propName]

	        if (propValue === undefined) {
	            removeProperty(node, propName, propValue, previous);
	        } else if (isHook(propValue)) {
	            removeProperty(node, propName, propValue, previous)
	            if (propValue.hook) {
	                propValue.hook(node,
	                    propName,
	                    previous ? previous[propName] : undefined)
	            }
	        } else {
	            if (isObject(propValue)) {
	                patchObject(node, props, previous, propName, propValue);
	            } else {
	                node[propName] = propValue
	            }
	        }
	    }
	}

	function removeProperty(node, propName, propValue, previous) {
	    if (previous) {
	        var previousValue = previous[propName]

	        if (!isHook(previousValue)) {
	            if (propName === "attributes") {
	                for (var attrName in previousValue) {
	                    node.removeAttribute(attrName)
	                }
	            } else if (propName === "style") {
	                for (var i in previousValue) {
	                    node.style[i] = ""
	                }
	            } else if (typeof previousValue === "string") {
	                node[propName] = ""
	            } else {
	                node[propName] = null
	            }
	        } else if (previousValue.unhook) {
	            previousValue.unhook(node, propName, propValue)
	        }
	    }
	}

	function patchObject(node, props, previous, propName, propValue) {
	    var previousValue = previous ? previous[propName] : undefined

	    // Set attributes
	    if (propName === "attributes") {
	        for (var attrName in propValue) {
	            var attrValue = propValue[attrName]

	            if (attrValue === undefined) {
	                node.removeAttribute(attrName)
	            } else {
	                node.setAttribute(attrName, attrValue)
	            }
	        }

	        return
	    }

	    if(previousValue && isObject(previousValue) &&
	        getPrototype(previousValue) !== getPrototype(propValue)) {
	        node[propName] = propValue
	        return
	    }

	    if (!isObject(node[propName])) {
	        node[propName] = {}
	    }

	    var replacer = propName === "style" ? "" : undefined

	    for (var k in propValue) {
	        var value = propValue[k]
	        node[propName][k] = (value === undefined) ? replacer : value
	    }
	}

	function getPrototype(value) {
	    if (Object.getPrototypeOf) {
	        return Object.getPrototypeOf(value)
	    } else if (value.__proto__) {
	        return value.__proto__
	    } else if (value.constructor) {
	        return value.constructor.prototype
	    }
	}


/***/ },
/* 20 */
/***/ function(module, exports) {

	// Maps a virtual DOM tree onto a real DOM tree in an efficient manner.
	// We don't want to read all of the DOM nodes in the tree so we use
	// the in-order tree indexing to eliminate recursion down certain branches.
	// We only recurse into a DOM node if we know that it contains a child of
	// interest.

	var noChild = {}

	module.exports = domIndex

	function domIndex(rootNode, tree, indices, nodes) {
	    if (!indices || indices.length === 0) {
	        return {}
	    } else {
	        indices.sort(ascending)
	        return recurse(rootNode, tree, indices, nodes, 0)
	    }
	}

	function recurse(rootNode, tree, indices, nodes, rootIndex) {
	    nodes = nodes || {}


	    if (rootNode) {
	        if (indexInRange(indices, rootIndex, rootIndex)) {
	            nodes[rootIndex] = rootNode
	        }

	        var vChildren = tree.children

	        if (vChildren) {

	            var childNodes = rootNode.childNodes

	            for (var i = 0; i < tree.children.length; i++) {
	                rootIndex += 1

	                var vChild = vChildren[i] || noChild
	                var nextIndex = rootIndex + (vChild.count || 0)

	                // skip recursion down the tree if there are no nodes down here
	                if (indexInRange(indices, rootIndex, nextIndex)) {
	                    recurse(childNodes[i], vChild, indices, nodes, rootIndex)
	                }

	                rootIndex = nextIndex
	            }
	        }
	    }

	    return nodes
	}

	// Binary search for an index in the interval [left, right]
	function indexInRange(indices, left, right) {
	    if (indices.length === 0) {
	        return false
	    }

	    var minIndex = 0
	    var maxIndex = indices.length - 1
	    var currentIndex
	    var currentItem

	    while (minIndex <= maxIndex) {
	        currentIndex = ((maxIndex + minIndex) / 2) >> 0
	        currentItem = indices[currentIndex]

	        if (minIndex === maxIndex) {
	            return currentItem >= left && currentItem <= right
	        } else if (currentItem < left) {
	            minIndex = currentIndex + 1
	        } else  if (currentItem > right) {
	            maxIndex = currentIndex - 1
	        } else {
	            return true
	        }
	    }

	    return false;
	}

	function ascending(a, b) {
	    return a > b ? 1 : -1
	}


/***/ },
/* 21 */
/***/ function(module, exports, __webpack_require__) {

	var applyProperties = __webpack_require__(19)

	var isWidget = __webpack_require__(8)
	var VPatch = __webpack_require__(4)

	var updateWidget = __webpack_require__(22)

	module.exports = applyPatch

	function applyPatch(vpatch, domNode, renderOptions) {
	    var type = vpatch.type
	    var vNode = vpatch.vNode
	    var patch = vpatch.patch

	    switch (type) {
	        case VPatch.REMOVE:
	            return removeNode(domNode, vNode)
	        case VPatch.INSERT:
	            return insertNode(domNode, patch, renderOptions)
	        case VPatch.VTEXT:
	            return stringPatch(domNode, vNode, patch, renderOptions)
	        case VPatch.WIDGET:
	            return widgetPatch(domNode, vNode, patch, renderOptions)
	        case VPatch.VNODE:
	            return vNodePatch(domNode, vNode, patch, renderOptions)
	        case VPatch.ORDER:
	            reorderChildren(domNode, patch)
	            return domNode
	        case VPatch.PROPS:
	            applyProperties(domNode, patch, vNode.properties)
	            return domNode
	        case VPatch.THUNK:
	            return replaceRoot(domNode,
	                renderOptions.patch(domNode, patch, renderOptions))
	        default:
	            return domNode
	    }
	}

	function removeNode(domNode, vNode) {
	    var parentNode = domNode.parentNode

	    if (parentNode) {
	        parentNode.removeChild(domNode)
	    }

	    destroyWidget(domNode, vNode);

	    return null
	}

	function insertNode(parentNode, vNode, renderOptions) {
	    var newNode = renderOptions.render(vNode, renderOptions)

	    if (parentNode) {
	        parentNode.appendChild(newNode)
	    }

	    return parentNode
	}

	function stringPatch(domNode, leftVNode, vText, renderOptions) {
	    var newNode

	    if (domNode.nodeType === 3) {
	        domNode.replaceData(0, domNode.length, vText.text)
	        newNode = domNode
	    } else {
	        var parentNode = domNode.parentNode
	        newNode = renderOptions.render(vText, renderOptions)

	        if (parentNode && newNode !== domNode) {
	            parentNode.replaceChild(newNode, domNode)
	        }
	    }

	    return newNode
	}

	function widgetPatch(domNode, leftVNode, widget, renderOptions) {
	    var updating = updateWidget(leftVNode, widget)
	    var newNode

	    if (updating) {
	        newNode = widget.update(leftVNode, domNode) || domNode
	    } else {
	        newNode = renderOptions.render(widget, renderOptions)
	    }

	    var parentNode = domNode.parentNode

	    if (parentNode && newNode !== domNode) {
	        parentNode.replaceChild(newNode, domNode)
	    }

	    if (!updating) {
	        destroyWidget(domNode, leftVNode)
	    }

	    return newNode
	}

	function vNodePatch(domNode, leftVNode, vNode, renderOptions) {
	    var parentNode = domNode.parentNode
	    var newNode = renderOptions.render(vNode, renderOptions)

	    if (parentNode && newNode !== domNode) {
	        parentNode.replaceChild(newNode, domNode)
	    }

	    return newNode
	}

	function destroyWidget(domNode, w) {
	    if (typeof w.destroy === "function" && isWidget(w)) {
	        w.destroy(domNode)
	    }
	}

	function reorderChildren(domNode, moves) {
	    var childNodes = domNode.childNodes
	    var keyMap = {}
	    var node
	    var remove
	    var insert

	    for (var i = 0; i < moves.removes.length; i++) {
	        remove = moves.removes[i]
	        node = childNodes[remove.from]
	        if (remove.key) {
	            keyMap[remove.key] = node
	        }
	        domNode.removeChild(node)
	    }

	    var length = childNodes.length
	    for (var j = 0; j < moves.inserts.length; j++) {
	        insert = moves.inserts[j]
	        node = keyMap[insert.key]
	        // this is the weirdest bug i've ever seen in webkit
	        domNode.insertBefore(node, insert.to >= length++ ? null : childNodes[insert.to])
	    }
	}

	function replaceRoot(oldRoot, newRoot) {
	    if (oldRoot && newRoot && oldRoot !== newRoot && oldRoot.parentNode) {
	        oldRoot.parentNode.replaceChild(newRoot, oldRoot)
	    }

	    return newRoot;
	}


/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	var isWidget = __webpack_require__(8)

	module.exports = updateWidget

	function updateWidget(a, b) {
	    if (isWidget(a) && isWidget(b)) {
	        if ("name" in a && "name" in b) {
	            return a.id === b.id
	        } else {
	            return a.init === b.init
	        }
	    }

	    return false
	}


/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	var h = __webpack_require__(24)

	module.exports = h


/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var isArray = __webpack_require__(3);

	var VNode = __webpack_require__(25);
	var VText = __webpack_require__(26);
	var isVNode = __webpack_require__(6);
	var isVText = __webpack_require__(7);
	var isWidget = __webpack_require__(8);
	var isHook = __webpack_require__(13);
	var isVThunk = __webpack_require__(9);

	var parseTag = __webpack_require__(27);
	var softSetHook = __webpack_require__(28);
	var evHook = __webpack_require__(29);

	module.exports = h;

	function h(tagName, properties, children) {
	    var childNodes = [];
	    var tag, props, key, namespace;

	    if (!children && isChildren(properties)) {
	        children = properties;
	        props = {};
	    }

	    props = props || properties || {};
	    tag = parseTag(tagName, props);

	    // support keys
	    if (props.hasOwnProperty('key')) {
	        key = props.key;
	        props.key = undefined;
	    }

	    // support namespace
	    if (props.hasOwnProperty('namespace')) {
	        namespace = props.namespace;
	        props.namespace = undefined;
	    }

	    // fix cursor bug
	    if (tag === 'INPUT' &&
	        !namespace &&
	        props.hasOwnProperty('value') &&
	        props.value !== undefined &&
	        !isHook(props.value)
	    ) {
	        if(typeof props.value === 'number') {
	            props.value = String(props.value);
	        }

	        if (props.value !== null && typeof props.value !== 'string') {
	            throw UnsupportedValueType({
	                expected: 'String',
	                received: typeof props.value,
	                Vnode: {
	                    tagName: tag,
	                    properties: props
	                }
	            });
	        }
	        props.value = softSetHook(props.value);
	    }

	    transformProperties(props);

	    if (children !== undefined && children !== null) {
	        addChild(children, childNodes, tag, props);
	    }


	    return new VNode(tag, props, childNodes, key, namespace);
	}

	function addChild(c, childNodes, tag, props) {
	    if (typeof c === 'string') {
	        childNodes.push(new VText(c));
	    } else if (typeof c === 'number') {
	        childNodes.push(new VText(String(c)));
	    } else if (isChild(c)) {
	        childNodes.push(c);
	    } else if (isArray(c)) {
	        for (var i = 0; i < c.length; i++) {
	            addChild(c[i], childNodes, tag, props);
	        }
	    } else if (c === null || c === undefined) {
	        return;
	    } else {
	        throw UnexpectedVirtualElement({
	            foreignObject: c,
	            parentVnode: {
	                tagName: tag,
	                properties: props
	            }
	        });
	    }
	}

	function transformProperties(props) {
	    for (var propName in props) {
	        if (props.hasOwnProperty(propName)) {
	            var value = props[propName];

	            if (isHook(value)) {
	                continue;
	            }

	            if (propName.substr(0, 3) === 'ev-') {
	                // add ev-foo support
	                props[propName] = evHook(value);
	            }
	        }
	    }
	}

	function isChild(x) {
	    return isVNode(x) || isVText(x) || isWidget(x) || isVThunk(x);
	}

	function isChildren(x) {
	    return typeof x === 'string' || isArray(x) || isChild(x);
	}

	function UnexpectedVirtualElement(data) {
	    var err = new Error();

	    err.type = 'virtual-hyperscript.unexpected.virtual-element';
	    err.message = 'Unexpected virtual DOM node passed in.\n' +
	        'Expected a VNode, VText, String, Number, Clearwater::Component (or other renderable), or nil but:\n' +
	        'got:\n' +
	        errorString(data.foreignObject) +
	        '.\n' +
	        'The parent vnode is:\n' +
	        errorString(data.parentVnode) +
	        '\n' +
	        'Suggested fix: change your `h(..., [ ... ])` callsite.';
	    err.foreignObject = data.foreignObject;
	    err.parentVnode = data.parentVnode;

	    return err;
	}

	function UnsupportedValueType(data) {
	    var err = new Error();

	    err.type = 'virtual-hyperscript.unsupported.value-type';
	    err.message = 'Unexpected value type for input passed to h().\n' +
	        'Expected a ' +
	        errorString(data.expected) +
	        ' but got:\n' +
	        errorString(data.received) +
	        '.\n' +
	        'The vnode is:\n' +
	        errorString(data.Vnode);
	    err.Vnode = data.Vnode;

	    return err;
	}

	function errorString(obj) {
	    try {
	        if(obj.$$class) {
	          return obj.$inspect();
	        } else {
	          return JSON.stringify(obj, null, '    ');
	        }
	    } catch (e) {
	        return String(obj);
	    }
	}


/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	var version = __webpack_require__(5)
	var isVNode = __webpack_require__(6)
	var isWidget = __webpack_require__(8)
	var isThunk = __webpack_require__(9)
	var isVHook = __webpack_require__(13)

	module.exports = VirtualNode

	var noProperties = {}
	var noChildren = []

	function VirtualNode(tagName, properties, children, key, namespace) {
	    this.tagName = tagName
	    this.properties = properties || noProperties
	    this.children = children || noChildren
	    this.key = key != null ? String(key) : undefined
	    this.namespace = (typeof namespace === "string") ? namespace : null

	    var count = (children && children.length) || 0
	    var descendants = 0
	    var hasWidgets = false
	    var hasThunks = false
	    var descendantHooks = false
	    var hooks

	    for (var propName in properties) {
	        if (properties.hasOwnProperty(propName)) {
	            var property = properties[propName]
	            if (isVHook(property) && property.unhook) {
	                if (!hooks) {
	                    hooks = {}
	                }

	                hooks[propName] = property
	            }
	        }
	    }

	    for (var i = 0; i < count; i++) {
	        var child = children[i]
	        if (isVNode(child)) {
	            descendants += child.count || 0

	            if (!hasWidgets && child.hasWidgets) {
	                hasWidgets = true
	            }

	            if (!hasThunks && child.hasThunks) {
	                hasThunks = true
	            }

	            if (!descendantHooks && (child.hooks || child.descendantHooks)) {
	                descendantHooks = true
	            }
	        } else if (!hasWidgets && isWidget(child)) {
	            if (typeof child.destroy === "function") {
	                hasWidgets = true
	            }
	        } else if (!hasThunks && isThunk(child)) {
	            hasThunks = true;
	        }
	    }

	    this.count = count + descendants
	    this.hasWidgets = hasWidgets
	    this.hasThunks = hasThunks
	    this.hooks = hooks
	    this.descendantHooks = descendantHooks
	}

	VirtualNode.prototype.version = version
	VirtualNode.prototype.type = "VirtualNode"


/***/ },
/* 26 */
/***/ function(module, exports, __webpack_require__) {

	var version = __webpack_require__(5)

	module.exports = VirtualText

	function VirtualText(text) {
	    this.text = String(text)
	}

	VirtualText.prototype.version = version
	VirtualText.prototype.type = "VirtualText"


/***/ },
/* 27 */
/***/ function(module, exports) {

	'use strict';

	module.exports = parseTag;

	function parseTag(tag, props) {
	    if (!tag) {
	        return 'DIV';
	    }

	    var noId = !(props.hasOwnProperty('id'));

	    var tagParts = splitTag(tag);

	    var tagName = tagParts[0] || 'DIV';

	    var classes, part, type, i;

	    for (i = 1; i < tagParts.length; i++) {
	        part = tagParts[i];

	        if (!part) {
	            continue;
	        }

	        type = part.charAt(0);

	        if (type === '.') {
	            classes = classes || [];
	            classes.push(part.substring(1, part.length));
	        } else if (type === '#' && noId) {
	            props.id = part.substring(1, part.length);
	        }
	    }

	    if (classes) {
	        if (props.className) {
	            classes.push(props.className);
	        }

	        props.className = classes.join(' ');
	    }

	    return props.namespace ? tagName : tagName.toUpperCase();
	}


	function splitTag(tag) {

	    var classIndex, idIndex,
	        remaining = tag,
	        parts = [],
	        last = '';

	    do {
	        idIndex = remaining.indexOf('#');
	        classIndex = remaining.indexOf('.');
	        if ((idIndex === -1 || idIndex > classIndex) && classIndex !== -1) {
	            parts.push(last + remaining.substr(0, classIndex));
	            last = '.';
	            remaining = remaining.substr(classIndex + 1);
	        } else if (idIndex !== -1){
	            parts.push(last + remaining.substr(0, idIndex));
	            last = '#';
	            remaining = remaining.substr(idIndex + 1);
	        }

	    } while(idIndex !== -1 || classIndex !== -1)

	    parts.push(last + remaining);

	    return parts;
	}


/***/ },
/* 28 */
/***/ function(module, exports) {

	'use strict';

	module.exports = SoftSetHook;

	function SoftSetHook(value) {
	    if (!(this instanceof SoftSetHook)) {
	        return new SoftSetHook(value);
	    }

	    this.value = value;
	}

	SoftSetHook.prototype.hook = function (node, propertyName) {
	    if (node[propertyName] !== this.value) {
	        node[propertyName] = this.value;
	    }
	};


/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var EvStore = __webpack_require__(30);

	module.exports = EvHook;

	function EvHook(value) {
	    if (!(this instanceof EvHook)) {
	        return new EvHook(value);
	    }

	    this.value = value;
	}

	EvHook.prototype.hook = function (node, propertyName) {
	    var es = EvStore(node);
	    var propName = propertyName.substr(3);

	    es[propName] = this.value;
	};

	EvHook.prototype.unhook = function(node, propertyName) {
	    var es = EvStore(node);
	    var propName = propertyName.substr(3);

	    es[propName] = undefined;
	};


/***/ },
/* 30 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var OneVersionConstraint = __webpack_require__(31);

	var MY_VERSION = '7';
	OneVersionConstraint('ev-store', MY_VERSION);

	var hashKey = '__EV_STORE_KEY@' + MY_VERSION;

	module.exports = EvStore;

	function EvStore(elem) {
	    var hash = elem[hashKey];

	    if (!hash) {
	        hash = elem[hashKey] = {};
	    }

	    return hash;
	}


/***/ },
/* 31 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var Individual = __webpack_require__(32);

	module.exports = OneVersion;

	function OneVersion(moduleName, version, defaultValue) {
	    var key = '__INDIVIDUAL_ONE_VERSION_' + moduleName;
	    var enforceKey = key + '_ENFORCE_SINGLETON';

	    var versionValue = Individual(enforceKey, version);

	    if (versionValue !== version) {
	        throw new Error('Can only have one copy of ' +
	            moduleName + '.\n' +
	            'You already have version ' + versionValue +
	            ' installed.\n' +
	            'This means you cannot install version ' + version);
	    }

	    return Individual(key, defaultValue);
	}


/***/ },
/* 32 */
/***/ function(module, exports) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';

	/*global window, global*/

	var root = typeof window !== 'undefined' ?
	    window : typeof global !== 'undefined' ?
	    global : {};

	module.exports = Individual;

	function Individual(key, value) {
	    if (key in root) {
	        return root[key];
	    }

	    root[key] = value;

	    return value;
	}

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 33 */
/***/ function(module, exports, __webpack_require__) {

	var createElement = __webpack_require__(18)

	module.exports = createElement


/***/ },
/* 34 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var isArray = __webpack_require__(3);

	var h = __webpack_require__(24);


	var SVGAttributeNamespace = __webpack_require__(35);
	var attributeHook = __webpack_require__(36);

	var SVG_NAMESPACE = 'http://www.w3.org/2000/svg';

	module.exports = svg;

	function svg(tagName, properties, children) {
	    if (!children && isChildren(properties)) {
	        children = properties;
	        properties = {};
	    }

	    properties = properties || {};

	    // set namespace for svg
	    properties.namespace = SVG_NAMESPACE;

	    var attributes = properties.attributes || (properties.attributes = {});

	    for (var key in properties) {
	        if (!properties.hasOwnProperty(key)) {
	            continue;
	        }

	        var namespace = SVGAttributeNamespace(key);

	        if (namespace === undefined) { // not a svg attribute
	            continue;
	        }

	        var value = properties[key];

	        if (typeof value !== 'string' &&
	            typeof value !== 'number' &&
	            typeof value !== 'boolean'
	        ) {
	            continue;
	        }

	        if (namespace !== null) { // namespaced attribute
	            properties[key] = attributeHook(namespace, value);
	            continue;
	        }

	        attributes[key] = value
	        properties[key] = undefined
	    }

	    return h(tagName, properties, children);
	}

	function isChildren(x) {
	    return typeof x === 'string' || isArray(x);
	}


/***/ },
/* 35 */
/***/ function(module, exports) {

	'use strict';

	var DEFAULT_NAMESPACE = null;
	var EV_NAMESPACE = 'http://www.w3.org/2001/xml-events';
	var XLINK_NAMESPACE = 'http://www.w3.org/1999/xlink';
	var XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace';

	// http://www.w3.org/TR/SVGTiny12/attributeTable.html
	// http://www.w3.org/TR/SVG/attindex.html
	var SVG_PROPERTIES = {
	    'about': DEFAULT_NAMESPACE,
	    'accent-height': DEFAULT_NAMESPACE,
	    'accumulate': DEFAULT_NAMESPACE,
	    'additive': DEFAULT_NAMESPACE,
	    'alignment-baseline': DEFAULT_NAMESPACE,
	    'alphabetic': DEFAULT_NAMESPACE,
	    'amplitude': DEFAULT_NAMESPACE,
	    'arabic-form': DEFAULT_NAMESPACE,
	    'ascent': DEFAULT_NAMESPACE,
	    'attributeName': DEFAULT_NAMESPACE,
	    'attributeType': DEFAULT_NAMESPACE,
	    'azimuth': DEFAULT_NAMESPACE,
	    'bandwidth': DEFAULT_NAMESPACE,
	    'baseFrequency': DEFAULT_NAMESPACE,
	    'baseProfile': DEFAULT_NAMESPACE,
	    'baseline-shift': DEFAULT_NAMESPACE,
	    'bbox': DEFAULT_NAMESPACE,
	    'begin': DEFAULT_NAMESPACE,
	    'bias': DEFAULT_NAMESPACE,
	    'by': DEFAULT_NAMESPACE,
	    'calcMode': DEFAULT_NAMESPACE,
	    'cap-height': DEFAULT_NAMESPACE,
	    'class': DEFAULT_NAMESPACE,
	    'clip': DEFAULT_NAMESPACE,
	    'clip-path': DEFAULT_NAMESPACE,
	    'clip-rule': DEFAULT_NAMESPACE,
	    'clipPathUnits': DEFAULT_NAMESPACE,
	    'color': DEFAULT_NAMESPACE,
	    'color-interpolation': DEFAULT_NAMESPACE,
	    'color-interpolation-filters': DEFAULT_NAMESPACE,
	    'color-profile': DEFAULT_NAMESPACE,
	    'color-rendering': DEFAULT_NAMESPACE,
	    'content': DEFAULT_NAMESPACE,
	    'contentScriptType': DEFAULT_NAMESPACE,
	    'contentStyleType': DEFAULT_NAMESPACE,
	    'cursor': DEFAULT_NAMESPACE,
	    'cx': DEFAULT_NAMESPACE,
	    'cy': DEFAULT_NAMESPACE,
	    'd': DEFAULT_NAMESPACE,
	    'datatype': DEFAULT_NAMESPACE,
	    'defaultAction': DEFAULT_NAMESPACE,
	    'descent': DEFAULT_NAMESPACE,
	    'diffuseConstant': DEFAULT_NAMESPACE,
	    'direction': DEFAULT_NAMESPACE,
	    'display': DEFAULT_NAMESPACE,
	    'divisor': DEFAULT_NAMESPACE,
	    'dominant-baseline': DEFAULT_NAMESPACE,
	    'dur': DEFAULT_NAMESPACE,
	    'dx': DEFAULT_NAMESPACE,
	    'dy': DEFAULT_NAMESPACE,
	    'edgeMode': DEFAULT_NAMESPACE,
	    'editable': DEFAULT_NAMESPACE,
	    'elevation': DEFAULT_NAMESPACE,
	    'enable-background': DEFAULT_NAMESPACE,
	    'end': DEFAULT_NAMESPACE,
	    'ev:event': EV_NAMESPACE,
	    'event': DEFAULT_NAMESPACE,
	    'exponent': DEFAULT_NAMESPACE,
	    'externalResourcesRequired': DEFAULT_NAMESPACE,
	    'fill': DEFAULT_NAMESPACE,
	    'fill-opacity': DEFAULT_NAMESPACE,
	    'fill-rule': DEFAULT_NAMESPACE,
	    'filter': DEFAULT_NAMESPACE,
	    'filterRes': DEFAULT_NAMESPACE,
	    'filterUnits': DEFAULT_NAMESPACE,
	    'flood-color': DEFAULT_NAMESPACE,
	    'flood-opacity': DEFAULT_NAMESPACE,
	    'focusHighlight': DEFAULT_NAMESPACE,
	    'focusable': DEFAULT_NAMESPACE,
	    'font-family': DEFAULT_NAMESPACE,
	    'font-size': DEFAULT_NAMESPACE,
	    'font-size-adjust': DEFAULT_NAMESPACE,
	    'font-stretch': DEFAULT_NAMESPACE,
	    'font-style': DEFAULT_NAMESPACE,
	    'font-variant': DEFAULT_NAMESPACE,
	    'font-weight': DEFAULT_NAMESPACE,
	    'format': DEFAULT_NAMESPACE,
	    'from': DEFAULT_NAMESPACE,
	    'fx': DEFAULT_NAMESPACE,
	    'fy': DEFAULT_NAMESPACE,
	    'g1': DEFAULT_NAMESPACE,
	    'g2': DEFAULT_NAMESPACE,
	    'glyph-name': DEFAULT_NAMESPACE,
	    'glyph-orientation-horizontal': DEFAULT_NAMESPACE,
	    'glyph-orientation-vertical': DEFAULT_NAMESPACE,
	    'glyphRef': DEFAULT_NAMESPACE,
	    'gradientTransform': DEFAULT_NAMESPACE,
	    'gradientUnits': DEFAULT_NAMESPACE,
	    'handler': DEFAULT_NAMESPACE,
	    'hanging': DEFAULT_NAMESPACE,
	    'height': DEFAULT_NAMESPACE,
	    'horiz-adv-x': DEFAULT_NAMESPACE,
	    'horiz-origin-x': DEFAULT_NAMESPACE,
	    'horiz-origin-y': DEFAULT_NAMESPACE,
	    'id': DEFAULT_NAMESPACE,
	    'ideographic': DEFAULT_NAMESPACE,
	    'image-rendering': DEFAULT_NAMESPACE,
	    'in': DEFAULT_NAMESPACE,
	    'in2': DEFAULT_NAMESPACE,
	    'initialVisibility': DEFAULT_NAMESPACE,
	    'intercept': DEFAULT_NAMESPACE,
	    'k': DEFAULT_NAMESPACE,
	    'k1': DEFAULT_NAMESPACE,
	    'k2': DEFAULT_NAMESPACE,
	    'k3': DEFAULT_NAMESPACE,
	    'k4': DEFAULT_NAMESPACE,
	    'kernelMatrix': DEFAULT_NAMESPACE,
	    'kernelUnitLength': DEFAULT_NAMESPACE,
	    'kerning': DEFAULT_NAMESPACE,
	    'keyPoints': DEFAULT_NAMESPACE,
	    'keySplines': DEFAULT_NAMESPACE,
	    'keyTimes': DEFAULT_NAMESPACE,
	    'lang': DEFAULT_NAMESPACE,
	    'lengthAdjust': DEFAULT_NAMESPACE,
	    'letter-spacing': DEFAULT_NAMESPACE,
	    'lighting-color': DEFAULT_NAMESPACE,
	    'limitingConeAngle': DEFAULT_NAMESPACE,
	    'local': DEFAULT_NAMESPACE,
	    'marker-end': DEFAULT_NAMESPACE,
	    'marker-mid': DEFAULT_NAMESPACE,
	    'marker-start': DEFAULT_NAMESPACE,
	    'markerHeight': DEFAULT_NAMESPACE,
	    'markerUnits': DEFAULT_NAMESPACE,
	    'markerWidth': DEFAULT_NAMESPACE,
	    'mask': DEFAULT_NAMESPACE,
	    'maskContentUnits': DEFAULT_NAMESPACE,
	    'maskUnits': DEFAULT_NAMESPACE,
	    'mathematical': DEFAULT_NAMESPACE,
	    'max': DEFAULT_NAMESPACE,
	    'media': DEFAULT_NAMESPACE,
	    'mediaCharacterEncoding': DEFAULT_NAMESPACE,
	    'mediaContentEncodings': DEFAULT_NAMESPACE,
	    'mediaSize': DEFAULT_NAMESPACE,
	    'mediaTime': DEFAULT_NAMESPACE,
	    'method': DEFAULT_NAMESPACE,
	    'min': DEFAULT_NAMESPACE,
	    'mode': DEFAULT_NAMESPACE,
	    'name': DEFAULT_NAMESPACE,
	    'nav-down': DEFAULT_NAMESPACE,
	    'nav-down-left': DEFAULT_NAMESPACE,
	    'nav-down-right': DEFAULT_NAMESPACE,
	    'nav-left': DEFAULT_NAMESPACE,
	    'nav-next': DEFAULT_NAMESPACE,
	    'nav-prev': DEFAULT_NAMESPACE,
	    'nav-right': DEFAULT_NAMESPACE,
	    'nav-up': DEFAULT_NAMESPACE,
	    'nav-up-left': DEFAULT_NAMESPACE,
	    'nav-up-right': DEFAULT_NAMESPACE,
	    'numOctaves': DEFAULT_NAMESPACE,
	    'observer': DEFAULT_NAMESPACE,
	    'offset': DEFAULT_NAMESPACE,
	    'opacity': DEFAULT_NAMESPACE,
	    'operator': DEFAULT_NAMESPACE,
	    'order': DEFAULT_NAMESPACE,
	    'orient': DEFAULT_NAMESPACE,
	    'orientation': DEFAULT_NAMESPACE,
	    'origin': DEFAULT_NAMESPACE,
	    'overflow': DEFAULT_NAMESPACE,
	    'overlay': DEFAULT_NAMESPACE,
	    'overline-position': DEFAULT_NAMESPACE,
	    'overline-thickness': DEFAULT_NAMESPACE,
	    'panose-1': DEFAULT_NAMESPACE,
	    'path': DEFAULT_NAMESPACE,
	    'pathLength': DEFAULT_NAMESPACE,
	    'patternContentUnits': DEFAULT_NAMESPACE,
	    'patternTransform': DEFAULT_NAMESPACE,
	    'patternUnits': DEFAULT_NAMESPACE,
	    'phase': DEFAULT_NAMESPACE,
	    'playbackOrder': DEFAULT_NAMESPACE,
	    'pointer-events': DEFAULT_NAMESPACE,
	    'points': DEFAULT_NAMESPACE,
	    'pointsAtX': DEFAULT_NAMESPACE,
	    'pointsAtY': DEFAULT_NAMESPACE,
	    'pointsAtZ': DEFAULT_NAMESPACE,
	    'preserveAlpha': DEFAULT_NAMESPACE,
	    'preserveAspectRatio': DEFAULT_NAMESPACE,
	    'primitiveUnits': DEFAULT_NAMESPACE,
	    'propagate': DEFAULT_NAMESPACE,
	    'property': DEFAULT_NAMESPACE,
	    'r': DEFAULT_NAMESPACE,
	    'radius': DEFAULT_NAMESPACE,
	    'refX': DEFAULT_NAMESPACE,
	    'refY': DEFAULT_NAMESPACE,
	    'rel': DEFAULT_NAMESPACE,
	    'rendering-intent': DEFAULT_NAMESPACE,
	    'repeatCount': DEFAULT_NAMESPACE,
	    'repeatDur': DEFAULT_NAMESPACE,
	    'requiredExtensions': DEFAULT_NAMESPACE,
	    'requiredFeatures': DEFAULT_NAMESPACE,
	    'requiredFonts': DEFAULT_NAMESPACE,
	    'requiredFormats': DEFAULT_NAMESPACE,
	    'resource': DEFAULT_NAMESPACE,
	    'restart': DEFAULT_NAMESPACE,
	    'result': DEFAULT_NAMESPACE,
	    'rev': DEFAULT_NAMESPACE,
	    'role': DEFAULT_NAMESPACE,
	    'rotate': DEFAULT_NAMESPACE,
	    'rx': DEFAULT_NAMESPACE,
	    'ry': DEFAULT_NAMESPACE,
	    'scale': DEFAULT_NAMESPACE,
	    'seed': DEFAULT_NAMESPACE,
	    'shape-rendering': DEFAULT_NAMESPACE,
	    'slope': DEFAULT_NAMESPACE,
	    'snapshotTime': DEFAULT_NAMESPACE,
	    'spacing': DEFAULT_NAMESPACE,
	    'specularConstant': DEFAULT_NAMESPACE,
	    'specularExponent': DEFAULT_NAMESPACE,
	    'spreadMethod': DEFAULT_NAMESPACE,
	    'startOffset': DEFAULT_NAMESPACE,
	    'stdDeviation': DEFAULT_NAMESPACE,
	    'stemh': DEFAULT_NAMESPACE,
	    'stemv': DEFAULT_NAMESPACE,
	    'stitchTiles': DEFAULT_NAMESPACE,
	    'stop-color': DEFAULT_NAMESPACE,
	    'stop-opacity': DEFAULT_NAMESPACE,
	    'strikethrough-position': DEFAULT_NAMESPACE,
	    'strikethrough-thickness': DEFAULT_NAMESPACE,
	    'string': DEFAULT_NAMESPACE,
	    'stroke': DEFAULT_NAMESPACE,
	    'stroke-dasharray': DEFAULT_NAMESPACE,
	    'stroke-dashoffset': DEFAULT_NAMESPACE,
	    'stroke-linecap': DEFAULT_NAMESPACE,
	    'stroke-linejoin': DEFAULT_NAMESPACE,
	    'stroke-miterlimit': DEFAULT_NAMESPACE,
	    'stroke-opacity': DEFAULT_NAMESPACE,
	    'stroke-width': DEFAULT_NAMESPACE,
	    'surfaceScale': DEFAULT_NAMESPACE,
	    'syncBehavior': DEFAULT_NAMESPACE,
	    'syncBehaviorDefault': DEFAULT_NAMESPACE,
	    'syncMaster': DEFAULT_NAMESPACE,
	    'syncTolerance': DEFAULT_NAMESPACE,
	    'syncToleranceDefault': DEFAULT_NAMESPACE,
	    'systemLanguage': DEFAULT_NAMESPACE,
	    'tableValues': DEFAULT_NAMESPACE,
	    'target': DEFAULT_NAMESPACE,
	    'targetX': DEFAULT_NAMESPACE,
	    'targetY': DEFAULT_NAMESPACE,
	    'text-anchor': DEFAULT_NAMESPACE,
	    'text-decoration': DEFAULT_NAMESPACE,
	    'text-rendering': DEFAULT_NAMESPACE,
	    'textLength': DEFAULT_NAMESPACE,
	    'timelineBegin': DEFAULT_NAMESPACE,
	    'title': DEFAULT_NAMESPACE,
	    'to': DEFAULT_NAMESPACE,
	    'transform': DEFAULT_NAMESPACE,
	    'transformBehavior': DEFAULT_NAMESPACE,
	    'type': DEFAULT_NAMESPACE,
	    'typeof': DEFAULT_NAMESPACE,
	    'u1': DEFAULT_NAMESPACE,
	    'u2': DEFAULT_NAMESPACE,
	    'underline-position': DEFAULT_NAMESPACE,
	    'underline-thickness': DEFAULT_NAMESPACE,
	    'unicode': DEFAULT_NAMESPACE,
	    'unicode-bidi': DEFAULT_NAMESPACE,
	    'unicode-range': DEFAULT_NAMESPACE,
	    'units-per-em': DEFAULT_NAMESPACE,
	    'v-alphabetic': DEFAULT_NAMESPACE,
	    'v-hanging': DEFAULT_NAMESPACE,
	    'v-ideographic': DEFAULT_NAMESPACE,
	    'v-mathematical': DEFAULT_NAMESPACE,
	    'values': DEFAULT_NAMESPACE,
	    'version': DEFAULT_NAMESPACE,
	    'vert-adv-y': DEFAULT_NAMESPACE,
	    'vert-origin-x': DEFAULT_NAMESPACE,
	    'vert-origin-y': DEFAULT_NAMESPACE,
	    'viewBox': DEFAULT_NAMESPACE,
	    'viewTarget': DEFAULT_NAMESPACE,
	    'visibility': DEFAULT_NAMESPACE,
	    'width': DEFAULT_NAMESPACE,
	    'widths': DEFAULT_NAMESPACE,
	    'word-spacing': DEFAULT_NAMESPACE,
	    'writing-mode': DEFAULT_NAMESPACE,
	    'x': DEFAULT_NAMESPACE,
	    'x-height': DEFAULT_NAMESPACE,
	    'x1': DEFAULT_NAMESPACE,
	    'x2': DEFAULT_NAMESPACE,
	    'xChannelSelector': DEFAULT_NAMESPACE,
	    'xlink:actuate': XLINK_NAMESPACE,
	    'xlink:arcrole': XLINK_NAMESPACE,
	    'xlink:href': XLINK_NAMESPACE,
	    'xlink:role': XLINK_NAMESPACE,
	    'xlink:show': XLINK_NAMESPACE,
	    'xlink:title': XLINK_NAMESPACE,
	    'xlink:type': XLINK_NAMESPACE,
	    'xml:base': XML_NAMESPACE,
	    'xml:id': XML_NAMESPACE,
	    'xml:lang': XML_NAMESPACE,
	    'xml:space': XML_NAMESPACE,
	    'y': DEFAULT_NAMESPACE,
	    'y1': DEFAULT_NAMESPACE,
	    'y2': DEFAULT_NAMESPACE,
	    'yChannelSelector': DEFAULT_NAMESPACE,
	    'z': DEFAULT_NAMESPACE,
	    'zoomAndPan': DEFAULT_NAMESPACE
	};

	module.exports = SVGAttributeNamespace;

	function SVGAttributeNamespace(value) {
	  if (SVG_PROPERTIES.hasOwnProperty(value)) {
	    return SVG_PROPERTIES[value];
	  }
	}


/***/ },
/* 36 */
/***/ function(module, exports) {

	'use strict';

	module.exports = AttributeHook;

	function AttributeHook(namespace, value) {
	    if (!(this instanceof AttributeHook)) {
	        return new AttributeHook(namespace, value);
	    }

	    this.namespace = namespace;
	    this.value = value;
	}

	AttributeHook.prototype.hook = function (node, prop, prev) {
	    if (prev && prev.type === 'AttributeHook' &&
	        prev.value === this.value &&
	        prev.namespace === this.namespace) {
	        return;
	    }

	    node.setAttributeNS(this.namespace, prop, this.value);
	};

	AttributeHook.prototype.unhook = function (node, prop, next) {
	    if (next && next.type === 'AttributeHook' &&
	        next.namespace === this.namespace) {
	        return;
	    }

	    var colonPosition = prop.indexOf(':');
	    var localName = colonPosition > -1 ? prop.substr(colonPosition + 1) : prop;
	    node.removeAttributeNS(this.namespace, localName);
	};

	AttributeHook.prototype.type = 'AttributeHook';


/***/ }
/******/ ])
});
;