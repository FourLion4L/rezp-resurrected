#if defined _util_paths_included
	#endinput
#endif

#define _util_paths_included

#include <amxmodx>
#include <string>

// #define DEBUG_GETPATH 2 // 1 - show error messages ; 2 - show errors and full paths

enum PathsWeaponModel
{
    WEAPONMODEL_V = 0,
    WEAPONMODEL_P,
    WEAPONMODEL_W
};

enum PathsSoundType
{
    SOUND_PLAYER = 0,
    SOUND_PLAYER_ZOMBIE,
    SOUND_KILLSTREAK,
    SOUND_ACCOUNT,
    SOUND_NOTICE
};

// new const PATHS_WEAPON_MODEL[] = "models/last_stand_cso/weapons/%s.mdl";
new const PATHS_SOUND[] = "last_stand_cso";

/**
*   Retrieves and returns full path to a sound file, wave file extension is applied automatically.
*
*   @param soundType A type of the sound to be retrieven.
*   @param sound Sound file name to be retrieven.
*
*   @return Returns 0 if a soundType is wrong or unknown, full sound file path otherwise.
*
**/
stock get_sound_path(PathsSoundType:soundType, const sound[])
{
    #if defined DEBUG_GETPATH
    new pluginName[512];
    get_plugin(-1, _, _, pluginName, charsmax(pluginName));
    #endif

    new fullSoundPath[RZ_MAX_RESOURCE_PATH];
    switch (soundType)
    {
        case SOUND_PLAYER: formatex(fullSoundPath, charsmax(fullSoundPath), "%s/player/%s.wav", PATHS_SOUND, sound);
        case SOUND_PLAYER_ZOMBIE: formatex(fullSoundPath, charsmax(fullSoundPath), "%s/player/zombie/%s.wav", PATHS_SOUND, sound);
        case SOUND_KILLSTREAK: formatex(fullSoundPath, charsmax(fullSoundPath), "%s/killstreak/%s.wav", PATHS_SOUND, sound);
        case SOUND_ACCOUNT: formatex(fullSoundPath, charsmax(fullSoundPath), "%s/account/%s.wav", PATHS_SOUND, sound);
        case SOUND_NOTICE: formatex(fullSoundPath, charsmax(fullSoundPath), "%s/notice/%s.wav", PATHS_SOUND, sound);
        #if defined DEBUG_GETPATH
        default:
        {
            server_print("[PATHS UTIL] non-existent sound type at plugin [ %s ] for a sound called > %s <", pluginName, sound);
        }
        #endif
    }

    #if defined DEBUG_GETPATH
    #if DEBUG_GETPATH > 1
    server_print("[PATHS UTIL] %s (%s)", fullSoundPath, pluginName);
    #endif
    #endif

    return fullSoundPath;
}