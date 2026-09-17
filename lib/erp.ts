export type Customer = {
  id: string;
  name: string;
  phone: string;
  email: string;
  lastPurchase: string;
  totalSpent: number;
};

export type Product = {
  id: string;
  name: string;
  category: string;
  sku: string;
  quantity: number;
  minimumStock: number;
  price: number;
};

export const initialCustomers: Customer[] = [
  { id: "cli-001", name: "Mariana Alves", phone: "(31) 9 8842-1030", email: "mariana@email.com", lastPurchase: "Hoje", totalSpent: 1284 },
  { id: "cli-002", name: "Rafael Costa", phone: "(31) 9 7721-4992", email: "rafael@email.com", lastPurchase: "Ontem", totalSpent: 986 },
  { id: "cli-003", name: "Lucas Silva", phone: "(31) 9 6154-2387", email: "lucas@email.com", lastPurchase: "10 set", totalSpent: 2140 },
];

export const initialProducts: Product[] = [
  { id: "pro-001", name: "Essência Uva Ice 50g", category: "Essências", sku: "ESS-UVA-50", quantity: 4, minimumStock: 8, price: 32.9 },
  { id: "pro-002", name: "Carvão de Coco 1kg", category: "Acessórios", sku: "CAR-COCO-1", quantity: 18, minimumStock: 10, price: 42 },
  { id: "pro-003", name: "Gin Tanqueray 750ml", category: "Adega", sku: "GIN-TAN-750", quantity: 5, minimumStock: 6, price: 139.9 },
  { id: "pro-004", name: "Seda Brown King Size", category: "Tabacaria", sku: "SED-BRO-KS", quantity: 31, minimumStock: 12, price: 8.5 },
];

export const money = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
});
