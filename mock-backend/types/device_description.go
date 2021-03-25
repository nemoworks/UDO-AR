package types

import (
	"math/rand"
	"time"
)

type DeviceAttribute struct {
	Speed               []float32 `json:"speed"`
	Temperature         []float32 `json:"temperature"`
	Humidity            []float32 `json:"humidity"`
	Aqi                 []float32 `json:"aqi"`
	Mode                string    `json:"mode"`
	FilterHoursUsed     int       `json:"filter_hours_used"`
	FilterLifeRemaining int       `json:"filter_life_remaining"`
}

type DeviceDescription struct {
	State      string          `json:"state"`
	Attributes DeviceAttribute `json:"attributes"`
}

func generateRandomFloatSlice(len int, min float32, max float32) []float32 {
	var result []float32
	span := max - min
	rand.Seed(time.Now().Unix())
	for i := 0; i < len; i++ {
		result = append(result, min+span*rand.Float32())
	}
	return result
}

func GenerateMockDeviceDescription() *DeviceDescription {
	description := &DeviceDescription{
		State: "On",
		Attributes: DeviceAttribute{
			Speed:               generateRandomFloatSlice(15, 2000.0, 4000.0),
			Temperature:         generateRandomFloatSlice(15, 20.0, 35.0),
			Humidity:            generateRandomFloatSlice(15, 20.0, 100.0),
			Aqi:                 generateRandomFloatSlice(15, 20.0, 100.0),
			Mode:                "Auto",
			FilterHoursUsed:     1630,
			FilterLifeRemaining: 53,
		},
	}

	return description
}
