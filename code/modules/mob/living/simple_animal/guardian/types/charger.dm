//Charger
/mob/living/simple_animal/hostile/guardian/charger
	ranged = 1 //technically
	ranged_message = "charges"
	ranged_cooldown_time = 20
	damage_coeff = list(BRUTE = 0.2, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5)
	playstyle_string = "<span class='holoparasite'>As a <b>charger</b> type you do medium damage, take half damage, have near immunity to brute damage, move very fast, and can charge at a location, damaging any target hit and forcing them to drop any items they are holding.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Hunter, an alien master of rapid assault.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Charge modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's a charger carp, that likes running at people. But it doesn't have any legs...</span>"
	var/charging = 0
	var/atom/movable/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/BiologicalLife(seconds, times_fired)
	if(!(. = ..()))
		return
	if(ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = throw_alert("charge", /atom/movable/screen/alert/cancharge)
	else
		clear_alert("charge")
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		clear_alert("charge")
		chargealert = null
		Shoot(A)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(charging_end)))

/mob/living/simple_animal/hostile/guardian/charger/proc/charging_end()
	charging = 0

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
	. = ..()

/mob/living/simple_animal/hostile/guardian/charger/snapback()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return ..()

	else if(hit_atom)
		if(isliving(hit_atom) && hit_atom != summoner)
			var/mob/living/L = hit_atom
			var/blocked = FALSE
			if(hasmatchingsummoner(hit_atom)) //if the summoner matches don't hurt them
				blocked = TRUE
			if(L.mob_run_block(src, 90, "[name]", ATTACK_TYPE_TACKLE, 0, src, null, null) & BLOCK_SUCCESS)
				blocked = TRUE
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)

		charging = 0
