import React from 'react';
import { 
  LayoutDashboard, 
  TrendingUp, 
  Building2, 
  Bot, 
  Wallet, 
  AlertTriangle, 
  FileText, 
  Settings as SettingsIcon,
  UserCog,
  Users,
  Bed,
  Stethoscope,
  Sliders,
  X
} from 'lucide-react';

interface SidebarProps {
  currentPage: string;
  onPageChange: (page: string) => void;
  isOpen: boolean;
  onClose: () => void;
}

export function Sidebar({ currentPage, onPageChange, isOpen, onClose }: SidebarProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
    { id: 'predictions', label: 'Prédictions', icon: TrendingUp },
    { id: 'services', label: 'Services', icon: Building2 },
    { id: 'medecins', label: 'Médecins', icon: UserCog },
    { id: 'patients', label: 'Patients', icon: Users },
    { id: 'sejours', label: 'Séjours', icon: Bed },
    { id: 'actes', label: 'Actes Médicaux', icon: Stethoscope },
    { id: 'ai', label: 'Assistant IA', icon: Bot },
    { id: 'investments', label: 'Investissements', icon: Wallet },
    { id: 'alerts', label: 'Alertes', icon: AlertTriangle },
    { id: 'reports', label: 'Rapports', icon: FileText },
    { id: 'settings', label: 'Paramètres', icon: SettingsIcon },
  ];

  const handleItemClick = (pageId: string) => {
    onPageChange(pageId);
    if (window.innerWidth < 1024) {
      onClose();
    }
  };

  return (
    <>
      {/* Overlay for mobile */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}
      
      {/* Sidebar */}
      <aside
        className={`fixed lg:static inset-y-0 left-0 z-50 w-64 bg-[#0B6FB0] text-white transform transition-transform duration-300 ease-in-out ${
          isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
        }`}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="p-6 border-b border-blue-700">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-xl font-bold text-white">CHU Santé</h1>
                <p className="text-sm text-blue-200 mt-1">Finance Dashboard</p>
              </div>
              <button
                onClick={onClose}
                className="lg:hidden p-2 hover:bg-blue-700 rounded-lg transition-colors"
                aria-label="Fermer le menu"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 overflow-y-auto">
            {menuItems.map((item) => {
              const Icon = item.icon;
              const isActive = currentPage === item.id;

              return (
                <button
                  key={item.id}
                  onClick={() => handleItemClick(item.id)}
                  className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition-all duration-200 min-h-[48px] ${
                    isActive
                      ? 'bg-blue-700 text-white shadow-md'
                      : 'text-blue-100 hover:bg-blue-800 hover:text-white'
                  }`}
                >
                  <Icon className="w-5 h-5 flex-shrink-0" />
                  <span className="text-sm font-medium">{item.label}</span>
                </button>
              );
            })}
          </nav>

          {/* Footer */}
          <div className="p-4 border-t border-blue-700">
            <div className="flex items-center gap-3 px-4 py-3">
              <div className="w-10 h-10 rounded-full bg-blue-700 flex items-center justify-center text-sm font-medium">
                AD
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-white truncate">Administrateur</p>
                <p className="text-xs text-blue-200 truncate">admin@chu-sante.fr</p>
              </div>
            </div>
          </div>
        </div>
      </aside>
    </>
  );
}