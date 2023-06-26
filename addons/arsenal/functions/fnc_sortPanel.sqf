#include "script_component.hpp"
#include "..\defines.hpp"
/*
 * Author: Alganthe, Dedmen, Brett Mayson, johnb43
 * Sort an arsenal panel.
 *
 * Arguments:
 * 0: Sort control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Public: No
*/

params ["_sortControl"];

private _display = ctrlParent _sortControl;

private _rightSort = ctrlIDC _sortControl == IDC_sortRightTab;
private _right = _rightSort && {GVAR(currentLeftPanel) in [IDC_buttonUniform, IDC_buttonVest, IDC_buttonBackpack]};
private _cfgFaces = configFile >> "CfgFaces";
private _cfgUnitInsignia = configFile >> "CfgUnitInsignia";
private _cfgUnitInsigniaMission = missionConfigFile >> "CfgUnitInsignia";
private _cfgMagazines = configFile >> "CfgMagazines";

if (_rightSort) then {
    [
        if (_right) then {
            _display displayCtrl IDC_rightTabContentListnBox
        } else {
            _display displayCtrl IDC_rightTabContent
        },
        switch (GVAR(currentRightPanel)) do {
            case IDC_buttonCurrentMag;
            case IDC_buttonCurrentMag2;
            case IDC_buttonThrow;
            case IDC_buttonPut;
            case IDC_buttonMag;
            case IDC_buttonMagALL: {_cfgMagazines};
            default {configFile >> "CfgWeapons"};
        },
        GVAR(sortListRightPanel) select (
            switch (GVAR(currentRightPanel)) do {
                case IDC_buttonOptic: { 0 };
                case IDC_buttonItemAcc: { 1 };
                case IDC_buttonMuzzle: { 2 };
                case IDC_buttonBipod: { 3 };
                case IDC_buttonCurrentMag;
                case IDC_buttonCurrentMag2;
                case IDC_buttonMag;
                case IDC_buttonMagALL: { 4 };
                case IDC_buttonThrow: { 5 };
                case IDC_buttonPut: { 6 };
                case IDC_buttonMisc: { 7 };
            }
        )
    ]
} else {
    [
        _display displayCtrl IDC_leftTabContent,
        switch (GVAR(currentLeftPanel)) do {
            case IDC_buttonBackpack: {configFile >> "CfgVehicles"};
            case IDC_buttonGoggles: {configFile >> "CfgGlasses"};
            case IDC_buttonFace: {_cfgFaces};
            case IDC_buttonVoice: {configFile >> "CfgVoice"};
            case IDC_buttonInsignia: {_cfgUnitInsignia};
            default {configFile >> "CfgWeapons"};
        },
        (GVAR(sortListLeftPanel) select ([
            IDC_buttonPrimaryWeapon,
            IDC_buttonHandgun,
            IDC_buttonSecondaryWeapon,
            IDC_buttonUniform,
            IDC_buttonVest,
            IDC_buttonBackpack,
            IDC_buttonHeadgear,
            IDC_buttonGoggles,
            IDC_buttonNVG,
            IDC_buttonBinoculars,
            IDC_buttonMap,
            IDC_buttonGPS,
            IDC_buttonRadio,
            IDC_buttonCompass,
            IDC_buttonWatch,
            IDC_buttonFace,
            IDC_buttonVoice,
            IDC_buttonInsignia
        ] find GVAR(currentLeftPanel)))
    ]
} params ["_panel", "_cfgClass", "_sorts"];

// Get currently selected item
private _curSel = if (_right) then {
    lnbCurSelRow _panel
} else {
    lbCurSel _panel
};

private _selected = if (_right) then {
    _panel lnbData [_curSel, 0]
} else {
    _panel lbData _curSel
};

// Get sort's information
private _sortName = _sortControl lbData (0 max lbCurSel _sortControl);
private _sortConfig = _sorts select (0 max (_sorts findIf {(_x select 0) isEqualTo _sortName}));
private _statement = _sortConfig select 2;
_sortConfig params ["", "", "_statement"];

// Update last sort
missionNamespace setVariable [
    [QGVAR(lastSortLeft), QGVAR(lastSortRight)] select _rightSort,
    _sortConfig select 1
];

