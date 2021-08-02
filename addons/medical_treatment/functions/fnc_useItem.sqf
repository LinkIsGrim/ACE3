#include "script_component.hpp"
/*
 * Author: Glowbal, mharis001, GhostIsSpooky
 * Uses one of the treatment items. Respects the priority defined by the allowSharedEquipment setting. Pulls from backpack first.
 * Self-Treatment pulls from uniform.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * User and Item <ARRAY>
 *
 * Example:
 * [player, cursorObject, ["bandage"]] call ace_medical_treatment_fnc_useItem
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

scopeName "Main";

if (_medic isEqualTo _patient) exitWith {
  {
    _medic removeItem _x;
    [_medic, _x] breakOut "Main";
  } forEach _items;
};

private _useOrder = [[_patient, _medic], [_medic, _patient], [_medic]] select GVAR(allowSharedEquipment);
{
    private _unit      = _x;
    private _unitItems = [backpackItems _x, vestItems _x, uniformItems _x];

    {
      switch true do {
        scopeName "Loop";

        case (_x in (_unitItems select 0)): {
          _unit removeItemFromBackpack _x;
          breakWith ([_unit, _x] breakOut "Main");
        };
        case (_x in (_unitItems select 1)): {
          _unit removeItemFromVest _x;
          breakWith ([_unit, _x] breakOut "Main");
        };
        case (_x in (_unitItems select 2)): {
          _unit removeItem _x;
          breakWith ([_unit, _x] breakOut "Main");
        };
        default {};
      };
    } forEach _items;
} forEach _useOrder;

[objNull, ""]
