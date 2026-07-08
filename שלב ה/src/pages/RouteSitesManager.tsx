import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'route_id', label: 'Route / Tour', type: 'select', lookup: 'routes', required: true },
  { key: 'site_id', label: 'Site / Station', type: 'select', lookup: 'sites', required: true },
  { key: 'order_index', label: 'Visit Order', type: 'number', required: true },
];

export default function RouteSitesManager() {
  return (
    <CrudManager
      title="Route Sites"
      endpoint="route-sites"
      fields={fields}
      accent="blue"
      description="Manage which sites belong to each route. The user chooses route and site names, while the database keeps the foreign keys."
      compositeKey={(item) => `${item.route_name || item.route_id} → ${item.site_name || item.site_id}`}
      compositeUrl={(item) => `${encodeURIComponent(String(item.route_id))}/${encodeURIComponent(String(item.site_id))}`}
    />
  );
}
