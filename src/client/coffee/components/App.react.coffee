React = require 'react'
MyChart = require './MyChart.react'

App = React.createClass
  displayName: 'App'
  getInitialState: ->
    null
  render: ->
    containerStyle =
      display: 'flex'
    sidebarStyle =
      flexBasis: 330
    mainStyle =
      flexBasis: '100%'
    <div style={containerStyle}>
      <div style={sidebarStyle} />
      <MyChart style={mainStyle} />
    </div>

module.exports = App
