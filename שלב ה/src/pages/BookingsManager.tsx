import CrudManager from '@/src/components/CrudManager';
import { FieldConfig } from '@/src/types';

const fields: FieldConfig[] = [
  { key: 'user_id', label: 'Traveler', type: 'select', lookup: 'users', required: true },
  { key: 'tour_id', label: 'Tour', type: 'select', lookup: 'tours', required: true },
  { key: 'booking_date', label: 'Booking Date', type: 'date' },
  { key: 'participants', label: 'Participants', type: 'number' },
  { key: 'payment_status', label: 'Payment Status', type: 'select', options: ['Pending', 'Paid', 'Unpaid', 'Refunded'] },
  { key: 'total_price', label: 'Total Price', type: 'number' },
];

export default function BookingsManager() {
  return (
    <CrudManager
      title="Bookings"
      endpoint="bookings"
      fields={fields}
      accent="purple"
      description="Manage bookings. Traveler and tour are selected from dropdowns and shown as names instead of IDs."
    />
  );
}
