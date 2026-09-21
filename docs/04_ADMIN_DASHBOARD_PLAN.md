# 04. Admin Dashboard Plan (React + Vite + TypeScript + Tailwind CSS)

## 1. Dashboard Purpose & Core Value
The Admin Dashboard is the central control hub for the Gas Station / Convenience Store owner and staff. It enables seamless store operations, live order processing, packing slip printing, inventory management, and delivery area pricing.

---

## 2. Key Modules & Client Features

### A. Live Orders & Real-Time Kitchen/Store Board
- **Real-Time Kanban / Tabbed View**:
  - `Received` ➔ `Confirmed` ➔ `Preparing` ➔ `Ready for Driver` ➔ `Out for Delivery` ➔ `Delivered`.
- **Audio & Visual Alerts**: Sound notification whenever a new customer order arrives.
- **Order Details Modal**:
  - Full items ordered with quantities.
  - Customer contact & delivery address.
  - Customer special delivery instructions (*"Leave at front door"*, etc.).
  - Total cash to collect.
  - Quick status transition dropdown/buttons.
  - Assign to Driver selector.

### B. One-Click Order Invoice / Packing Slip PDF (Client Priority)
- Every order card has a **"Print Packing Slip"** / **"Download Receipt PDF"** button.
- Clean, professional receipt formatted for standard thermal or A4/Letter printers.
- Staff prints this receipt, staples it to the customer's grocery bag, and hands it to the driver or pickup customer.

### C. Menu & Catalog Management (Dakota Spec)
- **Categories**: Create, edit, and re-order store categories (Drinks, Pop, Snacks, Ice, Automotive, Firewood, etc.).
- **Product Management**:
  - Add product with photo, name, description, unit/size, price, sale price, category.
  - **Quick Stock Toggle**: 1-click switch between `In Stock` and `Sold Out` so customers cannot order unavailable items.
  - Set maximum purchase quantity limit.

### D. Delivery Zone & Pricing Settings
- Configure store base location.
- Set delivery radius (e.g. up to 20 km) or postal code whitelist.
- Configure tiered delivery pricing:
  - `0 - 5 km`: $X.XX
  - `5 - 10 km`: $Y.YY
  - `10 - 20 km`: $Z.ZZ
- Configure **Free Delivery Order Minimum** (e.g. $50.00).

### E. Store & Payment Settings
- Enable / Disable **Store Pickup**.
- Enable / Disable **Pay at Door**.
- Configure Sales Tax rate percentage (e.g. 5%, 13%, etc.).

---

## 3. Directory Structure (`admin-dashboard/`)

```text
admin-dashboard/
├── src/
│   ├── assets/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Badge.tsx
│   │   │   ├── Button.tsx
│   │   │   ├── Modal.tsx
│   │   │   └── Toggle.tsx
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── Layout.tsx
│   │   └── orders/
│   │       ├── OrderCard.tsx
│   │       ├── OrderDetailsModal.tsx
│   │       └── InvoicePrintView.tsx   # Printable packing slip preview
│   ├── context/
│   │   ├── AuthContext.tsx
│   │   └── SocketContext.tsx          # Real-time alert notifications
│   ├── pages/
│   │   ├── DashboardOverview.tsx      # Today's sales, pending orders, revenue
│   │   ├── LiveOrders.tsx             # Kanban / List of active orders
│   │   ├── MenuCatalog.tsx            # Category & Product management
│   │   ├── DeliverySettings.tsx       # Distance tiers & postal codes
│   │   ├── DriverManagement.tsx       # Drivers list & assigned orders
│   │   ├── StoreSettings.tsx          # Tax, pickup, cash payment toggles
│   │   └── Login.tsx                  # Staff / Admin login
│   ├── services/
│   │   ├── api.ts                     # Axios client with interceptor
│   │   └── socket.ts                  # Socket.io client setup
│   ├── types/
│   │   └── index.ts                   # TypeScript interfaces
│   ├── App.tsx
│   ├── index.css                      # Tailwind CSS styles
│   └── main.tsx
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── vite.config.ts
```
