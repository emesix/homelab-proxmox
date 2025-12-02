# ADR-002: AI Layering – Bronze, Silver, Gold

## Status

Draft / Proposed

## Context

The homelab will use AI in three distinct ways:

- External, high-quality models (expensive, but best results).
- Local high-power AI worker (X99 + dual A770) which is not always online.
- Local AI-orchestrator/controller (CW-NAS with 8845HS) which is always online and should be relatively lightweight.

Requirements:

- Reduce cloud costs by offloading suitable work to local models when available.
- Still make it easy to get **high quality** answers when required.
- Keep the orchestration logic as simple and standard as possible (avoid reinventing the wheel).

## Decision

Introduce a three-tier AI model:

- **Bronze (Local Orchestrator)**:
  - Runs on the CW-NAS AI-controller.
  - Handles:
    - lightweight reasoning,
    - glue code,
    - job preparation,
    - validation of outputs,
    - orchestration between tools/agents.
  - Uses modest local models for cheap, fast responses where possible.

- **Silver (Local Worker)**:
  - Runs on the X99 AI-worker with dual A770.
  - Handles:
    - heavier computation,
    - long-running tasks,
    - local inference where GPU acceleration provides benefit.
  - Not always powered on:
    - jobs can queue here until the worker is available.

- **Gold (External APIs)**:
  - Uses external services (e.g. OpenRouter, OpenAI).
  - Reserved for:
    - high-value tasks,
    - situations where highest accuracy or robustness is needed.
  - Controlled via explicit flags or policies (e.g. “allow external = true”).

Job routing will follow a simple policy:

- Low importance:
  - Bronze only.
- Medium importance:
  - Prefer Silver (if worker online).
  - Optionally queue until Silver is available.
- High importance:
  - If external is allowed → Gold.
  - If external is not allowed → Silver or explicit user intervention.

## Consequences

- There is a clear conceptual model for where a job runs.
- Power use is minimised by keeping the high-power worker off until needed.
- Cloud spend is controlled by explicit decisions to use Gold-tier models.
- Implementation can lean on existing tools (e.g. queues, flow engines) rather than custom frameworks.

## Open Questions

- Which concrete tools will implement the queue/orchestrator?
- How is job state persisted (DB vs. file vs. queue system)?
- What visibility/dashboard will be provided to inspect the queue?
