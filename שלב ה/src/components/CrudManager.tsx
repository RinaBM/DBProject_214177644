import React, { useEffect, useMemo, useState } from 'react';
import {
  Edit2,
  Loader2,
  Plus,
  RefreshCcw,
  Search,
  Trash2,
  X,
  ChevronDown,
  ChevronUp
} from 'lucide-react';
import { cn } from '@/src/lib/utils';
import { CrudItem, FieldConfig, Lookups } from '@/src/types';

type CrudManagerProps = {
  title: string;
  endpoint: string;
  fields: FieldConfig[];
  accent?: 'orange' | 'blue' | 'green' | 'purple';
  idKey?: string;
  description?: string;
  displayKey?: string;
  compositeKey?: (item: CrudItem) => string;
  compositeUrl?: (item: CrudItem) => string;
};

const accentMap = {
  orange: {
    bg: 'bg-orange-500 hover:bg-orange-600',
    pale: 'bg-orange-50 text-orange-600 border-orange-100',
    ring: 'focus:border-orange-400 focus:ring-orange-100',
    header: 'text-orange-500 bg-orange-50/70',
  },
  blue: {
    bg: 'bg-blue-500 hover:bg-blue-600',
    pale: 'bg-blue-50 text-blue-600 border-blue-100',
    ring: 'focus:border-blue-400 focus:ring-blue-100',
    header: 'text-blue-500 bg-blue-50/70',
  },
  green: {
    bg: 'bg-emerald-500 hover:bg-emerald-600',
    pale: 'bg-emerald-50 text-emerald-600 border-emerald-100',
    ring: 'focus:border-emerald-400 focus:ring-emerald-100',
    header: 'text-emerald-500 bg-emerald-50/70',
  },
  purple: {
    bg: 'bg-violet-500 hover:bg-violet-600',
    pale: 'bg-violet-50 text-violet-600 border-violet-100',
    ring: 'focus:border-violet-400 focus:ring-violet-100',
    header: 'text-violet-500 bg-violet-50/70',
  },
};

const emptyLookups: Lookups = {
  routes: [],
  sites: [],
  guides: [],
  users: [],
  tours: [],
};

function emptyForm(fields: FieldConfig[]) {
  return fields.reduce<Record<string, any>>((acc, field) => {
    acc[field.key] = field.type === 'select' ? field.options?.[0] || '' : '';
    return acc;
  }, {});
}

function friendlyError(message: string) {
  if (!message) return 'Action failed.';

  if (
    message.includes('foreign key') ||
    message.includes('violates foreign key constraint') ||
    message.includes('guidedtour_guide_id_fkey')
  ) {
    return 'Cannot delete this record because it is connected to other records in the database. For example, a site can be connected to routes, and a guide can be connected to guided tours. To demonstrate delete, create a new test record that is not connected to anything and delete it.';
  }

  if (message.includes('duplicate key') || message.includes('unique constraint')) {
    return 'A record with these values already exists. Please change the value and try again.';
  }

  if (message.includes('not-null') || message.includes('null value')) {
    return 'A required field is missing. Please fill all required fields and try again.';
  }

  return message;
}

function displayValue(field: FieldConfig, value: any, lookups: Lookups) {
  if (value === null || value === undefined || value === '') return '—';

  if (field.lookup) {
    return lookups[field.lookup]?.find((option) => String(option.id) === String(value))?.label || value;
  }

  return String(value);
}

function normalizePayload(fields: FieldConfig[], form: Record<string, any>) {
  const payload: Record<string, any> = {};

  for (const field of fields) {
    const raw = form[field.key];

    if (raw === '') payload[field.key] = null;
    else if (field.type === 'number') payload[field.key] = Number(raw);
    else payload[field.key] = raw;
  }

  return payload;
}

