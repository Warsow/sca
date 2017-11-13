<?php 
	// Returns a top25 json list
	include "config.php";
	$mysqli = new mysqli($server, $db_user, $db_pw, $db);
	$mysqli->options(MYSQLI_OPT_INT_AND_FLOAT_NATIVE, true);
	$result = $mysqli->query("SELECT account, player, d_given, d_received FROM stats WHERE account != '' OR ( player_clean != 'player' AND player_clean NOT LIKE 'player(%)') ORDER BY d_given DESC LIMIT 25");

	echo json_encode($result->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	$mysqli->close();
?>