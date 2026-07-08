import React, { useEffect, useState } from 'react';
import {
  Map as MapIcon,
  MapPin,
  Users,
  Calendar,
  Ticket,
  ListChecks,
  Settings,
  FileText,
  DollarSign
} from 'lucide-react';

type DashboardProps = {
  setActiveTab: (tab: string) => void;
};

export default function Dashboard({ setActiveTab }: DashboardProps) {
  const [stats, setStats] = useState<any>({
    revenue: 0,
    routes: 0,
    tours: 0,
    bookings: 0
  });

  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/dashboard/stats')
      .then(async (res) => {
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Cannot load dashboard data');

        setStats({
          revenue: Number(data.revenue ?? data.total_revenue ?? 0),
          routes: Number(data.routes ?? data.active_routes ?? 0),
          tours: Number(data.tours ?? data.guided_tours ?? 0),
          bookings: Number(data.bookings ?? data.total_bookings ?? 0)
        });

        setError('');
      })
      .catch((err) => {
        setError(err.message || 'Dashboard data error');
        setStats({
          revenue: 0,
          routes: 0,
          tours: 0,
          bookings: 0
        });
      });
  }, []);

  const statCards = [
    { label: 'Revenue', value: `$${Number(stats.revenue || 0).toLocaleString()}`, icon: DollarSign },
    { label: 'Active Routes', value: Number(stats.routes || 0), icon: MapIcon },
    { label: 'Tours', value: Number(stats.tours || 0), icon: Calendar },
    { label: 'Bookings', value: Number(stats.bookings || 0), icon: Ticket }
  ];

  const navCards = [
    { id: 'routes', label: 'Routes', subtitle: 'Manage routes', icon: MapIcon },
    { id: 'sites', label: 'Sites', subtitle: 'Manage sites', icon: MapPin },
    { id: 'guides', label: 'Guides', subtitle: 'Manage guides', icon: Users },
    { id: 'tours', label: 'Tours', subtitle: 'Schedule guided tours', icon: Calendar },
    { id: 'travelers', label: 'Travelers', subtitle: 'Manage travelers', icon: Users },
    { id: 'bookings', label: 'Bookings', subtitle: 'Manage bookings', icon: Ticket },
    { id: 'route-sites', label: 'Route Sites', subtitle: 'Connect routes and sites', icon: ListChecks },
    { id: 'advanced', label: 'Advanced', subtitle: 'Queries and PL/pgSQL', icon: Settings },
    { id: 'logs', label: 'Logs', subtitle: 'System logs', icon: FileText }
  ];

  return (
    <div className="space-y-10">
      {error && (
        <div className="bg-orange-50 border border-orange-100 text-orange-700 rounded-[2rem] p-5 font-bold">
          Dashboard warning: {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((card) => {
          const Icon = card.icon;
          return (
            <div
              key={card.label}
              className="bg-white p-7 rounded-[2.5rem] border border-orange-50 shadow-xl shadow-orange-100/20"
            >
              <div className="w-14 h-14 bg-orange-500 text-white rounded-2xl flex items-center justify-center mb-5 shadow-lg">
                <Icon size={26} />
              </div>
              <p className="text-slate-400 text-[11px] font-black uppercase tracking-[0.2em]">
                {card.label}
              </p>
              <h3 className="text-3xl font-black text-slate-800 mt-1">
                {card.value}
              </h3>
            </div>
          );
        })}
      </div>

      <section className="bg-white rounded-[3rem] border border-orange-50 shadow-xl shadow-orange-100/20 p-8">
        <h2 className="text-2xl font-black text-slate-800 mb-2">Dashboard Summary</h2>
        <p className="text-slate-500 font-bold leading-relaxed">
          This interface connects to PostgreSQL and allows CRUD operations, query execution,
          and activation of PL/pgSQL functions and procedures from the graphical screens.
        </p>
      </section>

      <section className="bg-white rounded-[3rem] border border-orange-50 shadow-xl shadow-orange-100/20 p-8">
        <h2 className="text-3xl font-black text-slate-800 mb-2">Open System Screens</h2>
        <p className="text-slate-400 font-bold mb-6">
          Quick access to all Phase E screens from the home page.
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {navCards.map((card) => {
            const Icon = card.icon;
            return (
              <button
                key={card.id}
                onClick={() => setActiveTab(card.id)}
                className="text-left bg-orange-50/70 hover:bg-orange-500 hover:text-white transition-all rounded-[2rem] p-5 border border-orange-100 group"
              >
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-white text-orange-500 rounded-2xl shadow-sm">
                    <Icon size={22} />
                  </div>
                  <div>
                    <p className="font-black text-slate-800 group-hover:text-white">
                      {card.label}
                    </p>
                    <p className="text-xs font-bold text-slate-400 group-hover:text-orange-100">
                      {card.subtitle}
                    </p>
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </section>
    </div>
  );
}
