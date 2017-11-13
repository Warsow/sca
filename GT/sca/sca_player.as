class scaPlayer 
{
	Table weaponAccuracyStats("l l l l l l l l");

	Client@ client;
	String account;
	uint permissionLevel;
	bool inUse;
	bool gotStats;
	bool tracking;
	uint[] ignoredPlayers;

	// Cmd & Chat flood protection vars
	uint lastCmd;
	uint cmdCounter;
	uint cmdFloodTime;

	// For chat
	uint lastMsg;
	uint msgCounter;
	uint chatFloodTime;

	// Player stats (Of the db)
	int dbScore;
	int dbFrags;
	int dbDeaths;
	int dbSuicides;
	int dbDamageGiven;
	int dbDamageReceived;
	int dbGames;
	int dbRounds;
	int dbMVP;
	float dbPlayTime;

	// Current stats used to save
	int pScore;
	int pFrags;
	int pDeaths;
	int pSuicides;
	int pDamageGiven;
	int pDamageReceived;
	int pGames;
	int pRounds;
	int pMVP;
	float pPlayTime;	
	int DPR; // Damage per round
	float currentPlayTime;

	// Current stats used to display
	// Weapons
	uint[] pShots;
	uint[] pHits;
	float GBAccuracy;
	float MGAccuracy;
	float RGAccuracy;
	float GRLAccuracy;
	float RLAccuracy;
	float PGAccuracy;
	float LGAccuracy;
	float EBAccuracy;

	// Misc
	
	scaPlayer()
	{
		this.inUse = false;
		this.gotStats = false;
		this.permissionLevel = 0;
		this.cmdCounter = 0;
		this.lastCmd = levelTime;
		this.cmdFloodTime = 0;
		this.lastMsg = levelTime;
		this.msgCounter = 0;
		this.chatFloodTime = 0;
		this.tracking = true;
		this.currentPlayTime = 0;
		this.account = "";
	}

	void addPlayer(Client@ client)
	{
		@this.client = @client;

		this.account = logins[client.playerNum];
		this.inUse = true;
		this.currentPlayTime = levelTime;
		this.getStats();
	}

	void clearPlayer()
	{
		G_Print(this.account + "\n");
		base.removeAuthedPlayer(client);
		this.syncStats();
		logins[this.client.playerNum] = "";

		this.inUse = false;
		this.pShots.resize(0);
		this.pHits.resize(0);
		this.weaponAccuracyStats.reset();
		this.weaponAccuracyStats.clear();


		// Reset all the current stats
		this.pScore = 0;
		this.pFrags = 0;
		this.pDeaths = 0;
		this.pSuicides = 0;
		this.pDamageGiven = 0;
		this.pDamageReceived = 0;
		this.pGames = 0;
		this.pRounds = 0;
		this.pMVP = 0;
		this.pPlayTime = 0;
		this.DPR = 0;

		this.account = "";
		this.permissionLevel = 0;
	}

	void getStats()
	{
		// The SCA-API handles creating and returning a new player if no player is found
		JSON json;
		
		if(this.account == "")
		{
			G_Print("Getting the stats of " + client.name + " clean name: " + client.name.removeColorTokens().tolower() + "...\n");
			Curl@ req = Curl("http://localhost/sca/player.php");
			json["player"] = client.name.removeColorTokens().tolower();
			req.postJSON(CurlJSONDone(this.StatsCallback), json);			
		}
		else
		{
			G_Print("Getting the stats of Account " + this.account + " clean name: " + client.name.removeColorTokens().tolower() + "...\n");
			Curl@ req = Curl("http://localhost/sca/account.php");
			json["account"] = this.account;
			base.addAuthedPlayer(client);
			req.postJSON(CurlJSONDone(this.StatsCallback), json);	
		}
	}

	void StatsCallback(Curl@ req, JSON json)
	{
		this.dbScore = json["score"].valueint;
		this.dbFrags = json["frags"].valueint;
		this.dbDeaths = json["deaths"].valueint;
		this.dbSuicides = json["suicides"].valueint;
		this.dbDamageGiven = json["d_given"].valueint;
		this.dbDamageReceived = json["d_received"].valueint;
		this.dbGames = json["games"].valueint;
		this.dbRounds = json["rounds"].valueint;
		this.dbMVP = json["mvps"].valueint;
		this.dbPlayTime = json["playtime"].valuefloat;

		this.permissionLevel = json["sca_group"].valueint;

		if(this.dbRounds == 0 || this.pRounds == 0)
			this.DPR = this.dbDamageGiven / 1;
		else
			this.DPR = this.dbDamageGiven / this.dbRounds;

		// GB MG RG GL RL PG LG EB
		this.pShots.push_back(json["GL_Shots"].valueint); this.pHits.push_back(json["GL_Hits"].valueint);
		this.pShots.push_back(json["MG_Shots"].valueint); this.pHits.push_back(json["MG_Hits"].valueint);
		this.pShots.push_back(json["RG_Shots"].valueint); this.pHits.push_back(json["RG_Hits"].valueint);
		this.pShots.push_back(json["GRL_Shots"].valueint); this.pHits.push_back(json["GRL_Hits"].valueint);
		this.pShots.push_back(json["RL_Shots"].valueint); this.pHits.push_back(json["RL_Hits"].valueint);
		this.pShots.push_back(json["PG_Shots"].valueint); this.pHits.push_back(json["PG_Hits"].valueint);
		this.pShots.push_back(json["LG_Shots"].valueint); this.pHits.push_back(json["LG_Hits"].valueint);
		this.pShots.push_back(json["EB_Shots"].valueint); this.pHits.push_back(json["EB_Hits"].valueint);

		this.GBAccuracy = this.calcAccuracy(this.pShots[0], this.pHits[0]) * 100;
		this.MGAccuracy = this.calcAccuracy(this.pShots[1], this.pHits[1]) * 100;
		this.RGAccuracy = this.calcAccuracy(this.pShots[2], this.pHits[2]) * 100;
		this.GRLAccuracy = this.calcAccuracy(this.pShots[3], this.pHits[3]) * 100;
		this.RLAccuracy = this.calcAccuracy(this.pShots[4], this.pHits[4]) * 100;
		this.PGAccuracy = this.calcAccuracy(this.pShots[5], this.pHits[5]) * 100;
		this.LGAccuracy = this.calcAccuracy(this.pShots[6], this.pHits[6]) * 100;
		this.EBAccuracy = this.calcAccuracy(this.pShots[7], this.pHits[7] * 100);

		// Table for the weapon accuracy
		this.weaponAccuracyStats.addCell("^7GB ");
		this.weaponAccuracyStats.addCell("^9MG "); 
		this.weaponAccuracyStats.addCell("^8RG "); 
		this.weaponAccuracyStats.addCell("^4GL ");
		this.weaponAccuracyStats.addCell("^1RL ");
		this.weaponAccuracyStats.addCell("^2PG ");
		this.weaponAccuracyStats.addCell("^3LG ");
		this.weaponAccuracyStats.addCell("^5EB ");
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.GBAccuracy)) + "%"); 
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.MGAccuracy)) + "%");
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.RGAccuracy)) + "%"); 
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.GRLAccuracy)) + "%");		
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.RLAccuracy)) + "%");
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.PGAccuracy)) + "%");
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.LGAccuracy)) + "%");
		this.weaponAccuracyStats.addCell("^7" + (ceil(this.EBAccuracy)) + "%");

		G_Print("Got the stats\n");
		this.gotStats = true;
	}

	void syncStats()
	{
		if(!this.gotStats)
		{
			G_PrintMsg(null, "^1Curl communication error, continuing without stats...\n");
		}

		// Check if the game is done
		if(this.pRounds == gameRounds && gameIsDone)
		{
			this.pGames++;
		}

		JSON json;
		json["player"] = client.name;
		json["player_clean"] = client.name.removeColorTokens().tolower();
		json["score"] = this.pScore + this.dbScore + "";
		json["frags"] = this.pFrags + this.dbFrags + "";
		json["deaths"] = this.pDeaths + this.dbDeaths + "";
		json["suicides"] = this.pSuicides + this.dbSuicides + "";
		json["dmg_given"] = this.pDamageGiven + this.dbDamageGiven + "";
		json["dmg_received"] = this.pDamageReceived + this.dbDamageReceived + "";
		json["games"] = this.pGames + this.dbGames + "";
		json["rounds"] = this.pRounds + this.dbRounds + "";
		json["mvp"] = this.pMVP + this.dbMVP + "";
		json["playtime"] = (this.dbPlayTime + (levelTime - this.currentPlayTime)) + "";

		// Weapon accuracy stuff
		uint weaponCounterArrayIndex = 0;

		for (int weapon_type = WEAP_GUNBLADE; weapon_type < WEAP_INSTAGUN; weapon_type++)
		{
			this.pShots[weaponCounterArrayIndex] += wstats[weapon_type][this.client.playerNum].shots;
			this.pHits[weaponCounterArrayIndex] += wstats[weapon_type][this.client.playerNum].hits;
			weaponCounterArrayIndex++;
		}

		// GB MG RG GL RL PG LG EB
		json["gb_shots"] = this.pShots[0] + ""; json["gb_hits"] = this.pHits[0] + "";
		json["mg_shots"] = this.pShots[1] + ""; json["mg_hits"] = this.pHits[1] + "";
		json["rg_shots"] = this.pShots[2] + ""; json["rg_hits"] = this.pHits[2] + "";
		json["gl_shots"] = this.pShots[3] + ""; json["gl_hits"] = this.pHits[3] + "";
		json["rl_shots"] = this.pShots[4] + ""; json["rl_hits"] = this.pHits[4] + "";
		json["pg_shots"] = this.pShots[5] + ""; json["pg_hits"] = this.pHits[5] + "";
		json["lg_shots"] = this.pShots[6] + ""; json["lg_hits"] = this.pHits[6] + "";
		json["eb_shots"] = this.pShots[7] + ""; json["eb_hits"] = this.pHits[7] + "";

		if(this.account == "")
		{
			G_Print("Syncing stats for " + client.name + " clean name: " + client.name.removeColorTokens().tolower() + "...\n");
			Curl@ req = Curl("http://localhost/sca/sync_player.php");
			req.postJSON(CurlJSONDone(this.SyncGuestCallback), json);
		}
		else
		{
			G_Print("Syncing account " + this.account + " clean name: " + client.name.removeColorTokens().tolower() + "...\n");
			json["account"] = this.account;
			Curl@ req = Curl("http://localhost/sca/sync_account.php");
			req.postJSON(CurlJSONDone(this.SyncAccountCallback), json);
		}
	}

	void SyncGuestCallback(Curl@ req, JSON json)
	{
		if(json["status"].valuestring == "synced")
			G_Print("Stats synced with the DB\n");
	}

	void SyncAccountCallback(Curl@ req, JSON json)
	{
		if(json["status"].valuestring == "synced")
			G_Print("Account synced with the DB\n");
	}

	void updateStats()
	{
		this.pScore += this.dbScore;
	}

	float calcAccuracy(float shots, float hits)
	{
		if(shots == 0)
			return 0;

		return hits / shots;
	}

	String formatMs(float ms)
	{
		uint min, hour, day;
		day = uint(ms / (1000*60*60*24));
		ms -= float(day) * (1000*60*60*24);
		hour = uint(ms / (1000*60*60));
		ms -= float(hour) * (1000*60*60);
		min = uint(ms / (1000*60));

		String dayString = day + " day";
		if ( day > 1 || day == 0 ) dayString += "s";
			String hourString = hour + " hour";
		if ( hour > 1 || hour == 0 ) hourString += "s";
			String minString = min + " minute";
		if ( min > 1 || min == 0 ) minString += "s";

		return dayString + " " + hourString + " " + minString;
	}

	void showStats(Client @client, int playerID = -1)
	{
		if(!this.gotStats)
		{
			G_PrintMsg(client.getEnt(), "^1Stats still loading, please wait\n");
			return;
		}
		uint totalDPR;

		if(this.dbRounds == 0 && this.pRounds == 0)
			totalDPR = this.dbDamageGiven / 1;
		else
			totalDPR = (this.dbDamageGiven + this.pRounds) / (this.dbRounds + this.pRounds);

		uint totalScore = this.pScore + this.dbScore;
		uint totalFrags = this.pFrags + this.dbFrags;
		uint totalDeaths = this.pDeaths + this.dbDeaths;
		uint totalSuicides = this.pSuicides + this.dbSuicides;
		uint totalDamageGiven = this.pDamageGiven + this.dbDamageGiven;
		uint totalDamageReceived = this.pDamageReceived + this.dbDamageReceived;
		uint totalRounds = this.pRounds + this.dbRounds;
		uint totalMVP = this.pMVP + this.dbMVP;
		float totalPlayTime = this.dbPlayTime;
		totalPlayTime += (levelTime - this.currentPlayTime);

		if(playerID == -1)
		{
			if(!this.gotStats)
			{
				G_PrintMsg(client.getEnt(), "^1Curl communication error, continuing without stats...\n");
				return;
			}

			if(this.account != "")
				G_PrintMsg(client.getEnt(), "^7Stats of " + client.name + " ^7(^1" + this.account + "^7)\n\n");
			else
				G_PrintMsg(client.getEnt(), "^7Stats of " + client.name + "\n\n");
			G_PrintMsg(client.getEnt(), "^7Total Score: ^1" + totalScore + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Frags / Deaths: ^1" + totalFrags + " ^7/ ^1" + totalDeaths + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Damage Given / Received: ^1" + totalDamageGiven + " ^7/ ^1" + totalDamageReceived + "\n");
			G_PrintMsg(client.getEnt(), "^7Damage per Round: ^1" + totalDPR + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Games: ^1" + this.dbGames + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Rounds: ^1" + totalRounds + "\n");
			G_PrintMsg(client.getEnt(), "^7Total MVPs: ^1" + totalMVP + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Playtime: ^1" + this.formatMs(totalPlayTime) + "\n");

			G_PrintMsg(client.getEnt(), "\n^7Overall weapon accuracy stats \n\n");
			
			for(uint i = 0; i < this.weaponAccuracyStats.numRows(); i++)
			{
				G_PrintMsg(client.getEnt(), this.weaponAccuracyStats.getRow(i) + "\n");
			}
		}
		else
		{
			if(!playerStats[playerID].gotStats)
			{
				G_PrintMsg(client.getEnt(), "^1Curl communication error, continuing without stats...\n");
				return;
			}

			if(playerStats[playerID].account != "")
				G_PrintMsg(client.getEnt(), "^7Stats of " + playerStats[playerID].client.name + " ^7(^1" + playerStats[playerID].account + "^7)\n\n");
			else
				G_PrintMsg(client.getEnt(), "^7Stats of " + playerStats[playerID].client.name + "\n\n");
			G_PrintMsg(client.getEnt(), "^7Total Score: ^1" + (playerStats[playerID].pScore + playerStats[playerID].dbScore)+ "\n");
			G_PrintMsg(client.getEnt(), "^7Total Frags / Deaths: ^1" + (playerStats[playerID].pFrags + playerStats[playerID].dbFrags) + " ^7/ ^1" + (playerStats[playerID].pDeaths + playerStats[playerID].dbDeaths) + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Damage Given / Received: ^1" + (playerStats[playerID].pDamageGiven + playerStats[playerID].dbDamageGiven) + " ^7/ ^1" + (playerStats[playerID].pDamageReceived + playerStats[playerID].dbDamageReceived) + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Games: ^1" + playerStats[playerID].dbGames + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Rounds: ^1" + (playerStats[playerID].pRounds + playerStats[playerID].dbRounds)+ "\n");
			G_PrintMsg(client.getEnt(), "^7Total MVPs: ^1" + (playerStats[playerID].pMVP + playerStats[playerID].dbMVP) + "\n");
			G_PrintMsg(client.getEnt(), "^7Total Playtime: ^1" + playerStats[playerID].formatMs((playerStats[playerID].dbPlayTime + (levelTime - playerStats[playerID].currentPlayTime))) + "\n");

			G_PrintMsg(client.getEnt(), "\n^7Overall weapon accuracy stats \n\n");

			for(uint i = 0; i < playerStats[playerID].weaponAccuracyStats.numRows(); i++)
			{
				G_PrintMsg(client.getEnt(), playerStats[playerID].weaponAccuracyStats.getRow(i) + "\n");
			}
		}
	}
}