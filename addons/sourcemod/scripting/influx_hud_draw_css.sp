#include <sourcemod>

#include <influx/core>
#include <influx/hud>

#include <msharedutil/misc>


#undef REQUIRE_PLUGIN
#include <influx/help>
#include <influx/recording>
#include <influx/strafes>
#include <influx/jumps>
#include <influx/pause>
#include <influx/practise>
//#include <influx/strfsync>
#include <influx/truevel>
#include <influx/zones_stage>
#include <influx/zones_checkpoint>


// LIBRARIES
bool g_bLib_Strafes;
bool g_bLib_Jumps;
bool g_bLib_Pause;
bool g_bLib_Practise;
bool g_bLib_Recording;
//bool g_bLib_StrfSync;
bool g_bLib_Truevel;
bool g_bLib_Stage;
bool g_bLib_CP;


public Plugin myinfo =
{
    author = INF_AUTHOR,
    url = INF_URL,
    name = INF_NAME..." - HUD | Draw CSS",
    description = "Displays info on player's screen.",
    version = INF_VERSION
};

public APLRes AskPluginLoad2( Handle hPlugin, bool late, char[] szError, int error_len )
{
    if ( GetEngineVersion() != Engine_CSS )
    {
        FormatEx( szError, error_len, "Bad engine version!" );
        
        return APLRes_Failure;
    }
    
    return APLRes_Success;
}

public void OnPluginStart()
{
    // LIBRARIES
    g_bLib_Strafes = LibraryExists( INFLUX_LIB_STRAFES );
    g_bLib_Jumps = LibraryExists( INFLUX_LIB_JUMPS );
    g_bLib_Pause = LibraryExists( INFLUX_LIB_PAUSE );
    g_bLib_Practise = LibraryExists( INFLUX_LIB_PRACTISE );
    g_bLib_Recording = LibraryExists( INFLUX_LIB_RECORDING );
    //g_bLib_StrfSync = LibraryExists( INFLUX_LIB_STRFSYNC );
    g_bLib_Truevel = LibraryExists( INFLUX_LIB_TRUEVEL );
    g_bLib_Stage = LibraryExists( INFLUX_LIB_ZONES_STAGE );
    g_bLib_CP = LibraryExists( INFLUX_LIB_ZONES_CP );
}

public void OnLibraryAdded( const char[] lib )
{
    if ( StrEqual( lib, INFLUX_LIB_STRAFES ) ) g_bLib_Strafes = true;
    if ( StrEqual( lib, INFLUX_LIB_JUMPS ) ) g_bLib_Jumps = true;
    if ( StrEqual( lib, INFLUX_LIB_PAUSE ) ) g_bLib_Pause = true;
    if ( StrEqual( lib, INFLUX_LIB_PRACTISE ) ) g_bLib_Practise = true;
    if ( StrEqual( lib, INFLUX_LIB_RECORDING ) ) g_bLib_Recording = true;
    //if ( StrEqual( lib, INFLUX_LIB_STRFSYNC ) ) g_bLib_StrfSync = true;
    if ( StrEqual( lib, INFLUX_LIB_TRUEVEL ) ) g_bLib_Truevel = true;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_STAGE ) ) g_bLib_Stage = true;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_CP ) ) g_bLib_CP = true;
}

public void OnLibraryRemoved( const char[] lib )
{
    if ( StrEqual( lib, INFLUX_LIB_STRAFES ) ) g_bLib_Strafes = false;
    if ( StrEqual( lib, INFLUX_LIB_JUMPS ) ) g_bLib_Jumps = false;
    if ( StrEqual( lib, INFLUX_LIB_PAUSE ) ) g_bLib_Pause = false;
    if ( StrEqual( lib, INFLUX_LIB_PRACTISE ) ) g_bLib_Practise = false;
    if ( StrEqual( lib, INFLUX_LIB_RECORDING ) ) g_bLib_Recording = false;
    //if ( StrEqual( lib, INFLUX_LIB_STRFSYNC ) ) g_bLib_StrfSync = false;
    if ( StrEqual( lib, INFLUX_LIB_TRUEVEL ) ) g_bLib_Truevel = false;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_STAGE ) ) g_bLib_Stage = false;
    if ( StrEqual( lib, INFLUX_LIB_ZONES_CP ) ) g_bLib_CP = false;
}

