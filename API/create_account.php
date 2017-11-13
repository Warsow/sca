<?php 
	if(isset($_POST))
	{
		include "config.php";
		$mysqli = new mysqli($server, $db_user, $db_pw, $db);

		$json = json_decode($_POST["json"]);
		$ip = $json->ip;
		$name = $json->name;
		$user = $json->user;
		$pw = $json->pw;

		// Check if the user exists
		$sql = "SELECT * FROM stats WHERE account = ?";
		$statement = $mysqli->prepare($sql);
		$statement->bind_param("s", $user);
		$statement->execute();

		$result = $statement->get_result();

		if($result->num_rows == 0)
		{
			$systemTime = time();
			$sql = "INSERT INTO stats (account, player_clean, player, password) VALUES (?, ?, ?, SHA2(?, 256))";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("ssss", $user, $name, $name, $pw);
			$statement->execute();

			$sql = "INSERT INTO sessions (timestamp, account, IP) VALUES (?, ?, ?)";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("iss", $systemTime, $user, $ip);
			$statement->execute();
			$mysqli->close();

			echo json_encode(["status"=>"success", "account"=>$user]);
		}
		else
		{
			echo json_encode(["status"=>"in_use"]);
		}
		$mysqli->close();		
	}
?>
