React = require 'react'

App = React.createClass
  getInitialState: ->
    message: 'Hello, world!'
  render: ->
    <p>{this.state.message}</p>

module.exports = App
