import './App.css';
import QualityChart from './charts/QualityChart';
import PerformanceChart from './charts/PerformanceChart';
import {Row, Col} from 'antd';
import { useEffect, useState } from 'react';
const axios = require('axios').default;


var data1 = [
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

function App() {
  axios.get(
    'http://localhost:8000/api/services/fan/states',
    {
      headers : {
        Authorization : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3ZmJlZjYxMGQ3ZmY0YWE5ODAxZTMxZWQ4OGUwYzI1MyIsImhdCI6MTYxNTcwMDgyMSwiZXhwIjoxOTMxMDYwODIxfQ.ULDq6jx5XFxYeDOG2qTd-CiISry3lh_HVPvc5Y0Elxo',
        'Content-Type' : 'application/json;charset=utf-8'
      }
    }
  ).then(({data})=>{
    console.log(data)
  })

  const [data, setData] = useState(data1)

  useEffect(()=>{
    const intervalId =setInterval(()=> {
      data1[0].scales = data1[0].scales + 1
      setData(data1)
    }, 1000);

    return ()=>{
      clearInterval(intervalId)
    }
  },[])

  return (

    <div>
      <Row gutter={8}>
        <h1>空气质量(AQI)</h1>
        <Col span={8}>
          <QualityChart />
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>风扇转速(Fan Speed)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 0.5:#7ec2f3 1:#1890ff'} data={data}/>
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>温度(Temprature)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 1:#01ee01'} data={data}/>
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>湿度(Humidity)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 1:#fe0000'} data={data}/>
        </Col>
      </Row>
    </div>
  );
}



export default App;
