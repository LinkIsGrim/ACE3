#include "..\script_component.hpp"
/*
 * Author: Dedmen, Blue
 * Return how many items of type _itemType the player has in his containers (Uniform, Vest, Backpack)
 * Doesn't count assignedItems, weapons, weapon attachments, magazines in weapons
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Classname of item (Case-Sensitive) <STRING>
 *
 * Return Value:
 * Item Count <NUMBER>
 *
 * Example:
 * [bob, "FirstAidKit"] call ace_common_fnc_getCountOfItem
 *
 * Public: Yes
 */

params ["_unit", "_itemType"];

[_unit, 0, 3, 3, 3, false] call FUNC(uniqueUnitItems) getOrDefault [_itemType, 0] // return
