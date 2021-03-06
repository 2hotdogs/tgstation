/obj/item/weapon/computer_hardware
	name = "hardware"
	desc = "Unknown Hardware."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"

	w_class = 1	// w_class limits which devices can contain this component.
	// 1: PDAs/Tablets, 2: Laptops, 3-4: Consoles only
	var/obj/item/device/modular_computer/holder = null
	// Computer that holds this hardware, if any.

	var/power_usage = 0 			// If the hardware uses extra power, change this.
	var/enabled = 1					// If the hardware is turned off set this to 0.
	var/critical = 0				// Prevent disabling for important component, like the CPU.
	var/can_install = 1				// Prevents direct installation of removable media.
	var/damage = 0					// Current damage level
	var/max_damage = 100			// Maximal damage level.
	var/damage_malfunction = 20		// "Malfunction" threshold. When damage exceeds this value the hardware piece will semi-randomly fail and do !!FUN!! things
	var/damage_failure = 50			// "Failure" threshold. When damage exceeds this value the hardware piece will not work at all.
	var/malfunction_probability = 10// Chance of malfunction when the component is damaged

/obj/item/weapon/computer_hardware/New(var/obj/L)
	..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/weapon/computer_hardware/Destroy()
	if(holder)
		holder.uninstall_component(src)
	return ..()


/obj/item/weapon/computer_hardware/attackby(obj/item/I, mob/living/user)
	// Multitool. Runs diagnostics
	if(istype(I, /obj/item/device/multitool))
		user << "***** DIAGNOSTICS REPORT *****"
		diagnostics(user)
		user << "******************************"
		return 1

	// Cable coil. Works as repair method, but will probably require multiple applications and more cable.
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/S = I
		if(!damage)
			user << "<span class='warning'>\The [src] doesn't seem to require repairs.</span>"
			return 1
		if(S.use(1))
			user << "<span class='notice'>You patch up \the [src] with a bit of \the [I].</span>"
			take_damage(-10)
		return 1

	if(try_insert(I, user))
		return 1

	return ..()

// Called on multitool click, prints diagnostic information to the user.
/obj/item/weapon/computer_hardware/proc/diagnostics(var/mob/user)
	user << "Hardware Integrity Test... (Corruption: [damage]/[max_damage]) [damage > damage_failure ? "FAIL" : damage > damage_malfunction ? "WARN" : "PASS"]"

// Handles damage checks
/obj/item/weapon/computer_hardware/proc/check_functionality()
	if(!enabled) // Disabled.
		return FALSE

	if(damage > damage_failure) // Too damaged to work at all.
		return FALSE

	if(damage > damage_malfunction) // Still working. Well, sometimes...
		if(prob(malfunction_probability))
			return FALSE

	return TRUE // Good to go.

/obj/item/weapon/computer_hardware/examine(var/mob/user)
	. = ..()
	if(damage > damage_failure)
		user << "<span class='danger'>It seems to be severely damaged!</span>"
	else if(damage > damage_malfunction)
		user << "<span class='warning'>It seems to be damaged!</span>"
	else if(damage)
		user << "<span class='notice'>It seems to be slightly damaged.</span>"

// Damages the component. Contains necessary checks. Negative damage "heals" the component.
/obj/item/weapon/computer_hardware/proc/take_damage(var/amount)
	damage += round(amount) 					// We want nice rounded numbers here.
	damage = max(0, min(damage, max_damage))		// Clamp the value.


// Component-side compatibility check.
/obj/item/weapon/computer_hardware/proc/can_install(obj/item/device/modular_computer/M, mob/living/user = null)
	return can_install

// Called when component is installed into PC.
/obj/item/weapon/computer_hardware/proc/on_install(obj/item/device/modular_computer/M, mob/living/user = null)
	return

// Called when component is removed from PC.
/obj/item/weapon/computer_hardware/proc/on_remove(obj/item/device/modular_computer/M, mob/living/user = null)
	try_eject()

// Called when someone tries to insert something in it - paper in printer, card in card reader, etc.
/obj/item/weapon/computer_hardware/proc/try_insert(obj/item/I, mob/living/user = null)
	return FALSE

// Called when someone tries to eject something from it - card from card reader, etc.
/obj/item/weapon/computer_hardware/proc/try_eject(slot=0, mob/living/user = null)
	return FALSE
