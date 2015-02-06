React = require 'react'

App = React.createClass
  getInitialState: ->
    'Hello, world!'
  render: ->
    <p>{this.state}</p>

module.exports = App
