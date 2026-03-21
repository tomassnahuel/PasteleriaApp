# HeMa Costos 🧁

![Demo](docs/demo.gif)

> **Calculá costos con precisión. Presupuestá en minutos. Vendé con margen.**

**HeMa Costos** es una app desarrollada en Flutter para pastelerías y emprendimientos gastronómicos que necesitan **dejar de improvisar precios y empezar a trabajar con números claros**.

---

## 🚀 Qué podés hacer

- 📦 Registrar insumos con su precio real  
- 🍰 Crear recetas y obtener su costo automáticamente  
- 💰 Definir precios con margen de ganancia  
- 🧾 Generar presupuestos en PDF listos para enviar  
- 🕓 Guardar historial de cálculos y pedidos  

---

## ⚠️ El problema

En la mayoría de los negocios gastronómicos:

- los precios se calculan “a ojo”  
- no se contemplan todos los costos  
- se pierde margen sin saberlo  
- responder presupuestos lleva demasiado tiempo  

---

## ✅ La solución

HeMa Costos organiza todo el proceso en un flujo simple:

**Insumos → Recetas → Costos → Presupuesto**

Esto permite:

- calcular con precisión  
- mantener márgenes consistentes  
- responder más rápido  
- mejorar la imagen frente al cliente  

---

## 💡 Beneficios directos

- Sabés exactamente cuánto cuesta producir  
- Evitás vender sin ganancia  
- Ahorrás tiempo en cada presupuesto  
- Tenés todo centralizado en una sola app  

---

## 🧠 Cómo funciona

1. Cargás tus insumos  
2. Armás tus recetas  
3. Calculás costos + margen  
4. Generás el presupuesto en PDF  

---

## 📄 Funcionalidades

### 📦 Gestión de insumos
Registro de materias primas con precio y unidad de medida.

### 🍰 Gestión de recetas
Cada producto queda asociado a su costo real.

### 💰 Cálculo de costos
- múltiples recetas  
- costos extra  
- packaging  
- margen configurable  
- guardado en historial  

### 🧾 Presupuestos en PDF
- cliente  
- productos y cantidades  
- mensaje personalizado  
- total final  

### 🕓 Historial
Acceso rápido a cálculos y presupuestos anteriores.

---

## 🎯 Público objetivo

- Pastelerías artesanales  
- Emprendedoras reposteras  
- Negocios de tortas personalizadas  
- Servicios de candy bar  
- Emprendimientos que venden por pedido  

---

## 🧩 Stack tecnológico

- **Flutter**  
- **Dart**  
- **SQLite (`sqflite`)**  
- **pdf + printing**  
- **path_provider + open_file**

---

## 🏗 Arquitectura

```text
lib/
├── data/
│   ├── database/
│   └── models/
├── logic/
├── pdf/
└── ui/
    ├── components/
    ├── screens/
    └── theme/
