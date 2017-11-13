class scaChat
{
	void doPublicChat(Client @client, String msg)
	{
		if(this.allowedToChat(client))
		{
			String clean_msg = msg.removeColorTokens();
			Entity @ent;
			Team @team;

			for (int i =0; i < GS_MAX_TEAMS; i++)
			{
				@team = @G_GetTeam(i);
	       		for(int j = 0; @team.ent(j) != null; j++)
        		{
        	 		@ent = @team.ent(j);
        	 		if(playerStats[ent.client.playerNum].ignoredPlayers.find(client.playerNum) < 0)
					{
						if (clean_msg.tolower().locate(ent.client.name.removeColorTokens().tolower(),0) != clean_msg.length() || clean_msg.tolower().locate(misc::makeAlphaNum(ent.client.name.removeColorTokens().tolower()) ,0) != clean_msg.length())
						{
							ent.client.execGameCommand("ch " + G_GetClient(client.playerNum).getEnt().entNum + " \"^1" + clean_msg + "\"");
						}
						else
						{
							ent.client.execGameCommand("ch " + G_GetClient(client.playerNum).getEnt().entNum + " \"" + msg + "\"");
						}
					}	
						
        		}
			}
			G_Print(client.name + "^2: " + msg + "\n");
		}
	}

	void doTeamChat(Client @client, String msg)
	{
		if(this.allowedToChat(client))
		{
			String clean_msg = msg.removeColorTokens();
			Entity @ent;
        	Team @team = @G_GetTeam(client.team);
        	 for(int i = 0; @team.ent(i) != null; i++)
        	 {
        	 	@ent = @team.ent(i);
				
				if (clean_msg.tolower().locate(ent.client.name.removeColorTokens().tolower(),0) != clean_msg.length() || clean_msg.tolower().locate(misc::makeAlphaNum(ent.client.name.removeColorTokens().tolower()) ,0) != clean_msg.length())
				{
					ent.client.execGameCommand("tch " + G_GetClient(client.playerNum).getEnt().entNum + " \"^1" + clean_msg + "\"");
				}
				else
				{
					ent.client.execGameCommand("tch " + G_GetClient(client.playerNum).getEnt().entNum + " \"" + msg + "\"");
				}
        	 }
        	 G_Print("^3[TEAM]" + client.name + "^2: " + msg + "\n");
		}
	}	

	bool allowedToChat(Client @client)
	{
		if(client.muted == 1 || client.muted == 3)
		{
			G_PrintMsg(client.getEnt(), "^1You're muted.\n");
			return false;
		}

		if(playerStats[client.playerNum].msgCounter < 5)
		{
			// Reset flood timer if the last message is over 1000ms ago
			if((playerStats[client.playerNum].lastMsg + 1) < localTime)
				playerStats[client.playerNum].msgCounter = 0;
			playerStats[client.playerNum].lastMsg = localTime;
			playerStats[client.playerNum].msgCounter++;

			if(playerStats[client.playerNum].msgCounter > 4)
			{
				playerStats[client.playerNum].chatFloodTime = localTime;
				G_PrintMsg(client.getEnt(), "^1Chat flood protection, please wait " + ((playerStats[client.playerNum].chatFloodTime + 10) - localTime) + " ^1seconds\n");
				return false;
			}
			return true;
		}
		else
		{
			if((playerStats[client.playerNum].chatFloodTime + 10) < localTime)
			{
				// Allow to chat again
				playerStats[client.playerNum].msgCounter = 1;
				return true;
			}
			G_PrintMsg(client.getEnt(), "^1Chat flood protection, please wait " + ((playerStats[client.playerNum].chatFloodTime + 10) - localTime) + " ^1seconds\n");
			return false;
		}
	}	
}