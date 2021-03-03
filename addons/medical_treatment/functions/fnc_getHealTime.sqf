#include "script_component.hpp"
/*
 * Author: Ruthberg
 * Calculates the PAK treatment time based on the amount of damage to heal.
 *
 * Arguments:
 * 0: Medic (not used) <OBJECT>
 * 1: Patient <OBJECT>
 *
 * Return Value:
 * Treatment Time <NUMBER>
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_getHealTime
 *
 * Public: No
 */

#define DAMAGE_SCALING_FACTOR 4

params ["", "_patient"];

private _bodyPartDamage = 0;
private _bloodVolume = _patient getVariable [QEGVAR(medical,bloodVolume), 6];

{
    _bodyPartDamage = _bodyPartDamage + _x;
} forEach (_patient getVariable [QEGVAR(medical,bodyPartDamage), []]);

private _fractures = {_x isEqualTo 1} count (_patient getVariable ["ace_medical_fractures",[0,0,0,0,0,0]]);

private _pain = _patient getVariable ["ace_medical_pain", 0];

private _time = ((_fractures * 5) + (_pain * 10) + (_bodyPartDamage * DAMAGE_SCALING_FACTOR));

private _coef = (3 - (linearConversion [0.5, 1, _bloodVolume / 6, 0, 2]));

10 max (((_time * _coef) min 180) * GVAR(timeCoefficientPAK))
