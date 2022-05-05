#include "script_component.hpp"
/*
 * Author: GhostIsSpooky
 * Dragging integration. Unloader starts carrying unloaded object.
 *
 * Arguments:
 * 0: Unloader <OBJECT>
 * 1: Item <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, object] call ace_cargo_fnc_unloadCarryItem
 *
 * Public: No
 */
params ["_unloader", "_object"];

if !(["ace_dragging"] call EFUNC(common,isModLoaded)) exitWith {};

if ([_unloader, _object] call EFUNC(dragging,canCarry)) then {
    [_unloader, _object] call EFUNC(dragging,startCarry);
} else {
    if ([_unloader, _object] call EFUNC(dragging,canDrag)) then {
        [_unloader, _object] call EFUNC(dragging,startDrag);
    };
};
