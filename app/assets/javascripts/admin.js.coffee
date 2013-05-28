#= require jquery
#= require jquery_ujs

$(document).on 'focus', 'textarea', ->
    namespace = 'sizer'
    textarea  = $(this)
    padding   = parseInt(textarea.css('paddingTop'), 10) + parseInt(textarea.css('paddingLeft'), 10)

    textarea.height textarea.prop('scrollHeight') - padding

    textarea.on "keypress.#{namespace} input.#{namespace} beforepaste.#{namespace}", ->
      textarea.height textarea.prop('scrollHeight') - padding

    textarea.on "blur.#{namespace}", ->
      textarea.height 1
      textarea.height textarea.prop('scrollHeight') - padding
      textarea.off ".#{namespace}"
