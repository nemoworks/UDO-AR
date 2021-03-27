import React, { useState, useEffect, Component } from 'react';
import { Area } from '@ant-design/charts';




function PerformanceChart({fill, data}) {
    var config = {
      data,
      xField: 'Date',
      yField: 'scales',
      xAxis: { tickCount: 5 },
      areaStyle: () => ({fill}),
    };

    return <Area {...config}/>
}



export default PerformanceChart;