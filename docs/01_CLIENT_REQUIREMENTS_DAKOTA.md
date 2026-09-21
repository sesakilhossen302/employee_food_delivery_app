# 01. Client Requirements Specification (From Dakota.pdf)

## Project Overview
- **Type**: Gas Station & Convenience Store Delivery Application.
- **Goal**: Allow local customers to order products directly from the gas station/convenience store and have them delivered to home, workplace, hotel, campground, or other local address, or choose store pickup.
- **Key Philosophy**: Simple, professional, fast, and easy for both customers and staff.

---

## 1. Customer Application (Mobile)
- **Authentication**:
  - Sign up & Login (Name, Phone number, Email address, Password).
  - Guest Checkout option.
- **Location & Delivery Verification**:
  - Save multiple delivery addresses.
  - Automatic check whether customer address falls within the store's delivery area/radius.
- **Home Screen**:
  - Gas station branding/logo & banner.
  - Current promotions, featured products, popular products.
  - Category horizontal chips & global search bar.
- **Product Catalog & Browsing**:
  - Categories: Drinks, Pop, Energy Drinks, Water, Coffee, Chips, Candy, Chocolate, Ice Cream, Snacks, Grocery, Automotive, Windshield washer fluid, Ice, Firewood, Propane-related, Seasonal, Specials.
  - Product details: Photo, name, description, price, sale price, size/options, max purchase limit, availability tag.
- **Cart & Pricing**:
  - Add/remove/increment/decrement quantity.
  - Breakdown: Items, Quantities, Subtotal, Taxes, Delivery fee, Discounts, Tip, Final Total.
  - Delivery instructions field: *"Leave at front door"*, *"Call when you arrive"*, *"Side entrance"*, *"Meet in lobby"*, etc.
- **Fulfillment Types**:
  - Delivery.
  - Store Pickup (if enabled by store).
- **Payment Method**:
  - **Cash / Hand payment ONLY (No online gateway required)**.
  - Options:
    1. Cash on Delivery (COD)
    2. Pay at Door
    3. Cash at Store Pickup
- **Order Tracking**:
  - 6 specific lifecycle statuses:
    1. `Order received`
    2. `Order confirmed`
    3. `Preparing order`
    4. `Ready for driver`
    5. `Out for delivery`
    6. `Delivered`
  - Real-time updates & Push notifications.
  - Prepared for future live driver GPS map tracking.

---

## 2. Order Packing Slip / Invoice PDF (Special Client Request)
- For every placed order, the system must generate a professional printable **Order Invoice / Packing Slip PDF**.
- **Usage**: Staff prints or exports this PDF from the Admin Dashboard and staples/attaches it with the grocery delivery bag to hand to the customer.
- **Contains**:
  - Store Name, Address, Contact.
  - Order Number & Barcode / QR Code.
  - Customer Name, Phone, Delivery Address & Delivery Instructions.
  - Itemized List with Quantity, Unit Price, Total Price.
  - Subtotal, Tax Breakdown, Distance Delivery Fee, Tip, Final Total (Cash to Collect).
  - Order Timestamp & Fulfillment Type (Delivery vs Store Pickup).

---

## 3. Delivery & Distance Settings
- Configurable delivery zone (by Postal/ZIP codes or Radial Distance in km from gas station).
- Tiered delivery pricing based on distance:
  - Example: `0 - 5 km` = $X
  - Example: `5 - 10 km` = $Y
  - Example: `10 - 20 km` = $Z
- Free delivery threshold: If subtotal >= Free Delivery Amount (e.g. $50), delivery fee is waived ($0).

---

## 4. Admin Dashboard (Web)
- **Live Orders Manager**: Real-time incoming orders, status changing, assigning driver, instant order sound alerts.
- **Order Invoice PDF**: One-click **Print / Download Order Receipt PDF** for bag attachment.
- **Catalog Management**: Add/edit/delete categories & products, image upload, sale price toggle, instant out-of-stock toggle.
- **Delivery Zone Settings**: Configure distance tiers, radius, postal codes, and free delivery thresholds.
- **Customer & Driver Management**: View registered customers, manage driver accounts and status.
- **Store Settings**: Enable/disable Store Pickup, tax rate configuration, Pay-at-Door toggle.
