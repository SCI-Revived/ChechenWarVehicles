# Per-vehicle prop-damage scaling (Simple Prop Damage)

`lua/autorun/server/spd_propdamage.lua` lets each vehicle in this pack do a
different amount of damage to **props** than it does to everything else.

## Why

The vehicles are balanced against each other. A cannon round that is fair
against another tank deletes anything a player built. Simple Prop Damage (SPD)
gives props health, but the shell still hits them with full anti-vehicle damage.

## How it works

The layer only ever runs inside SPD's `SPD_PreEntityTakeDamage` hook, which
fires for `prop_physics` on the prop-damage path only. Vehicle-vs-vehicle and
vehicle-vs-player damage never goes through it and is never modified.

Per hit:

```
final damage to prop = weapon damage  ×  perVehicleMultiplier  ×  cwv_spd_propdamage_mult
```

`1` = unchanged, `0` = that vehicle can't scratch props, `>1` = harder on props
than on vehicles.

## Tuning

Edit `CWV_PropDamage.Multipliers` in `spd_propdamage.lua`. Key = the vehicle's
simfphys spawn-list name, value = its multiplier. Unlisted vehicles use
`CWV_PropDamage.Default` (0.15).

| Key     | Vehicle            | Key     | Vehicle              |
|---------|--------------------|---------|----------------------|
| `t62`   | T-62               | `bm1`   | BMP-1                |
| `t80`   | T-80U              | `bm2`   | BMD-2                |
| `t72b`  | T-72B              | `bm3`   | BMP-3                |
| `c21`   | 2S1 Gvozdika       | `bm21`  | BM-21 Grad           |
| `232`   | 2S3 Akatsiya       | `mt1`   | MT-LB (mtlb_v)       |
| `gaz66` | GAZ-66 / ZU-23     | `mt2`   | MT-LB (mtlb)         |

### ConVars (live, no map change)

| ConVar                       | Default | Meaning                                  |
|------------------------------|---------|------------------------------------------|
| `cwv_spd_propdamage_enabled` | `1`     | Master toggle.                           |
| `cwv_spd_propdamage_mult`    | `1`     | Global multiplier stacked on every one.  |

```
lua_run CWV_PropDamage.Multipliers.t62 = 0.05
```

### Per-weapon override (finer than per-vehicle)

In a weapon file under `lua/simfphys_weapons/`, set a field on the projectile
table before the `simfphys.Fire*` call:

```lua
projectile.CWV_PropDamageMultiplier = 0   -- this MG can't hurt props at all
simfphys.FireHitScan( projectile )
```

When set it replaces the per-vehicle number for that one weapon.

> The field is `CWV_PropDamageMultiplier`, **not** `SPD_PropDamageMultiplier`.
> Simple Prop Damage's LVS compat layer also scales by any inflictor's
> `SPD_PropDamageMultiplier`, so using that name makes the multiplier apply
> twice (you'd see `damage × mult²`).

### Server-wide last word

```lua
hook.Add( "SPD_CWVPropDamageMultiplier", "MyServer", function( propEnt, dmginfo, multiplier )
    return 0 -- or any number to override; return nothing to leave it
end )
```

## Notes

- If Simple Prop Damage is not installed, this file does nothing (there is no
  prop health system to scale against).
- Coverage: hitscan MGs/autocannons (`simfphys.FireHitScan`), cannon/HE/ATGM
  shells (`simfphys.FirePhysProjectile` -> `simfphys_tankprojectile`), and the
  BMP-1 wire-guided missile (`arctic_avx_atgm`).
