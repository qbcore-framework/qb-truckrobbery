local Translations = {
    error = {
     Get_Out_Water = 'Get out of the water',  
     Guards_dead = 'The guards must be dead to place the bomb',
     Truck_IsMoving = 'You cant rob a vehicle that is moving.',
     ActivePolice = 'Need at least %{ActivePolice} Police to activate the mission.',
     AlreadyActive = 'Someone is already carrying out this mission',
    },
    success = {
      packing_cash = 'You are packing cash into a bag',
      Took_bags = 'You took %{bags} bags of cash from the Truck',
    },
    mission = {
      Activation_cost = "You need $ %{ActivationCost} in the bank to accept the mission",
      Accept_Mission = '[E] To accept missions',
      Stockade = 'Stockade',
      sender = "The Boss",
      subject ="New Target",
      message = "So you are intrested in making some money? good... go get yourself a Gun and make it happen... sending you the location now.",
    },
    info = {
      Before_bomb = 'Get rid of the guards before you place the bomb.',
      Detonate_bomb = 'Press [G] to blow up the back door and take the money',
      Bomb_timer = 'The load will be detonated in %{TimeToBlow} Seconds',
      Collect = 'You can start collecting cash.',
      Take_money = 'Press [E] to take the money',
      Bail_out = 'Hold [G] to bail out',
      Cop_Blip = "10-90: Armored Truck Robbery",
      alerttitle = "Armored Truck Robbery Attempt",
      PoliceBlip = 'Assault on the transport of cash',
      Silence_alarm = 'Press ~INPUT_DETONATE~ to silence the alarm',
      Call_place = 'Armored Truck',
      Call_msg = 'The Alarm has been activated from a %{place} at %{streetLabel}'
    },      
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})