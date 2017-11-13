<?php
	if(isset($_POST))
	{
		include "config.php";

		$mysqli = new mysqli($server, $db_user, $db_pw, $db);
		$mysqli->options(MYSQLI_OPT_INT_AND_FLOAT_NATIVE, true);

		// Check if the player exists
		$player = json_decode($_POST["json"]);

		$sql = "SELECT * FROM stats WHERE player_clean = ? AND account = ''";
		$statement = $mysqli->prepare($sql);
		$statement->bind_param("s", $player->player);
		$statement->execute();

		$result = $statement->get_result();

		if($result->num_rows == 0)
		{
			 $result->free_result();

			// Create new player
			$sql = "INSERT INTO stats (player_clean, player) VALUES (?, ?)";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("ss", $player->player, $player->player);
			$statement->execute();
			$result = $statement->get_result();

			// Return it
			$sql = "SELECT * FROM stats WHERE player_clean = ? AND account = ''";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("s", $player->player);
			$statement->execute();

			$result = $statement->get_result();

			echo json_encode($result->fetch_assoc(), JSON_PRETTY_PRINT);
		}
		else
		{
			echo json_encode($result->fetch_assoc(), JSON_PRETTY_PRINT);
		}
		$mysqli->close();
	}
	else
	{
		echo json_encode(["status"=>"in_use"]);
	}
?>