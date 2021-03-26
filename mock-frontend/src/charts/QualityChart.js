
import React, {Component } from 'react';
import { Gauge } from '@ant-design/charts';

class QualityChart extends Component {

  render() {
    var ticks = [0, 1 / 3, 2 / 3, 1];
    var color = ['#30BF78', '#FAAD14', '#F4664A'];
    var config = {
      percent: 0.5,
      range: {
        ticks: [0, 1],
        color: ['l(0) 0:#30BF78 0.5:#FAAD14 1:#F4664A'],
      },
      indicator: {
        pointer: { style: { stroke: '#D0D0D0' } },
        pin: { style: { stroke: '#D0D0D0' } },
      },
      statistic: {
        title: {
          formatter: function formatter(_ref) {
            var percent = _ref.percent;
            if (percent < ticks[1]) {
              return '优';
            }
            if (percent < ticks[2]) {
              return '中';
            }
            return '差';
          },

          style: function style(_ref2) {
            var percent = _ref2.percent;
            return {
              fontSize: '20px',
              lineHeight: 1,
              color: percent < ticks[1] ? color[0] : percent < ticks[2] ? color[1] : color[2],
            };
          },
        },

        content: {
          offsetY: 36,
          style: {
            fontSize: '24px',
            color: '#4B535E',
          },
          formatter: function formatter() {
            return '空气质量';
          },
        },
      },
    };



    return <div>
      <Gauge {...config}/>
    </div>
  }
}

  export default QualityChart