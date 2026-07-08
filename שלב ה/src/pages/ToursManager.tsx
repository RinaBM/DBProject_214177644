import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'route_id', label: 'Route', type: 'select', lookup: 'routes', required: true },
  { key: 'guide_id', label: 'Guide', type: 'select', lookup: 'guides' },
  { key: 'start_date', label: 'Start Date', type: 'date', required: true },
  { key: 'start_time', label: 'Start Time', type: 'time' },
  { key: 'end_time', label: 'End Time', type: 'time' },
  { key: 'max_participants', label: 'Max Participants', type: 'number' },
  { key: 'price', label: 'Price', type: 'number' },
  { key: 'status', label: 'Status', type: 'select', options: ['Draft', 'Open', 'Confirmed', 'Completed', 'Cancelled'] },
];

export default function ToursManager() {
  return (
    <CrudManager
      title="Guided Tours"
      endpoint="tours"
      fields={fields}
      accent="orange"
      description="Manage scheduled guided tours. Route and guide are displayed by name instead of foreign-key IDs."
    />
  );
}
