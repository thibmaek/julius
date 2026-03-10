## Overview & scope

- **Repository**: Home Assistant configuration with a strong focus on ESPHome device YAMLs.
- **Audience**: LLM-based agents (and tools using them) working on this repo.
- **Scope**: This document governs work on ESPHome configuration under `esphome/`. Broader Home Assistant configuration (automations, scenes, scripts, dashboards, etc.) is **out of scope** unless explicitly requested in a task.
- **Direct access**: Agents **do not** talk to the running Home Assistant instance. They only edit files in this repo.

## Repo map (ESPHome)

- **Top-level ESPHome directory**
  - `esphome/`: Individual device configs, e.g.`bed-sensor.yaml`, `esp8266-roomnode-zolder.yaml`, etc.
- **Shared configuration packages**
  - `esphome/shared/`: Shared packages pulled into devices via `packages:` includes, such as:
    - `base_config.yaml` – common ESPHome boilerplate (logging, status sensors, etc.).
    - `wifi.yaml` – Wi‑Fi configuration.
    - `api.yaml` – Home Assistant API configuration.
    - `metrics.yaml`, `i2c.yaml`, and similar cross-device settings.
- **Reusable component snippets**
  - `esphome/lib/`: Reusable component and device snippets, e.g.:
    - `roomnode.yaml`, `ikea_vindriktning.yaml`.
    - PWM / MOSFET / LED driver helpers.
    - Other patterns intended to be included into device configs.

**Standard device pattern**

- Typical device YAMLs follow this structure:
  - `substitutions:` for `device_name`, `friendly_name`, and similar values.
  - Board definition (`esp32:` or `esp8266:`).
  - Optional `external_components:` for third-party integrations.
  - `packages:` referencing shared configs from `esphome/shared/`.
  - Device-specific components (`sensor:`, `binary_sensor:`, `switch:`, `light:`, etc.), often using helpers from `esphome/lib/`.
- Agents should **mirror these patterns** when adding or updating devices.

## What agents should do

- **Primary responsibilities**
  - Create new ESPHome device configs by copying and adapting from the most similar existing device (same chip family, similar sensors or actuators).
  - Extend or refactor existing ESPHome YAMLs to:
    - Add sensors, switches, lights, and diagnostics.
    - Improve reliability, observability, or performance without changing behavior unexpectedly.
  - Keep shared packages in `esphome/shared/` and reusable snippets in `esphome/lib/` **consistent and reusable**.
  - Ensure configs remain compatible with current ESPHome and Home Assistant documentation.
- **Secondary responsibilities**
  - Make small, targeted documentation improvements in comments when they help future maintenance (e.g. explain non-obvious filters or lambdas).
  - Suggest (but not implement) larger architectural changes outside ESPHome (e.g. full HA automation rewrites) unless the task explicitly asks for that.

## Safety & constraints

- **Config-only edits**
  - Work only on repository files; do **not** assume any ability to deploy, restart, or otherwise affect the live Home Assistant instance.
- **Higher-risk domains**
  - For devices that control power, heating, locks, doors, or other safety/comfort‑critical systems:
    - Keep changes **small and incremental**.
    - Prefer extending diagnostics or adding sensors over changing core behavior.
    - When a behavior change is required, clearly describe it in comments and in any PR description.
- **External components**
  - When using `external_components:` (e.g. in `sound-level-sensor.yaml`):
    - Reference the relevant ESPHome or upstream component documentation.
    - Prefer stable, well-maintained sources. If a specific version or tag is important, note it explicitly in the config or in comments.

## ESPHome change workflow

- **1. Discover & understand**
  - Identify the target device file in `esphome/`.
  - Inspect its `packages:` block and read all referenced files under `esphome/shared/`.
  - If additional behavior is pulled from `esphome/lib/`, read those snippets as well.
  - Before inventing a new pattern, search for the most similar existing device and understand how it is structured.
- **2. Design changes**
  - Prefer reuse over duplication:
    - Use helpers from `esphome/lib/` and shared configs from `esphome/shared/` where possible.
    - When introducing a new reusable pattern, add it to `esphome/lib/` or `esphome/shared/` (whichever matches its purpose) and keep the name descriptive.
  - Avoid modifying `base_config.yaml`, `wifi.yaml`, or `api.yaml` unless:
    - The change is clearly repo‑wide.
    - It is well‑justified and documented.
    - It is unlikely to break existing devices.
- **3. Implement safely**
  - Follow the style and naming conventions described below.
  - Keep behavior changes minimal and explicit. When changing defaults (thresholds, delays, power behavior), consider introducing new parameters or comments describing why.
- **4. Validate**
  - Ensure YAML syntax is valid (no indentation or structure errors).
  - Ensure component keys and options match current ESPHome schema:
    - Cross‑check against the official ESPHome docs.
  - When suggesting changes, recommend that the user run local validation such as:
    - `esphome config <device>.yaml`
    - Or equivalent commands in their existing workflow.

## External docs & references

- **Primary references**
  - ESPHome documentation for:
    - Supported boards and variants (`esp32`, `esp32c3`, `esp8266`, etc.).
    - Components (`sensor`, `binary_sensor`, `switch`, `light`, `sound_level_meter`, filters, etc.).
  - Home Assistant documentation for:
    - How ESPHome entities appear in HA.
    - Entity naming, device classes, and state classes.
- **Best practices**
  - Prefer stable features and documented options over experimental or undocumented ones.
  - When using advanced constructs (e.g. `lambda` filters, complex filter chains, quantiles, sliding windows):
    - Base them on documented ESPHome examples.
    - Add a short comment when the intent would not be obvious from the config alone.

## Style & conventions

- **YAML formatting**
  - Use two-space indentation.
  - Keep related keys grouped and ordered consistently (e.g. `name`, `id`, `unit_of_measurement`, `device_class`, `state_class`, `icon`, `filters`).
  - Avoid unnecessary inline comments; focus on non-obvious behavior.
- **Naming conventions**
  - Use `substitutions:` for common values:
    - `device_name` – machine-friendly name.
    - `friendly_name` – human-friendly device name.
  - Sensor/entity naming:
    - Follow existing patterns where possible (e.g. `LAeq_1s`, `LAeq_10s`, `LA50_10s` in the sound-level sensor config).
    - Use clear, descriptive `name` values for entities as shown in the existing configs.
- **Comments**
  - Use comments to:
    - Explain non-obvious configuration, such as DSP filters, math transforms, or subtle timing choices.
    - Point to upstream docs or reasoning for complex setups.
  - Do **not** add comments that simply restate what the YAML already shows.

## Out of scope & future work

- **Out of scope for this document**
  - Creating or editing Home Assistant automations, scenes, scripts, dashboards, or other HA‑side configuration (unless a specific task explicitly requests it).
  - Managing Nix, flakes, CI pipelines, or deployment tooling for this repo.
- **Potential future extensions**
  - If Home Assistant core configuration, Nix/flake settings, or CI workflows become regular agent tasks, extend this `AGENTS.md` with:
    - A repo map for those areas.
    - Additional rules and safety constraints.
    - Specific workflows and validation steps.

