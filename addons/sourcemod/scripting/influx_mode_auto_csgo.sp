#include <sourcemod>
#include <sdkhooks>
#include <cstrike>

#include <influx/core>


//#define DEBUG_THINK


public Plugin myinfo =
{
    author = INF_AUTHOR,
    url = INF_URL,
    name = INF_NAME..." - Mode - Auto",
    description = "",
    version = INF_VERSION
};

public APLRes AskPluginLoad2( Handle hPlugin, bool late, char[] szError, int error_len )
{
    if ( GetEngineVersion() != Engine_CSGO )
    {
        FormatEx( szError, error_len, "Bad engine version!" );
        return APLRes_Failure;
    }
    
    return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
    AddMode();
}

public void OnPluginEnd()
{
    Influx_RemoveMode( MODE_AUTO );
}

public void Influx_OnRequestModes()
{
    AddMode();
}

stock void AddMode()
{
    if ( !Influx_AddMode( MODE_AUTO, "Autobhop", "Auto", "auto", 260.0 ) )
    {
        SetFailState( INF_CON_PRE..."Couldn't add mode! (%i)", MODE_AUTO );
    }
}

stock void UnhookThinks( int client )
{
    SDKUnhook( client, SDKHook_PreThinkPost, E_PreThinkPost_Client );
    SDKUnhook( client, SDKHook_PostThinkPost, E_PostThinkPost_Client );
}

public Action Influx_OnSearchType( const char[] szArg, Search_t &type, int &value )
{
    if (StrEqual( szArg, "auto", false )
    ||  StrEqual( szArg, "autobhop", false )
    ||  StrEqual( szArg, "auto-bhop", false )
    ||  StrEqual( szArg, "autobunnyhop", false ) )
    {
        value = MODE_AUTO;
        type = SEARCH_MODE;
        
        return Plugin_Stop;
    }
    
    return Plugin_Continue;
}

public Action Cmd_Mode_Auto( int client, int args )
{
    if ( !client ) return Plugin_Handled;
    
    
    Influx_SetClientMode( client, MODE_AUTO );
    
    return Plugin_Handled;
}
