import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'full_name', label: 'Guide Full Name', type: 'text', required: true },
  { key: 'phone', label: 'Phone', type: 'text' },
  { key: 'email', label: 'Email', type: 'text' },
  { key: 'languages', label: 'Languages', type: 'text' },
  { key: 'experience_years', label: 'Experience Years', type: 'number' },
];

export default function GuidesManager() {
  return (
    <CrudManager
      title="Guides"
      endpoint="guides"
      fields={fields}
      accent="green"
      displayKey="full_name"
      description="Manage guides. The interface shows a friendly full name instead of forcing the user to deal with integration details."
    />
  );
}
