const fs = require("fs");

function write(file, content) {
  fs.writeFileSync(file, content, "utf8");
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

/* 1. Add helperText to FieldConfig */
let types = read("src/types.ts");
if (!types.includes("helperText?: string;")) {
  types = types.replace(
    "showInTable?: boolean;",
    "showInTable?: boolean;\n  helperText?: string;"
  );
  write("src/types.ts", types);
}

/* 2. Fix CrudManager: show errors inside modal + validate number fields */
let crud = read("src/components/CrudManager.tsx");

if (!crud.includes("const [modalError, setModalError]")) {
  crud = crud.replace(
    "const [error, setError] = useState('');",
    "const [error, setError] = useState('');\n  const [modalError, setModalError] = useState('');\n  const [isSaving, setIsSaving] = useState(false);"
  );
}

if (!crud.includes("function getFieldHint")) {
  crud = crud.replace(
    "function normalizePayload(fields: FieldConfig[], form: Record<string, any>) {",
    `function getFieldHint(field: FieldConfig) {
  if (field.helperText) return field.helperText;
  if (field.lookup) return 'Choose an existing value from the database.';
  if (field.type === 'number') return 'Numbers only. Example: 2 or 12.5. Do not write words.';
  if (field.type === 'date') return 'Date format: YYYY-MM-DD.';
  if (field.type === 'time') return 'Time format: HH:MM.';
  if (field.type === 'select') return 'Choose one of the allowed values.';
  if (field.type === 'textarea') return 'Free text.';
  return 'Text value.';
}

function normalizePayload(fields: FieldConfig[], form: Record<string, any>) {`
  );
}

crud = crud.replace(
  "const openCreate = () => {\n    setEditingItem(null);",
  "const openCreate = () => {\n    setError('');\n    setModalError('');\n    setEditingItem(null);"
);

crud = crud.replaceAll(
  "setError('');\n    try {",
  "setError('');\n    setModalError('');\n    try {"
);

crud = crud.replace(
  "const closeModal = () => {\n    setIsModalOpen(false);\n    setEditingItem(null);\n  };",
  "const closeModal = () => {\n    setIsModalOpen(false);\n    setEditingItem(null);\n    setModalError('');\n  };"
);

const newSave = [
"  const saveItem = async (event: React.FormEvent) => {",
"    event.preventDefault();",
"    setError('');",
"    setModalError('');",
"",
"    for (const field of fields) {",
"      const raw = formData[field.key];",
"      if (field.required && (raw === '' || raw === null || raw === undefined)) {",
"        setModalError(field.label + ' is required.');",
"        return;",
"      }",
"      if (field.type === 'number' && raw !== '' && raw !== null && raw !== undefined && Number.isNaN(Number(raw))) {",
"        setModalError(field.label + ' must be a number. Example: 2. Do not write text like two hours.');",
"        return;",
"      }",
"    }",
"",
"    const payload = normalizePayload(fields, formData);",
"    const isEdit = Boolean(editingItem);",
"    const url = isEdit",
"      ? compositeUrl",
"        ? `/api/${endpoint}/${compositeUrl(editingItem as CrudItem)}`",
"        : `/api/${endpoint}/${(editingItem as CrudItem)[idKey]}`",
"      : `/api/${endpoint}`;",
"    try {",
"      setIsSaving(true);",
"      const res = await fetch(url, {",
"        method: isEdit ? 'PUT' : 'POST',",
"        headers: { 'Content-Type': 'application/json' },",
"        body: JSON.stringify(payload),",
"      });",
"      const data = await res.json().catch(() => ({}));",
"      if (!res.ok) throw new Error(data.error || 'Save failed');",
"      closeModal();",
"      await loadItems();",
"      await loadLookups();",
"    } catch (err: any) {",
"      setModalError(err.message || 'Cannot save data');",
"    } finally {",
"      setIsSaving(false);",
"    }",
"  };"
].join("\\n");

crud = crud.replace(
  /  const saveItem = async \(event: React\.FormEvent\) => \{[\s\S]*?\n  \};\n\n  const deleteItem = async/,
  newSave + "\n\n  const deleteItem = async"
);

if (!crud.includes("{modalError && (")) {
  crud = crud.replace(
    '              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">',
    `              {modalError && (
                <div className="bg-red-50 border border-red-100 text-red-600 rounded-3xl p-5 font-bold">
                  {modalError}
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">`
  );
}

if (!crud.includes("{getFieldHint(field)}")) {
  crud = crud.replace(
    "                    )}\n                  </div>",
    "                    )}\n                    <p className=\"text-[11px] font-bold text-slate-400 ml-1\">{getFieldHint(field)}</p>\n                  </div>"
  );
}

crud = crud.replace(
  "                <button type=\"submit\" className={cn('flex-1 py-5 text-white rounded-3xl font-black uppercase tracking-widest transition-all shadow-xl text-xs', colors.bg)}>\n                  {editingItem ? 'Save Update' : 'Create Record'}\n                </button>",
  "                <button type=\"submit\" disabled={isSaving} className={cn('flex-1 py-5 text-white rounded-3xl font-black uppercase tracking-widest transition-all shadow-xl text-xs disabled:opacity-60', colors.bg)}>\n                  {isSaving ? 'Saving...' : editingItem ? 'Save Update' : 'Create Record'}\n                </button>"
);

write("src/components/CrudManager.tsx", crud);

/* 3. Fix Routes duration from text to number and add helper notes */
write("src/pages/RoutesManager.tsx", `import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'name', label: 'Route / Tour Name', type: 'text', required: true, helperText: 'Text. Example: Jerusalem Old City.' },
  { key: 'difficulty', label: 'Difficulty', type: 'select', options: ['Easy', 'Medium', 'Moderate', 'Hard', 'Expert'], helperText: 'Choose one value from the list.' },
  { key: 'duration', label: 'Estimated Duration', type: 'number', helperText: 'Integer/number only. Example: 2. Do not write “2 hours”.' },
  { key: 'distance', label: 'Distance KM', type: 'number', helperText: 'Number only. Example: 3.5.' },
  { key: 'area', label: 'Area', type: 'text', helperText: 'Text. Example: Jerusalem.' },
  { key: 'route_type', label: 'Route Type', type: 'text', helperText: 'Text. Example: Urban / Nature / Historical.' },
  { key: 'max_participants', label: 'Max Participants', type: 'number', helperText: 'Integer only. Example: 25.' },
  { key: 'price', label: 'Price', type: 'number', helperText: 'Number only. Example: 120.' },
  { key: 'description', label: 'Description', type: 'textarea', helperText: 'Free text.' },
];

export default function RoutesManager() {
  return (
    <CrudManager
      title="Routes"
      endpoint="routes"
      fields={fields}
      accent="orange"
      displayKey="name"
      description="Create, read, update and delete route/tour records. The ID stays hidden and only user-friendly route data is shown."
    />
  );
}
`);

console.log("Phase E UI patch completed successfully.");
