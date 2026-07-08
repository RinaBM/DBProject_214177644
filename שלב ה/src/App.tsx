/**
 * SmartRoute - Phase E graphical interface
 */

import React, { useState } from 'react';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import RoutesManager from './pages/RoutesManager';
import SitesManager from './pages/SitesManager';
import GuidesManager from './pages/GuidesManager';
import ToursManager from './pages/ToursManager';
import TravelersManager from './pages/TravelersManager';
import BookingsManager from './pages/BookingsManager';
import RouteSitesManager from './pages/RouteSitesManager';
import AdvancedActions from './pages/AdvancedActions';
import SystemLogs from './pages/SystemLogs';

export default function App() {
  const [activeTab, setActiveTabState] = useState(() => {
    return localStorage.getItem('smartroute_active_tab') || 'dashboard';
  });

  const setActiveTab = (tab: string) => {
    localStorage.setItem('smartroute_active_tab', tab);
    setActiveTabState(tab);
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard setActiveTab={setActiveTab} />;
      case 'routes':
        return <RoutesManager />;
      case 'sites':
        return <SitesManager />;
      case 'guides':
        return <GuidesManager />;
      case 'tours':
        return <ToursManager />;
      case 'travelers':
        return <TravelersManager />;
      case 'bookings':
        return <BookingsManager />;
      case 'route-sites':
        return <RouteSitesManager />;
      case 'advanced':
        return <AdvancedActions />;
      case 'logs':
        return <SystemLogs />;
      default:
        return <Dashboard setActiveTab={setActiveTab} />;
    }
  };

  return (
    <Layout activeTab={activeTab} setActiveTab={setActiveTab}>
      {renderContent()}
    </Layout>
  );
}
