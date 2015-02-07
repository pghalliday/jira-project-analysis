React = require 'react'
LineChart = require('react-chartjs').Line

chartOptions =
  bezierCurve: false
  pointDot: false

Chart = React.createClass
  displayName: 'Chart'
  getInitialState: ->
    this.props.data
  render: ->
    <LineChart data={this.state} options={chartOptions} />

module.exports = Chart
