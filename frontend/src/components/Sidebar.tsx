import React from 'react';
import { LayoutDashboard, Building2, Users, BedDouble, Activity } from 'lucide-react';

interface SidebarProps {
  currentPage: string;
  onPageChange: (page: string) => void;
}

export function Sidebar({ currentPage, onPageChange }: SidebarProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
    { id: 'services', label: 'Services', icon: Building2 },
    { id: 'patients', label: 'Patients', icon: Users },
    { id: 'sejours', label: 'Séjours', icon: BedDouble },
    { id: 'actes', label: 'Actes médicaux', icon: Activity },
  ];

  return (
    <aside className="w-64 bg-blue-900 text-white p-6">
      <div className="mb-8">
        <h1 className="text-white">Anticipation Financière</h1>
        <p className="text-blue-200 text-sm mt-2">Gestion des coûts hospitaliers</p>
      </div>

      <nav>
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentPage === item.id;

          return (
            <button
              key={item.id}
              onClick={() => onPageChange(item.id)}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition-colors ${
                isActive
                  ? 'bg-blue-700 text-white'
                  : 'text-blue-100 hover:bg-blue-800'
              }`}
            >
              <Icon className="w-5 h-5" />
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>
    </aside>
  );
}