public Action Influx_OnDrawHUD( int client, int target, HudType_t hudtype )
{
    static char szMsg[256];
    szMsg[0] = '\0';
    
    decl String:szTemp[32];
    decl String:szSecFormat[12];
    
    int hideflags = Influx_GetClientHideFlags( client );
    
    
    if ( hudtype == HUDTYPE_HINT )
    {
        Influx_GetSecondsFormat_Timer( szSecFormat, sizeof( szSecFormat ) );
        
        
        RunState_t state = Influx_GetClientState( target );
        
        if ( !(hideflags & HIDEFLAG_TIME) && state >= STATE_RUNNING )
        {
            if ( state == STATE_FINISHED )
            {
                float time = Influx_GetClientFinishedTime( target );
                Inf_FormatSeconds( time, szMsg, sizeof( szMsg ), "%05.2f" );
                
                
                float finishbest = Influx_GetClientFinishedBestTime( target );
                
                if ( finishbest != INVALID_RUN_TIME )
                {
                    decl String:szTime[10];
                    
                    decl Float:dif;
                    decl String:c[1];
                    
                    if ( time >= finishbest )
                    {
                        dif = time - finishbest;
                        c[0] = '+';
                    }
                    else
                    {
                        dif = finishbest - time;
                        c[0] = '-';
                    }
                    
                    Inf_FormatSeconds( dif, szTime, sizeof( szTime ), "%05.2f" );
                    
                    Format( szMsg, sizeof( szMsg ), "%s\n(%c%s)", szMsg, c[0], szTime );
                }
            }
            else if ( g_bLib_Pause && Influx_IsClientPaused( target ) )
            {
                Inf_FormatSeconds( Influx_GetClientPausedTime( target ), szMsg, sizeof( szMsg ), szSecFormat );
            }
            else
            {
                Inf_FormatSeconds( Influx_GetClientTime( target ), szMsg, sizeof( szMsg ), szSecFormat );
            }
        }
        else if ( state == STATE_START )
        {
            Influx_GetRunName( Influx_GetClientRunId( target ), szTemp, sizeof( szTemp ) );
            FormatEx( szMsg, sizeof( szMsg ), "In %s Start", szTemp );
        }
        
        
        if (g_bLib_CP
        &&  (GetEngineTime() - Influx_GetClientLastCPTouch( target )) < 2.0 )
        {
            float rectime = Influx_GetClientLastCPBestTime( target );
            
            if ( rectime != INVALID_RUN_TIME )
            {
                float time = Influx_GetClientLastCPTime( target );
                
                
                decl Float:dif;
                decl pre;
                
                if ( rectime <= time )
                {
                    dif = time - rectime;
                    pre = '+';
                }
                else
                {
                    dif = rectime - time;
                    pre = '-';
                }
                
                //decl String:szName[MAX_CP_NAME];
                //Influx_GetClientLastCPName( client, szName, sizeof( szName ) );
                
                
                decl String:form[16];
                Inf_FormatSeconds( dif, form, sizeof( form ), szSecFormat );
                
                
                Format( szMsg, sizeof( szMsg ), "%s%s(%c%s)",
                    szMsg,
                    NEWLINE_CHECK( szMsg ), 
                    pre,
                    form );
            }
        }
        
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        if ( !(hideflags & HIDEFLAG_SPEED) )
        {
            Format( szMsg, sizeof( szMsg ), "%s%s%03.0f",
                szMsg,
                NEWLINE_CHECK( szMsg ), 
                GetSpeed( target ) );
        }
        
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        if ( g_bLib_Practise && !(hideflags & HIDEFLAG_PRACMODE) && Influx_IsClientPractising( target ) )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sPractising",
                szMsg,
                NEWLINE_CHECK( szMsg ) );
        }
        
        if ( g_bLib_Pause && !(hideflags & HIDEFLAG_PAUSEMODE) && Influx_IsClientPaused( target ) )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sPaused",
                szMsg,
                NEWLINE_CHECK( szMsg ) );
        }
        
        PrintHintText( client, szMsg );
    }
    else if ( hudtype == HUDTYPE_KEYHINT )
    {
        Influx_GetSecondsFormat_Sidebar( szSecFormat, sizeof( szSecFormat ) );
        
        
        decl String:szTemp2[32];
        decl String:szTemp3[32];
        
        // Disable for bots.
        if ( IsFakeClient( target ) )
        {
            // Draw recording bot info.
            if ( g_bLib_Recording && Influx_GetReplayBot() == target )
            {
                float time = Influx_GetReplayTime();
                if ( time == INVALID_RUN_TIME ) return Plugin_Stop;
                
                
                decl String:szTime[12];
                
                
                
                Influx_GetModeName( Influx_GetReplayMode(), szTemp, sizeof( szTemp ), true );
                Influx_GetStyleName( Influx_GetReplayStyle(), szTemp2, sizeof( szTemp2 ), true );
                
                
                Inf_FormatSeconds( time, szTime, sizeof( szTime ), szSecFormat );
                
                
                decl String:szName[16];
                Influx_GetReplayName( szName, sizeof( szName ) );
                
                FormatEx( szMsg, sizeof( szMsg ), "%s%s%s\n \nTime: %s\nName: %s",
                    szTemp2, // Style
                    ( szTemp[0] != '\0' && szTemp2[0] != '\0' ) ? " " : "",
                    szTemp, // Mode
                    szTime,
                    szName );
                
                
                Inf_ShowKeyHintText( client, szMsg );
            }
            
            return Plugin_Stop;
        }
        
        
        if ( !(hideflags & HIDEFLAG_RUNNAME) )
        {
            Influx_GetRunName( Influx_GetClientRunId( target ), szTemp, sizeof( szTemp ) );
            FormatEx( szMsg, sizeof( szMsg ), "Run: %s", szTemp );
        }
        
        
        if ( g_bLib_Stage && Influx_ShouldDisplayStages( client ) )
        {
            int stages = Influx_GetClientStageCount( client );
            
            if ( stages < 1 )
            {
                FormatEx( sz, len, "Stage: Linear" );
            }
            else
            {
                FormatEx( sz, len, "Stage: %i/%i", Influx_GetClientStage( client ), stages + 1 );
            }
            
            Format( szMsg, sizeof( szMsg ), "%s%s%s",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                szTemp2 );
        }
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        if ( !(hideflags & HIDEFLAG_MODENSTYLE) )
        {
            Influx_GetModeName( Influx_GetClientMode( target ), szTemp, sizeof( szTemp ), true );
            Influx_GetStyleName( Influx_GetClientStyle( target ), szTemp2, sizeof( szTemp2 ), true );
            
            
            if ( szTemp[0] != '\0' || szTemp2[0] != '\0' )
            {
                Format( szMsg, sizeof( szMsg ), "%s%s%s%s%s",
                    szMsg,
                    NEWLINE_CHECK( szMsg ),
                    szTemp2,
                    ( szTemp[0] != '\0' && szTemp2[0] != '\0' ) ? " " : "",
                    szTemp );
            }
        }
        
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        
        if ( !(hideflags & HIDEFLAG_PB_TIME) && Influx_IsClientCached( target ) )
        {
            float time = Influx_GetClientCurrentPB( target );
            
            if ( time != INVALID_RUN_TIME )
            {
                Inf_FormatSeconds( time, szTemp2, sizeof( szTemp2 ), szSecFormat );
                FormatEx( szTemp, sizeof( szTemp ), "PB: %s", szTemp2 );
            }
            else
            {
                strcopy( szTemp, sizeof( szTemp ), "PB: N/A" );
            }
            
            Format( szMsg, sizeof( szMsg ), "%s%s%s",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                szTemp );
        }
        
        if ( !(hideflags & HIDEFLAG_WR_TIME) )
        {
            float time = Influx_GetClientCurrentBestTime( target );
            
            if ( time > INVALID_RUN_TIME )
            {
                Inf_FormatSeconds( time, szTemp2, sizeof( szTemp2 ), szSecFormat );
                Influx_GetClientCurrentBestName( target, szTemp3, sizeof( szTemp3 ) );
                
                LimitString( szTemp3, sizeof( szTemp3 ), 10 );
                
                
                FormatEx( szTemp, sizeof( szTemp ), "SR: %s (%s)", szTemp2, szTemp3 );
            }
            else
            {
                strcopy( szTemp, sizeof( szTemp ), "SR: N/A" );
            }
            
            Format( szMsg, sizeof( szMsg ), "%s%s%s",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                szTemp );
        }
        
        
        ADD_SEPARATOR( szMsg, "\n " );
        
        
        RunState_t state = Influx_GetClientState( target );
        
        if ( g_bLib_Strafes && state >= STATE_RUNNING )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sStrafes: %i",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                Influx_GetClientStrafeCount( target ) );
        }
        
        if ( g_bLib_Jumps && state >= STATE_RUNNING )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sJumps: %i",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                Influx_GetClientJumpCount( target ) );
        }
        
        /*if ( g_bLib_StrfSync && !(hideflags & HIDEFLAG_STRFSYNC) && state >= STATE_RUNNING )
        {
            Format( szMsg, sizeof( szMsg ), "%s%sSync: %.1f",
                szMsg,
                NEWLINE_CHECK( szMsg ),
                Influx_GetClientStrafeSync( target ) );
        }*/
        
        Inf_ShowKeyHintText( client, szMsg );
    }
    
    return Plugin_Stop;
}

// Check if they want truevel.
stock float GetSpeed( int client )
{
    return ( g_bLib_Truevel && Influx_IsClientUsingTruevel( client ) ) ? GetEntityTrueSpeed( client ) : GetEntitySpeed( client );
}