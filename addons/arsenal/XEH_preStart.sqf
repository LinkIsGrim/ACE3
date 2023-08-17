#include "script_component.hpp"

#include "XEH_PREP.hpp"

// Cache for FUNC(baseWeapon)
private _baseWeaponCache = createHashMap;
uiNamespace setVariable [QGVAR(baseWeaponNameCache), _baseWeaponCache];

call FUNC(scanConfig);

uiNamespace setVariable [QGVAR(baseWeaponNameCache), compileFinal _baseWeaponCache];
