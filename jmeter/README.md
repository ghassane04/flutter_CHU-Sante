# JMeter Load Testing

This folder contains JMeter test plans for load testing the Healthcare Dashboard APIs.

## Prerequisites

1. Install Apache JMeter: https://jmeter.apache.org/download_jmeter.cgi
2. Ensure the backend APIs are running at `http://localhost:8085`
3. Ensure the ML API is running at `http://localhost:5000`

## Test Plans

| File | Description | Target |
|------|-------------|--------|
| `healthcare_api_load_test.jmx` | Main test plan for Spring Boot APIs | Backend (port 8085) |
| `ml_api_load_test.jmx` | Prediction API load test | ML Flask (port 5000) |

## Running Tests

### GUI Mode (development)
```bash
jmeter -t healthcare_api_load_test.jmx
```

### Non-GUI Mode (CI/production)
```bash
jmeter -n -t healthcare_api_load_test.jmx -l results.jtl -e -o reports/
```

## Test Configuration

Edit the following User Defined Variables in the JMX files:
- `BASE_URL`: API base URL (default: localhost)
- `PORT`: API port (default: 8085 for backend, 5000 for ML)
- `THREADS`: Number of concurrent users
- `RAMP_UP`: Ramp-up period in seconds
- `DURATION`: Test duration in seconds

## Results

After running tests:
- `results.jtl`: Raw results file
- `reports/`: HTML report with graphs and statistics
