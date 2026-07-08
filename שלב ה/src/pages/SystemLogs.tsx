import React, { useEffect, useState } from 'react';
import { Loader2, ReceiptText, RefreshCcw, TrendingUp } from 'lucide-react';

function Table({ rows }: { rows: any[] }) {
  if (!rows.length) return <p className="text-slate-400 font-bold p-6">No rows yet.</p>;
  const columns = Array.from(new Set(rows.flatMap((row) => Object.keys(row).filter((key) => key !== 'id'))));
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-orange-50/70 text-orange-500 text-[10px] uppercase font-black tracking-[0.2em]">
            {columns.map((column) => <th key={column} className="px-6 py-4 whitespace-nowrap">{column}</th>)}
          </tr>
        </thead>
        <tbody className="divide-y divide-orange-50">
          {rows.map((row, index) => (
            <tr key={index}>
              {columns.map((column) => <td key={column} className="px-6 py-4 text-sm font-bold text-slate-600">{String(row[column] ?? '—')}</td>)}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function SystemLogs() {
  const [paymentRows, setPaymentRows] = useState<any[]>([]);
  const [priceRows, setPriceRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const [payments, prices] = await Promise.all([
        fetch('/api/logs/payment').then((res) => res.json()),
        fetch('/api/logs/price-history').then((res) => res.json()),
      ]);
      setPaymentRows(Array.isArray(payments) ? payments : []);
      setPriceRows(Array.isArray(prices) ? prices : []);
    } catch (err: any) {
      setError(err.message || 'Cannot load logs');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="space-y-8 font-sans">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="text-4xl font-black text-slate-800 tracking-tight">System Logs</h2>
          <p className="text-slate-400 font-bold mt-2 max-w-3xl">
            These tables show the effect of Phase D procedures and triggers: payment_log and tour_price_history.
          </p>
        </div>
        <button onClick={load} className="flex items-center justify-center gap-2 px-6 py-4 bg-white text-slate-500 rounded-3xl border border-slate-100 font-black hover:bg-slate-50 transition-all">
          {loading ? <Loader2 size={18} className="animate-spin" /> : <RefreshCcw size={18} />}
          Refresh
        </button>
      </div>

      {error && <div className="bg-red-50 border border-red-100 text-red-600 rounded-3xl p-5 font-bold">{error}</div>}

      <div className="grid grid-cols-1 gap-8">
        <section className="bg-white rounded-[3rem] border border-emerald-50 overflow-hidden shadow-xl shadow-emerald-100/20">
          <div className="p-8 flex items-center gap-4 border-b border-emerald-50">
            <div className="p-4 rounded-2xl bg-emerald-50 text-emerald-500"><ReceiptText size={26} /></div>
            <div>
              <h3 className="text-2xl font-black text-slate-800">Payment Log</h3>
              <p className="text-sm font-bold text-slate-400">Rows added by pr_pay_customer_bookings.</p>
            </div>
          </div>
          <Table rows={paymentRows} />
        </section>

        <section className="bg-white rounded-[3rem] border border-orange-50 overflow-hidden shadow-xl shadow-orange-100/20">
          <div className="p-8 flex items-center gap-4 border-b border-orange-50">
            <div className="p-4 rounded-2xl bg-orange-50 text-orange-500"><TrendingUp size={26} /></div>
            <div>
              <h3 className="text-2xl font-black text-slate-800">Tour Price History</h3>
              <p className="text-sm font-bold text-slate-400">Rows added automatically by the price-update trigger.</p>
            </div>
          </div>
          <Table rows={priceRows} />
        </section>
      </div>
    </div>
  );
}
