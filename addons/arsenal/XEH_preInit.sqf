#include "script_component.hpp"
#include "defines.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Arsenal
[QGVAR(camInverted), "CHECKBOX", LLSTRING(invertCameraSetting), LLSTRING(settingCategory), false] call CBA_fnc_addSetting;
[QGVAR(enableModIcons), "CHECKBOX", [LSTRING(modIconsSetting), LSTRING(modIconsTooltip)], LLSTRING(settingCategory), true] call CBA_fnc_addSetting;
[QGVAR(fontHeight), "SLIDER", [LSTRING(fontHeightSetting), LSTRING(fontHeightTooltip)], LLSTRING(settingCategory), [1, 10, 4.5, 1]] call CBA_fnc_addSetting;
[QGVAR(enableIdentityTabs), "CHECKBOX", LLSTRING(enableIdentityTabsSettings), LLSTRING(settingCategory), true, true] call CBA_fnc_addSetting;

// Arsenal loadouts
[QGVAR(allowDefaultLoadouts), "CHECKBOX", [LSTRING(allowDefaultLoadoutsSetting), LSTRING(defaultLoadoutsTooltip)], [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], true, true] call CBA_fnc_addSetting;
[QGVAR(allowSharedLoadouts), "CHECKBOX", LLSTRING(allowSharingSetting), [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], true, true] call CBA_fnc_addSetting;
[QGVAR(EnableRPTLog), "CHECKBOX", [LSTRING(printToRPTSetting), LSTRING(printToRPTTooltip)], [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], false, false] call CBA_fnc_addSetting;

[QGVAR(loadoutsSaveFace), "CHECKBOX", LLSTRING(loadoutsSaveFaceSetting), [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], false] call CBA_fnc_addSetting;
[QGVAR(loadoutsSaveVoice), "CHECKBOX", LLSTRING(loadoutsSaveVoiceSetting), [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], false] call CBA_fnc_addSetting;
[QGVAR(loadoutsSaveInsignia), "CHECKBOX", LLSTRING(loadoutsSaveInsigniaSetting), [LLSTRING(settingCategory), LLSTRING(loadoutSubcategory)], true] call CBA_fnc_addSetting;

// Arsenal events
[QGVAR(statsToggle), {
    params ["_display", "_showStats"];

    private _statsCtrlGroupCtrl = _display displayCtrl IDC_statsBox;
    private _statsPreviousPageCtrl = _display displayCtrl IDC_statsPreviousPage;
    private _statsNextPageCtrl = _display displayCtrl IDC_statsNextPage;
    private _statsCurrentPageCtrl = _display displayCtrl IDC_statsCurrentPage;

    private _statsButtonCtrl = _display displayCtrl IDC_statsButton;
    private _statsButtonCloseCtrl = _display displayCtrl IDC_statsButtonClose;

    {
        _x ctrlShow (GVAR(showStats) && {_showStats});
    } forEach [
        _statsCtrlGroupCtrl,
        _statsPreviousPageCtrl,
        _statsNextPageCtrl,
        _statsCurrentPageCtrl,
        _statsButtonCloseCtrl
    ];

    _statsButtonCtrl ctrlShow (!GVAR(showStats) && {_showStats})
}] call CBA_fnc_addEventHandler;

[QGVAR(statsButton), {
    _this call FUNC(buttonStats);
}] call CBA_fnc_addEventHandler;

[QGVAR(statsChangePage), {
    _this call FUNC(buttonStatsPage);
}] call CBA_fnc_addEventHandler;

[QGVAR(displayStats), {
    _this call FUNC(handleStats);
}] call CBA_fnc_addEventHandler;

call FUNC(compileStats);
call FUNC(compileSorts);

// Caches for names, pictures, mod icons
GVAR(addListBoxItemCache) = createHashMap;
GVAR(rightPanelCache) = createHashMap;

[QUOTE(ADDON), {!isNil QGVAR(camera)}] call CBA_fnc_registerFeatureCamera;

// Compatibility with CBA scripted optics and disposable framework
[QGVAR(displayOpened), {
    "CBA_optics_arsenalOpened" call CBA_fnc_localEvent;
    "CBA_disposable_arsenalOpened" call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(displayClosed), {
    "CBA_optics_arsenalClosed" call CBA_fnc_localEvent;
    "CBA_disposable_arsenalClosed" call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

ADDON = true;
