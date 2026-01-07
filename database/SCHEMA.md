# Task Manager Database Schema (PostgreSQL)

This database container uses `database/startup.sh` to start PostgreSQL and create the database/user.  
Per project rules, schema and seed data are applied via `psql ... -c "SQL"` statements (one statement at a time), **not** via `.sql` startup files.

## Connection

See:

- `database/db_connection.txt` (authoritative)
- Default (from `database/startup.sh`): `postgresql://appuser:dbuser123@localhost:5000/myapp`

Example:

```bash
psql postgresql://appuser:dbuser123@localhost:5000/myapp
```

## Extensions

- `pgcrypto` is enabled to provide `gen_random_uuid()` for UUID primary keys.

## Types

### `task_status`
Enum values:

- `todo`
- `in_progress`
- `done`

## Tables

### `tasks`

| column      | type        | null | default | notes |
|-------------|-------------|------|---------|------|
| id          | uuid        | no   | gen_random_uuid() | primary key |
| title       | text        | no   | —       | required |
| description | text        | yes  | —       | optional |
| status      | task_status | no   | 'todo'  | enum |
| priority    | smallint    | no   | 2       | constrained to 1..3 (1 highest) |
| due_date    | timestamptz | yes  | null    | optional |
| created_at  | timestamptz | no   | now()   | |
| updated_at  | timestamptz | no   | now()   | maintained by trigger |

Trigger:

- `trg_tasks_set_updated_at` calls function `set_updated_at()` on `BEFORE UPDATE` to set `updated_at = now()`.

Indexes:

- `idx_tasks_status` on `(status)`
- `idx_tasks_due_date` on `(due_date)`

### `labels` (optional)

| column     | type        | null | default | notes |
|------------|-------------|------|---------|------|
| id         | uuid        | no   | gen_random_uuid() | primary key |
| name       | text        | no   | —       | unique |
| created_at | timestamptz | no   | now()   | |

### `task_labels` (optional)

Join table for many-to-many between `tasks` and `labels`.

| column  | type | null | notes |
|---------|------|------|------|
| task_id | uuid | no   | FK → tasks(id) ON DELETE CASCADE |
| label_id| uuid | no   | FK → labels(id) ON DELETE CASCADE |

Primary key:

- `(task_id, label_id)`

## Seed Data

Seeded in development with:

- 10 tasks across statuses (`todo`, `in_progress`, `done`) and priorities (1..3)
- 4 labels: `work`, `personal`, `urgent`, `shopping`
- A few task-label associations

If you need to re-seed for development, you can:

```sql
TRUNCATE TABLE task_labels, labels, tasks RESTART IDENTITY CASCADE;
```

Then re-run the individual INSERT statements as needed.

