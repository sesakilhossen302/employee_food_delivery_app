# 05. Complete Order Lifecycle & Communication Flow

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 📱 Customer (Mobile)
    actor Admin as 💻 Store Staff / Admin (Web)
    actor Driver as 🛵 Driver (Mobile)
    participant Backend as ⚙️ Backend (TypeScript + Socket.io)
    participant DB as 🗄️ MongoDB

    Note over Customer, Admin: Phase 1: Order Placement
    Customer->>Backend: POST /api/v1/orders (Items, Delivery Address, Instructions, Cash on Delivery)
    Backend->>DB: Save Order (Status: 'received')
    Backend-->>Customer: 201 Created (Order Confirmation #GS-1001)
    Backend-)Admin: WebSocket emit('new_order') [Sound Alert Triggers 🔔]

    Note over Admin: Phase 2: Confirmation & Packing Slip
    Admin->>Backend: PATCH /api/v1/orders/:id/status ('confirmed' -> 'preparing')
    Backend-)Customer: WebSocket emit('order_status_updated')
    Admin->>Backend: GET /api/v1/orders/:id/invoice-pdf
    Backend-->>Admin: Printable Packing Slip PDF
    Note over Admin: Staff prints packing slip & staples to grocery bag 🛍️

    Note over Admin, Driver: Phase 3: Driver Assignment
    Admin->>Backend: PATCH /api/v1/orders/:id/assign-driver (driverId)
    Backend->>DB: Update (Status: 'ready_for_driver', assignedDriver)
    Backend-)Driver: WebSocket emit('driver_order_assigned')
    Backend-)Customer: WebSocket emit('order_status_updated', 'ready_for_driver')

    Note over Driver: Phase 4: Delivery
    Driver->>Backend: PATCH /api/v1/orders/:id/status ('out_for_delivery')
    Backend-)Customer: WebSocket emit('order_status_updated', 'out_for_delivery')
    Driver->>Customer: Arrives, hands products with attached packing slip
    Customer->>Driver: Pays Cash at Door 💵
    Driver->>Backend: PATCH /api/v1/orders/:id/status ('delivered', paymentStatus: 'paid')
    Backend-)Customer: WebSocket emit('order_status_updated', 'delivered')
    Backend-)Admin: WebSocket emit('order_status_updated', 'delivered')
```

---

## Order Status Mapping Across Components

| Status Key | Customer Display Title | Driver Action | Admin Action |
| :--- | :--- | :--- | :--- |
| `received` | Order Received | Waiting store confirmation | Audio alert plays; review order |
| `confirmed` | Order Confirmed | None | Accept order & start gathering items |
| `preparing` | Preparing Your Order | None | Pack items & print PDF packing slip |
| `ready_for_driver` | Ready for Pickup | Notification received; accept delivery | Hand packed bag with invoice to driver |
| `out_for_delivery` | Out for Delivery | En route to customer address | Monitor delivery progress |
| `delivered` | Delivered & Paid | Cash collected confirmed | Order marked completed in daily totals |
