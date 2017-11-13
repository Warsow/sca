<?php 
	if(isset($_POST))
	{
		include "config.php";
		$mysqli = new mysqli($server, $db_user, $db_pw, $db);
		
		$json = json_decode($_POST["json"]);
		$account = $json->account;
		$ip = $json->ip;
		$systemTime = time();

		$sql = "SELECT * FROM sessions WHERE IP = ?";
		$statement = $mysqli->prepare($sql);
		$statement->bind_param("s", $ip);
		$statement->execute();

		$result = $statement->get_result();

		if($result->num_rows == 0)
		{
			$sql = "INSERT INTO sessions (timestamp, account, IP) VALUES (?, ?, ?)";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("iss", $systemTime, $account, $ip);
			$statement->execute();
		}
		else
		{
			$sql = "UPDATE sessions SET IP = ?, timestamp = ? WHERE account = ?";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("sis", $ip, $systemTime, $account);
			$statement->execute();
		}

		$mysqli->close();
	}
?>