local Translations = {
    error = {
     get_out_water = 'Sortez de l\'eau',
     guards_dead = 'Les gardes doivent être morts pour placer la bombe',
     truck_ismoving = 'Vous ne pouvez pas braquer un camion en mouvement.',
     activepolice = 'Il faut au moins %{ActivePolice} Policiers pour activer la mission.',
     alreadyactive = 'Quelqu\'un est déjà en train de faire cette mission',
    },
    success = {
      packing_cash = 'Vous êtes entrain de remplir le sac!',
      took_bags = 'Vous avez pris %{bags} sacs de cash du camion',
    },
    mission = {
      activation_cost = "Vous avez besoin de $ %{ActivationCost} en banque pour accepter la mission",
      accept_mission_target = 'Accepter la mission',
      accept_mission = '~g~[E]~b~ Accepter la mission',
      stockade = 'Stockade',
      sender = "Le Boss",
      subject ="Nouvelle cible",
      message = "Alors vous-voulez vous faire de l'argent? bon... allez trouvez une arme et faites le boulot.. Je vous envoie la localisation.",
    },
    info = {
      before_bomb = 'Débarassez vous des gardes avant de placer la bombe.',
      detonate_bomb = 'Appuyez sur [G] pour exploser la porte arrière et prendre le cash',
      detonate_bomb_target = 'Posez la bombe',
      plant_bomb = 'Poser la bombe',
      planting_bomb = 'Pose la bombe..',
      bomb_timer = 'La bombe explosera dans %{TimeToBlow} Secondes',
      collect = 'Vous pouvez commencer à collecter l\'argent.',
      take_money_target = 'Prendre l\'argent',
      take_money = 'Appuyez sur [E] pour prendre l\'argent',
      cop_Blip = "10-90: Braquage de Transport de Fonds",
      alerttitle = "Braquage de Transport de Fonds",
      alert_desc = "Un Transport de Fonds se fait braquer!",
      policeblip = 'Assaut sur le Transport de fonds',
      grabing_money = 'Vous prenez l\'argent..'
    },
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
