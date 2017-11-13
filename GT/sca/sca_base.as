WeaponStats[][] wstats(WEAP_TOTAL, WeaponStats[](maxClients));
scaPlayer[] playerStats(maxClients);
String[] cleanNames(maxClients);
String[] cleanAlphaNames(maxClients);
String[] authedPlayers(maxClients);
uint[] top_timestamp(maxClients);

int gameRounds = 0;
bool gameIsDone = false;

void addGameRound()
{
	gameRounds++;
}

void setGameIsDone()
{
	gameIsDone = true;
}

class scaBase
{
	float[] roundDamagePlayers(maxClients);
	uint[] mvpCount(maxClients, 0);
	String factMessage;

	scaBase()
	{
		this.factMessage = "";
	}

	void displayTop(Client@ client, uint delay)
	{
		if(delay > 0)
		{
			top_timestamp[client.playerNum] = levelTime + delay;
			return;
		}	

		top_timestamp[client.playerNum] = 0;
		cmd.execute(client, "!top");
	}

	void showAuthed(Client@ client)
	{
		G_PrintMsg(playerStats[client.playerNum].client.getEnt(), "^2ID  Player\n");

		for(uint i = 0; i < authedPlayers.length(); i++)
		{
			if(authedPlayers[i] == "")
				continue;

			if(i < 10)
			{
				G_PrintMsg(playerStats[client.playerNum].client.getEnt(), "^9" + i + "   ^7" + authedPlayers[i] + "\n");
			}
			else
			{
				G_PrintMsg(playerStats[client.playerNum].client.getEnt(), "^9" + i + "  ^7" + authedPlayers[i] + "\n");
			}
		}
	}

	void addAuthedPlayer(Client@ client)
	{
		if(playerStats[client.playerNum].account != "")
			authedPlayers[client.playerNum] = client.name + " ^7(^1" + playerStats[client.playerNum].account + "^7)";
	}	

	void removeAuthedPlayer(Client@ client)
	{
		// Make sure the player was authed
		if(playerStats[client.playerNum].account != "")
			authedPlayers[client.playerNum] = "";
	}

	void getBestOverallAccuracy()
    {
    	
        float highestScore = -999.9;
        float highestAccuracy = -999.9;
        uint best_cid;
        Item@ best_weapon = null;
 
        for ( int weapon_type = WEAP_GUNBLADE; weapon_type < WEAP_TOTAL; weapon_type++ )
        {
            Item@ weapon = @G_GetItem(weapon_type);
            int ammo_type = weapon.ammoTag;
 
            for ( int i = 0; i < maxClients; i++ )
            {
                Client@ client = @G_GetClient(i);
 
                if ( @client == null )
                    continue;
 
                // get current total stats
                int hits = client.stats.accuracyHits(ammo_type);
                int shots = client.stats.accuracyShots(ammo_type);
 
                // get current round stats
                int cur_hits = hits - wstats[weapon_type][i].hits;
                int cur_shots = shots - wstats[weapon_type][i].shots;
 
                // calc accuracy and score for current round
                float accuracy = 0.0; //default if no shots
                float score = 0.0;
                if ( cur_shots > 0 )
                {
                    accuracy = float(cur_hits) / float(cur_shots);
                    score = float(cur_hits)*float(cur_hits) / float(cur_shots);
                }
 
 
                if ( score > highestScore )
                {
                    highestScore = score;
                    highestAccuracy = accuracy;
                    best_cid = i;
                    @best_weapon = @weapon;
                }
 
                // save current total stats
                wstats[weapon_type][i].hits = hits;
                wstats[weapon_type][i].shots = shots;
                wstats[weapon_type][i].accuracy = accuracy;
            }
        }    	
 		if(highestAccuracy > 0)
        {
        	if((highestAccuracy*100.0) > 100)
        	{
        		this.factMessage = "^7" + G_GetClient(best_cid).name + " ^7got the best ^1" + best_weapon.name + " ^7accuracy with ^1100% ^7this round !\n";
        	}
        	else
        	{
        		this.factMessage = "^7" + G_GetClient(best_cid).name + " ^7got the best ^1" + best_weapon.name + " ^7accuracy with ^1" + ceil(highestAccuracy*100.0) + "% ^7this round !\n";
        	}
        	
        	G_CenterPrintMsg(null, this.factMessage);
        	//this.factTime = levelTime + 2000;
    	} 
    	else
    	{
    		this.factMessage = "^1No hits? You all suck.";
    		G_CenterPrintMsg(null, this.factMessage);
    		//this.factTime = levelTime + 2000;
    	}
    }

    void getMVP()
	{
		uint cid;
		float maxdmg = 0.0;
		
		for(int i = 0; i < maxClients; i++)
		{
			if(maxdmg < this.roundDamagePlayers[i])
			{
				cid = i;
				maxdmg = this.roundDamagePlayers[i];
			}
			this.roundDamagePlayers[i] = 0;
		}

		if(maxdmg > 0)
		{
			G_PrintMsg(null, "^1MVP:^7 " + G_GetClient(cid).name + " ^7did ^1" + ceil(maxdmg) + " ^7Damage!\n");
			this.addMVP(cid);

			// 420 blaze it
			if(ceil(maxdmg) == 420)
			{
				G_PrintMsg(null, "^3420 Blaze it\n");
			}

		}
		else
		{
			G_PrintMsg(null, "^1No damage - No MVP\n");
		}
	}

	void addMVP(uint clientNum)
	{
		mvpCount[clientNum]++;
		playerStats[clientNum].pMVP++;
	}

	void resetRoundBasedValues()
	{

	}

	void addPlayer (Client@ client)
	{
		playerStats[client.playerNum].addPlayer(client);
	}
}

int playerOnServer(String player, Client @client) {
	bool isID;
		
	if(player == "")
	{
		G_PrintMsg(client.getEnt(), "^1Player ID/Name missing!\n");
		return -1;
	}

	// Check if its a player ID or name
	if(player.isNumeric())
	{
		player = player.toInt();
		isID = true;
	}
	else
	{
		player = player.removeColorTokens().tolower();
		isID = false;
	}

	if(!isID)
	{
		if(cleanNames.find(player)  >= 0)
			return cleanNames.find(player);
		else if(cleanAlphaNames.find(player) >= 0)
			return cleanAlphaNames.find(player);
		else
		{
			G_PrintMsg(client.getEnt(), "^1Can't find the given name!\n");
			return -1;
		} 	
	}
	else 
	{
		if(player > maxClients-1)
		{
			G_PrintMsg(client.getEnt(), "^1Given player ID is too high!\n");
			return -1;
		}
		else if(player < 0)
		{
			return -1;
		}
		else if(!playerStats[player].inUse)
		{
			G_PrintMsg(client.getEnt(), "^1Can't find the given player ID!\n");
			return -1;
		}
		else
		{
			return player;
		}			
	}
}

void updateCleanPlayers(Client@ client, bool userInfoChange = false)
{
	if(userInfoChange)
	{
		cleanNames[client.playerNum] = client.name.removeColorTokens().tolower();
		cleanAlphaNames[client.playerNum] = misc::makeAlphaNum(client.name.removeColorTokens().tolower());
		return;
	}

	if(cleanNames[client.playerNum] == "")
	{
		cleanNames[client.playerNum] = client.name.removeColorTokens().tolower();
		cleanAlphaNames[client.playerNum] = misc::makeAlphaNum(client.name.removeColorTokens().tolower());
	}
	else
	{
		cleanNames[client.playerNum] = "";
		cleanAlphaNames[client.playerNum] = "";
	}
}