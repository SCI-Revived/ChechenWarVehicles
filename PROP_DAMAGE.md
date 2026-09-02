# Per-weapon prop-damage multiplier

`lua/autorun/server/cwv_prop_damage.lua` lets each weapon in this pack scale the
damage it does **to props** (Simple Prop Damage) without changing its damage to
vehicles, players or NPCs.

## Tuning

Every weapon fire function in `lua/simfphys_weapons/` now has a line:

```lua
projectile.SPD_PropDamageMultiplier = 1   -- 1 = full, 0.1 = 10%, 0 = none
```

Change the number. That's it.

| value | effect on props |
|-------|-----------------|
| `1`   | unchanged (vanilla) |
| `0.1` | props take 10% of this weapon's damage |
| `0`   | this weapon can't hurt props at all |
| `2`   | props take double (harder on props than on vehicles) |

The number applies to the direct hit **and** the shell's blast. Blast still
falls off with distance, so a prop at the edge of the radius takes about
`BlastDamage × multiplier × falloff`.

The BMP-1 wire-guided missile uses an entity instead of a projectile table, so
its line in `bm.lua` reads:

```lua
CWV_SetPropDamageMultiplier( vehicle.missile, 1 )
```

## ConVars

| ConVar                | default | meaning |
|-----------------------|---------|---------|
| `cwv_propdmg_enabled` | `1`     | master toggle |
| `cwv_propdmg_debug`   | `0`     | print every prop hit + the multiplier resolved |

## How it avoids conflicts

- `projectile.SPD_PropDamageMultiplier` is a key on a plain Lua table this pack
  owns — no other addon reads it.
- The scale is applied **once**, inside a frame-scoped window opened around the
  exact `FireBullets` call that deals the damage. Entities are never tagged with
  the `SPD_PropDamageMultiplier` field, so Simple Prop Damage's bundled LVS layer
  (which blindly scales by that entity field) never touches our shots — no
  double-application.
- Only `prop_physics` damage is affected, via SPD's public
  `SPD_PreEntityTakeDamage` hook.
- If Simple Prop Damage isn't installed, the file does nothing.
