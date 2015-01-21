React = require 'react'
RadComponent = require './RadComponent'

window.onload = ->
  React.render(
    <RadComponent rad="Hell, yeah!"/>
    document.getElementById 'content'
  )
