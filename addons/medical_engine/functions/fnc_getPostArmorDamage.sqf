#include "script_component.hpp"
/*
 * Author: GhostIsSpooky
 * Calculates damage taking into account armor and passThrough
 *
 * Arguments:
 * 0: Impacted unit
 * 1: Impact damage
 * 2: Impact hitpoint
 * 3: Impact ammo
 *
 * Return Value:
 * Damage to be inflicted <NUMBER>
 *
 * Example:
 * [player, 0.1, "HitChest", "B_762x51_Ball"] call ace_medical_engine_fnc_getPostArmorDamage
 *
 * Public: No
 */

// Reference armor is vanilla Carrier Lite chest hitpoint
// In vanilla, resistant to one hit of 7.62x51mm M80 at point blank
#define REFERENCE_ARMOR 16
// Reference passThrough is also vanilla Carrier Lite chest hitpoint
#define REFERENCE_PASSTHROUGH 0.2
// Reference caliber is vanilla B_762x51_Ball, 7.62x51mm M80
#define REFERENCE_CALIBER 1.6
// Same deal
#define REFERENCE_HIT 11.6
#define REFERENCE_PENETRATION = REFERENCE_CALIBER * REFERENCE_HIT
// Damage is handled in 0-1 range, most 'hit' param is under 100
#define DAMAGE_SCALING_FACTOR 10

// _damage is force, _caliber * _hit is penetration
// resulting damage is how much force gets through armor
// armor is reduced by reference armor * penetration / reference penetration

// passthrough can be considered "penetrability" of armor like in material penetration math
// in this case, substitute impact speed for config hit value
// x = (hit / rH) * (caliber / rC) * (armor * passthrough) / 10
// using reference values, damage would be reduced to 32%, roughly appropriate for 7.62x51mm M80 against NIJ-III body armor

params ["_unit", "_damage", "_hitpoint", "_ammo"];

([_unit, _hitpoint] call FUNC(getHitpointArmor)) params ["_armor", "_passThrough"];

if (_ammo == "") exitWith {[_damage * _armor, _damage]}; // leave damage handling for weird stuff to handleDamage

if (_armor == 0) exitWith {[_damage * 2, _damage * 2]}; // just deal double damage if there's no armor and leave it at that

private _ammoEntry = GVAR(ammoCache) getOrDefault [_ammo, []];
if (_ammoEntry isEqualTo []) then {
        private _cfgAmmo = configFile >> "CfgAmmo" >> _ammo;
    {
        _ammoEntry pushback (getNumber (_cfgAmmo >> _x));
    } forEach ["caliber", "explosive", "hit"];
    GVAR(ammoCache) set [_ammo, _ammoEntry];
};
_ammoEntry params ["_caliber", "_explosive", "_hit"];

if (_explosive > 0) then { // explosive damage should be treated as primarily force, so increase soft armor
    _armor = _armor * (1 + _explosive);
};

private _penetration = (_caliber / REFERENCE_CALIBER) * (_hit / REFERENCE_HIT) * (_armor * _passThrough) / DAMAGE_SCALING_FACTOR;

_damage = _damage * _penetration; // cap damage at double

[_damage * _armor, _damage]
