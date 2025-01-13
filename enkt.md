# Документация по интеграции с ЕНКТ

## 1. Описание структуры данных

### 1.1 Таблица `ref_enkt_categories`
- Хранит дерево категорий, где каждая категория может быть вложена в другую.
- Поля:
  - `id`: Уникальный идентификатор категории.
  - `parent_id`: Родительская категория.
  - `code`: Код категории (например, `12.16.44`).
  - `deleted_at`: Дата деактивации категории.
  - `name`: JSON с переводами наименований категорий.

### 1.2 Таблица `ref_enkt_products`
- Хранит товары и их связь с категориями.
- Поля:
  - `id`: Уникальный идентификатор товара.
  - `category_id`: Ссылка на категорию.
  - `code`: Код товара.
  - `type`: Тип (1 — товары, 2 — услуги, 3 — прочее).
  - `deleted_at`: Дата деактивации товара.
  - `name`: JSON с переводами наименований товаров.

### 1.3 Таблица `ref_enkt_properties`
- Хранит свойства товаров.
- Поля:
  - `id`: Уникальный идентификатор свойства.
  - `position_id`: Ссылка на товар.
  - `number`: Уникальный номер свойства (используется для проверки контролирующим органом).
  - `required`: Указывает, обязательно ли свойство (булево).
  - `deleted_at`: Дата деактивации свойства.
  - `name`: JSON с переводами наименований свойств.

### 1.4 Таблица `ref_enkt_values`
- Хранит значения свойств.
- Поля:
  - `id`: Уникальный идентификатор значения.
  - `property_id`: Ссылка на свойство.
  - `number`: Уникальный номер значения (используется для проверки контролирующим органом).
  - `deleted_at`: Дата деактивации значения.
  - `name`: JSON с переводами наименований значений.

---

## 2. Основные требования

1. **Соответствие ЕНКТ**:
   - Данные (категории, товары, свойства, значения) должны соответствовать структуре и номерам, указанным на платформе ЕНКТ: [tasniflagich.mf.uz](https://tasniflagich.mf.uz/).
   - Контролирующий орган проверяет корректность данных на разных этапах.

2. **Деактивация записей**:
   - При деактивации записей в таблицы добавляется значение в поле `deleted_at`.

3. **Обработка выгрузки**:
   - Данные из выгрузки часто содержат ошибки или неполные пакеты.
   - Возможны ситуации, когда данные нужно корректировать вручную.

---

## 3. Логи выгрузок

- Входящие данные сохраняются в таблице `queue_log` в БД `integration`.
  - Поля:
    - `id`: Уникальный идентификатор записи.
    - `method_name`: Тип данных (например, `ENKT_PROP_VALUES`, `ENKT_PROPERTIES`, и т.д.).
    - `payload`: JSON с данными.
    - `status_code`: Статус обработки.
  
---

## 4. Логика обработки данных

### 4.1 Уникальность номера (`number`)
Для таблиц `ref_enkt_properties` и `ref_enkt_values` необходимо соблюдать уникальность поля `number`. Для этого рекомендуется настроить индексы:
```sql
CREATE UNIQUE INDEX idx_ref_enkt_properties_number ON ref_enkt_properties (number);
CREATE UNIQUE INDEX idx_ref_enkt_values_number ON ref_enkt_values (number);
```

### 4.2 Проверка связей
#### 4.2.1 Целостность данных
- Проверка товаров без свойств:
  ```sql
  SELECT p.id AS product_id
  FROM ref_enkt_products p
  LEFT JOIN ref_enkt_properties pr ON pr.position_id = p.id
  WHERE pr.id IS NULL AND p.deleted_at IS NULL;
  ```

- Проверка свойств без значений:
  ```sql
  SELECT pr.id AS property_id
  FROM ref_enkt_properties pr
  LEFT JOIN ref_enkt_values v ON v.property_id = pr.id
  WHERE v.id IS NULL AND pr.deleted_at IS NULL;
  ```

#### 4.2.2 Деактивация записей
При изменении данных старые записи помечаются как удаленные:
```sql
UPDATE ref_enkt_properties
SET deleted_at = NOW()
WHERE number = '2';
```

### 4.3 Обработка изменений
#### Добавление новых данных:
```sql
INSERT INTO ref_enkt_properties (position_id, number, required, name, inserted_at)
VALUES (1, '12345', TRUE, 'Название свойства', NOW());
```

#### Обновление существующих данных:
```sql
UPDATE ref_enkt_properties
SET name = 'Новое название', updated_at = NOW()
WHERE id = 1;
```

### 4.4 Проверка выгрузки
Перед загрузкой данных необходимо проверять их целостность. Например:
```sql
SELECT *
FROM queue_log
WHERE method_name ILIKE '%ENKT%' AND status_code IS NULL;
```

---

## 5. Запросы в проекте `common`
В проекте `common` файлы запросов находятся по пути `apps/ms_dict/lib/ms_dict/crud.ex`. Запросы обрабатывают следующие таблицы:
- `ref_enkt_tree_products`
- `ref_enkt_categories`
- `ref_enkt_limit_categories`
- `ref_enkt_products`
- `ref_enkt_properties`
- `ref_enkt_values`

---
