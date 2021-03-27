import './App.css';
import QualityChart from './charts/QualityChart';
import PerformanceChart from './charts/PerformanceChart';
import {Row, Col} from 'antd';
import { useEffect, useState } from 'react';
const axios = require('axios').default;





function App() {
  const [data, setData] = useState({
    aqi: 0.5,
    speed: [{'index': 1, 'speed': 0}],
    temp: [{'index': 1, 'temp': 0}],
    humidity: [{'index': 1, 'humidity': 0}]
  })

  console.log(data);

  useEffect(()=>{
    const intervalId =setInterval(()=> {
      axios.get(
        'http://localhost:8000/api/services/fan/states',
        {
          headers : {
            Authorization : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3ZmJlZjYxMGQ3ZmY0YWE5ODAxZTMxZWQ4OGUwYzI1MyIsImhdCI6MTYxNTcwMDgyMSwiZXhwIjoxOTMxMDYwODIxfQ.ULDq6jx5XFxYeDOG2qTd-CiISry3lh_HVPvc5Y0Elxo',
            'Content-Type' : 'application/json;charset=utf-8'
          }
        }
      ).then(({data:{attributes:{aqi, speed, temperature, humidity}}})=>{
        return {
          aqi: aqi[0] / 300,
          speed: speed.map((v, i)=> ({'index':i + 1, 'speed':v})),
          temp: temperature.map((v, i)=> ({'index':i + 1, 'temp':v})),
          humidity: humidity.map((v, i)=> ({'index':i + 1, 'humidity':v}))
        }
      }).then(setData)
      
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
          <QualityChart aqi={data.aqi}/>
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>风扇转速(Fan Speed)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 0.5:#7ec2f3 1:#1890ff'} data={data.speed} xlabel={'index'} ylabel={'speed'}/>
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>温度(Temprature)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 1:#01ee01'} data={data.temp} xlabel={'index'} ylabel={'temp'}/>
        </Col>
      </Row>

      <Row gutter={8}>
        <h1>湿度(Humidity)</h1>
        <Col span={8}>
          <PerformanceChart fill={'l(270) 0:#ffffff 1:#fe0000'} data={data.humidity} xlabel={'index'} ylabel={'humidity'}/>
        </Col>
      </Row>
    </div>
  );
}



export default App;
