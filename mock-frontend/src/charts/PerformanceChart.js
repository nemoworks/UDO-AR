import React, { useState, useEffect, Component } from 'react';
import { Area } from '@ant-design/charts';


class PerformanceChart extends Component {
  render() {
    var data = [
      {
        "Date": "2010-01",
        "scales": 1998
      },
      {
        "Date": "2010-02",
        "scales": 1850
      },
      {
        "Date": "2010-03",
        "scales": 1720
      },
      {
        "Date": "2010-04",
        "scales": 1818
      },
      {
        "Date": "2010-05",
        "scales": 1920
      },
      {
        "Date": "2010-06",
        "scales": 1802
      },
      {
        "Date": "2010-07",
        "scales": 1945
      },
      {
        "Date": "2010-08",
        "scales": 1856
      },
      {
        "Date": "2010-09",
        "scales": 2107
      },
    ]

    var config = {
      data: data,
      xField: 'Date',
      yField: 'scales',
      xAxis: { tickCount: 5 },
      areaStyle: function areaStyle() {
        return { fill: 'l(270) 0:#ffffff 0.5:#7ec2f3 1:#1890ff' };
      },
    };

    return <Area {...config}/>
  }

}

export default PerformanceChart;