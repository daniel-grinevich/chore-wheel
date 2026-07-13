# Chore Wheel 🧹

A shared weekly chore board for two people. It randomly but *fairly* assigns the
active chores each week — balancing total **minutes** per person — and each chore
has a start/stop **timer**. Completed timings refine every chore's average
duration and difficulty over time, which feeds the next week's fairness math.

Rails 8 monolith: Hotwire (Turbo + Stimulus) UI, PostgreSQL, Solid Queue for the
weekly auto-assign job (run inside Puma). No separate frontend, no login — it's a
private two-person app served over a tailnet.

## How it works

- **People** — two rows (you + partner), each a color. Pick "who am I" per browser.
- **Chores** — a master list; each has a `base_estimate_minutes` guess.
- **Weekly assignment** (`app/services/weekly_assigner.rb`) — greedy
  Longest-Processing-Time: shuffle for randomness, then hand out chores
  largest-first to whoever has the fewest minutes so far. Idempotent per week.
- **Timer** — Start opens a `WorkSession`; Stop records its duration and marks the
  chore done. `Chore#average_minutes` is the rolling mean of the last
  `RECENT_SAMPLE` real timings (falling back to the base guess), and
  `Chore#difficulty` (easy/medium/hard) is derived from it — both self-refine.
- **Recurring job** — `config/recurring.yml` runs `WeeklyAssignJob` every Monday
  00:05 to generate the new week automatically.

## Local development

```bash
bin/setup            # installs deps, prepares the DB
bin/rails db:seed    # two people + starter chores
bin/dev              # http://localhost:3000
bin/rails test       # model + service specs
```

On the board, click **Generate this week**, then **Start**/**Stop** a chore's timer
and watch its refined average and difficulty update on the Chores page.

## Deployment (rainbow-road / ArgoCD)

Runs on the `rainbow-road` cluster the same way as `navi`: image built to GHCR by
CI, kustomize manifests synced by ArgoCD, served privately over the tailnet.

1. **Push code** to `main` → `.github/workflows/deploy.yml` builds and pushes
   `ghcr.io/daniel-grinevich/chore-wheel:staging-<sha>` and `:staging-latest`.
2. **Manifests** live in `rainbow-road/chores/{base,staging}` with an ArgoCD
   Application at `rainbow-road/argocd/applications/chores-staging.yaml`.
3. **Fill secrets** in `rainbow-road/chores/base/secrets.yaml` before applying:
   - `RAILS_MASTER_KEY` = contents of `config/master.key`
   - `POSTGRES_PASSWORD` = a strong password (POSTGRES_USER/DB already set)
4. **Deploy a build**: set `newTag` in `chores/staging/kustomization.yaml` to the
   `staging-<sha>` you want and push rainbow-road; ArgoCD syncs it.

The pod runs migrations on boot (`bin/docker-entrypoint` → `db:prepare` creates
the primary/cache/queue/cable databases in the one Postgres pod) and runs the
Solid Queue worker inside Puma (`SOLID_QUEUE_IN_PUMA=true`).

Result: `https://chores-staging.tailf9a785.ts.net` on your tailnet.
