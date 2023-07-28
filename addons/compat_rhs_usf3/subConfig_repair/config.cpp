#include "script_component.hpp"

#if __has_include("\rhsusf\addons\rhsusf_main\loadorder\config.bin")
#else
    #define PATCH_SKIP "RHS USAF"
#endif

#if __has_include("\z\ace\addons\repair\script_component.hpp")
#else
    #ifdef PATCH_SKIP
    #else
        #define PATCH_SKIP "ACE Repair"
    #endif
#endif

#ifdef PATCH_SKIP
ACE_PATCH_NOT_LOADED(ADDON,PATCH_SKIP)
#else

class CfgPatches {
    class ADDON {
        addonRootClass = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "rhsusf_main_loadorder",
            "ace_refuel"
        };
        skipWhenMissingDependencies = 1;
        VERSION_CONFIG;
    };
};

#include "CfgVehicles.hpp"

#endif
