import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'name', label: 'Route / Tour Name', type: 'text', required: true },
  { key: 'difficulty', label: 'Difficulty', type: 'select', required: true, options: ['Easy', 'Medium', 'Hard'] },
  { key: 'duration', label: 'Estimated Duration', type: 'number' },
  { key: 'distance', label: 'Distance KM', type: 'number' },
  { key: 'area', label: 'Area', type: 'text' },
  { key: 'route_type', label: 'Route Type', type: 'text' },
  { key: 'max_participants', label: 'Max Participants', type: 'number' },
  { key: 'price', label: 'Price', type: 'number' },
  { key: 'description', label: 'Description', type: 'textarea' },
];

export default function RoutesManager() {
  return (
    <CrudManager
      title="Routes"
      endpoint="routes"
      fields={fields}
      accent="orange"
      displayKey="name"
      description="CRUD for routes. The ID is hidden. Use numbers only in numeric fields."
    />
  );
}
