#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp>

const GAMEMODE_LAUNCH_MINALIVES = 2;

new Float:rz_gamemode_notice_hud_pos[2];

public plugin_precache()
{
	register_plugin("[ReZP] Game Modes", REZP_VERSION_STR, "fl0wer");
}

public plugin_init()
{
	RegisterHookChain(RG_CSGameRules_RestartRound, "@CSGameRules_RestartRound_Pre", false);
	RegisterHookChain(RG_CSGameRules_OnRoundFreezeEnd, "@CSGameRules_OnRoundFreezeEnd_Pre", false);

	bind_pcvar_float(create_cvar("rz_gamemode_notice_hud_x", "-1.0", _, "", true, -1.0, true, 1.0), rz_gamemode_notice_hud_pos[0]);
	bind_pcvar_float(create_cvar("rz_gamemode_notice_hud_y", "0.17", _, "", true, -1.0, true, 1.0), rz_gamemode_notice_hud_pos[1]);

	rz_load_langs("gamemodes");
}

public plugin_cfg()
{
	if (!rz_gamemodes_size())
		rz_sys_error("No loaded game modes");
}

public rz_gamemodes_change_pre(gameMode, alivesNum, bool:force)
{
	server_print("[gamemodes_change_pre] ID : %d | Alive players : %d | FORCED? : %d", gameMode, alivesNum, force);

	return RZ_CONTINUE;
}

public rz_gamemodes_change_post(gameMode, Array:alivesArray)
{
	server_print("[gamemodes_change_post] Gamemode %d have started", gameMode);
	rz_gamemodes_set(RZ_GAMEMODES_CURRENT, gameMode);
	rz_gamemodes_set(RZ_GAMEMODES_LAST, gameMode);

	new roundTime = rz_gamemode_get(gameMode, RZ_GAMEMODE_ROUND_TIME);
	new hudColor[3];
	new notice[RZ_MAX_LANGKEY_LENGTH];

	rz_gamemode_get(gameMode, RZ_GAMEMODE_HUD_COLOR, hudColor);
	rz_gamemode_get(gameMode, RZ_GAMEMODE_NOTICE, notice, charsmax(notice));

	set_dhudmessage(hudColor[0], hudColor[1], hudColor[2],
		rz_gamemode_notice_hud_pos[0], rz_gamemode_notice_hud_pos[1],
		0, 0.0, 5.0, 1.0, 1.0);
	show_dhudmessage(0, "%l", "RZ_GAMEMODE_FMT", LANG_PLAYER, notice);

	if (roundTime)
		set_member_game(m_iRoundTime, roundTime);
}

@CSGameRules_RestartRound_Pre()
{
	rz_main_lighting_global_reset();
	rz_main_lighting_nvg_reset();

	rz_gamemodes_set(RZ_GAMEMODES_CURRENT, 0);
	rz_gamemodes_set(RZ_GAMEMODES_FORCE, 0);

	rz_class_override_default(TEAM_TERRORIST, 0);
	rz_class_override_default(TEAM_CT, 0);
}

@CSGameRules_OnRoundFreezeEnd_Pre()
{
	if (!get_member_game(m_bGameStarted))
		return;

	new alivesNum;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_alive(i))
			continue;

		alivesNum++;
	}

	if (alivesNum < GAMEMODE_LAUNCH_MINALIVES)
		return;

	new gameMode = rz_gamemodes_get(RZ_GAMEMODES_FORCE);

	if (gameMode)
	{
		if (rz_gamemodes_check_status(gameMode, _, _, true) == RZ_CONTINUE)
			gameMode = 0;
	}

	if (!gameMode)
	{
		new start = rz_gamemodes_start();
		new end = start + rz_gamemodes_size();
		//new Array:gameModes = ArrayCreate(1, 0);

		for (new i = start; i < end; i++)
		{
			// MARK: random moved here
			new iRandom = random_num(1, rz_gamemode_get(i, RZ_GAMEMODE_CHANCE));
			server_print("[Gamemodes Roll(OnRoundFreezeEnd_Pre)] gameMode: %d | random: %d", i, iRandom);
			if (rz_gamemodes_check_status(i, _, _, iRandom) != RZ_CONTINUE)
				continue;

			//ArrayPushCell(gameModes, gameMode);
			gameMode = i;
			break;
		}

		/*gameModesNum = ArraySize(gameModes);

		if (gameModesNum)
			mode = ArrayGetCell(gameModes, random_num(0, gameModesNum - 1));

		ArrayDestroy(gameModes);*/
	}

	if (!gameMode)
	{
		gameMode = rz_gamemodes_get(RZ_GAMEMODES_DEFAULT);
		server_print("[Gamemodes Roll(OnRoundFreezeEnd_Pre)] No gamemodes won in the roll, picking default one...");
	}

	rz_gamemodes_change(gameMode);
}
