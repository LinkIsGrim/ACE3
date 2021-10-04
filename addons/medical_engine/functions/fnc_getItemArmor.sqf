#include "script_component.hpp"
/*
 * Author: Pterolatypus
 * Returns the armor value the given item provides to a particular hitpoint, either from a cache or by reading the item config.
 *
 * Arguments:
 * 0: Item Class <STRING>
 * 1: Hitpoint <STRING>
 *
 * Return Value:
 * Item armor for the given hitpoint <NUMBER>
 *
 * Example:
 * ["V_PlateCarrier1_rgr", "HitBody"] call ace_medical_engine_fnc_getItemArmor
 *
 * Public: No
 */

params ["_item", "_hitpoint"];

if ("" in [_item, _hitpoint]) exitWith { // just exit with default values if empty
    [0, 1]
};

private _key = format ["%1$%2", _item, _hitpoint];
private _entry = GVAR(armorCache) getOrDefault [_key, []];
_entry params [["_armor", 0], ["_passThrough", 1]];

if (_entry isEqualTo []) then {
    TRACE_2("Cache miss",_item,_hitpoint);
    private _itemInfo = configFile >> "CfgWeapons" >> _item >> "ItemInfo";

    if (getNumber (_itemInfo >> "type") == TYPE_UNIFORM) then {
        private _unitCfg = configFile >> "CfgVehicles" >> getText (_itemInfo >> "uniformClass");
        private _entry = _unitCfg >> "HitPoints" >> _hitpoint;
        if !(isNull _entry) then {
            _armor = getNumber (_unitCfg >> "armor") * getNumber (_entry >> "armor");
            _passThrough = getNumber (_entry >> "passThrough");
        };
    } else {
        private _condition = format ["getText (_x >> 'hitpointName') == '%1'", _hitpoint];
        private _entry = configProperties [_itemInfo >> "HitpointsProtectionInfo", _condition] param [0, configNull];
        if !(isNull _entry) then {
            _armor = getNumber (_entry >> "armor");
            _passThrough = getNumber (_entry >> "passThrough");
        };
    };
    GVAR(armorCache) set [_key, [_armor, _passThrough]];
};

[_armor, _passThrough] // return
