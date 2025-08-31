Config = {}


Config.DrugItems = {
    ['cannabis'] = {
        name = 'cannabis',
        label = 'Tráva',
        sellPrice = {min = 50, max = 150},
        dealTime = {min = 30, max = 60},
        clientModels = {'a_m_m_beach_01', 'a_m_m_bevhills_01', 'a_m_m_business_01'},
        sellText = 'Prodej trávu'
    },
    ['cocaine'] = {
        name = 'cocaine', 
        label = 'Kokain',
        sellPrice = {min = 200, max = 400},
        dealTime = {min = 45, max = 90},
        clientModels = {'a_m_m_eastsa_01', 'a_m_m_fatlatin_01', 'a_m_m_golfer_01'},
        sellText = 'Prodej kokain'
    },
    ['meth'] = {
        name = 'meth',
        label = 'Pervitin', 
        sellPrice = {min = 300, max = 500},
        dealTime = {min = 60, max = 120},
        clientModels = {'a_m_m_hillbilly_01', 'a_m_m_indian_01', 'a_m_m_ktown_01'},
        sellText = 'Prodej pervitin'
    }
}

Config.Animations = {
    phone = {
        dict = 'amb@world_human_stand_mobile@male@text@base',
        anim = 'base',
        flag = 49
    }
}

Config.ClientSettings = {
    arrivalRadius = 3.0,
    interactionRadius = 2.0,
    despawnTime = 30000,
    maxWaitTime = 120000,
    wanderTime = 15000,
    spawnDistance = {min = 20, max = 25},
    spawnAttempts = 15,
    safeZoneRadius = 3.0
}

Config.StreetCredit = {
    enabled = true,
    pointsPerDeal = {
        ['cannabis'] = 3,
        ['cocaine'] = 5,
        ['meth'] = 8
    },
    levels = {
        {level = 1, required = 0, multiplier = 1.0, name = 'Nováček'},
        {level = 2, required = 50, multiplier = 1.1, name = 'Začátečník'},
        {level = 3, required = 150, multiplier = 1.2, name = 'Dealer'},
        {level = 4, required = 300, multiplier = 1.35, name = 'Veterán'},
        {level = 5, required = 500, multiplier = 1.5, name = 'Boss'},
        {level = 6, required = 750, multiplier = 1.7, name = 'Kingpin'},
        {level = 7, required = 1000, multiplier = 2.0, name = 'Legenda'}
    },
    barSettings = {
        duration = 10000,
        position = 'top-center'
    }
}

Config.DealFailure = {
    enabled = true,
    chance = 15,
    policeJobs = {'police', 'sheriff', 'state'},
    reportBlipSettings = {
        sprite = 161,
        color = 1,
        scale = 1.2,
        duration = 300000,
        radius = 150.0,
        name = 'Hlášený prodej drog'
    }
}

Config.Notifications = {
    noDrugs = 'Nemáš u sebe žádné drogy k prodeji',
    dealStarted = 'Vyřizuješ deal...',
    clientComing = 'Setrvej na místě, klient se blíží',
    clientArrived = 'Klient dorazil, můžeš s ním obchodovat',
    dealComplete = 'Deal úspěšně dokončen! Získal jsi $%s',
    dealCancelled = 'Deal byl zrušen',
    clientLeft = 'Klient odešel, byl jsi příliš daleko',
    streetCreditGained = '+%s Street Credit (+%s XP)',
    levelUp = '🔥 Level UP! Nový level: %s - %s',
    dealReported = 'Místní tě nahlásil policii! Rychle zmiz!',
    policeReport = 'Občan nahlásil prodej drog v okolí'
}