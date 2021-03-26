import './App.css';
import QualityChart from './charts/QualityChart';
import PerformanceChart from './charts/PerformanceChart';
import {Divider, Row, Col} from 'antd';

function App() {
  return (

    <div>
      <Row gutter={8}>
        <Col span={8}>
          <QualityChart/>
        </Col>
      </Row>

      <Row gutter={8}>
        <Col span={8}>
          <PerformanceChart/>
        </Col>
      </Row>

      <Row gutter={8}>
        <Col span={8}>
          <PerformanceChart/>
        </Col>
      </Row>

      <Row gutter={8}>
        <Col span={8}>
          <PerformanceChart/>
        </Col>
      </Row>

        
    </div>
  );
}



export default App;
