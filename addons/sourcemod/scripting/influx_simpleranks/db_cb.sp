public void Thrd_Empty( Handle db, Handle res, const char[] szError, int client )
{
    if ( res == null )
    {
        Inf_DB_LogError( db, "inserting rank data into database", client ? GetClientOfUserId( client ) : 0, "An error occurred while saving your ranks!" );
    }
}

public void Thrd_InitMap( Handle db, Handle res, const char[] szError, any data )
{
    if ( res == null )
    {
        Inf_DB_LogError( db, "getting map rank reward" );
        return;
    }
    
    
    g_hMapRewards.Clear();
    
    while ( SQL_FetchRow( res ) )
    {
        AddMapReward( SQL_FetchInt( res, 0 ), SQL_FetchInt( res, 1 ) );
    }
}

public void Thrd_InitClient( Handle db, Handle res, const char[] szError, int client )
{
    if ( !(client = GetClientOfUserId( client )) ) return;
    
    if ( res == null )
    {
        Inf_DB_LogError( db, "getting client rank" );
        return;
    }
    
    
    if ( SQL_FetchRow( res ) )
    {
        g_nPoints[client] = SQL_FetchInt( res, 0 );
        
        
        decl String:szRank[MAX_RANK_SIZE];
        SQL_FetchString( res, 1, szRank, sizeof( szRank ) );
        
        if ( szRank[0] != 0 )
        {
            int index = FindRankByName( szRank );
            
            if ( index != -1 )
            {
                SetClientRank( client, index, true, szRank );
            }
            else if ( CanUserUseCustomRank( client ) )
            {
                SetClientRank( client, -1, true, szRank );
            }
            else
            {
                SetClientDefRank( client );
            }
        }
        else
        {
            SetClientDefRank( client );
        }
    }
    else
    {
        static char szQuery[256];
        FormatEx( szQuery, sizeof( szQuery ),
            "INSERT INTO "...INF_TABLE_SIMPLERANKS..." (uid,cachedpoints,chosenrank) VALUES (%i,0,NULL)", Influx_GetClientId( client ) );
        
        SQL_TQuery( db, Thrd_Empty, szQuery, GetClientUserId( client ), DBPrio_Normal );
    }
}

public void Thrd_CheckClientRecCount( Handle db, Handle res, const char[] szError, ArrayList array )
{
    decl data[5];
    
    array.GetArray( 0, data, sizeof( data ) );
    delete array;
    
    
    int client = data[0];
    int mapid = data[1];
    int reqrunid = data[2];
    /*int reqmode = data[3];
    int reqstyle = data[4];*/
    
    
    if ( mapid != Influx_GetCurrentMapId() ) return;
    
    if ( !(client = GetClientOfUserId( client )) ) return;
    
    if ( res == null )
    {
        Inf_DB_LogError( db, "checking client record count for reward" );
        return;
    }
    
    
    // Check whether the server has updated this map's reward to be higher. If so, update ours!
    int override_reward = -1;
    
    if ( SQL_FetchRow( res ) )
    {
        int oldreward = SQL_FetchInt( res, 0 );
        
        int curreward = GetMapRewardPointsSafe( reqrunid );
        
        if ( oldreward >= curreward )
        {
            return;
        }
        
        override_reward = curreward - oldreward;
    }
    
    
    RewardClient( client, reqrunid, g_ConVar_NotifyReward.BoolValue, g_ConVar_NotifyNewRank.BoolValue, override_reward );
}

public void Thrd_SetMapReward( Handle db, Handle res, const char[] szError, ArrayList array )
{
    decl data[3];
    
    array.GetArray( 0, data, sizeof( data ) );
    delete array;
    
    
    int client = data[0];
    int runid = data[1];
    int reward = data[2];
    
    
    if ( client && !(client = GetClientOfUserId( client )) ) return;
    
    if ( res == null )
    {
        Inf_DB_LogError( db, "setting map reward by name" );
        return;
    }
    
    // We never know which query gets executed first.
    // So... we'll check if this one record we have is the same one we are receiving the reward for.
    if ( SQL_GetRowCount( res ) > 1 )
    {
        Inf_ReplyToClient( client, "Found multiple maps with similar name! Try to be more specific." );
        return;
    }
    
    if ( !SQL_FetchRow( res ) )
    {
        Inf_ReplyToClient( client, "Couldn't find a similar map!" );
        return;
    }
    
    
    int mapid = SQL_FetchInt( res, 0 );
    
    decl String:szMap[64];
    SQL_FetchString( res, 1, szMap, sizeof( szMap ) );
    
    
    if ( mapid == Influx_GetCurrentMapId() )
    {
        SetCurrentMapReward( client, runid, reward );
    }
    
    
    DB_UpdateMapReward( mapid, runid, reward );
    
    Inf_ReplyToClient( client, "Setting {MAINCLR1}%s{CHATCLR}'s reward to {MAINCLR1}%i{CHATCLR}!", szMap, reward );
}

