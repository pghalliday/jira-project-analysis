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
# coffeelint: disable=max_line_length
    <LineChart data={this.state} options={chartOptions} />
# coffeelint: enable=max_line_length

module.exports = Chart
