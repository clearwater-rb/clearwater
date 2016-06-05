var diff       = require('virtual-dom/diff')
var patch      = require('virtual-dom/patch')
var h          = require('virtual-dom/h')
var create     = require('virtual-dom/create-element')
var VNode      = require('virtual-dom/vnode/vnode')
var VText      = require('virtual-dom/vnode/vtext')
var svg        = require('virtual-dom/virtual-hyperscript/svg')

module.exports = {
  diff,
  patch,
  h,
  create,
  VNode,
  VText,
  svg,
}