private _originalNames = createHashMap;
private _item = "";
private _quantity = "";
private _itemCfg = configNull;
private _value = "";
private _name = "";

private _faceCache = if (_cfgClass == _cfgFaces) then {
    uiNamespace getVariable [QGVAR(faceCache), createHashMap]
} else {
    createHashMap
};

private _countColumns = if (_right) then {
    count lnbGetColumnsPosition _panel
} else {
    0
};

private _for = if (_right) then {
    for '_i' from 0 to (lnbSize _panel select 0) - 1
} else {
    for '_i' from 0 to (lbSize _panel) - 1
};

private _magazineMiscItems = uiNamespace getVariable [QGVAR(magazineMiscItems), createHashMap];

_for do {
    // Get item
    _item = if (_right) then {
        _panel lnbData [_i, 0]
    } else {
        _panel lbData _i
    };

    // Handle misc magazines
    if (_item in _magazineMiscItems) then {
        _cfgClass = _cfgMagazines;
    };

    // Get item's count
    _quantity = if (_right) then {
        parseNumber (_panel lnbText [_i, 2])
    } else {
        0
    };

    // Check item's config
    _itemCfg = if !(_cfgClass in [_cfgFaces, _cfgUnitInsignia]) then {
        _cfgClass >> _item
    } else {
        // If insignia, check both config and mission file
        if (_cfgClass == _cfgUnitInsignia) then {
            _itemCfg = _cfgClass >> _item;

            if (isNull _itemCfg) then {
                _itemCfg = _cfgUnitInsigniaMission >> _item;
            };

            _itemCfg
        } else {
            // If face, check correct category
            _cfgClass >> (_faceCache get _item) param [2, "Man_A3"] >> _item
        };
    };

    // Some items may not belong to the config class for the panel (misc. items panel can have unique items)
    if (isNull _itemCfg) then {
        _itemCfg = _item call CBA_fnc_getItemConfig;
    };

    // Value can be any type
    _value = [_itemCfg, _item, _quantity] call _statement;

    // If number, convert to string
    if (_value isEqualType 0) then {
        _value = [_value, 8] call CBA_fnc_formatNumber;
    };

    // If empty string, add alphabetically small char at beginning to make it sort correctly
    if (_value isEqualTo "") then {
        _value = "_";
    };

    // Save the current row's item's name in a cache and set text to it's sorting value
    if (_right) then {
        _originalNames set [_item, _panel lnbText [_i, 1]];

        // Use tooltip to sort, as it also contains the classname, which means a fixed alphabetical order is guaranteed
        _panel lnbSetText [[_i, 1], format ["%1%2", _value, _panel lbTooltip (_i * _countColumns)]];
    } else {
        if (_item != "") then {
            _originalNames set [_item, _panel lbText _i];

            // Use tooltip to sort, as it also contains the classname, which means a fixed alphabetical order is guaranteed
            _panel lbSetText [_i, format ["%1%2", _value, _panel lbTooltip _i]];
        };
    };
};

// Sort alphabetically, find the previously selected item, select it again and reset text to original text
if (_right) then {
    _panel lnbSort [1, false];

    _for do {
        _item = _panel lnbData [_i, 0];

        _panel lnbSetText [[_i, 1], _originalNames get _item];

        // Set selection after text, otherwise item info box on the right side shows invalid name
        if (_curSel != -1 && {_item == _selected}) then {
            _panel lnbSetCurSelRow _i;

            // To avoid unnecessary checks after previsouly selected item was found
            _curSel = -1;
        };
    };
} else {
    lbSort [_panel, "ASC"];

    _for do {
        _item = _panel lbData _i;

        // Check if valid item (problems can be caused when searching)
        if (_item != "") then {
            _panel lbSetText [_i, _originalNames get _item];
        };

        // Set selection after text, otherwise item info box on the right side shows invalid name
        if (_curSel != -1 && {_item == _selected}) then {
            _panel lbSetCurSel _i;

            // To avoid unnecessary checks after previsouly selected item was found
            _curSel = -1;
        };
    };
};
