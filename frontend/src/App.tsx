import React, { useState, useEffect } from 'react';
import { Login } from './pages/Login';
import { MainLayout } from './components/layout/MainLayout';
import { Dashboard } from './pages/Dashboard';
import { Predictions } from './pages/Predictions';
import { AIAssistant } from './pages/AIAssistant';
import { Investments } from './pages/Investments';
import { Alerts } from './pages/Alerts';
import { Reports } from './pages/Reports';
import { Settings } from './pages/Settings';
import { Services } from './pages/Services';
import { Medecins } from './pages/Medecins';
import { PatientsPage } from './pages/PatientsPage';
import { SejoursPage } from './pages/SejoursPage';
import { ActesMedicauxPage } from './pages/ActesMedicauxPage';
import { ParametresPage } from './pages/ParametresPage';
import { api } from './services/api';

type Page = 'login' | 'dashboard' | 'predictions' | 'services' | 'medecins' | 'patients' | 'sejours' | 'actes' | 'ai' | 'investments' | 'alerts' | 'reports' | 'settings' | 'parametres';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('login');
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Vérifier si l'utilisateur est déjà connecté au chargement
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      setIsAuthenticated(true);
      setCurrentPage('dashboard');
    }
  }, []);

  const handleLogin = () => {
    setIsAuthenticated(true);
    setCurrentPage('dashboard');
  };

  const handleLogout = () => {
    api.logout();
    setIsAuthenticated(false);
    setCurrentPage('login');
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard />;
      case 'predictions':
        return <Predictions />;
      case 'services':
        return <Services />;
      case 'medecins':
        return <Medecins />;
      case 'patients':
        return <PatientsPage />;
      case 'sejours':
        return <SejoursPage />;
      case 'actes':
        return <ActesMedicauxPage />;
      case 'parametres':
        return <ParametresPage />;
      case 'ai':
        return <AIAssistant />;
      case 'investments':
        return <Investments />;
      case 'alerts':
        return <Alerts />;
      case 'reports':
        return <Reports />;
      case 'settings':
        return <Settings />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <MainLayout 
      currentPage={currentPage} 
      onPageChange={setCurrentPage}
      onLogout={handleLogout}
    >
      {renderPage()}
    </MainLayout>
  );
}