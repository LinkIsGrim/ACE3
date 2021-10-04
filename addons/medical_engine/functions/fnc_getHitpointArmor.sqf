#include "script_component.hpp"
/*
 * Author: Pterolatypus
 * Checks a unit's equipment to calculate the total armor on a hitpoint.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Hitpoint <STRING>
 *
 * Return Value:
 * Total armor for the given hitpoint <NUMBER>
 *
 * Example:
 * [player, "HitChest"] call ace_medical_engine_fnc_getHitpointArmor
 *
 * Public: No
 */

params ["_unit", "_hitpoint"];

private _uniform = uniform _unit;
// If unit is naked, use its underwear class instead
if (_uniform isEqualTo "") then {
    _uniform = getText (configOf _unit >> "nakedUniform");
};

private _gear = [
    _uniform,
    vest _unit,
    headgear _unit
];

private _rags = _gear joinString "$";
private _var = format [QGVAR(armorCache$%1), _hitpoint];
_unit getVariable [_var, [""]] params ["_prevRags", "_armor", "_passThrough"];

if (_rags != _prevRags) then {
    _armor = 0;
    _passThrough = 1;

    {
        [_x, _hitpoint] call FUNC(getItemArmor) params ["_gearArmor", "_gearPassThrough"];
        _armor = _armor + _gearArmor;
        _passThrough = _passThrough * _gearPassThrough;
    } forEach _gear;

    _unit setVariable [_var, [_rags, _armor, _passThrough]];
};

[_armor, _passThrough] // return
