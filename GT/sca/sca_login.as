String[] logins(maxClients);
bool[] alreadyLoggedOut(maxClients, false);

class scaLogin
{
    void sessionCheck(Client @client)
    {
        String clientIP = this.ipPortToIp(client.getUserInfoKey("ip"));
        JSON json;
        json["ip"] = clientIP;
        any client_any;
        client_any.store(@client);
        G_Print(json.PrintUnformatted());
        Curl@ req = Curl("http://localhost/sca/session.php");
        req.postJSONCustom(CurlJSONCustomDone(this.SessionCallback), json, any(@client));
    }
 
    void SessionCallback(Curl@ req, JSON json, any@ client_any)
    {
        Client@ client;
        client_any.retrieve(@client);
        
        // Check status
        if(json["status"].valuestring == "active_session")
        {
            logins[client.playerNum] = json["account"].valuestring;
            base.addPlayer(client);
            G_PrintMsg(null, client.name + " ^7successfully authed as ^1" + logins[client.playerNum] + "\n");
            return;
        }
 
        if(json["status"].valuestring == "no_session")
        {
        	base.addPlayer(client);
        }
        else
        {
            G_Print("Error in the Curl communication!\n");
            base.addPlayer(client);
        }
    }
 
    void login(Client @client, String user, String password)
    {
    	if(playerStats[client.playerNum].account != "")
    	{
    		G_PrintMsg(client.getEnt(), "^1You're already logged in!\n");
    		return;
    	}

        String clientIP = this.ipPortToIp(client.getUserInfoKey("ip"));
        JSON json;
        json["ip"] = clientIP;
        json["user"] = user;
        json["pw"] = password;
        any client_any;
        client_any.store(@client);
        Curl@ req = Curl("http://localhost/sca/login.php");
        req.postJSONCustom(CurlJSONCustomDone(this.LoginCallback), json, any(@client));
    }
 
    void LoginCallback(Curl @req, JSON json, any@ client_any)
    {
        Client@ client;
        client_any.retrieve(@client);
 
        if(json["status"].valuestring == "success")
        {
        	playerStats[client.playerNum].clearPlayer();
            logins[client.playerNum] = json["account"].valuestring;
            playerStats[client.playerNum].addPlayer(client);
            G_PrintMsg(null, client.name + " ^7successfully authed as ^1" + logins[client.playerNum] + "\n");
        }

        if(json["status"].valuestring == "no_account" || json["status"].valuestring == "wrong_password")
        {
        	G_PrintMsg(client.getEnt(), "^1Wrong username/password.\n");
        }
    }

    void logout(Client @client)
    {
    	if(playerStats[client.playerNum].account == "")
    	{
    		G_PrintMsg(client.getEnt(), "^1You're not logged in!\n");
    		return;
    	}

    	if(alreadyLoggedOut[client.playerNum])
    	{
    		G_PrintMsg(client.getEnt(), "^1You're only allowed to logout once per game!\n");
    		return;
    	}

    	JSON json;
    	json["account"] = playerStats[client.playerNum].account;

        any client_any;
        client_any.store(@client);

        Curl@ req = Curl("http://localhost/sca/logout.php");
        req.postJSONCustom(CurlJSONCustomDone(this.LogoutCallback), json, any(@client));
    }

    void LogoutCallback(Curl @req, JSON json, any@ client_any)
    {
        Client@ client;
        client_any.retrieve(@client);

        if(json["status"].valuestring == "success")
        {
        	alreadyLoggedOut[client.playerNum] = true;
        	logins[client.playerNum] = "";
        	playerStats[client.playerNum].clearPlayer();
        	playerStats[client.playerNum].addPlayer(client);
        	G_PrintMsg(client.getEnt(), "^2Logged out!\n");
        }
        else
        {
        	G_PrintMsg(client.getEnt(), "^1SCA-API communication error, please report this to an admin!\n");
        }    	
    }

    void register(Client @client, String user, String pw, String pw_repeat)
    {
    	if(logins[client.playerNum] != "" || alreadyLoggedOut[client.playerNum])
    	{
    		G_PrintMsg(client.getEnt(), "^1You already got an account!\n");
    		return;
    	}

    	if(user == "")
    	{
    		G_PrintMsg(client.getEnt(), "^9==== Information about the account system ====\n\n^7With your own account you have the ability to use whatever name you want and your stats are still tracked as long as you are logged in.\n^7If you are logged in, your session will be active for 12 hours, if you visit the server again it gets renewed.\n\n^7How to login: ^1!login user password\n^7How to register: ^1!register user password password\n ^7Example: ^1/register slice 1337 1337\n\n^7Tip: You can bind your login: ^1bind KEY \"!login user password\"\n\n^2All passwords are saved encrypted using SHA-256\n");
    		return;
    	}

    	if(pw == "")
    	{
    		G_PrintMsg(client.getEnt(), "^7Syntax: ^1!register user password password\n");
    		return;
    	}

    	// PW repeat check
    	if(pw != pw_repeat)
    	{
    		G_PrintMsg(client.getEnt(), "^1Password missmatch, please try again\n");
    		return;
    	}

    	if(pw.length() > 30)
    	{
    		G_PrintMsg(client.getEnt(), "^1The password length exceeded 30 chars!\n");
    		return;
    	}

    	if(pw.length() < 5)
    	{
    		G_PrintMsg(client.getEnt(), "^1The minimum password length is 5 chars!\n");
    		return;
    	}

    	if(user.length() > 15)
    	{
    		G_PrintMsg(client.getEnt(), "^1The username length exceeded 15 chars!\n");
    		return;
    	}

        JSON json;

        json["ip"] = this.ipPortToIp(client.getUserInfoKey("ip"));
        json["name"] = client.name.removeColorTokens().tolower();
        json["user"] = user;
        json["pw"] = pw;

        Curl@ req = Curl("http://localhost/sca/create_account.php");
        req.postJSONCustom(CurlJSONCustomDone(this.RegisterCallback), json, any(@client));       
    }

    void RegisterCallback(Curl @req, JSON json, any@ client_any)
    {
        Client@ client;
        client_any.retrieve(@client);

        if(json["status"].valuestring == "success")
        {
            playerStats[client.playerNum].clearPlayer();
            logins[client.playerNum] = json["account"].valuestring;
            playerStats[client.playerNum].addPlayer(client);
            G_PrintMsg(null, client.name + " ^7successfully authed as ^1" + logins[client.playerNum] + "\n"); 	
        }
        else if(json["status"].valuestring == "in_use")
        {
        	G_PrintMsg(client.getEnt(), "^1The username already exists!\n");
        }
        else 
        {
        	G_PrintMsg(client.getEnt(), "^1SCA-API communication error, please report this to an admin!\n");
        }

    }
 
    String ipPortToIp(String &ip)
    {
        uint i = ip.length();
 
        if(ip == "127.0.0.1")
            return ip;
 
        /* 58 is ":". */
        while (ip[i] != 58) {
        i--;
       }
       return ip.substr(0, i);
    }  
}