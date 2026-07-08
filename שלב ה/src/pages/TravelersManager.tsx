import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'full_name', label: 'Traveler Full Name', type: 'text' },
  { key: 'first_name', label: 'First Name', type: 'text' },
  { key: 'last_name', label: 'Last Name', type: 'text' },
  { key: 'email', label: 'Email', type: 'text' },
  { key: 'phone', label: 'Phone', type: 'text' },
];

export default function TravelersManager() {
  return (
    <CrudManager
      title="Travelers"
      endpoint="users"
      fields={fields}
      accent="green"
      displayKey="full_name"
      description="Manage users / travelers / customers in the system."
    />
  );
}
