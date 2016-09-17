## Version 1.0.0.rc4

- Add routing transition hooks ([#52](https://github.com/clearwater-rb/clearwater/pull/52))
- Fix regression from rc1 where we optimized performance but accidentally sacrificed correctness in converting element attributes from Ruby hashes to JS objects for the virtual-DOM engine to consume.

## Version 1.0.0.rc3

- Fix bug with nested CachedRenders
- Fix bug that caused CachedRender components with a `@type` instance variable not to cache

## Version 1.0.0.rc2

- Free DOM nodes when a DOMReference's node has been removed from the DOM
- Handle case where a DOMReference has methods called on it before DOM rendering
- Memoize VDOM property camelization for improved performance
- Improve time to check whether properties passed in are a Hash
- Add the ability to unmount a Clearwater::Application

## Version 1.0.0.rc1

- Server rendering
- Improve performance of generating VDOM nodes
- Warn when trying to make persistent components cacheable

## Version 1.0.0.beta5

- Remove touch handlers from `Link`

## Version 1.0.0.beta4

- Improve SVG attribute sanitization

## Version 1.0.0.beta3

- Make route namespacing play nice with params

## Version 1.0.0.beta2

- Add `DOMReference#to_n` to play nice with a change to Opal's `Native` module

## Version 1.0.0.beta1

- Replace `opal-browser` gem with `bowser`
  - Significantly reduced JS payload size
  - Drastically reduced load times in development
- Add `BlackBoxNode` to let components manage themselves
- Add `DOMReference` to give apps a way to get real DOM nodes
