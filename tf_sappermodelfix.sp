#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = {
	name = "[TF2] Sapper Model Crash Fix",
	author = "FlaminSarge",
	description = "Fixes crashes for custom sapper models due to the placement models not existing",
	url = "https://github.com/flaminsarge/tf_sappermodelfix",
	version = PLUGIN_VERSION
};

Handle hSetModel;

char strDefaultPlacement[] = "models/buildables/sapper_placement.mdl";
char strDefaultPlaced[] = "models/buildables/sapper_placed.mdl";

public void OnPluginStart() {
	CreateConVar("tf_sappermodelfix_version", PLUGIN_VERSION, "[TF2] Sapper Model Crash Fix Version", FCVAR_NOTIFY);

	Handle hGameConf = LoadGameConfigFile("tf.sappermodelfix");

	if (hGameConf == INVALID_HANDLE) {
		SetFailState("[TF2] Sapper Model Crash Fix gamedata missing (tf.sappermodelfix.txt)");
	}
	int offset = GameConfGetOffset(hGameConf, "SetModel");
	hSetModel = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, SetSapperModel);
	DHookAddParam(hSetModel, HookParamType_CharPtr);

	CloseHandle(hGameConf);
}

public void OnEntityCreated(int entity) {
	char buf[64];
	GetEntityNetClass(entity, buf, sizeof(buf));
	if (StrEqual(buf, "CObjectSapper")) {
		DHookEntity(hSetModel, false, entity);
	}
}

public MRESReturn SetSapperModel(int iEntity, Handle hParams) {
	char buf[PLATFORM_MAX_PATH];
	DHookGetParamString(hParams, 1, buf, sizeof(buf));
	if (IsModelPrecached(buf)) {
		return MRES_Ignored;
	}
	bool placed = StrContains(buf, "_placement.mdl") == -1;
	//using MRES_ChangedHandled crashes for some reason
	//DHookSetParamString(hParams, 1, placed ? strDefaultPlaced : strDefaultPlacement);
	//return MRES_ChangedHandled;
	SetEntityModel(iEntity, placed ? strDefaultPlaced : strDefaultPlacement);
	return MRES_Supercede;
}
