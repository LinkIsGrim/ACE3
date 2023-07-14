#include "script_component.hpp"
/*
 * Author: LinkIsGrim, mharris001
 * Wrapper for engine doArtilleryFire, fires barrage one round at a time.
 * Handles CSW magazines.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Target <OBJECT, STRING or POSITION AGL>
 * 2: Magazine Type <STRING>
 * 3: Rounds to fire <NUMBER>
 *
 * Return Value:
 * Barrage Started <BOOL>
 *
 * Example:
 * [cursorObject] call ace_artillerytables_fnc_doArtilleryFire
 *
 * Public: Yes
 */
params [["_vehicle", objNull, [objNull]], ["_position", [0, 0, 0], [[], objNull, ""], 3], ["_magazine", "", [""]], ["_rounds", 0, [0]]];

if (isNull _vehicle || {_rounds isEqualTo 0} || {_magazine isEqualTo ""} || {!(_vehicle turretLocal [0])}) exitWith {false};

if (_position isEqualType objNull) then {
    _position = ASLtoAGL getPosASL _position;
};

if (_position isEqualType "") then {
    _position = [_position, true] call CBA_fnc_mapGridToPos;
};

private _usingCSW = false;
if ((typeOf _vehicle) in EGVAR(csw,initializedStaticTypes)) then {
    if (["ace_csw"] call EFUNC(common,isModLoaded)) then {
        _usingCSW = EGVAR(csw,ammoHandling) > 0;
    };
    if (["ace_mk6mortar"] call EFUNC(common,isModLoaded) && {_vehicle isKindOf "StaticMortar"}) then {
        _usingCSW = EGVAR(mk6mortar,useAmmoHandling);
    };
    _usingCSW = _usingCSW && {_vehicle getVariable [QEGVAR(csw,assemblyMode), 3] isNotEqualTo 0}
};

if (_usingCSW && {EGVAR(csw,ammoHandling) < 2}) exitWith {false};

private _vehicleMagazine = _magazine;
if (_usingCSW) then {
    private _carryMag = _magazine;
    private _isCarryMag = isClass (configFile >> QEGVAR(csw,groups) >> _magazine);
    if (_isCarryMag) then {
        _vehicleMagazine = [_vehicle, [0], _magazine] call EFUNC(csw,reload_getVehicleMagazine);
    } else {
        _carryMag = [_magazine] call EFUNC(csw,getCarryMagazine);
    };
    [_vehicle, _carryMag, [0], true, false] call EFUNC(csw,ai_switchMagazine);
};

// Needs to be config case
_vehicleMagazine = configName (configFile >> "CfgMagazines" >> _vehicleMagazine);
if (_vehicleMagazine isEqualTo "") exitWith {false};

if (!_usingCSW && {!(_vehicleMagazine in (getArtilleryAmmo [_vehicle]))}) exitWith {false};

if !(_position inRangeOfArtillery [[_vehicle], _vehicleMagazine]) exitWith {false};

_vehicle doWatch _position;

[{
    params ["_vehicle", "_position", "_magazine", "_roundsLeft", "_lastFired"];
    if (CBA_missionTime - _lastFired > 30) exitWith {true};

    // have to wait a bit or the AI goes insane
    if (CBA_missionTime - _lastFired < 3) exitWith {false};

    (weaponState [_vehicle, [0]]) params ["", "", "", "_loadedMag", "_ammoCount", "_roundReloadPhase", "_magazineReloadPhase"];
    if (
        _loadedMag isEqualTo _magazine &&
        {_ammoCount > 0} &&
        {_roundReloadPhase isEqualTo 0} &&
        {_magazineReloadPhase isEqualTo 0} &&
        {unitReady _vehicle}
    ) then {
        _vehicle doArtilleryFire [_position, _magazine, 1];
        _roundsLeft = _roundsLeft - 1;
        _this set [3, _roundsLeft];
        _this set [4, CBA_missionTime];
    };

    if (_roundsLeft <= 0 || {!alive _vehicle} || {!alive (gunner _vehicle)} || {objectParent (gunner _vehicle) isNotEqualTo _vehicle}) exitWith {
        [{_this doWatch objNull}, _vehicle, 5] call CBA_fnc_waitAndExecute;
        _vehicle setVariable [QEGVAR(csw,forcedMag), nil, true];
        true
    };
    false
}, {}, [_vehicle, _position, _vehicleMagazine, _rounds, CBA_missionTime]] call CBA_fnc_waitUntilAndExecute;

true
