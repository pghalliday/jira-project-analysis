React = require 'react'
App = require './components/App.react'

render = ->
  React.render(
    <App />
    document.body
  )
 
window.addEventListener 'resize', render
 
render()
