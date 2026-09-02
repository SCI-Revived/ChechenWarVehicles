# Chechen War Vehicles — Prop Damage Multiplier system

Per‑weapon control over how much damage a CWV vehicle does to **build props**
(`prop_physics`), without changing how it fights tanks. Works like LVS'
`bullet.SPD_PropDamageMultiplier`.

Core file: [`lua/autorun/server/cwv_prop_damage.lua`](lua/autorun/server/cwv_prop_damage.lua)

## Why

CWV weapons are tuned to kill armour (LVS, other simfphys packs). That damage
applied to a player's build prop deletes it instantly. This system lets you
knock down *only* the prop damage of each weapon, individually, by hand.

It relies on **Simple Prop Damage** to give props health (same as the LVS
system does). Without SPD it falls back to a lighter built‑in hook.

## How to tune a weapon

Open the weapon file in [`lua/simfphys_weapons/`](lua/simfphys_weapons/). Every
firing function builds a `projectile` table. Add **one line** to it:

```lua
local projectile = {}
    projectile.filter         = vehicle.VehicleData["filter"]
    projectile.shootOrigin    = shootOrigin
    projectile.shootDirection  = shootDirection
    projectile.attacker       = ply
    projectile.attackingent   = vehicle
    projectile.Damage         = 3500
    projectile.BlastDamage    = 500

    projectile.CWV_PropDamageMultiplier = 0.05   -- <-- add this, then tune it

simfphys.FirePhysProjectile( projectile )   -- or simfphys.FireHitScan( projectile )
```

This is the same for hitscan guns (`simfphys.FireHitScan`) and shells / rockets
(`simfphys.FirePhysProjectile`). It covers the direct hit **and** the blast.

### Missile entities (arctic_avx_atgm)

The BM‑1's ATGM is a real entity, not a `projectile` table. Set the field on the
entity after spawning it (already wired in [`bm.lua`](lua/simfphys_weapons/bm.lua)):

```lua
vehicle.missile = ents.Create( "arctic_avx_atgm" )
-- ...
vehicle.missile:Spawn()
vehicle.missile.CWV_PropDamageMultiplier = 0.1
-- or:  CWV_PropDamage.SetPropDamageMultiplier( vehicle.missile, 0.1 )
```

## What the number means

| Value  | Effect on props |
|--------|-----------------|
| `1`    | Unchanged (this is the default — a weapon that sets nothing is never touched) |
| `0`    | Weapon cannot damage props at all |
| `0.05` | 5 % of normal damage lands on props |
| `0.5`  | Half damage |
| `> 1`  | Hits props *harder* than vehicles (rarely wanted) |

Example: a 3500‑damage cannon at `0.05` does 175 to a prop but still 3500 to a tank.

## Server ConVars

| ConVar | Default | Meaning |
|--------|---------|---------|
| `cwv_propdamage_enabled` | `1` | Master switch for the whole system |
| `cwv_propdamage_multiplier` | `1` | Fallback multiplier for CWV weapons that don't set their own. `1` = leave them alone |

## Server‑wide override hook

```lua
hook.Add( "CWV_PropDamageMultiplier", "MyServer",
    function( propEnt, propTable, dmginfo, multiplier )
        -- return a number to replace `multiplier` for this hit, or nothing to keep it
        -- e.g. ignore CWV damage to frozen props:
        local phys = propEnt:GetPhysicsObject()
        if IsValid( phys ) and not phys:IsMotionEnabled() then return 0 end
    end )
```

## Conflict safety

* Everything is namespaced `CWV_` / `cwv_`. No shared names with Simple Prop
  Damage, LVS, M9K, or GBombs‑5.
* The multiplier is applied in exactly **one** `dmginfo:ScaleDamage()` call,
  gated by a per‑frame window that is only open while a CWV weapon is dealing
  damage. Non‑CWV damage to props is never seen by this system, so it can't
  double up with another addon's prop‑damage scaling.
* It never sets `SPD_PropDamageMultiplier` on an entity — SPD's `lvs.lua`
  scales by that field with no LVS guard, which would apply the multiplier
  twice (`m²`). That is deliberately avoided.
* The detours on `simfphys.FireHitScan` / `simfphys.FirePhysProjectile` /
  `Entity:FireBullets` / `util.BlastDamage` are transparent pass‑throughs
  unless a CWV tag is present, and are re‑installed on a 5s timer because the
  vehicle pack rewrites the simfphys functions from inline copies and the
  simfphys base self‑repairs them ~18 s after load.

## Coverage status

Fully wired as worked examples: `t62.lua`, `bm.lua` (incl. the ATGM entity).
Every other file in `lua/simfphys_weapons/` still needs the one‑liner added to
its `projectile` tables — the system is inert (multiplier `1`) for them until
you do, or until you set `cwv_propdamage_multiplier` server‑wide.
