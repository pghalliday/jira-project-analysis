React = require 'react'
test = require './test'

RadComponent = React.createClass
  render: ->
    <div className="rad-component">
      <p>is this component rad? {@props.rad}</p>
      <test/>
    </div>

module.exports = RadComponent
