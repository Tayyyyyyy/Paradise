/mob/proc/emote(var/act, var/m_type, var/message)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, "-")
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E = emote_list[act]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	E.run_emote(src, param, m_type)
	

/mob/proc/custom_emote(var/m_type=EMOTE_VISIBLE, var/message=null)
	emote("me", m_type, message)

/datum/emote/mob/help
	key = "help"
	stat_allowed = DEAD

/datum/emote/mob/help/run_emote(mob/user, params)
	var/list/keys = list()
	var/prefix = "Available emotes (you can use them with say \"*emote\"): "

	for(var/k in user.emote_list)
		var/datum/emote/E = user.emote_list[k]
		if(E.key in keys)
			continue
		if(E.can_run_emote(user, status_check = FALSE))
			keys += E.key

	keys = sortList(keys)

	message = "[prefix] [jointext(keys, ", ")]."

	to_chat(user, message)
	return TRUE

/datum/emote/mob/custom
	key = "me"
	key_third_person = "custom"
	punct = ""
	message = null

/datum/emote/mob/custom/proc/check_invalid(mob/user, input)
	. = TRUE
	if(copytext(input,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else
		. = FALSE

/datum/emote/mob/custom/run_emote(mob/user, params, type_override = null)
	if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, "You cannot send IC messages (muted).")
		return FALSE
	if(user.client && user.client.handle_spam_prevention(params, MUTE_IC))
		return FALSE

	if(!params)
		var/custom_emote = copytext(sanitize(input("Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
			switch(type)
				if("Visible")
					emote_type = EMOTE_VISIBLE
				if("Hearable")
					emote_type = EMOTE_AUDIBLE
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			message = custom_emote
	else
		message = params
		if(type_override)
			emote_type = type_override
	. = ..(user)
	message = null
	emote_type = EMOTE_VISIBLE

/datum/emote/mob/custom/replace_pronoun(mob/user, message)
	return message
