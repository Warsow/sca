<?php
    if(isset($_POST))
    {
        include "config.php";
        $mysqli = new mysqli($server, $db_user, $db_pw, $db);
        $mysqli->options(MYSQLI_OPT_INT_AND_FLOAT_NATIVE, true);
 
        $player = json_decode($_POST["json"]);
 
        $sql = "
        UPDATE stats SET
        player_clean = ?, player = ?,
        score = ?, frags = ?, deaths = ?, suicides = ?,
        d_given = ?, d_received = ?,
        games = ?, rounds = ?, mvps = ?, playtime = ?,
        GL_Shots = ?, GL_Hits = ?,
        MG_Shots = ?, MG_Hits = ?,
        RG_Shots = ?, RG_Hits = ?,
        GRL_Shots = ?, GRL_Hits = ?,
        RL_Shots = ?, RL_Hits = ?,
        PG_Shots = ?, PG_Hits = ?,
        LG_Shots = ?, LG_Hits = ?,
        EB_Shots = ?, EB_Hits = ?
        WHERE account = ?";
 
        $statement = $mysqli->prepare($sql);
 
        $account = $player->account;
        $name = $player->player;
        $name_clean = $player->player_clean;
        $score = $player->score;
        $frags = $player->frags;
        $deaths = $player->deaths;
        $suicides = $player->suicides;
        $dmg_given = $player->dmg_given;
        $dmg_received = $player->dmg_received;
        $games = $player->games;
        $rounds = $player->rounds;
        $mvp = $player->mvp;
        $playtime = $player->playtime;
 
        // Weapon stats
        $gb_shots = $player->gb_shots; $gb_hits = $player->gb_hits;
        $mg_shots = $player->mg_shots; $mg_hits = $player->mg_hits;
        $rg_shots = $player->rg_shots; $rg_hits = $player->rg_hits;
        $gl_shots = $player->gl_shots; $gl_hits = $player->gl_hits;
        $rl_shots = $player->rl_shots; $rl_hits = $player->rl_hits;
        $pg_shots = $player->pg_shots; $pg_hits = $player->pg_hits;
        $lg_shots = $player->lg_shots; $lg_hits = $player->lg_hits;
        $eb_shots = $player->eb_shots; $eb_hits = $player->eb_hits;

         $statement->bind_param("ssiiiiiiiiidiiiiiiiiiiiiiiiis", $name_clean, $name, $score, $frags, $deaths, $suicides, $dmg_given, $dmg_received, $games, $rounds, $mvp, $playtime, $gb_shots, $gb_hits, $mg_shots, $mg_hits, $rg_shots, $rg_hits, $gl_shots, $gl_hits, $rl_shots, $rl_hits, $pg_shots, $pg_hits, $lg_shots, $lg_hits, $eb_shots, $eb_hits, $account);
 
        $statement->execute();
        $mysqli->close();

        echo json_encode(["status"=>"synced"]);
    }
?>