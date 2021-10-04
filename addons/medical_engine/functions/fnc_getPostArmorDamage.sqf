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
#define REFERENCE_TYPICALSPEED 800
// Damage is handled in 0-1 range, most 'hit' param is under 100
#define DAMAGE_SCALING_FACTOR 10

// _damage is force, _caliber is penetration
// resulting damage is how much force gets through armor
// armor is reduced by reference armor * penetration / reference penetration

params ["_unit", "_damage", "_hitpoint", "_ammo"];

([_unit, _hitpoint] call FUNC(getHitpointArmor)) params ["_armor", "_passThrough"];

private _realDamage = _damage * _armor;
if (_ammo == "" || {_armor == 0}) exitWith {[_realDamage, _damage]}; // leave damage handling for weird stuff to handleDamage

_realDamage = _realDamage * (_passThrough * 2); // multiply by passThrough scaled, vests made for explosive resistance will have higher values
private _ammoEntry = [];

if (_ammo in GVAR(ammoCache)) then {
    _ammoEntry = GVAR(ammoCache) get _ammo;
} else {
    private _cfgAmmo = configFile >> "CfgAmmo" >> _ammo;
    {
        _ammoEntry pushback (getNumber (_cfgAmmo >> _x));
    } forEach ["caliber", "explosive", "typicalSpeed"];
    GVAR(ammoCache) set [_ammo, _ammoEntry];
};
_ammoEntry params ["_caliber", "_explosive", "_typicalSpeed"];

if (_explosive > 0) then { // explosive damage should be treated as primarily force, so reduce caliber
    _caliber = _caliber * (1 - _explosive);
};

private _penetratedArmor = ((_caliber / REFERENCE_CALIBER) * REFERENCE_ARMOR);

private _penetrated = (random 1) < (_penetratedArmor / _armor);

if (_penetrated) then { // hit "bounced", cap at penetration threshold
    systemChat "bounce";
    _realDamage = _realDamage min (PENETRATION_THRESHOLD * _armor);
} else {
    if ((_penetratedArmor - _armor) > 5) then { // overpenetration, reduce damage by up to 50%
        systemChat "over";
        _realDamage = _realDamage * (1 - random 0.5);
    } else { // penetration, increase damage by up to 100% (internal wounds)
        systemChat "sweet spot";
        _realDamage = _realDamage * (1 + random 1);
    };
};

[_realDamage, _realDamage / DAMAGE_SCALING_FACTOR]