#include "script_component.hpp"
/*
 * Author: PabstMirror
 * Vanilla Killed EH, attempts to set correct source/killer for other killed event handlers (vanilla and XEH)
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Killer <OBJECT>
 * 2: Instigator <OBJECT>
 * 3: Use Effects <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorObject, player, player, true] call ace_medical_status_fnc_handleKilled
 *
 * Public: No
 */

params ["_unit", "_killer", "_instigator", "_useEffects"];
TRACE_4("handleKilled",_unit,_killer,_instigator,_useEffects);

// ensure event is only called once
if (_unit isEqualTo (_unit getVariable [QGVAR(killed), objNull])) exitWith {
    _this set [0, objNull];
    _this set [1, objNull];
    _this set [2, objNull];
};
_unit setVariable [QGVAR(killed), _unit];

private _causeOfDeath = _unit getVariable [QEGVAR(medical,causeOfDeath), "#scripted"];
private _modifyKilledArray = missionNamespace getVariable [QEGVAR(medical,modifyKilledArray), true]; // getVar so this can be disabled

// if undefined then it's a death not caused by ace's setDead (mission setDamage, disconnect, forced respawn while conscious)
if (_causeOfDeath != "#scripted") then {
    _killer = _unit getVariable [QEGVAR(medical,lastDamageSource), _killer]; // vehicle
    _instigator = _unit getVariable [QEGVAR(medical,lastInstigator), _instigator]; // unit in the turret
} else {
    // call setDead manually to prevent any issues
    [_unit, "#scripted"] call FUNC(setDead);
};

// All Killed EHs uses the same array, so we can modify it now to pass the correct killer/instigator
if (_modifyKilledArray) then {
    _this set [1, _killer];
    _this set [2, _instigator];
};
TRACE_3("killer info",_killer,_instigator,_causeOfDeath);

if (_unit == player) then {
    // Enable user input before respawn, in case mission is using respawnTemplates
    ["unconscious", false] call EFUNC(common,setDisableUserInputStatus);
};

// Let AI resume firing at dead units in most situations (global effect) (which was blocked upon unconsciouness)
[_unit, "setHidden", "ace_unconscious", false] call EFUNC(common,statusEffect_set);

// Unblock radio on dead for compatibility with captive module (which was blocked upon unconsciouness)
[_unit, "blockRadio", "ace_unconscious", false] call EFUNC(common,statusEffect_set);

// Unblock speaking on death (which was blocked upon unconsciouness)
[_unit, "blockSpeaking", "ace_unconscious", false] call EFUNC(common,statusEffect_set);

["ace_killed", [_unit, _causeOfDeath, _killer, _instigator]] call CBA_fnc_globalEvent;