export default function CrudManager({
  title,
  endpoint,
  fields,
  accent = 'orange',
  idKey = 'id',
  description,
  displayKey,
  compositeKey,
  compositeUrl,
}: CrudManagerProps) {
  const colors = accentMap[accent];

  const [items, setItems] = useState<CrudItem[]>([]);
  const [lookups, setLookups] = useState<Lookups>(emptyLookups);
  const [formData, setFormData] = useState<Record<string, any>>(() => emptyForm(fields));
  const [editingItem, setEditingItem] = useState<CrudItem | null>(null);
  const [expandedRows, setExpandedRows] = useState<Record<string, boolean>>({});
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [search, setSearch] = useState('');
  const [loadId, setLoadId] = useState('');
  const [error, setError] = useState('');
  const [modalError, setModalError] = useState('');
  const [success, setSuccess] = useState('');

  const tableFields = fields.filter((field) => field.showInTable !== false);
  const mainFields = tableFields.slice(0, 4);
  const detailFields = tableFields.slice(4);

  const loadLookups = async () => {
    try {
      const res = await fetch('/api/lookups');
      if (res.ok) setLookups(await res.json());
    } catch {}
  };

  const loadItems = async () => {
    setIsLoading(true);
    setError('');

    try {
      const res = await fetch(`/api/${endpoint}`);
      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Server error');

      setItems(Array.isArray(data) ? data : []);
    } catch (err: any) {
      setError(friendlyError(err.message || 'Cannot load data'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadItems();
    loadLookups();
  }, [endpoint]);

  const filteredItems = useMemo(() => {
    const needle = search.toLowerCase().trim();

    if (!needle) return items;

    return items.filter((item) =>
      fields.some((field) =>
        String(displayValue(field, item[field.key], lookups)).toLowerCase().includes(needle)
      )
    );
  }, [items, search, fields, lookups]);

  const rowKey = (item: CrudItem) => {
    if (compositeKey) return compositeKey(item);
    if (item[idKey] !== undefined && item[idKey] !== null) return String(item[idKey]);
    if (displayKey && item[displayKey]) return String(item[displayKey]);
    return JSON.stringify(item);
  };

  const openCreate = () => {
    setError('');
    setModalError('');
    setSuccess('');
    setEditingItem(null);
    setFormData(emptyForm(fields));
    setIsModalOpen(true);
  };

  const openEdit = async (item: CrudItem) => {
    setError('');
    setModalError('');
    setSuccess('');

    try {
      let fresh = item;

      if (!compositeUrl && item[idKey] !== undefined) {
        const res = await fetch(`/api/${endpoint}/${item[idKey]}`);
        const data = await res.json();

        if (res.ok && data) fresh = data;
      }

      setEditingItem(item);

      const nextForm = emptyForm(fields);

      for (const field of fields) {
        nextForm[field.key] = fresh[field.key] ?? item[field.key] ?? '';
      }

      setFormData(nextForm);
      setIsModalOpen(true);
    } catch (err: any) {
      setError(friendlyError(err.message || 'Cannot load item for update'));
    }
  };

  const openEditById = async () => {
    if (!loadId.trim()) {
      setError('Enter a key value first.');
      return;
    }

    if (compositeUrl) {
      setError('Composite-key records are updated from the row edit button.');
      return;
    }

    setError('');
    setSuccess('');

    try {
      const res = await fetch(`/api/${endpoint}/${encodeURIComponent(loadId.trim())}`);
      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Cannot find record');

      setEditingItem({ ...data, [idKey]: loadId.trim() });

      const nextForm = emptyForm(fields);

      for (const field of fields) {
        nextForm[field.key] = data[field.key] ?? '';
      }

      setFormData(nextForm);
      setIsModalOpen(true);
    } catch (err: any) {
      setError(friendlyError(err.message || 'Cannot load item for update'));
    }
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingItem(null);
    setModalError('');
  };

  const saveItem = async (event: React.FormEvent) => {
    event.preventDefault();

    setError('');
    setModalError('');
    setSuccess('');

    for (const field of fields) {
      const raw = formData[field.key];

      if (field.required && (raw === '' || raw === null || raw === undefined)) {
        setModalError(`${field.label} is required.`);
        return;
      }

      if (
        field.type === 'number' &&
        raw !== '' &&
        raw !== null &&
        raw !== undefined &&
        Number.isNaN(Number(raw))
      ) {
        setModalError(`${field.label} must be a number.`);
        return;
      }
    }

    const payload = normalizePayload(fields, formData);
    const isEdit = Boolean(editingItem);

    const url = isEdit
      ? compositeUrl
        ? `/api/${endpoint}/${compositeUrl(editingItem as CrudItem)}`
        : `/api/${endpoint}/${(editingItem as CrudItem)[idKey]}`
      : `/api/${endpoint}`;

    try {
      setIsSaving(true);

      const res = await fetch(url, {
        method: isEdit ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) throw new Error(data.error || 'Save failed');

      closeModal();
      await loadItems();
      await loadLookups();

      setSuccess(isEdit ? 'Record updated successfully.' : 'New record added successfully.');
      setTimeout(() => setSuccess(''), 3500);
    } catch (err: any) {
      setModalError(friendlyError(err.message || 'Cannot save data'));
    } finally {
      setIsSaving(false);
    }
  };

  const deleteItem = async (item: CrudItem) => {
    const label = displayKey ? item[displayKey] : item[idKey] || compositeKey?.(item);

    if (!confirm(`Delete ${label}?`)) return;

    setError('');
    setSuccess('');

    const url = compositeUrl
      ? `/api/${endpoint}/${compositeUrl(item)}`
      : `/api/${endpoint}/${item[idKey]}`;

    try {
      const res = await fetch(url, { method: 'DELETE' });
      const data = await res.json().catch(() => ({}));

      if (!res.ok) throw new Error(data.error || 'Delete failed');

      await loadItems();
      await loadLookups();

      setSuccess('Record deleted successfully.');
      setTimeout(() => setSuccess(''), 3500);
    } catch (err: any) {
      setError(friendlyError(err.message || 'Cannot delete data'));
    }
  };

  return (
    <div className="space-y-8 font-sans w-full max-w-full overflow-hidden">
      <div className="space-y-5">
        <div>
          <h2 className="text-4xl font-black text-slate-800 tracking-tight">{title}</h2>

          {description && (
            <p className="text-slate-400 font-bold mt-2 max-w-4xl leading-relaxed text-sm sm:text-base">
              {description}
            </p>
          )}
        </div>

        <div className="flex flex-wrap gap-3 items-stretch">
          <div className="relative group flex-1 min-w-[280px]">
            <Search
              className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-orange-400"
              size={20}
            />

            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by name, city, status, date or any visible value..."
              className={cn(
                'w-full pl-14 pr-14 py-4 bg-white border-2 border-transparent rounded-3xl focus:outline-none focus:ring-4 transition-all font-bold shadow-sm',
                colors.ring
              )}
            />
            {search && (
              <button
                type="button"
                aria-label="Clear search"
                onClick={() => setSearch('')}
                className="absolute right-5 top-1/2 -translate-y-1/2 text-slate-300 hover:text-slate-600 transition-all"
              >
                <X size={18} />
              </button>
            )}
          </div>

          

          <button
            onClick={loadItems}
            className="flex items-center justify-center gap-2 px-5 py-4 bg-white text-slate-500 rounded-3xl border border-slate-100 font-black hover:bg-slate-50 transition-all"
          >
            <RefreshCcw size={18} />
            Refresh
          </button>

          <button
            onClick={openCreate}
            className={cn(
              'flex items-center justify-center gap-3 px-6 sm:px-8 py-4 text-white rounded-3xl font-black transition-all shadow-xl active:scale-95',
              colors.bg
            )}
          >
            <Plus size={20} />
            Add New
          </button>
        </div>
      </div>

      <div className="text-xs font-black uppercase tracking-[0.2em] text-slate-400">
        {filteredItems.length} of {items.length} records shown
      </div>

      {success && (
        <div className="bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-3xl p-5 font-bold flex items-center justify-between">
          <span>{success}</span>
          <button onClick={() => setSuccess('')}>
            <X size={18} />
          </button>
        </div>
      )}

      {error && (
        <div className="bg-red-50 border border-red-100 text-red-600 rounded-3xl p-5 font-bold flex items-center justify-between">
          <span>{error}</span>
          <button onClick={() => setError('')}>
            <X size={18} />
          </button>
        </div>
      )}

      <div className="bg-white rounded-[3rem] border border-orange-50 overflow-hidden shadow-xl shadow-orange-100/20">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[720px] text-left border-collapse">
            <thead>
              <tr className={cn('text-[10px] uppercase font-black tracking-[0.16em] border-b border-orange-50', colors.header)}>
                {mainFields.map((field) => (
                  <th key={field.key} className="px-4 py-4 whitespace-nowrap">
                    {field.label}
                  </th>
                ))}

                {detailFields.length > 0 && (
                  <th className="px-4 py-4 whitespace-nowrap">More</th>
                )}

                <th className="px-4 py-4 text-right sticky right-0 bg-white z-20">
                  Actions
                </th>
              </tr>
            </thead>

            <tbody className="divide-y divide-orange-50">
              {isLoading ? (
                <tr>
                  <td colSpan={mainFields.length + 2} className="py-20 text-center text-slate-400 font-black uppercase tracking-widest">
                    <Loader2 className="mx-auto mb-4 animate-spin text-orange-400" size={40} />
                    Loading data...
                  </td>
                </tr>
              ) : filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={mainFields.length + 2} className="py-20 text-center text-slate-300 font-black uppercase tracking-widest">
                    No records found
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => {
                  const key = rowKey(item);

                  return (
                    <React.Fragment key={key}>
                      <tr className="hover:bg-orange-50/20 transition-all group">
                        {mainFields.map((field, index) => (
                          <td key={field.key} className="px-4 py-4 text-sm font-bold text-slate-600 align-top max-w-[220px]">
                            {index === 0 ? (
                              <div>
                                <p className="text-slate-900 font-black text-base truncate">
                                  {displayValue(field, item[field.key], lookups)}
                                </p>
                                <p className="text-[10px] text-slate-300 uppercase tracking-widest mt-1 font-black">
                                  {key}
                                </p>
                              </div>
                            ) : field.type === 'select' || field.lookup ? (
                              <span className={cn('px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest border inline-block', colors.pale)}>
                                {displayValue(field, item[field.key], lookups)}
                              </span>
                            ) : (
                              <span className="line-clamp-2">
                                {displayValue(field, item[field.key], lookups)}
                              </span>
                            )}
                          </td>
                        ))}

                        {detailFields.length > 0 && (
                          <td className="px-4 py-4">
                            <button
                              onClick={() => setExpandedRows({ ...expandedRows, [key]: !expandedRows[key] })}
                              className="flex items-center gap-1 px-3 py-2 rounded-2xl bg-slate-50 text-slate-500 font-black text-xs hover:bg-slate-100"
                            >
                              {expandedRows[key] ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
                              Show More
                            </button>
                          </td>
                        )}

                        <td className="px-4 py-4 text-right sticky right-0 bg-white z-20 shadow-[-12px_0_18px_-18px_rgba(15,23,42,0.4)]">
                          <div className="flex items-center justify-end gap-2">
                            <button
                              onClick={() => openEdit(item)}
                              className="p-3 bg-blue-50 text-blue-500 hover:bg-blue-500 hover:text-white rounded-2xl transition-all shadow-sm"
                              title="Update"
                            >
                              <Edit2 size={18} />
                            </button>

                            <button
                              onClick={() => deleteItem(item)}
                              className="p-3 bg-red-50 text-red-500 hover:bg-red-500 hover:text-white rounded-2xl transition-all shadow-sm"
                              title="Delete"
                            >
                              <Trash2 size={18} />
                            </button>
                          </div>
                        </td>
                      </tr>

                      {expandedRows[key] && detailFields.length > 0 && (
                        <tr className="bg-slate-50/60">
                          <td colSpan={mainFields.length + 2} className="px-6 py-5">
                            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                              {detailFields.map((field) => (
                                <div key={field.key} className="bg-white rounded-2xl border border-slate-100 p-4">
                                  <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1">
                                    {field.label}
                                  </p>
                                  <p className="font-bold text-slate-700">
                                    {displayValue(field, item[field.key], lookups)}
                                  </p>
                                </div>
                              ))}
                            </div>
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/30 backdrop-blur-sm">
          <div className="bg-white rounded-[3rem] w-full max-w-3xl shadow-2xl overflow-hidden border border-orange-100 max-h-[90vh] overflow-y-auto">
            <form onSubmit={saveItem} className="p-8 sm:p-10 space-y-6">
              <div className="flex items-start justify-between gap-4 mb-6">
                <div>
                  <h3 className="text-3xl font-black text-slate-800 tracking-tight">
                    {editingItem ? `Update ${title}` : `Add ${title}`}
                  </h3>
                  <p className="text-slate-400 font-bold mt-1">
                    Do not enter ID. The system handles IDs automatically.
                  </p>
                </div>

                <button type="button" onClick={closeModal} className="p-3 bg-slate-50 text-slate-400 hover:text-slate-900 rounded-2xl">
                  <X size={22} />
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {fields.map((field) => (
                  <div key={field.key} className={cn('space-y-1', field.type === 'textarea' && 'md:col-span-2')}>
                    <label className="block text-xs font-black text-slate-400 uppercase tracking-widest ml-1">
                      {field.label}
                    </label>

                    {field.type === 'textarea' ? (
                      <textarea
                        required={field.required}
                        rows={4}
                        value={formData[field.key] ?? ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        className={cn('w-full px-5 py-4 bg-slate-50 border-2 border-transparent rounded-2xl outline-none focus:ring-4 transition-all font-bold resize-none', colors.ring)}
                      />
                    ) : field.type === 'select' ? (
                      <select
                        required={field.required}
                        value={formData[field.key] ?? ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        className={cn('w-full px-5 py-4 bg-slate-50 border-2 border-transparent rounded-2xl outline-none focus:ring-4 transition-all font-bold', colors.ring)}
                      >
                        <option value="">Choose...</option>

                        {field.lookup
                          ? lookups[field.lookup]?.map((option) => (
                              <option key={String(option.id)} value={option.id}>
                                {option.label}
                              </option>
                            ))
                          : field.options?.map((option) => (
                              <option key={option} value={option}>
                                {option}
                              </option>
                            ))}
                      </select>
                    ) : (
                      <input
                        type={field.type}
                        required={field.required}
                        value={formData[field.key] ?? ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        className={cn('w-full px-5 py-4 bg-slate-50 border-2 border-transparent rounded-2xl outline-none focus:ring-4 transition-all font-bold', colors.ring)}
                      />
                    )}
                  </div>
                ))}
              </div>

              {modalError && (
                <div className="bg-red-50 border border-red-100 text-red-600 rounded-3xl p-5 font-bold leading-relaxed">
                  {modalError}
                </div>
              )}

              <div className="bg-blue-50 border border-blue-100 text-blue-700 rounded-3xl p-5 text-sm font-bold leading-relaxed">
                Before saving: do not enter ID. Choose values from lists when they appear. In numeric fields enter digits only.
              </div>

              <div className="flex gap-4 pt-2">
                <button type="button" onClick={closeModal} className="flex-1 py-5 bg-slate-100 text-slate-500 rounded-3xl font-black uppercase tracking-widest hover:bg-slate-200 transition-all text-xs">
                  Cancel
                </button>

                <button disabled={isSaving} type="submit" className={cn('flex-1 py-5 text-white rounded-3xl font-black uppercase tracking-widest transition-all shadow-xl text-xs disabled:opacity-60', colors.bg)}>
                  {isSaving ? 'Saving...' : editingItem ? 'Save Update' : 'Create Record'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
