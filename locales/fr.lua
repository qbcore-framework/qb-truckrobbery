local Translations = {
    error = {
     Get_Out_Water = 'Sortez de l\'eau',  
     Guards_dead = 'Les gardes doivent être morts pour placer la bombe',
     Truck_IsMoving = 'Vous ne pouvez pas braquer un camion en mouvement.',
     ActivePolice = 'Il faut au moins %{ActivePolice} Policiers pour activer la mission.',
     AlreadyActive = 'Quelqu\'un est déjà en train de faire cette mission',
    },
    success = {
      packing_cash = 'Vous êtes entrain de remplir le sac!',
      Took_bags = 'Vous avez pris %{bags} sacs de cash du camion',
    },
    mission = {
      Activation_cost = "Vous avez besoin de $ %{ActivationCost} en banque pour accepter la mission",
      Accept_Mission = '[E] Accepter la missions',
      Stockade = 'Stockade',
      sender = "Le Boss",
      subject ="Nouvelle cible",
      message = "Alors vous-voulez vous faire de l'argent? bon... allez trouvez une arme et faites le boulot.. Je vous envoie la localisation.",
    },
    info = {
      Before_bomb = 'Débarassez vous des gardes avant de placer la bombe.',
      Detonate_bomb = 'Appuyez sur [G] pour exploser la porte et prendre le cash',
      Bomb_timer = 'La bombe explosera dans %{TimeToBlow} Secondes',
      Collect = 'Vous pouvez commencer à collecter l\'argent.',
      Take_money = 'Appuyez sur [E] pour prendre l\'argent',
      Bail_out = 'Appuyez sur [G] pour sortir',
      Cop_Blip = "10-90: Braquage de Transport de Fonds",
      alerttitle = "Braquage de Transport de Fonds",
      PoliceBlip = 'Assaut sur le Transport de fonds',
      Silence_alarm = 'Appuyez sur ~INPUT_DETONATE~ pour éteindre l\'alarme',
      Call_place = 'Transport de fonds',
      Call_msg = 'L\'alarme à été activé depuis %{place} à %{streetLabel}'
    },      
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
