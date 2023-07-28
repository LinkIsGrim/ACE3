class RscInGameUI {
    class RscOptics_LaserDesignator {
        class CA_IGUI_elements_group: RscControlsGroup {
            class controls {
                // Hide the vanilla distance display
                class CA_Distance: RscText {
                    idc = 151; // Purposeful overwrite, makes range update constantly, do not remove
                    fade = 1;
                };
                class ACE_Distance: CA_Distance {
                    idc = IDC_LASERDESIGNATOR_ACEDISTANCE;
                    fade = 0;
                };
                class ACE_LaserCode_Helper: RscMapControl {
                    idc = -1;
                    onDraw = QUOTE(_this call FUNC(onLaserDesignatorDraw));
                    w = 0;
                    h = 0;
                };
                class ACE_LaserCode: RscText {
                    idc = 123001;
                    style = 0;
                    sizeEx = "0.038*SafezoneH";
                    colorText[] = {0.706,0.0745,0.0196,1};
                    shadow = 0;
                    font = "EtelkaMonospacePro";
                    text = "Code: 1001";
                    x = "32.7 *         (0.01875 * SafezoneH)";
                    y = "35.5 *         (0.025 * SafezoneH)";
                    w = "12 *         (0.01875 * SafezoneH)";
                    h = "1.6 *         (0.025 * SafezoneH)";
                };
            };
        };
    };
};
