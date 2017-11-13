class scaCmd
{
	/*
	Permissions
	0: Guest
	1: User
	2: Mod
	3: Admin
	*/

	bool execute(Client @client, String args = "")
	{
		String cmd = args.getToken(0);

		if(cmd == "!authed")
		{
			if(!this.allowedToExecute(client, 0))
				return true;
			base.showAuthed(client);
			return true;
		}

		if(cmd == "!register")
		{
			if(!this.allowedToExecute(client, 0))
				return true;
			login.register(client, args.getToken(1), args.getToken(2), args.getToken(3));
			return true;
		}

		if(cmd == "!login" || cmd == "login")
		{
			if(!this.allowedToExecute(client, 0))
				return true;
			login.login(client, args.getToken(1), args.getToken(2));
			return true;
		}

		if(cmd == "!logout")
		{
			if(!this.allowedToExecute(client, 0))
				return true;
			login.logout(client);
			return true;
		}

		if(cmd == "!top")
		{
			if (!this.allowedToExecute(client, 0))
				return true;
			topPlayers.showTop(client);
			return true;
		}

		if(cmd == "!top25")
		{
			if (!this.allowedToExecute(client, 0))
				return true;
			topPlayers.showTop25(client);
			return true;
		}

		// Own stats
		if(cmd == "!stats" && args.getToken(1) == "")
		{
			if (!this.allowedToExecute(client, 0))
				return true;
			playerStats[client.playerNum].showStats(client);
			return true;
		}

		// Other player
		if(cmd == "!stats" && args.getToken(1) != "")
		{
			if (!this.allowedToExecute(client, 0))
				return true;
			if(playerOnServer(args.getToken(1), client) != -1)
			{
				playerStats[client.playerNum].showStats(client, playerOnServer(args.getToken(1), client));
			}
			return true;
		}

		if (cmd == "!delay")
		{
			if (!this.allowedToExecute(client, 3))
				return true;
			Curl@ req = Curl("http://localhost/sca/toplist.php");
			req.getUrl(delayTest);
			return true;
		}

		if(cmd == "!broadcast")
		{
			if (!this.allowedToExecute(client, 3))
				return true;

			String msg;
			uint index = 1;
			while(true)
			{
				String token = args.getToken(index++);
				if(token == "")
					break;
				msg += token + " ";
			}

			G_CenterPrintMsg(null,"^1" + msg);
			return true;
		}

		if(cmd == "!kick")
		{
			if (!this.allowedToExecute(client, 2))
				return true;

			if(playerOnServer(args.getToken(1), client) != -1)
			{
				if(playerStats[playerOnServer(args.getToken(1), client)].permissionLevel < 2)
				{
					G_PrintMsg(null, playerStats[playerOnServer(args.getToken(1), client)].client.name + " ^7got kicked by " + client.name + "\n");
					G_CmdExecute("kick " + playerOnServer(args.getToken(1), client));
				}
				else
				{
					G_PrintMsg(client.getEnt(), "^0Nope.\n");
				}
			}

			return true;
		}
		return false;
	}

	bool allowedToExecute(Client @client, uint requiredPermission) 
	{
		// Check for permission first
		G_Print(playerStats[client.playerNum].permissionLevel + "\n");
		if(playerStats[client.playerNum].permissionLevel >= requiredPermission)
		{
			// Now check for the cmd flood protection
			if(playerStats[client.playerNum].cmdCounter < 4)
			{
				if((playerStats[client.playerNum].lastCmd + 3) < localTime)
					playerStats[client.playerNum].cmdCounter = 0;
				playerStats[client.playerNum].lastCmd = localTime;
				playerStats[client.playerNum].cmdCounter++;
				
				if(playerStats[client.playerNum].cmdCounter > 3)
				{
					playerStats[client.playerNum].cmdFloodTime = localTime;
					G_PrintMsg(client.getEnt(), "^1Command flood protection, please wait " + ((playerStats[client.playerNum].cmdFloodTime + 10) - localTime) + " ^1seconds\n");
					return false;
				}
				return true;
			}
			else
			{
				if((playerStats[client.playerNum].cmdFloodTime + 10) < localTime)
				{
					playerStats[client.playerNum].cmdCounter = 1;
					return true;
				}
				G_PrintMsg(client.getEnt(), "^1Command flood protection, please wait " + ((playerStats[client.playerNum].cmdFloodTime + 10) - localTime) + " ^1seconds\n");
				return false;
			}
		}
		else
		{
			G_PrintMsg(client.getEnt(), "^1You got no permission for that!\n");
			return false;
		}
	}
}

void delayTest(Curl@ req, String& bla)
{
	G_PrintMsg(null, bla);
}