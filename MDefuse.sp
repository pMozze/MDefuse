#include <sdktools>

public Plugin myinfo = {
	name = "MDefuse",
	author = "Mozze",
	description = "",
	version = "1.0",
	url = "t.me/pMozze"
}

int g_iWire;
bool g_bIsHaveDefuseKit;

public void OnPluginStart() {
	LoadTranslations("mdefuse.phrases");
	HookEvent("bomb_planted", onBombPlanted);
	HookEvent("bomb_beginplant", onBombBeginPlant);
	HookEvent("bomb_begindefuse", onBombBeginDefuse);
	HookEvent("bomb_abortplant", onBombAbort);
	HookEvent("bomb_abortdefuse", onBombAbort);
}

public void onBombBeginPlant(Event hEvent, const char[] szName, bool bDontBroadCast) {
	showBombPanel(GetClientOfUserId(hEvent.GetInt("userid")), 5);	
}

public void onBombBeginDefuse(Event hEvent, const char[] szName, bool bDontBroadCast) {
	g_bIsHaveDefuseKit = hEvent.GetBool("haskit");
	showBombPanel(GetClientOfUserId(hEvent.GetInt("userid")), 5);
}

public void onBombPlanted(Event hEvent, const char[] szName, bool bDontBroadCast) {
	if (g_iWire == 0)
		g_iWire = GetRandomInt(1, 4);
}

public void onBombAbort(Event hEvent, const char[] szName, bool bDontBroadCast) {
	CancelClientMenu(GetClientOfUserId(hEvent.GetInt("userid")), true);
}

public void showBombPanel(int iClient, int iTime) {
	int iClientTeam = GetClientTeam(iClient);
	Panel hBombPanel = new Panel();
	char szBuffer[256];

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel title plant");
	hBombPanel.SetTitle(szBuffer);

	switch (iClientTeam) {
		case 2: {
			g_iWire = 0;
			Format(szBuffer, sizeof(szBuffer), "%t", "T Panel hint");
		}

		case 3: {
			Format(szBuffer, sizeof(szBuffer), "%t", "CT Panel hint");
		}
	}

	hBombPanel.DrawText(szBuffer);

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel wire 1");
	hBombPanel.DrawItem(szBuffer);

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel wire 2");
	hBombPanel.DrawItem(szBuffer);

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel wire 3");
	hBombPanel.DrawItem(szBuffer);

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel wire 4");
	hBombPanel.DrawItem(szBuffer);

	hBombPanel.DrawText("\n ");

	Format(szBuffer, sizeof(szBuffer), "%t", "Panel exit");
	hBombPanel.DrawItem(szBuffer);

	hBombPanel.Send(iClient, bombMenuHandler, iTime);
}

public int bombMenuHandler(Menu hMenu, MenuAction iAction, int iClient, int iItem) {
	switch (iAction) {
		case MenuAction_Select: {
			switch (GetClientTeam(iClient)) {
				case 2: {
					if (iItem != 5) {
						char szWire[12];
						g_iWire = iItem;

						Format(szWire, sizeof(szWire), "Chat wire %d", iItem);
						PrintToChat(iClient, "%t%t", "Prefix", "Chat wire selected", szWire);
					}
				}

				case 3: {
					if (iItem != 5) {
						int iBombEntity = FindEntityByClassname(-1, "planted_c4");

						if (iBombEntity != -1) {
							char
								szWire[12],
								szCorrectWire[12];

							Format(szWire, sizeof(szWire), "Chat wire %d", iItem);
							Format(szCorrectWire, sizeof(szCorrectWire), "Chat wire %d", g_iWire);

							if (g_bIsHaveDefuseKit) {
								if (g_iWire == iItem) {
									SetEntPropFloat(iBombEntity, Prop_Send, "m_flDefuseCountDown", 0.0);
									PrintToChat(iClient, "%t%t", "Prefix", "Chat correct wire is cut", iClient, szWire);
								} else {
									SetEntPropFloat(iBombEntity, Prop_Send, "m_flC4Blow", 0.0);
									PrintToChat(iClient, "%t%t", "Prefix", "Chat incorrect wire is cut", iClient, szWire, szCorrectWire);
								}
							} else {
								if (g_iWire == iItem) {
									if (GetRandomInt(0, 1)) {
										SetEntPropFloat(iBombEntity, Prop_Send, "m_flDefuseCountDown", 0.0);
										PrintToChat(iClient, "%t%t", "Prefix", "Chat successful correct wire is torn", iClient, szWire);
									} else {
										SetEntPropFloat(iBombEntity, Prop_Send, "m_flC4Blow", 0.0);
										PrintToChat(iClient, "%t%t", "Prefix", "Chat correct wire is failed torn", iClient, szWire);
									}
								} else {
									SetEntPropFloat(iBombEntity, Prop_Send, "m_flC4Blow", 0.0);
									PrintToChat(iClient, "%t%t", "Prefix", "Chat incorrect wire is torn", iClient, szWire, szCorrectWire);
								}
							}
						}
					}
				}
			}
		}

		case MenuAction_End:
			delete hMenu;
	}

	return 0;
}
