# 02. Backend Plan: Node.js + Express + TypeScript + Socket.io + MongoDB

## 1. Core Responsibilities
1. **Authentication & RBAC**:
   - Roles: `customer` (or employee), `driver`, `admin`, `staff`.
   - JWT authentication & Guest checkout support.
2. **Product & Category Engine**:
   - Gas station categories (Drinks, Pop, Snacks, Automotive, Firewood, Ice, Propane, etc.).
   - Products with photo, price, sale price, size/options, stock toggle (`inStock: boolean`), and max limit.
3. **Delivery Zone & Fee Calculation**:
   - Validate customer address / postal code / coordinates against store delivery zone.
   - Calculate distance-tiered delivery fee (0-5km, 5-10km, 10-20km).
   - Apply free delivery threshold if order subtotal exceeds minimum limit.
4. **Order Management & Status Flow**:
   - Flow: `Order received` ➔ `Order confirmed` ➔ `Preparing order` ➔ `Ready for driver` ➔ `Out for delivery` ➔ `Delivered`.
   - Cash / Hand payment tracking (`Cash on Delivery`, `Pay at Door`, `Cash at Store Pickup`).
5. **Real-time Engine (Socket.io)**:
   - Real-time updates emitted on order state changes.
   - Admin receives live audio-visual notification on `new_order`.
   - Driver receives `driver_order_assigned` and updates status in real-time.
   - Customer app receives `order_status_updated`.
6. **Order Invoice / Packing Slip PDF Generation**:
   - Server-side PDF generation using `pdfkit` or clean HTML-to-PDF template.
   - Accessible via `GET /api/v1/orders/:id/invoice-pdf` for one-click print/download in Admin Dashboard.

---

## 2. Directory Structure (`backend/`)

```text
backend/
├── src/
│   ├── @types/
│   │   └── express.d.ts             # Express request user extensions
│   ├── config/
│   │   ├── db.ts                    # MongoDB Mongoose connection
│   │   └── env.ts                   # Type-safe environment variables
│   ├── controllers/
│   │   ├── auth.controller.ts       # Customer, Driver, Admin Auth & Guest checkout
│   │   ├── category.controller.ts   # Category CRUD
│   │   ├── product.controller.ts    # Product CRUD, quick stock toggle
│   │   ├── order.controller.ts      # Place order, status transitions, driver assignment
│   │   ├── invoice.controller.ts    # PDF Packing Slip generator
│   │   ├── delivery.controller.ts   # Delivery zone & tiered fee calculations
│   │   └── admin.controller.ts      # Analytics, sales summaries, driver management
│   ├── middlewares/
│   │   ├── auth.middleware.ts       # Verify JWT token
│   │   ├── role.middleware.ts       # Role guard ('admin' | 'staff' | 'driver' | 'customer')
│   │   └── error.middleware.ts      # Global centralized error handler
│   ├── models/
│   │   ├── User.model.ts            # Customer & staff profiles, saved addresses
│   │   ├── Category.model.ts        # Categories from Dakota spec
│   │   ├── Product.model.ts         # Products with images, sale price, stock
│   │   ├── Order.model.ts           # Orders with 6 statuses, delivery fee, payment
│   │   └── StoreSettings.model.ts   # Delivery zones, tiered fees, tax rate, pickup toggle
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── category.routes.ts
│   │   ├── product.routes.ts
│   │   ├── order.routes.ts
│   │   ├── delivery.routes.ts
│   │   └── admin.routes.ts
│   ├── services/
│   │   ├── pdf.service.ts           # Creates professional packing slip PDF
│   │   └── delivery.service.ts      # Distance calculation & zone matching
│   ├── sockets/
│   │   └── socket.handler.ts        # Real-time rooms & broadcasts
│   ├── utils/
│   │   └── seed.ts                  # Seeds Gas Station categories & demo items
│   ├── app.ts                       # Express app configuration & middlewares
│   └── server.ts                    # Entry point, HTTP server & Socket.io mount
├── .env.example
├── package.json
└── tsconfig.json
```

---

## 3. Database Schema Blueprint

### A. Order Model (`Order.model.ts`)
- `orderNumber`: Human-readable e.g., `#GS-10023`
- `customer`: Name, Phone, Email, Delivery Address, Delivery Instructions (*"Leave at front door"*, etc.)
- `fulfillmentType`: `'delivery' | 'pickup'`
- `items`: `[{ product, name, quantity, price, totalPrice }]`
- `pricing`:
  - `subtotal`: Number
  - `taxes`: Number
  - `deliveryFee`: Number
  - `discount`: Number
  - `tip`: Number
  - `total`: Number (Cash to collect)
- `paymentMethod`: `'cash_on_delivery' | 'pay_at_door' | 'cash_at_pickup'`
- `paymentStatus`: `'unpaid' | 'paid' | 'refunded'`
- `status`: `'received' | 'confirmed' | 'preparing' | 'ready_for_driver' | 'out_for_delivery' | 'delivered'`
- `assignedDriver`: ObjectId (User)
- `estimatedDeliveryMinutes`: Number (e.g. 20-30 min)
- `timestamps`: createdAt, updatedAt

---

## 4. Packing Slip PDF Layout Specification
The generated PDF will feature:
- Header: Gas Station & Convenience Store Logo, Store Address, Phone, Date & Time.
- Customer Box: Customer Name, Phone, Delivery Address, Specific Delivery Instructions.
- Order Details: Order Number, Order Type (Delivery / Pickup), Payment Type (CASH).
- Items Table: Item Name, Qty, Unit Price, Total.
- Financial Summary Box: Subtotal, Taxes, Delivery Fee, Tip, Total Cash Due.
- Driver Signature / Confirmation tear-off section.
