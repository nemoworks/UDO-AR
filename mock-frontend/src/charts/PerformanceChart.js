import React, { useState, useEffect, Component } from 'react';
import { Area } from '@ant-design/charts';




function PerformanceChart({fill, data, xlabel, ylabel}) {
    var config = {
      data,
      xField: xlabel,
      yField: ylabel,
      xAxis: { tickCount: 5 },
      areaStyle: () => ({fill}),
    };

    return <Area {...config}/>
}



export default PerformanceChart;