#!/usr/bin/env python3
"""
Flask ML Prediction Server for Healthcare Dashboard
Endpoints:
  - POST /predict - Healthcare prediction
  - GET /health - Health check
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os

app = Flask(__name__)
CORS(app)

# Load dataset at startup
DATASET_PATH = os.path.join(os.path.dirname(__file__), 'healthcare_dataset.csv')
df = None

def load_dataset():
    global df
    try:
        df = pd.read_csv(DATASET_PATH)
        print(f"✅ Dataset loaded: {df.shape[0]} rows, {df.shape[1]} columns")
        return True
    except FileNotFoundError:
        print(f"⚠️ Dataset not found at {DATASET_PATH}")
        return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'ML Prediction API',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
        'dataset_loaded': df is not None
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Healthcare prediction endpoint
    Expected JSON body:
    {
        "age": 45,
        "gender": "M",
        "diagnosis": "Hypertension",
        "duration_days": 7,
        "previous_admissions": 2
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        # Extract features
        age = data.get('age', 45)
        gender = data.get('gender', 'M')
        diagnosis = data.get('diagnosis', 'General')
        duration_days = data.get('duration_days', 5)
        previous_admissions = data.get('previous_admissions', 0)
        
        # Simple prediction logic based on features
        base_cost = 500.0
        
        # Age factor
        if age > 65:
            base_cost *= 1.3
        elif age < 18:
            base_cost *= 0.9
        
        # Duration factor
        base_cost += duration_days * 150
        
        # Previous admissions factor
        if previous_admissions > 2:
            base_cost *= 1.2
        
        # Diagnosis severity mapping
        severity_map = {
            'Hypertension': 1.1,
            'Diabetes': 1.15,
            'Heart Disease': 1.5,
            'Cancer': 2.0,
            'Asthma': 0.9,
            'General': 1.0
        }
        severity = severity_map.get(diagnosis, 1.0)
        base_cost *= severity
        
        # Calculate prediction with confidence interval
        predicted_cost = round(base_cost, 2)
        confidence_min = round(predicted_cost * 0.85, 2)
        confidence_max = round(predicted_cost * 1.15, 2)
        
        # Risk assessment
        risk_score = min(1.0, (age / 100) + (previous_admissions * 0.1) + (severity - 1))
        risk_level = 'HIGH' if risk_score > 0.6 else ('MEDIUM' if risk_score > 0.3 else 'LOW')
        
        # Predicted length of stay
        predicted_los = max(1, duration_days + (1 if previous_admissions > 1 else 0))
        
        return jsonify({
            'prediction': {
                'estimated_cost': predicted_cost,
                'confidence_interval': {
                    'min': confidence_min,
                    'max': confidence_max
                },
                'predicted_length_of_stay': predicted_los,
                'risk_assessment': {
                    'score': round(risk_score, 2),
                    'level': risk_level
                }
            },
            'input': {
                'age': age,
                'gender': gender,
                'diagnosis': diagnosis,
                'duration_days': duration_days,
                'previous_admissions': previous_admissions
            },
            'model': {
                'name': 'Healthcare Cost Predictor',
                'version': '1.0.0',
                'timestamp': datetime.now().isoformat()
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/predict/cost', methods=['POST'])
def predict_cost_by_service():
    """
    Predict costs by service
    Expected JSON body:
    {
        "service": "Urgences",
        "days": 30
    }
    """
    try:
        data = request.get_json()
        service_name = data.get('service', 'Urgences')
        days = data.get('days', 30)
        
        if df is None:
            return jsonify({'error': 'Dataset not loaded'}), 500
        
        # Filter by service
        service_data = df[df['service'] == service_name].copy()
        
        if service_data.empty:
            return jsonify({'error': f'Service {service_name} not found'}), 404
        
        # Calculate predictions based on historical data
        avg_cost = service_data['cout_total'].mean()
        std_cost = service_data['cout_total'].std()
        
        # Generate predictions
        predictions = []
        base_date = datetime.now()
        for i in range(1, days + 1):
            pred_date = base_date + timedelta(days=i)
            pred_value = avg_cost + np.random.normal(0, std_cost * 0.1)
            
            # Weekend adjustment
            if pred_date.weekday() >= 5:
                pred_value *= 0.85
            
            predictions.append({
                'date': pred_date.strftime('%Y-%m-%d'),
                'predicted_cost': round(pred_value, 2),
                'confidence_interval': {
                    'min': round(pred_value * 0.9, 2),
                    'max': round(pred_value * 1.1, 2)
                }
            })
        
        return jsonify({
            'service': service_name,
            'prediction_period_days': days,
            'average_predicted_cost': round(avg_cost, 2),
            'predictions': predictions,
            'generated_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/services', methods=['GET'])
def get_services():
    """Get list of available services"""
    if df is None:
        return jsonify({'error': 'Dataset not loaded'}), 500
    
    services = df['service'].unique().tolist()
    return jsonify({
        'services': services,
        'count': len(services)
    })

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Starting ML Prediction Server")
    print("=" * 60)
    
    load_dataset()
    
    print("\n📡 Available endpoints:")
    print("   GET  /health         - Health check")
    print("   POST /predict        - Healthcare prediction")
    print("   POST /predict/cost   - Cost prediction by service")
    print("   GET  /services       - List available services")
    print("\n" + "=" * 60)
    
    app.run(host='0.0.0.0', port=5000, debug=True)
