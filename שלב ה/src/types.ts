export type FieldType = 'text' | 'number' | 'date' | 'time' | 'select' | 'textarea';

export type LookupName = 'routes' | 'sites' | 'guides' | 'users' | 'tours';

export type LookupOption = {
  id: number | string;
  label: string;
};

export type Lookups = Record<LookupName, LookupOption[]>;

export type FieldConfig = {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  lookup?: LookupName;
  options?: string[];
  showInTable?: boolean;
  helperText?: string;
};

export type CrudItem = Record<string, any>;

export interface DashboardStats {
  routes: number;
  sites: number;
  guides: number;
  travelers: number;
  tours: number;
  bookings: number;
  revenue: number;
}
