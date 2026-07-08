import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'name', label: 'Site / Station Name', type: 'text', required: true },
  { key: 'city', label: 'City', type: 'text' },
  { key: 'country', label: 'Country', type: 'text' },
  { key: 'address', label: 'Address / Location', type: 'text' },
  { key: 'category', label: 'Category', type: 'text' },
  { key: 'description', label: 'Description', type: 'textarea' },
];

export default function SitesManager() {
  return (
    <CrudManager
      title="Sites"
      endpoint="sites"
      fields={fields}
      accent="blue"
      displayKey="name"
      description="Manage all tour sites, stations and landmarks."
    />
  );
}
