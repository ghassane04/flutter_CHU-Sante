#!/usr/bin/env python3
"""
Script de test rapide pour les prédictions ML
Usage: python test_ml_predictions.py
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import seaborn as sns

# Configuration
print("=" * 80)
print("🧪 TEST DES PRÉDICTIONS ML - Healthcare Dashboard")
print("=" * 80)

# 1. Charger le dataset
print("\n📂 Chargement du dataset...")
try:
    df = pd.read_csv('healthcare_dataset.csv')
    print(f"✅ Dataset chargé: {df.shape[0]} lignes, {df.shape[1]} colonnes")
    print(f"📅 Période: {df['date'].min()} à {df['date'].max()}")
except FileNotFoundError:
    print("❌ Erreur: healthcare_dataset.csv introuvable!")
    print("💡 Assurez-vous d'être dans le dossier ml/")
    exit(1)

# 2. Statistiques par service
print("\n📊 Statistiques par Service:")
print("-" * 80)
stats_by_service = df.groupby('service').agg({
    'cout_total': ['mean', 'std', 'min', 'max'],
    'patients_count': ['mean', 'std'],
    'taux_occupation': ['mean']
}).round(2)

for service in df['service'].unique():
    service_data = df[df['service'] == service]
    print(f"\n🏥 {service}:")
    print(f"   Coût moyen:       {service_data['cout_total'].mean():.2f}€")
    print(f"   Coût min/max:     {service_data['cout_total'].min():.2f}€ - {service_data['cout_total'].max():.2f}€")
    print(f"   Patients moyen:   {service_data['patients_count'].mean():.1f}")
    print(f"   Taux occupation:  {service_data['taux_occupation'].mean():.2%}")

# 3. Test de prédiction simple
print("\n" + "=" * 80)
print("🔮 SIMULATION DE PRÉDICTIONS")
print("=" * 80)

def predict_next_days(service_name, days=30):
    """
    Prédiction simple basée sur moyenne mobile et tendance
    """
    service_data = df[df['service'] == service_name].copy()
    service_data['date'] = pd.to_datetime(service_data['date'])
    service_data = service_data.sort_values('date')
    
    # Calculer la moyenne mobile sur 7 jours
    service_data['ma7'] = service_data['cout_total'].rolling(window=7).mean()
    
    # Calculer la tendance (régression simple)
    last_30_days = service_data.tail(30)
    x = np.arange(len(last_30_days))
    y = last_30_days['cout_total'].values
    z = np.polyfit(x, y, 1)
    trend = z[0]  # Pente de la tendance
    
    # Dernière valeur connue
    last_value = service_data['cout_total'].iloc[-1]
    last_date = service_data['date'].iloc[-1]
    
    # Générer prédictions
    predictions = []
    for i in range(1, days + 1):
        pred_date = last_date + timedelta(days=i)
        pred_value = last_value + (trend * i)
        
        # Ajouter facteur saisonnier
        if pred_date.weekday() >= 5:  # Weekend
            pred_value *= 0.85
        
        # Intervalle de confiance ±10%
        pred_min = pred_value * 0.9
        pred_max = pred_value * 1.1
        
        predictions.append({
            'date': pred_date.strftime('%Y-%m-%d'),
            'valeur': round(pred_value, 2),
            'min': round(pred_min, 2),
            'max': round(pred_max, 2)
        })
    
    return predictions, trend

# Test pour Urgences
print("\n🚨 Prédictions pour URGENCES (30 prochains jours):")
predictions_urgences, trend = predict_next_days('Urgences', 30)

print(f"\n📈 Tendance détectée: {'+' if trend > 0 else ''}{trend:.2f}€/jour")
print(f"📊 Coût prévu moyen: {np.mean([p['valeur'] for p in predictions_urgences]):.2f}€")
print(f"📉 Intervalle: {predictions_urgences[0]['min']:.2f}€ - {predictions_urgences[-1]['max']:.2f}€")

print("\n🗓️  Prévisions détaillées (7 premiers jours):")
for pred in predictions_urgences[:7]:
    print(f"   {pred['date']}: {pred['valeur']:.2f}€ (intervalle: {pred['min']:.2f}€ - {pred['max']:.2f}€)")

# 4. Comparaison tous services
print("\n" + "=" * 80)
print("🏆 COMPARAISON TOUS SERVICES (Prédiction 30 jours)")
print("=" * 80)

all_predictions = {}
for service in df['service'].unique():
    preds, trend = predict_next_days(service, 30)
    avg_pred = np.mean([p['valeur'] for p in preds])
    all_predictions[service] = {
        'moyenne': avg_pred,
        'tendance': 'HAUSSE' if trend > 0 else 'BAISSE',
        'trend_value': trend
    }

# Afficher tableau
print(f"\n{'Service':<15} {'Coût Moyen Prédit':<20} {'Tendance':<10} {'Évolution'}")
print("-" * 70)
for service, pred_info in sorted(all_predictions.items(), key=lambda x: x[1]['moyenne'], reverse=True):
    trend_icon = '↑' if pred_info['tendance'] == 'HAUSSE' else '↓'
    print(f"{service:<15} {pred_info['moyenne']:>18.2f}€  {trend_icon} {pred_info['tendance']:<8} {pred_info['trend_value']:>+6.2f}€/j")

# 5. Visualisation (si matplotlib disponible)
try:
    print("\n📊 Génération du graphique...")
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 10))
    fig.suptitle('🔮 Prédictions ML - Healthcare Dashboard', fontsize=16, fontweight='bold')
    
    # Graphique 1: Évolution historique Urgences
    urgences_data = df[df['service'] == 'Urgences'].copy()
    urgences_data['date'] = pd.to_datetime(urgences_data['date'])
    urgences_data = urgences_data.sort_values('date')
    
    axes[0, 0].plot(urgences_data['date'], urgences_data['cout_total'], marker='o', linewidth=2, color='#3B82F6')
    axes[0, 0].set_title('Historique Urgences (2024)', fontweight='bold')
    axes[0, 0].set_xlabel('Date')
    axes[0, 0].set_ylabel('Coût (€)')
    axes[0, 0].grid(alpha=0.3)
    axes[0, 0].tick_params(axis='x', rotation=45)
    
    # Graphique 2: Distribution des coûts par service
    df.boxplot(column='cout_total', by='service', ax=axes[0, 1])
    axes[0, 1].set_title('Distribution des Coûts par Service', fontweight='bold')
    axes[0, 1].set_xlabel('Service')
    axes[0, 1].set_ylabel('Coût (€)')
    plt.sca(axes[0, 1])
    plt.xticks(rotation=45, ha='right')
    
    # Graphique 3: Taux d'occupation moyen
    occupation_by_service = df.groupby('service')['taux_occupation'].mean().sort_values(ascending=False)
    axes[1, 0].barh(occupation_by_service.index, occupation_by_service.values, color='#10B981')
    axes[1, 0].set_title('Taux d\'Occupation Moyen par Service', fontweight='bold')
    axes[1, 0].set_xlabel('Taux d\'Occupation')
    axes[1, 0].set_xlim(0, 1)
    
    # Graphique 4: Prédictions comparatives
    services_sorted = sorted(all_predictions.items(), key=lambda x: x[1]['moyenne'], reverse=True)
    services_names = [s[0] for s in services_sorted]
    services_values = [s[1]['moyenne'] for s in services_sorted]
    
    bars = axes[1, 1].bar(services_names, services_values, color='#8B5CF6')
    axes[1, 1].set_title('Coût Moyen Prédit (30 jours)', fontweight='bold')
    axes[1, 1].set_ylabel('Coût (€)')
    axes[1, 1].tick_params(axis='x', rotation=45)
    
    # Colorier selon tendance
    for i, (service, pred_info) in enumerate(services_sorted):
        color = '#EF4444' if pred_info['tendance'] == 'HAUSSE' else '#10B981'
        bars[i].set_color(color)
    
    plt.tight_layout()
    plt.savefig('ml_predictions_test.png', dpi=300, bbox_inches='tight')
    print("✅ Graphique sauvegardé: ml_predictions_test.png")
    
except Exception as e:
    print(f"⚠️  Graphique non généré: {e}")

# 6. Rapport final
print("\n" + "=" * 80)
print("✅ TEST TERMINÉ")
print("=" * 80)
print(f"\n📊 Résumé:")
print(f"   • Dataset validé: {df.shape[0]} observations")
print(f"   • Services analysés: {df['service'].nunique()}")
print(f"   • Prédictions générées: {len(predictions_urgences)} jours")
print(f"   • Graphique: ml_predictions_test.png")

print("\n🚀 Prochaines étapes:")
print("   1. Ouvrir le notebook Jupyter: jupyter notebook healthcare_ml_predictions.ipynb")
print("   2. Démarrer le backend: cd ../backend && mvn spring-boot:run")
print("   3. Tester les endpoints: http://localhost:8085/api/ml/predictions/...")
print("   4. Vérifier le frontend: http://localhost:3001/predictions")

print("\n" + "=" * 80)
