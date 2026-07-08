import React from 'react';
import {
  LayoutDashboard,
  Map as MapIcon,
  MapPin,
  Calendar,
  Users as UsersIcon,
  Ticket,
  LogOut,
  Compass,
  Route as RouteIcon,
  UserRoundCheck,
  WandSparkles,
  ReceiptText,
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { motion } from 'motion/react';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const titles: Record<string, string> = {
  dashboard: 'Dashboard',
  routes: 'Routes',
  sites: 'Sites',
  guides: 'Guides',
  tours: 'Tours',
  travelers: 'Travelers',
  bookings: 'Bookings',
  'route-sites': 'Route Sites',
  advanced: 'Advanced Actions',
  logs: 'System Logs',
};

export default function Layout({ children, activeTab, setActiveTab }: LayoutProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Home', icon: LayoutDashboard },
    { id: 'routes', label: 'Routes', icon: MapIcon },
    { id: 'sites', label: 'Sites', icon: MapPin },
    { id: 'guides', label: 'Guides', icon: UserRoundCheck },
    { id: 'tours', label: 'Tours', icon: Calendar },
    { id: 'travelers', label: 'Travelers', icon: UsersIcon },
    { id: 'bookings', label: 'Bookings', icon: Ticket },
    { id: 'route-sites', label: 'Route Sites', icon: RouteIcon },
    { id: 'advanced', label: 'Advanced', icon: WandSparkles },
    { id: 'logs', label: 'Logs', icon: ReceiptText },
  ];

  return (
    <div className="flex h-screen bg-[#FFFBF0] font-sans text-slate-900">
      <aside className="w-72 bg-white/80 backdrop-blur-xl border-r border-orange-100 flex flex-col m-3 rounded-[2rem] shadow-xl shadow-orange-200/20">
        <div className="p-5">
          <div
            className="flex items-center gap-3 text-orange-500 font-extrabold text-2xl tracking-tight cursor-pointer hover:scale-105 transition-transform"
            onClick={() => setActiveTab('dashboard')}
          >
            <div className="bg-orange-500 text-white p-2 rounded-2xl shadow-lg shadow-orange-200">
              <Compass size={28} />
            </div>
            <span>SmartRoute</span>
          </div>
        </div>

        <nav className="flex-1 px-4 space-y-2 overflow-y-auto pb-3">
          {menuItems.map((item) => (
            <button
              id={`nav-${item.id}`}
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={cn(
                'w-full flex items-center gap-3 px-5 py-3 rounded-[1.3rem] transition-all duration-300 text-sm font-bold group',
                activeTab === item.id
                  ? 'bg-orange-500 text-white shadow-lg shadow-orange-200 translate-x-2'
                  : 'text-slate-400 hover:bg-orange-50 hover:text-orange-600'
              )}
            >
              <item.icon
                size={22}
                className={cn(
                  'transition-colors shrink-0',
                  activeTab === item.id ? 'text-white' : 'text-slate-300 group-hover:text-orange-400'
                )}
              />
              {item.label}
              {activeTab === item.id && (
                <motion.div layoutId="activeTab" className="ml-auto">
                  <div className="w-1.5 h-1.5 bg-white rounded-full shadow-[0_0_8px_white]" />
                </motion.div>
              )}
            </button>
          ))}
        </nav>

        <div className="p-4">
          <button
            id="logout-btn"
            className="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-[1.4rem] text-sm font-bold text-red-400 hover:bg-red-50 hover:text-red-600 transition-all"
          >
            <LogOut size={20} />
            Sign Out
          </button>
        </div>
      </aside>

      <main className="flex-1 overflow-auto p-4 relative">
        <header className="min-h-20 bg-white/40 backdrop-blur-md rounded-[2rem] mb-4 px-10 py-4 flex items-center justify-between border border-white/50 shadow-sm">
          <div>
            <h1 className="text-2xl font-black text-slate-800 tracking-tight select-none">{titles[activeTab] || 'SmartRoute'}</h1>
            <div className="flex gap-2 items-center mt-1">
              <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">PostgreSQL Connected</span>
            </div>
          </div>
          <div className="flex items-center gap-5">
            <div className="text-right">
              <p className="text-sm font-black text-slate-800">Guided Tours</p>
              <p className="text-[10px] text-orange-500 font-bold uppercase tracking-wider">Database Project</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-400 to-orange-600 border-2 border-white shadow-lg flex items-center justify-center text-white font-black text-lg">
              DB
            </div>
          </div>
        </header>

        <div className="px-6 py-2 max-w-7xl mx-auto">{children}</div>
      </main>
    </div>
  );
}
