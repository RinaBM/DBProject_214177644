import React, { useState } from 'react';
import { Sparkles } from 'lucide-react';
import { cn } from '@/src/lib/utils';

type CardState = {
  args: string;
  loading: boolean;
  message: string;
  result: any;
};

function parseArgs(value: string) {
  const parsed = JSON.parse(value || '[]');
  if (!Array.isArray(parsed)) {
    throw new Error('Arguments must be an array. Example: [1] or [1,1,2].');
  }
  return parsed;
}

function ResultBox({ state }: { state: CardState }) {
  if (!state.message && !state.result) return null;

  const isSuccess = state.message.toLowerCase().includes('successfully');

  return (
    <div className="mt-5 space-y-4">
      {state.message && (
        <div className={cn(
          'rounded-3xl p-5 font-bold leading-relaxed text-sm',
          isSuccess
            ? 'bg-emerald-50 text-emerald-700 border border-emerald-100'
            : 'bg-red-50 text-red-600 border border-red-100'
        )}>
          {state.message}
        </div>
      )}

      {state.result && (
        <pre className="bg-white border border-slate-100 rounded-3xl p-5 text-xs overflow-auto max-h-56 text-slate-600 font-bold">
          {JSON.stringify(state.result, null, 2)}
        </pre>
      )}
    </div>
  );
}

export default function AdvancedActions() {
  const [cards, setCards] = useState<Record<string, CardState>>({
    busiest: { args: '[]', loading: false, message: '', result: null },
    guideLoad: { args: '[]', loading: false, message: '', result: null },
    f1: { args: '[1]', loading: false, message: '', result: null },
    f2: { args: '[1]', loading: false, message: '', result: null },
    p1: { args: '[1,1,2]', loading: false, message: '', result: null },
    p2: { args: '[1]', loading: false, message: '', result: null },
  });

  const updateCard = (key: string, patch: Partial<CardState>) => {
    setCards((prev) => ({ ...prev, [key]: { ...prev[key], ...patch } }));
  };

  const runGet = async (key: string, url: string, title: string) => {
    updateCard(key, { loading: true, message: '', result: null });

    try {
      const res = await fetch(url);
      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Action failed');

      updateCard(key, {
        message: `${title} executed successfully.`,
        result: data,
      });
    } catch (err: any) {
      updateCard(key, {
        message: err.message || 'Action failed',
        result: null,
      });
    } finally {
      updateCard(key, { loading: false });
    }
  };

  const runRoutine = async (key: string, url: string, title: string) => {
    updateCard(key, { loading: true, message: '', result: null });

    try {
      const args = parseArgs(cards[key].args);

      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ args }),
      });

      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Routine failed');

      updateCard(key, {
        message: `${title} executed successfully.`,
        result: data,
      });
    } catch (err: any) {
      updateCard(key, {
        message: err.message || 'Routine failed',
        result: null,
      });
    } finally {
      updateCard(key, { loading: false });
    }
  };

  const queryCards = [
    {
      key: 'busiest',
      title: 'Busiest Day Query',
      label: 'Query 1',
      text: 'Phase B query: shows which day of week has the most guided tours.',
      action: () => runGet('busiest', '/api/advanced/busiest-day', 'Busiest Day Query'),
    },
    {
      key: 'guideLoad',
      title: 'Guide Load Query',
      label: 'Query 2',
      text: 'Phase B query: shows guide workload by number of tours.',
      action: () => runGet('guideLoad', '/api/advanced/guide-load', 'Guide Load Query'),
    },
  ];

  const routineCards = [
    {
      key: 'f1',
      title: 'fn_available_places',
      label: 'Function 1',
      text: 'Checks available places for a guided tour. Example argument: [1]',
      action: () => runRoutine('f1', '/api/advanced/function/1', 'fn_available_places'),
    },
    {
      key: 'f2',
      title: 'fn_customer_unpaid_bookings',
      label: 'Function 2',
      text: 'Returns unpaid bookings for a traveler/customer. Example argument: [1]',
      action: () => runRoutine('f2', '/api/advanced/function/2', 'fn_customer_unpaid_bookings'),
    },
    {
      key: 'p1',
      title: 'pr_create_booking',
      label: 'Procedure 1',
      text: 'Creates a booking if enough places are available. Example argument: [1,1,2]',
      action: () => runRoutine('p1', '/api/advanced/procedure/1', 'pr_create_booking'),
    },
    {
      key: 'p2',
      title: 'pr_pay_customer_bookings',
      label: 'Procedure 2',
      text: 'Marks unpaid bookings as paid. Example argument: [1]',
      action: () => runRoutine('p2', '/api/advanced/procedure/2', 'pr_pay_customer_bookings'),
    },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-4xl font-black text-slate-800 tracking-tight">Advanced Actions</h2>
        <p className="text-slate-400 font-bold mt-2 max-w-4xl">
          This screen runs Phase B queries and activates Phase D PL/pgSQL functions and procedures.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {queryCards.map((card) => (
          <div key={card.key} className="bg-slate-50 rounded-[2.5rem] p-7 border border-slate-100">
            <p className="text-[10px] font-black uppercase tracking-[0.25em] text-orange-500">{card.label}</p>
            <h3 className="text-2xl font-black text-slate-800 mt-2">{card.title}</h3>
            <p className="text-sm font-bold text-slate-400 mt-3">{card.text}</p>

            <button
              onClick={card.action}
              disabled={cards[card.key].loading}
              className="mt-6 w-full py-4 bg-orange-500 hover:bg-orange-600 text-white rounded-3xl font-black transition-all disabled:opacity-60"
            >
              {cards[card.key].loading ? 'Running...' : 'Run Query'}
            </button>

            <ResultBox state={cards[card.key]} />
          </div>
        ))}

        {routineCards.map((card) => (
          <div key={card.key} className="bg-slate-50 rounded-[2.5rem] p-7 border border-slate-100">
            <p className="text-[10px] font-black uppercase tracking-[0.25em] text-blue-500">{card.label}</p>
            <h3 className="text-2xl font-black text-slate-800 mt-2">{card.title}</h3>
            <p className="text-sm font-bold text-slate-400 mt-3">{card.text}</p>

            <input
              value={cards[card.key].args}
              onChange={(e) => updateCard(card.key, { args: e.target.value })}
              className="mt-5 w-full px-5 py-4 bg-white border border-slate-100 rounded-3xl font-bold outline-none focus:ring-4 focus:ring-blue-100"
            />

            <button
              onClick={card.action}
              disabled={cards[card.key].loading}
              className="mt-4 w-full py-4 bg-blue-500 hover:bg-blue-600 text-white rounded-3xl font-black transition-all disabled:opacity-60 flex items-center justify-center gap-2"
            >
              <Sparkles size={18} />
              {cards[card.key].loading ? 'Running...' : card.label.includes('Procedure') ? 'Run Procedure' : 'Run Function'}
            </button>

            <ResultBox state={cards[card.key]} />
          </div>
        ))}
      </div>
    </div>
  );
}
